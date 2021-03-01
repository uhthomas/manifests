package query_frontend

import appsv1 "k8s.io/api/apps/v1"

deployment: appsv1.#Deployment & {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name:      "query-frontend"
		namespace: "thanos"
	}
	spec: {
		revisionHistoryLimit:    5
		progressDeadlineSeconds: 120
		strategy: rollingUpdate: maxUnavailable: 1
		minReadySeconds: 1
		selector: matchLabels: app: "query-frontend"
		template: {
			metadata: {
				annotations: "prometheus.io/scrape": "true"
				labels: app:                         "query-frontend"
			}
			spec: containers: [{
				name: "query-frontend"
				// v0.18.0
				image:           "quay.io/thanos/thanos@sha256:b94171aed499b2f1f81b6d3d385e0eeeca885044c59cef28ce6a9a9e8a827217"
				imagePullPolicy: "IfNotPresent"
				ports: [{
					name:          "http"
					containerPort: 80
				}]
				args: [
					"query-frontend",
					"--http-address=:80",
					"--http-grace-period=5s",
					"--query-frontend.downstream-url=http://query",
				]
				livenessProbe: {
					httpGet: {
						path: "/-/healthy"
						port: "http"
					}
					initialDelaySeconds: 5
					periodSeconds:       3
				}
				readinessProbe: {
					httpGet: {
						path: "/-/ready"
						port: "http"
					}
					initialDelaySeconds: 5
					periodSeconds:       3
				}
				resources: {
					requests: {
						memory: "32Mi"
						cpu:    "150m"
					}
					limits: {
						memory: "64Mi"
						cpu:    "500m"
					}
				}
			}]
		}
	}
}
