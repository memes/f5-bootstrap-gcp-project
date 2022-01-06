project_id = "f5-7626-networks-public"
tf_sa_impersonators = [
  "group:app-gcs_7626_networks-public_users@f5.com",
  "group:APP-GCS_7626_networks-public_admin@f5.com",
]
oslogin_accounts = [
  "group:app-gcs_7626_networks-public_users@f5.com",
]
tf_sa_roles = [
  "roles/compute.admin",
  "roles/iam.serviceAccountAdmin",
  "roles/iam.serviceAccountKeyAdmin",
  "roles/iam.serviceAccountTokenCreator",
  "roles/storage.admin",
  "roles/resourcemanager.projectIamAdmin",
  "roles/iam.serviceAccountUser",
  "roles/secretmanager.admin",
  "roles/iam.roleAdmin",
  # Cloud Build and source repos
  "roles/cloudbuild.builds.editor",
  "roles/source.admin",
]
