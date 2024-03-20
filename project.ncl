let inputs = import "./nickel.lock.ncl" in
let organist = inputs.organist in
let k8s_namespace = import "./k8s/namespace.yaml" in
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
  files = std.record.from_array ((import "users.yaml")
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
   )
}
  | organist.OrganistExpression
