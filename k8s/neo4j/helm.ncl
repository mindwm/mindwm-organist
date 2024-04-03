let ContextName = "teama" in
let K8sNamespaceName = String in
let HelmChartName = String in
let HelmChartVersion = String in
let HelmRepoName = String in
let ValuesFilePath = String in
let HelmReleaseName = String in
let KafkaBootstrap = "neo4j-cdc-stream.redpanda.svc.cluster.local:9093" in
let Neo4jPluginPvcName = "neo4j-plugins" in
let LocalRepoName = "neo4j" in
let KafkaTopicName = "context-%{ContextName}-events" in
let TeamKubernetesNamespace : String -> K8sNamespaceName = fun teamName => "context-" ++ teamName | K8sNamespaceName in
{
  HelmReleaseSchema | not_exported = {
    k8s_namespace 
      | K8sNamespaceName
      | default = "default"
      ,
    chart_name 
      | HelmChartName
      ,
    chart_version 
      | HelmChartVersion
      , 
    chart_repo 
      | HelmRepoName
      , 
    values
      | Dyn
      ,
    release_name 
      | HelmReleaseName
      | default = "neo4j"
  },

  make_helm_release : K8sNamespaceName -> HelmRepoName -> HelmChartName -> HelmChartVersion -> String -> HelmReleaseSchema | not_exported =
    fun namespace helm_repo_name helm_chart_name helm_chart_version values_file_path => { 
      k8s_namespace | force = TeamKubernetesNamespace namespace,
      chart_name | force = helm_chart_name,
      chart_repo | force = helm_repo_name,
      chart_version | force = helm_chart_version,
      values | force = (import "./helm_values.yml") & {
        env = {
          NEO4J_kafka_bootstrap_servers | force = KafkaBootstrap,
          "NEO4J_streams_source_topic_nodes_%{KafkaTopicName}" | force = "*",
          "NEO4J_streams_source_topic_relationships_%{KafkaTopicName}" | force = "*",
        }
      }
    } | HelmReleaseSchema,

  neo4j_plugins_pvc | not_exported = {
    apiVersion = "v1",
    kind = "PersistentVolumeClaim",
    metadata = {
      name = Neo4jPluginPvcName
    },
    spec = {
      accessModes = ["ReadWriteOnce"],
      resources = {
        requests = {
          storage = "1Gi"
        }
      }
    }
  },


  helm_release | not_exported = make_helm_release ContextName "https://helm.neo4j.com/neo4j" "neo4j-standalone" "4.4.28" "./helm_values.yml",
  files = {
    "k8s/context/%{ContextName}/neo4j_helm_values.yml" = {
        content = std.serialize 'Yaml helm_release.values
    },
    "k8s/context/%{ContextName}/neo4j_plugins_pvc.yml" = {
        content = std.serialize 'Yaml neo4j_plugins_pvc
    },
    "k8s/context/%{ContextName}/neo4j_helm_install.sh" = {
        content = m%"
          #!/usr/bin/env bash
          set -ex
          (
            cd $(dirname "${BASH_SOURCE[0]}") 
            #helm repo add %{LocalRepoName} %{helm_release.chart_repo}
            #helm repo update %{LocalRepoName}
            kubectl -n %{helm_release.k8s_namespace} apply -f ./neo4j_plugins_pvc.yml
            helm upgrade --install --repo %{helm_release.chart_repo} --create-namespace --namespace %{helm_release.k8s_namespace} %{helm_release.release_name} \
              %{helm_release.chart_name} --version %{helm_release.chart_version} -f ./neo4j_helm_values.yml
          )
        "%
    }
    
  }
}
