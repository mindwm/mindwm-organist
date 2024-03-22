let knative_jsm_broker = import "./k8s/knative/eventing/broker-jetstream/broker.ncl" in
let k8s_user_namespace = import "./k8s/user-namespace.ncl" in
let mindwm_sessions = (import "./mindwm/mindwm.ncl").MindwmSessions in 
{
  # TODO(@metacoma) get rid of temp `_files` variable
  _files = mindwm_sessions
    |> std.array.map 
     (
       fun session => session.host |> std.array.map(
          fun host => {
            field = "%{session.user.name}/%{host.name}/configmap.yml",
            value = {
               content = std.serialize 'Yaml
                 (knative_jsm_broker session.user.name host.name).configmap
            }
          }
        ) 
     ),
  files = std.record.from_array(std.array.at 0 _files)
   
}
