let ContextName = "teama" in
let NamespaceName = fun context_name => "context-" ++ context_name in
let Namespace = NamespaceName  ContextName in
let KafkaTopics = [ ContextName ] in
let memory_broker = import "./k8s/knative/eventing/broker-memory/broker.ncl" in
let KafkaBootstrapServerList = [ "my-cluster-kafka-bootstrap.kafka:9092" ] in
let kafka_source = import "./k8s/knative/eventing/kafka-source/kafka-source.ncl" in
let ContextBrokerName = fun context_name => "context-broker-" ++ context_name in
let KnativeServing = import "./k8s/knative/serving/serving.ncl" in
{
  contextBroker | not_exported = memory_broker (ContextBrokerName ContextName),
  kafkaSource | not_exported = kafka_source Namespace "graph-events" KafkaBootstrapServerList KafkaTopics contextBroker.broker.metadata.name,
  event_display | not_exported = KnativeServing Namespace "event-display" "gcr.io/knative-releases/knative.dev/eventing/cmd/event_display" [],
  files = {
      "k8s/%{ContextName}/context-broker.yml" = { content = std.serialize 'Yaml contextBroker.broker },
      "k8s/%{ContextName}/context-broker-configmap.yml" = { content = std.serialize 'Yaml contextBroker.configmap},
      "k8s/%{ContextName}/context-broker-event-display.yml" = { content = std.serialize 'Yaml event_display},
      "k8s/%{ContextName}/kafkaSource.yml" = { content = std.serialize 'Yaml kafkaSource},
      "k8s/%{ContextName}/apply.sh" = { 
        content = m%"
        #!/usr/bin/env bash
        set -ex
        kubectl -n %{Namespace} apply -f .
        "%
      }
  }

  
}
