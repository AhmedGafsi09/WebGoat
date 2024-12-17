terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kubernetes" {
  # Assurez-vous que ce fichier existe et est accessible lors de l'exécution.
  # Si vous utilisez une variable d'environnement KUBECONFIG, supprimez cette ligne
  # et laissez Terraform utiliser le contexte courant.
  config_path = "~/.kube/config"
}

# Crée le namespace monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Crée le namespace webgoat
resource "kubernetes_namespace" "webgoat" {
  metadata {
    name = "webgoat"
  }
}

# Déploiement Prometheus dans le namespace monitoring
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata.name
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
}

# Service Prometheus de type NodePort
resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata.name
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
}
