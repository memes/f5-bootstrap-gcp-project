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

output "workload_identity_pool" {
  description = <<EOD
The full-qualified workload identity pool name, if created.
EOD
  value       = try(google_iam_workload_identity_pool.automation[0].name, "")
}
