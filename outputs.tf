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
