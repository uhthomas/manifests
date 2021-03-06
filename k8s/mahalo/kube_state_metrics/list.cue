package kube_state_metrics

import "k8s.io/api/core/v1"

list: v1.#List & {
	apiVersion: "v1"
	kind:       "List"
	items: [...{
		metadata: {
			name:      "kube-state-metrics"
			namespace: "kube-state-metrics"
			labels: {
				"app.kubernetes.io/name":      "kube-state-metrics"
				"app.kubernetes.io/instance":  "kube-state-metrics"
				"app.kubernetes.io/version":   "2.0.0-rc.0"
				"app.kubernetes.io/component": "kube-state-metrics"
			}
		}
	}]
}

list: items:
	namespaceList.items +
	serviceAccountList.items +
	clusterRoleList.items +
	clusterRoleBindingList.items +
	serviceList.items +
	deploymentList.items
