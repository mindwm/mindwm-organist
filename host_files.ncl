let knative_jsm_broker = import "./k8s/knative/eventing/broker-jetstream/broker.ncl" in
let k8s_user_namespace = import "./k8s/mindwm_user_namespace.ncl" in
let mindwm_sessions = (import "./mindwm/mindwm.ncl").MindwmSessions in 
{
  # TODO(@metacoma) get rid of temp `_files` variable
  _configmap = mindwm_sessions
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
  _broker = mindwm_sessions
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

  broker = std.array.at 0 _broker,
  configmap = std.array.at 0 _configmap,
  files = std.record.from_array(std.array.concat broker configmap)
   
}
