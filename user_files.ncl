let knative_memory_broker = import "./k8s/knative/eventing/broker-memory/broker.ncl" in
let k8s_user_namespace = import "./k8s/user-namespace.ncl" in
let mindwm_sessions = (import "./mindwm/mindwm.ncl").MindwmSessions in 
{
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
