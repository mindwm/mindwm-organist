let kafkaSource = import "./kafka-source.yml" in
fun namespace name bootstrapServers topics brokerName => kafkaSource & {
  metadata.name | force = name,
  metadata.namespace | force = namespace,
  spec.bootstrapServers | force = bootstrapServers, # Array of String
  spec.topics | force = topics, # Array of String
  spec.sink.ref.name | force = brokerName
}


