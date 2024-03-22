let { validKubernetesNamespace, validKubernetesResourceName } = import "./k8s-schema.ncl" in
let { TmuxServer, .. } = import "./tmux-schema.ncl" in
let MindwmUserName = validKubernetesNamespace in
let MindwmHostName = validKubernetesResourceName in
let MindwmTmuxPaneSessionId = std.contract.from_predicate
  (
    fun value =>
      std.string.is_match "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$" value
  ) in
{
  MindwmUser = {
    name | MindwmUserName,
    k8s_namespace 
      | validKubernetesResourceName
      | default  
      = "user-%{name}"
  },
  MindwmHost = {
    name | MindwmHostName
  },
  MindwmTmuxPaneSession = {
    user | MindwmUser, 
    host | MindwmHost,
    session_id | MindwmTmuxPaneSessionId,
    tmux | TmuxServer
  }
}
