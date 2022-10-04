project_id = "f5-gcs-4261-sales-shrdvpc-host"
tf_sa_impersonators = [
  "group:app-gcs_4261_sales_shrdvpc_host_users@f5.com",
  "group:app-gcs_4261_sales_shrdvpc_host_admin@f5.com",
]
oslogin_accounts = [
  "group:app-gcs_4261_sales_shrdvpc_host_users@f5.com",
]
apis = [
  # Defaults
  "compute.googleapis.com",
  "iap.googleapis.com",
  "oslogin.googleapis.com",
  "iam.googleapis.com",
  "iamcredentials.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "secretmanager.googleapis.com",
  # NCC
  "networkconnectivity.googleapis.com",
]
tf_sa_roles = [
  # Defaults
  "roles/compute.admin",
  "roles/iam.serviceAccountAdmin",
  "roles/iam.serviceAccountKeyAdmin",
  "roles/storage.admin",
  "roles/resourcemanager.projectIamAdmin",
  "roles/secretmanager.admin",
  "roles/iam.roleAdmin",
  # NCC
  "roles/networkconnectivity.hubAdmin",
]
