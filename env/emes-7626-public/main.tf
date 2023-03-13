# F5 project 7626 Public bootstrap.
#
# Note: GCS backend requires the current user to have valid application-default
# credentials. An error like '... failed: dialing: google: could not find default
# credenitals' indicates that the calling user must (re-)authenticate application
# default credentials using `gcloud auth application-default login`.
terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.56"
    }
  }

  # After bucket is created, the state can be migrated to the GCS location by
  # setting bucket and prefix below.
  backend "gcs" {
    bucket = "tf-f5-7626-networks-public"
    prefix = "foundations/terraform-bootstrap"
  }
}

module "bootstrap" {
  source     = "../../"
  project_id = "f5-7626-networks-public"
  tf_sa_impersonators = [
    "group:app-gcs_7626_networks-public_users@f5.com",
    "group:APP-GCS_7626_networks-public_admin@f5.com",
  ]
  oslogin_accounts = [
    "group:app-gcs_7626_networks-public_users@f5.com",
  ]
  apis = [
    # Default
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "compute.googleapis.com",
    "iap.googleapis.com",
    "oslogin.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
    # Extras
    "cloudbuild.googleapis.com",
    "sourcerepo.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "appengine.googleapis.com",
  ]
  tf_sa_roles = [
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/storage.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/secretmanager.admin",
    "roles/iam.roleAdmin",
    # Cloud Build and source repos
    "roles/cloudbuild.builds.editor",
    "roles/source.admin",
    # Allow API management
    "roles/serviceusage.serviceUsageAdmin",
    # Allow repo management
    "roles/artifactregistry.repoAdmin",
    # Allow management of Cloud Run and AppEngine
    "roles/run.admin",
    "roles/appengine.appAdmin",
  ]

}
