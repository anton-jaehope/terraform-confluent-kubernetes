resource "kubernetes_network_policy" "kafka_connect" {
  metadata {
    name = "${local.metadata.name}-netpol"
    namespace = local.metadata.namespace
    labels = local.metadata.labels
  }

  spec {
    pod_selector {
      match_labels = local.metadata.labels
    }

    ingress {
      dynamic "ports" {
        for_each = local.kafka_connect.ports

        content {
          port = ports.value
          protocol = "TCP"
        }
      }
    }

    ingress {
      ports {
        port = local.jmx_exporter.port
        protocol = "TCP"
      }

      from {
        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
      }
    }

    egress {}

    policy_types = [
      "Ingress",
      "Egress"
    ]
  }
}