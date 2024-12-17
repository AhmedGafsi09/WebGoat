terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kubernetes" {
  config_path = "${path.cwd}/../kubeconfig"
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_namespace_v1" "webgoat" {
  metadata {
    name = "webgoat"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }
  
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "prometheus"
      }
    }
    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }
      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus"
          port {
            container_port = 9090
          }
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    selector = {
      app = "prometheus"
    }
    port {
      port        = 9090
      target_port = 9090
    }
    type = "NodePort"
  }
  lifecycle {
    ignore_changes = all
  }
}