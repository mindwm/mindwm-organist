let ContextName = "teama" in
let Namespace = ContextName in
let KafkaTopics = [ ContextName ] in
let memory_broker = import "./k8s/knative/eventing/broker-memory/broker.ncl" in
let KafkaBootstrapServerList = [ "my-cluster-kafka-bootstrap.kafka:9092" ] in
let kafka_source = import "./k8s/knative/eventing/kafka-source/kafka-source.ncl" in
let ContextBrokerName = fun context_name => "context-broker-" ++ context_name in
{
  contextBroker | not_exported = memory_broker (ContextBrokerName ContextName),
  kafkaSource | not_exported = kafka_source Namespace "graph-events" KafkaBootstrapServerList KafkaTopics contextBroker.broker.metadata.name,
  files = {
      "k8s/%{ContextName}/context-broker.yml" = { content = std.serialize 'Yaml contextBroker.broker },
      "k8s/%{ContextName}/context-broker-configmap.yml" = { content = std.serialize 'Yaml contextBroker.configmap},
      "k8s/%{ContextName}/kafkaSource.yml" = { content = std.serialize 'Yaml kafkaSource},
  }

  
}
