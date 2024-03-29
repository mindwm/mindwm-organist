let inputs = import "./nickel.lock.ncl" in
let organist = inputs.organist in
let k8s_user_namespace = import "./k8s/user-namespace.ncl" in
let mindwm_sessions = (import "./mindwm/mindwm.ncl").MindwmSessions in
{
  shells = organist.shells.Bash,

  shells.build = {
    packages = {},
  },

  shells.dev = {
    packages.hello = organist.import_nix "nixpkgs#hello",
  },
  files = (import "./user_files.ncl").files & (import "./host_files.ncl").files & (import "./k8s/neo4j/helm.ncl").files
    & (import "./context_broker.ncl").files,
}
  | organist.OrganistExpression
