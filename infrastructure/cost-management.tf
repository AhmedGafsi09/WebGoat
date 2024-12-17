# Budget pour le projet WebGoat
resource "azurerm_consumption_budget_subscription" "webgoat_budget" {
  name            = "webgoat-monthly-budget"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 100  # Budget de 100$ par mois
  time_grain = "Monthly"

  time_period {
    start_date = "2024-01-01T00:00:00Z"
    end_date   = "2024-12-31T23:59:59Z"
  }

  notification {
    enabled   = true
    threshold = 90.0  # Alerte à 90% du budget
    operator  = "GreaterThanOrEqualTo"

    contact_emails = [
      "ahmed.gafsi@umontreal.ca"
    ]

    contact_roles = [
      "Owner",
      "Contributor"
    ]
  }

  notification {
    enabled   = true
    threshold = 100.0  # Alerte à 100% du budget
    operator  = "GreaterThanOrEqualTo"

    contact_emails = [
      "ahmed.gafsi@umontreal.ca"  
    ]

    contact_roles = [
      "Owner",
      "Contributor"
    ]
  }
}

# Récupérer l'ID de la souscription actuelle
data "azurerm_subscription" "current" {}

# Configuration du fournisseur Azure
provider "azurerm" {
  features {}
}