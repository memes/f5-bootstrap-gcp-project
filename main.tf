# This module adds a Terraform and an Ansible service account to the project,
# and allows members of a group to impersonate the account.
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
  version = "~> 3.49"
}

# Create the Terraform service account
resource "google_service_account" "tf" {
  project      = var.project_id
  account_id   = coalesce(var.tf_sa_name, "terraform")
  display_name = "Terraform automation service account"
}

# Create a key for Terraform SA
resource "google_service_account_key" "tf_creds" {
  service_account_id = google_service_account.tf.name
}

# Bind the impersonation privileges to the Terraform service account if group
# list is not empty.
resource "google_service_account_iam_member" "tf_impersonate_user" {
  for_each           = toset(var.tf_sa_impersonators)
  service_account_id = google_service_account.tf.name
  role               = "roles/iam.serviceAccountUser"
  member             = each.value
}
resource "google_service_account_iam_member" "tf_impersonate_token" {
  for_each           = toset(var.tf_sa_impersonators)
  service_account_id = google_service_account.tf.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
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

# Allow the Terraform service account and impersonators to be a storage admin on
# the bucket
#
# NOTE: this does not change associations of other members
resource "google_storage_bucket_iam_member" "tf_bucket_admin" {
  for_each = toset(concat([format("serviceAccount:%s", google_service_account.tf.email)], var.tf_sa_impersonators))
  bucket   = google_storage_bucket.tf_bucket.name
  role     = "roles/storage.admin"
  member   = each.value
}

# Enable any GCP APIs needed
resource "google_project_service" "apis" {
  for_each = toset(var.apis)
  project  = var.project_id
  service  = each.value
  # Shared project - don't disable the API on destroy in case someone else has
  # a dependency on it
  disable_on_destroy = false
}

# Assign IAM roles to Terraform service account
#
# NOTE: all these are additive, and will not unassign existing IAM privileges
resource "google_project_iam_member" "tf_sa_roles" {
  for_each = toset(var.tf_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = format("serviceAccount:%s", google_service_account.tf.email)

  depends_on = [google_project_service.apis]
}

# Allow these accounts to use OS Login
resource "google_project_iam_member" "oslogin" {
  for_each = toset(var.oslogin_accounts)
  project  = var.project_id
  role     = "roles/compute.osLogin"
  member   = each.value

  depends_on = [google_project_service.apis]
}

# Create a service account for Ansible
resource "google_service_account" "ansible" {
  project      = var.project_id
  account_id   = coalesce(var.ansible_sa_name, "ansible")
  display_name = "Ansible automation service account"
}

# Create a key for Ansible SA
resource "google_service_account_key" "ansible" {
  service_account_id = google_service_account.ansible.name
}

# Assign IAM roles to Ansible service account
#
# NOTE: all these are additive, and will not unassign existing IAM privileges
resource "google_project_iam_member" "ansible_sa_roles" {
  for_each = toset(var.ansible_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = format("serviceAccount:%s", google_service_account.ansible.email)

  depends_on = [google_project_service.apis]
}

# Create a slot for Terraform credential store in Secret Manager
resource "google_secret_manager_secret" "tf_creds" {
  project   = var.project_id
  secret_id = coalesce(var.tf_sa_creds_secret_id, "terraform-creds")
  replication {
    automatic = true
  }
}

# Stash the Terraform JSON credentials in Secret Manager
resource "google_secret_manager_secret_version" "tf_creds" {
  secret      = google_secret_manager_secret.tf_creds.id
  secret_data = base64decode(google_service_account_key.tf_creds.private_key)
}

# Allow the supplied accounts to read the Terraform JSON credentials
# NOTE: These are additive, and will not unassign existing IAM privileges
resource "google_secret_manager_secret_iam_member" "tf_creds" {
  for_each  = toset(var.tf_sa_creds_secret_readers)
  project   = var.project_id
  secret_id = google_secret_manager_secret.tf_creds.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}

# Create a slot for Ansible credential store in Secret Manager
resource "google_secret_manager_secret" "ansible_creds" {
  project   = var.project_id
  secret_id = coalesce(var.ansible_sa_creds_secret_id, "ansible-creds")
  replication {
    automatic = true
  }
}

# Stash the Ansible JSON credentials in Secret Manager
resource "google_secret_manager_secret_version" "ansible_creds" {
  secret      = google_secret_manager_secret.ansible_creds.id
  secret_data = base64decode(google_service_account_key.ansible.private_key)
}

# Allow the supplied accounts to read the Ansible JSON credentials
# NOTE: These are additive, and will not unassign existing IAM privileges
resource "google_secret_manager_secret_iam_member" "ansible_creds" {
  for_each  = toset(var.ansible_sa_creds_secret_readers)
  project   = var.project_id
  secret_id = google_secret_manager_secret.ansible_creds.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}
