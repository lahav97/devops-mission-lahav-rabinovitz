# ---- Variables ----
variable "cluster_name" {
  description = "Name of the kind cluster"
  type        = string
  default     = "devops"
}

# ---- kind cluster: 1 control-plane + 2 workers ----
resource "kind_cluster" "this" {
  name           = var.cluster_name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # Control-plane: maps Mac port 80 into the node for the ingress controller
    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
}