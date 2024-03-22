let configMapName = fun name => "host-%{name}-jsm-broker-configmap" in
fun username hostname => {
	broker = (import "./broker.yaml") & { 
		metadata.name | force = hostname,
		spec.config.name | force = configMapName hostname
	},
	configmap = (import "./configmap.yaml") & {
		metadata.name | force = configMapName hostname,
		data.channelTemplateSpec | force = std.serialize 'Yaml
		   {
		     apiVersion =  "messaging.knative.dev/v1alpha1",
		     kind = "NatsJetStreamChannel",
		     spec = {
		       stream = {
		  	 overrideName = "%{hostname}",
		           config = {
			     additionalSubjects = [
		               "mindwm.%{username}.%{hostname}.>"
			     ]
			 }
		       }
		      }
		    }

	}


}

