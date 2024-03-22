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
  files = (import "./user_files.ncl").files
}
  | organist.OrganistExpression
