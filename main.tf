module "jx" {
  source                          = "github.com/jenkins-x/terraform-google-jx?ref=v1.12.6"
 gcp_project                     = var.gcp_project
  master_authorized_networks = var.master_authorized_networks
  jx2                             = false
  gsm                             = var.gsm
  cluster_name                    = var.cluster_name
  cluster_location                = var.cluster_location
  resource_labels                 = var.resource_labels
  node_machine_type               = var.node_machine_type
  initial_cluster_node_count = var.initial_cluster_node_count
  initial_primary_node_pool_node_count = var.initial_primary_node_pool_node_count
  autoscaler_min_node_count    = var.autoscaler_min_node_count
  autoscaler_max_node_count    = var.autoscaler_max_node_count
  node_disk_size                  = var.node_disk_size
  node_disk_type                  = var.node_disk_type
  tls_email                       = var.tls_email
  lets_encrypt_production         = var.lets_encrypt_production
  jx_git_url                      = var.jx_git_url
  jx_bot_username                 = var.jx_bot_username
  jx_bot_token                    = var.jx_bot_token
  force_destroy                   = var.force_destroy
  delete_protect                  = var.delete_protect
  apex_domain                     = var.apex_domain
  subdomain                       = var.subdomain
  apex_domain_gcp_project         = var.apex_domain_gcp_project
  apex_domain_integration_enabled = var.apex_domain_integration_enabled
  node_preemptible                = var.node_preemptible
  kuberhealthy                    = var.kuberhealthy
  node_spot                       = var.node_spot
  artifact_enable                 = var.artifact_enable
  artifact_location               = var.artifact_location
  artifact_repository_id          = var.artifact_repository_id

}

# Define the Google Secret Manager Secret for Lighthouse HMAC token
resource "google_secret_manager_secret" "lighthouse_hmac_secret" {
  project = var.gcp_project
  secret_id = "lfs268-lab-lighthouse-hmac"

replication {
    auto {}
  }
  labels = {
    "managed-by" = "terraform"
    "purpose"    = "jenkins-x-lighthouse-hmac"
  }
}

# Add a version to the Lighthouse HMAC secret with the token in JSON format
resource "google_secret_manager_secret_version" "lighthouse_hmac_secret_version" {
  secret = google_secret_manager_secret.lighthouse_hmac_secret.id
  secret_data = jsonencode({
    token = var.jx_bot_token
  })
}

# Define the Google Secret Manager Secret for Lighthouse OAuth token
resource "google_secret_manager_secret" "lighthouse_oauth_secret" {
  project = var.gcp_project
  secret_id = "lfs268-lab-lighthouse-oauth"


replication {
    auto {}
  }

  
  labels = {
    "managed-by" = "terraform"
    "purpose"    = "jenkins-x-lighthouse-oauth"
  }
  deletion_protection = false
}

# Add a version to the Lighthouse OAuth secret with the token in JSON format
resource "google_secret_manager_secret_version" "lighthouse_oauth_secret_version" {
  secret = google_secret_manager_secret.lighthouse_oauth_secret.id
  secret_data = jsonencode({
    token = var.jx_bot_token
  })
  deletion_protection = false
}

output "connect" {
  description = "Connect to cluster"
  value       = module.jx.connect
}

output "follow_install_logs" {
  description = "Follow Jenkins X install logs"
  value       = "jx admin log"
}

output "docs" {
  description = "Follow Jenkins X 3.x alpha docs for more information"
  value       = "https://jenkins-x.io/v3/"
}

