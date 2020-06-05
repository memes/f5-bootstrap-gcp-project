output "tf_sa" {
  description = <<EOD
The fully-qualified Terraform service account identifier.
EOD
  value       = google_service_account.tf.email
}

output "tf_state_bucket" {
  description = <<EOD
The GCS bucket that will hold Terraform state.
EOD
  value       = google_storage_bucket.tf_bucket.name
}

output "ansible_sa" {
  description = <<EOD
The fully-qualified Ansible service account identifier.
EOD
  value       = google_service_account.ansible.email
}

output "tf_sa_secret_id" {
  description = <<EOD
The unique secret ID to access Terraform JSON credentials.
EOD
  value       = google_secret_manager_secret.tf_creds.secret_id
}

output "ansible_sa_secret_id" {
  description = <<EOD
The unique secret ID to access Ansible JSON credentials.
EOD
  value       = google_secret_manager_secret.ansible_creds.secret_id
}
