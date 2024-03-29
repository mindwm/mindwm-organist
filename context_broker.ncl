let ContextName = "teama" in
let memory_broker = import "./k8s/knative/eventing/broker-memory/broker.ncl" in
let ContextBrokerName = fun context_name => "context-broker-" ++ context_name in
{
  contextBroker | not_exported = memory_broker (ContextBrokerName ContextName),

  files = {
      "k8s/%{ContextName}/context-broker.yml" = std.serialize 'Yaml contextBroker.broker,
      "k8s/%{ContextName}/context-broker-configmap.yml" = std.serialize 'Yaml contextBroker.configmap
  }

  
}
