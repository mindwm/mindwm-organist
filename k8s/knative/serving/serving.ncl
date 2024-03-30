fun k8s_namespace serving_name image_name env_vars => {
  apiVersion = "serving.knative.dev/v1",
  kind = "Service",
  metadata = {
    name = serving_name,
    namespace = k8s_namespace,
  },
  spec = {
    template = {
      spec = {
        containers = [
          {
            image = image_name,
            env = env_vars
          }
        ]
      }
    }
  }

}

