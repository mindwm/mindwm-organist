let Mindwm = import "./mindwm/mindwm.ncl" in
let TriggerName = fun username contextname => "user-%{username}-to-context-%{contextname}-broker" in
let ContextNamespaceName = fun contextname => "context-" ++ contextname in
let ContextBrokerName = fun context_name => "context-broker-" ++ context_name in
let UserNamespace = fun username => "user-" ++ username in
{
  ContextUsers | not_exported = Mindwm.MindwmSessions 
    |> std.array.map(
      fun mindwm_session => mindwm_session.tmux.session 
      |> std.array.map(
        fun session => {
            user = mindwm_session.user.name,
            context = session.name
        }
      )
    ),

  files = std.record.from_array(std.array.flatten ContextUsers 
    |> std.array.map(
      fun ContextUser => {
        field = "k8s/context/%{ContextUser.context}/" ++ TriggerName ContextUser.user ContextUser.context ++ ".yml",
        value = {
          content = std.serialize 'Yaml ((import "././k8s/knative/eventing/trigger/broker-to-broker.yml") & {
            metadata.name | force = TriggerName ContextUser.user ContextUser.context,
            metadata.namespace | force = UserNamespace ContextUser.user,
            spec.subscriber.ref.name | force = ContextBrokerName ContextUser.context,
            spec.subscriber.ref.namespace | force = ContextNamespaceName ContextUser.context,
          })
        }
      }

    ) 
  )
}
