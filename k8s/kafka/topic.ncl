let kafkaTopic = import "./topic.yml" in
fun namespace brokers topic => kafkaTopic & {
  metadata.name | force = topic,
  metadata.namespace | force = namespace,
  spec.kafkaApiSpec.brokers = brokers
}
