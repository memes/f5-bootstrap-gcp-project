project_id = "f5-gcs-4276-sales-anthos"
tf_sa_impersonators = [
  "group:app-gcs_4276_sales_anthos_users@f5.com",
  "group:app-gcs_4276_sales_anthos_admin@f5.com",
]
oslogin_accounts = [
  "group:app-gcs_4276_sales_anthos_users@f5.com",
]
apis = [
  "compute.googleapis.com",
  "iap.googleapis.com",
  "oslogin.googleapis.com",
  "iam.googleapis.com",
  "secretmanager.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "serviceusage.googleapis.com",
  "container.googleapis.com",
  "gkeconnect.googleapis.com",
  "gkehub.googleapis.com",
  "anthosgke.googleapis.com",
  "stackdriver.googleapis.com",
  "monitoring.googleapis.com",
  "logging.googleapis.com",
  "binaryauthorization.googleapis.com",
  "bigquery.googleapis.com",
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
  "roles/container.clusterAdmin",
  "roles/iam.roleAdmin",
  "roles/iam.securityAdmin",
]
