package rook_ceph

import "k8s.io/api/core/v1"

cephObjectStoreList: v1.#List & {
	apiVersion: "v1"
	kind:       "List"
	items: [...{
		apiVersion: "ceph.rook.io/v1"
		kind:       "CephObjectStore"
	}]
}

cephObjectStoreList: items: [{
	metadata: name: "replicapool"
	spec: {
		// The pool spec used to create the metadata pools. Must use replication.
		metadataPool: {
			failureDomain: "host"
			replicated: {
				size: 3
				// Disallow setting pool with replica 1, this could lead to data loss without recovery.
				// Make sure you're *ABSOLUTELY CERTAIN* that is what you want
				requireSafeReplicaSize: true
			}
			parameters: {
				// Inline compression mode for the data pool
				// Further reference: https://docs.ceph.com/docs/nautilus/rados/configuration/bluestore-config-ref/#inline-compression
				compression_mode: "none"
			}
		}
		// gives a hint (%) to Ceph in terms of expected consumption of the total cluster capacity of a given pool
		// for more info: https://docs.ceph.com/docs/master/rados/operations/placement-groups/#specifying-expected-pool-size
		//target_size_ratio: ".5"
		// The pool spec used to create the data pool. Can use replication or erasure coding.
		dataPool: {
			failureDomain: "host"
			replicated: {
				size: 3
				// Disallow setting pool with replica 1, this could lead to data loss without recovery.
				// Make sure you're *ABSOLUTELY CERTAIN* that is what you want
				requireSafeReplicaSize: true
			}
			parameters: {
				// Inline compression mode for the data pool
				// Further reference: https://docs.ceph.com/docs/nautilus/rados/configuration/bluestore-config-ref/#inline-compression
				compression_mode: "none"
			}
		}
		// gives a hint (%) to Ceph in terms of expected consumption of the total cluster capacity of a given pool
		// for more info: https://docs.ceph.com/docs/master/rados/operations/placement-groups/#specifying-expected-pool-size
		//target_size_ratio: ".5"
		// Whether to preserve metadata and data pools on object store deletion
		preservePoolsOnDelete: false
		// The gateway service configuration
		gateway: {
			// A reference to the secret in the rook namespace where the ssl certificate is stored
			// sslCertificateRef:
			// The port that RGW pods will listen on (http)
			port: 80
			// The port that RGW pods will listen on (https). An ssl certificate is required.
			// securePort: 443
			// The number of pods in the rgw deployment
			instances: 1
			// The affinity rules to apply to the rgw deployment.
			placement: {
				podAntiAffinity: preferredDuringSchedulingIgnoredDuringExecution: [{
					weight: 100
					podAffinityTerm: {
						labelSelector: matchExpressions: [{
							key:      "app"
							operator: "In"
							values: [
								"rook-ceph-rgw",
							]
						}]
						// topologyKey: */zone can be used to spread RGW across different AZ
						// Use <topologyKey: failure-domain.beta.kubernetes.io/zone> in k8s cluster if your cluster is v1.16 or lower
						// Use <topologyKey: topology.kubernetes.io/zone>  in k8s cluster is v1.17 or upper
						topologyKey: "kubernetes.io/hostname"
					}
				}]
			}
			// A key/value list of annotations
			//  nodeAffinity:
			//    requiredDuringSchedulingIgnoredDuringExecution:
			//      nodeSelectorTerms:
			//      - matchExpressions:
			//        - key: role
			//          operator: In
			//          values:
			//          - rgw-node
			//  topologySpreadConstraints:
			//  tolerations:
			//  - key: rgw-node
			//    operator: Exists
			//  podAffinity:
			//  podAntiAffinity:
			// A key/value list of annotations
			annotations: null
			//  key: value
			// A key/value list of labels
			labels: null
			//  key: value
			resources: null
		}
		// The requests and limits set here, allow the object store gateway Pod(s) to use half of one CPU core and 1 gigabyte of memory
		//  limits:
		//    cpu: "500m"
		//    memory: "1024Mi"
		//  requests:
		//    cpu: "500m"
		//    memory: "1024Mi"
		// priorityClassName: my-priority-class
		//zone:
		//name: zone-a
		// service endpoint healthcheck
		healthCheck: {
			bucket: {
				disabled: false
				interval: "60s"
			}
			// Configure the pod liveness probe for the rgw daemon
			livenessProbe: {
				disabled: false
			}
		}
	}
}]
