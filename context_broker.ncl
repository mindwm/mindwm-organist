let ContextName = "teama" in
let NamespaceName = fun context_name => "context-" ++ context_name in
let Namespace = NamespaceName  ContextName in
let KafkaTopics = [ ContextName ] in
let memory_broker = import "./k8s/knative/eventing/broker-memory/broker.ncl" in
let KafkaBootstrapServerList = [ "neo4j-cdc-stream.redpanda.svc.cluster.local:9093" ] in
let kafka_source = import "./k8s/knative/eventing/kafka-source/kafka-source.ncl" in
let kafkaTopic = import "./k8s/kafka/topic.ncl" in
let kafkaTopicName = Namespace ++ "-events" in
let ContextBrokerName = fun context_name => "context-broker-" ++ context_name in
let KnativeServing = import "./k8s/knative/serving/serving.ncl" in
let KnativeTrigger = import "./k8s/knative/eventing/trigger/trigger.ncl" in
let RedPandaNamespace = "redpanda" in
{
  contextBroker | not_exported = memory_broker (ContextBrokerName ContextName),
  kafkaSource | not_exported = kafka_source Namespace "graph-events" KafkaBootstrapServerList [ kafkaTopicName ] contextBroker.broker.metadata.name,
  cdc_topic | not_exported = kafkaTopic RedPandaNamespace KafkaBootstrapServerList kafkaTopicName,
  event_display | not_exported = KnativeServing Namespace "event-display" "gcr.io/knative-releases/knative.dev/eventing/cmd/event_display" [],
  io_context | not_exported = KnativeServing Namespace "io-context" "10.20.30.211:5000/knative-neomodel:latest" [
      {
        name = "NEO4J_URL",
        value = "bolt://neo4j.%{Namespace}:7687"
      },
      {
        name = "NEO4J_USERNAME",
        value = "neo4j"
      },
      {
        name = "NEO4J_PASSWORD",
        value = "password"
      }
  ], # test
  event_display_trigger | not_exported = KnativeTrigger Namespace "context-event-display" contextBroker.broker.metadata.name [
    {
      exact = {
        type = "iodocument"
      }
    }
  ] {apiVersion = "serving.knative.dev/v1", kind = "Service", name = "event-display"} {apiVersion = "serving.knative.dev/v1", kind = "Service", name = "event-display"},
  io_context_trigger | not_exported = KnativeTrigger Namespace ("trigger-" ++ io_context.metadata.name) contextBroker.broker.metadata.name [
    {
      exact = {
        type = "iodocument"
      }
    }
  ] {apiVersion = "serving.knative.dev/v1", kind = "Service", name = io_context.metadata.name } {apiVersion = "serving.knative.dev/v1", kind = "Service", name = "event-display"},
  files = {
      "k8s/%{ContextName}/context-broker.yml" = { content = std.serialize 'Yaml contextBroker.broker },
      "k8s/%{ContextName}/context-broker-configmap.yml" = { content = std.serialize 'Yaml contextBroker.configmap},
      "k8s/%{ContextName}/context-broker-event-display.yml" = { content = std.serialize 'Yaml event_display},
      "k8s/%{ContextName}/context-broker-event-display-trigger.yml" = { content = std.serialize 'Yaml event_display_trigger},
      "k8s/%{ContextName}/context-broker-io-context.yml" = { content = std.serialize 'Yaml io_context},
      "k8s/%{ContextName}/context-broker-io-context-trigger.yml" = { content = std.serialize 'Yaml io_context_trigger},
      "k8s/%{ContextName}/kafkaSource.yml" = { content = std.serialize 'Yaml kafkaSource},
      "k8s/%{ContextName}/kafkaTopic.yml" = { content = std.serialize 'Yaml cdc_topic},
      "k8s/%{ContextName}/apply.sh" = { 
        content = m%"
        #!/usr/bin/env bash
        set -ex
        kubectl -n %{Namespace} apply -f .
        "%
      }
  }

  
}
