let knative_memory_broker = import "./k8s/knative/eventing/broker-memory/broker.ncl" in
let k8s_user_namespace = import "./k8s/user-namespace.ncl" in
let mindwm_sessions = (import "./mindwm/mindwm.ncl").MindwmSessions in 
let KnativeServing = import "./k8s/knative/serving/serving.ncl" in
let KnativeTrigger = import "./k8s/knative/eventing/trigger/trigger.ncl" in
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
   ) & std.record.from_array (mindwm_sessions
    |> std.array.map
      (
        fun session => {
          field = "%{session.user.name}/event-display.yaml",
          value = {
            materialisation_method = 'Copy,
	          content = std.serialize 'Yaml
	           (
               KnativeServing session.user.k8s_namespace "event-display" "gcr.io/knative-releases/knative.dev/eventing/cmd/event_display" []
             )
          } 
      	} 
      ) 
   ) & std.record.from_array (mindwm_sessions
    |> std.array.map
      (
        fun session => {
          field = "%{session.user.name}/user-broker-to-context-broker.yaml",
          value = {
            materialisation_method = 'Copy,
	          content = std.serialize 'Yaml
	            (
                let context_broker_name = "context-broker-" ++ (std.array.at 0 session.tmux.session).name in
                let context_broker_namespace = "context-" ++ (std.array.at 0 session.tmux.session).name  in
                KnativeTrigger session.user.k8s_namespace "trigger-user-broker-to-context-broker" (knative_memory_broker session.user.name).broker.metadata.name 
                [
                  {
                    exact = {
                      type = "iodocument"
                    }
                  }
                # TODO(metacoma) remove hardcode in context broker name
                ] {apiVersion = "eventing.knative.dev/v1", kind = "Broker", name = context_broker_name, namespace = context_broker_namespace } {apiVersion = "serving.knative.dev/v1", kind = "Service", name = "event-display"}
              )
          } 
      	} 
      ) 
   )
}
