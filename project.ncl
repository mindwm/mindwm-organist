let inputs = import "./nickel.lock.ncl" in
let organist = inputs.organist in
let k8s_namespace = import "./k8s/namespace.yaml" in
let knative_memory_broker = import "./k8s/knative/eventing/broker-memory.ncl" in
let users = import "./users.yaml" in
let teams = {
	alpha = {
		name = "Alpha"
	}
} in
{
  shells = organist.shells.Bash,

  shells.build = {
    packages = {},
  },

  shells.dev = {
    packages.hello = organist.import_nix "nixpkgs#hello",
  },
  files = std.record.from_array (users
    |> std.array.map
      (
        fun user_record => {
          field = "%{user_record.username}.yaml",
          value = {
            materialisation_method = 'Copy,
	    content = std.serialize 'Yaml
              (
 	        k8s_namespace & {
		  metadata.name | force = user_record.username,
		  metadata.labels."kubernetes.io/metadata.name" | force = user_record.username
                }
              )
          }
        }
      )
   ) & std.record.from_array (users
    |> std.array.map
      (
        fun user_record => {
          field = "%{user_record.username}/broker.yaml",
          value = {
            materialisation_method = 'Copy,
	    content = std.serialize 'Yaml
		(knative_memory_broker user_record.username).broker
          }
        }
      )
   ) & std.record.from_array (users
    |> std.array.map
      (
        fun user_record => {
          field = "%{user_record.username}/broker_configmap.yaml",
          value = {
            materialisation_method = 'Copy,
	    content = std.serialize 'Yaml
		(knative_memory_broker user_record.username).configmap
          }
        }
      )
   ) 
}
  | organist.OrganistExpression
