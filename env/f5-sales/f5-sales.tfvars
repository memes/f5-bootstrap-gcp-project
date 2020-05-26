project_id = "f5-gcs-4138-sales-cloud-sales"
tf_sa_impersonate_groups = [
  "app-gcs_4138_sales_cloud_sales_users@f5.com",
  "app-gcs_4138_sales_cloud_sales_admin@f5.com",
]
oslogin_groups = [
  "app-gcs_4138_sales_cloud_sales_users@f5.com",
]
apis = [
  "compute.googleapis.com",
  "iap.googleapis.com",
  "oslogin.googleapis.com",
  "iam.googleapis.com",
  "iamcredentials.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "cloudbuild.googleapis.com",
  "sourcerepo.googleapis.com",
  "cloudkms.googleapis.com",
]
tf_sa_roles = [
  "roles/compute.admin",
  "roles/iam.serviceAccountAdmin",
  "roles/iam.serviceAccountKeyAdmin",
  "roles/iam.serviceAccountTokenCreator",
  "roles/storage.admin",
  "roles/resourcemanager.projectIamAdmin",
  "roles/cloudbuild.builds.editor",
  "roles/source.admin",
  "roles/cloudkms.admin",
]
