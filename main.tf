# This module adds a Terraform service account to the project, and allows members
# of a group to impersonate the account.
#
# Note: GCS backend requires the current user to have valid application-default
# credentials. An error like '... failed: dialing: google: could not find default
# credenitals' indicates that the calling user must (re-)authenticate application
# default credentials using `gcloud auth application-default login`.
terraform {
  required_version = "~> 0.12"
  # After bucket is created, the state can be migrated to the GCS location by
  # setting bucket and prefix in env/[ENV]/[NAME].config
  backend "gcs" {}
}

provider "google" {
  version = "~> 3.14"
}

# Create the Terraform service account
resource "google_service_account" "tf" {
  project      = var.project_id
  account_id   = coalesce(var.tf_sa_name, "terraform")
  display_name = "Terraform automation service account"
}

# Bind the impersonation privileges to the Terraform service account if group
# list is not empty.
resource "google_service_account_iam_binding" "tf_impersonate" {
  count              = length(var.tf_sa_impersonate_groups) > 0 ? 1 : 0
  service_account_id = google_service_account.tf.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = formatlist("group:%s", var.tf_sa_impersonate_groups)
}

# Create a bucket for Terraform state
resource "google_storage_bucket" "tf_bucket" {
  project  = var.project_id
  name     = coalesce(var.tf_bucket_name, format("tf-%s", var.project_id))
  location = var.tf_bucket_location
  versioning {
    enabled = false
  }
}

# Allow the Terraform service account to be a storage admin on the bucket
#
# NOTE: this does not change associations of other members
resource "google_storage_bucket_iam_member" "tf_bucket_admin" {
  bucket = google_storage_bucket.tf_bucket.name
  role   = "roles/storage.admin"
  member = format("serviceAccount:%s", google_service_account.tf.email)
}

# Enable any GCP APIs needed
resource "google_project_service" "apis" {
  count   = length(var.apis)
  project = var.project_id
  service = element(var.apis, count.index)
  # Shared project - don't disable the API on destroy in case someone else has
  # a dependency on it
  disable_on_destroy = false
}

# Assign IAM roles to Terraform service account
#
# NOTE: all these are additive, and will not unassign existing IAM privileges
resource "google_project_iam_member" "tf_sa_roles" {
  count   = length(var.tf_sa_roles)
  project = var.project_id
  role    = element(var.tf_sa_roles, count.index)
  member  = format("serviceAccount:%s", google_service_account.tf.email)

  depends_on = [google_project_service.apis]
}
