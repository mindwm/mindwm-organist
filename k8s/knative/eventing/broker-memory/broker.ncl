let configMapName = fun name => "%{name}-configmap" in
fun name => {
	broker = (import "./broker.yaml") & { 
		metadata.name | force = name,
		spec.config.name | force = configMapName name
	},
	configmap = (import "./configmap.yaml") & {
		metadata.name | force = configMapName name,
	}

}

