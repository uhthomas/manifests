package rasmus

import (
	"k8s.io/api/core/v1"
	appsv1 "k8s.io/api/apps/v1"
)

deploymentList: appsv1.#DeploymentList & {
	apiVersion: "apps/v1"
	kind:       "DeploymentList"
	items: [...{
		apiVersion: "apps/v1"
		kind:       "Deployment"
	}]
}

deploymentList: items: [{
	spec: {
		revisionHistoryLimit:    5
		progressDeadlineSeconds: 120
		strategy: rollingUpdate: maxUnavailable: 1
		minReadySeconds: 1
		selector: matchLabels: {
			"app.kubernetes.io/name":      "rasmus"
			"app.kubernetes.io/instance":  "rasmus"
			"app.kubernetes.io/component": "rasmus"
		}
		template: {
			metadata: labels: {
				"app.kubernetes.io/name":      "rasmus"
				"app.kubernetes.io/instance":  "rasmus"
				"app.kubernetes.io/component": "rasmus"
			}
			spec: containers: [{
				name:  "rasmus"
				image: "ghcr.io/uhthomas/rasmus:v0.2.5@sha256:b688a8a21a2c48c1dc04f15241c5c4ca8da28583e2f18d844174c1a1eac30b21"
				ports: [{
					name:          "http"
					containerPort: 8080
				}]
				env: [{
					name: "POD_IP"
					valueFrom: fieldRef: fieldPath: "status.podIP"
				}, {
					name:  "RELEASE_COOKIE"
					value: "0123456789abcdef"
				}]
				resources: {
					requests: {
						memory: "16Mi"
						cpu:    "150m"
					}
					limits: {
						memory: "128Mi"
						cpu:    "400m"
					}
				}
				imagePullPolicy: v1.#PullIfNotPresent
			}]
		}
	}
}]
