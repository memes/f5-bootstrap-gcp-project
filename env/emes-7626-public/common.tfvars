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
