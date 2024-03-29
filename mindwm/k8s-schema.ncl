{
  validKubernetesResourceName = std.contract.from_predicate
  (
    fun value =>
      std.string.is_match "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$" value
  ),
  validKubernetesNamespace = validKubernetesResourceName
}
