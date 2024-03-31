let knative_jsm_broker = import "./k8s/knative/eventing/broker-jetstream/broker.ncl" in
let k8s_user_namespace = import "./k8s/mindwm_user_namespace.ncl" in
let mindwm_sessions = (import "./mindwm/mindwm.ncl").MindwmSessions in 
let KnativeTrigger = import "./k8s/knative/eventing/trigger/trigger.ncl" in
{
  # TODO(@metacoma) get rid of temp `_files` variable
  _configmap
    | not_exported
    = mindwm_sessions
    |> std.array.map 
     (
       fun session => session.host |> std.array.map(
          fun host => {
            field = "%{session.user.name}/%{host.name}/configmap.yml",
            value = {
               content = std.serialize 'Yaml
                 (((knative_jsm_broker session.user.name host.name).configmap) & {
			metadata.namespace | force = k8s_user_namespace session.user.name
		 })
            }
          }
        ) 
     ), 
  _broker 
    | not_exported
    = mindwm_sessions
    |> std.array.map 
     (
       fun session => session.host |> std.array.map(
          fun host => {
            field = "%{session.user.name}/%{host.name}/broker.yml",
            value = {
               content = std.serialize 'Yaml
                 (((knative_jsm_broker session.user.name host.name).broker) & {
			metadata.namespace | force = k8s_user_namespace session.user.name
                 })
            }
          }
        ) 
     ), 
  _trigger_host_broker_to_user_broker
    | not_exported
    = mindwm_sessions
    |> std.array.map 
     (
       fun session => session.host |> std.array.map(
          fun host => {
            field = "%{session.user.name}/%{host.name}/host_broker_to_user_broker.yml",
            value = {
               content = std.serialize 'Yaml
                 (
                   KnativeTrigger (k8s_user_namespace session.user.name) "trigger-host-%{host.name}-to-user-%{session.user.name}" (knative_jsm_broker session.user.name host.name).broker.metadata.name [
                    {
                      exact = {
                        type = "iodocument"
                      }
                    }
                  ] {apiVersion = "eventing.knative.dev/v1", kind = "Broker", name = session.user.name } {apiVersion = "serving.knative.dev/v1", kind = "Service", name = "event-display"}
                 )
            }
          }
        ) 
     ), 
  files 
    = std.record.from_array(std.array.concat _broker _configmap |> std.array.concat _trigger_host_broker_to_user_broker
    |> std.array.map(
      fun n => { 
	field = (std.array.at 0 n).field,
        value = (std.array.at 0 n).value
      }
    )),

}
