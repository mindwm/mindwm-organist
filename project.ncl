let inputs = import "./nickel.lock.ncl" in
let organist = inputs.organist in
let k8s_user_namespace = import "./k8s/user-namespace.ncl" in
let knative_memory_broker = import "./k8s/knative/eventing/broker-memory.ncl" in
let mindwm_sessions = (import "./mindwm/mindwm.ncl").MindwmSessions in
{
  shells = organist.shells.Bash,

  shells.build = {
    packages = {},
  },

  shells.dev = {
    packages.hello = organist.import_nix "nixpkgs#hello",
  },
  files = std.record.from_array (mindwm_sessions
    |> std.array.map
      (
        fun session => {
          field = "%{session.user.name}/namespace.yaml",
          value = {
            materialisation_method = 'Copy,
	    content = std.serialize 'Yaml
 	      (k8s_user_namespace "%{session.user.k8s_namespace}")
          } 
	} 
      ) 
   ) & std.record.from_array (mindwm_sessions
    |> std.array.map
      (
        fun session => {
          field = "%{session.user.name}/user-broker.yaml",
          value = {
            materialisation_method = 'Copy,
	    content = std.serialize 'Yaml
	      (
                (knative_memory_broker session.user.name).broker & {
		  metadata.namespace | force = session.user.k8s_namespace
                } 
              )
          } 
	} 
      ) 
   ) & std.record.from_array (mindwm_sessions
    |> std.array.map
      (
        fun session => {
          field = "%{session.user.name}/user-broker-configmap.yaml",
          value = {
            materialisation_method = 'Copy,
	    content = std.serialize 'Yaml
	      (
                (knative_memory_broker session.user.name).configmap & {
		  metadata.namespace | force = session.user.k8s_namespace
                } 
              )
          } 
	} 
      ) 
   )
}
  | organist.OrganistExpression
