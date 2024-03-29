fun k8s_namespace trigger_name broker_name trigger_filters sub_ref dead_ref => {
  apiVersion = "eventing.knative.dev/v1",
  kind = "Trigger",
  metadata = {
    name = trigger_name,
    namespace = k8s_namespace,
  },
  spec = {
    broker = broker_name, 
    filters = trigger_filters, 
    subscriber = {
      ref = sub_ref
    },
    delivery = {
      deadLetterSink = {
        ref = dead_ref
      }
    }
  }
}
