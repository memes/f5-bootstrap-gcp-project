project_id = "f5-gcs-4138-sales-cloud-sales"
tf_sa_impersonators = [
  "group:app-gcs_4138_sales_cloud_sales_users@f5.com",
  "group:app-gcs_4138_sales_cloud_sales_admin@f5.com",
  "serviceAccount:tf-cloud-memes@f5-gcs-4138-sales-cloud-sales.iam.gserviceaccount.com",
]
oslogin_accounts = [
  "group:app-gcs_4138_sales_cloud_sales_users@f5.com",
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
  "secretmanager.googleapis.com",
  "cloudfunctions.googleapis.com",
  "vpcaccess.googleapis.com",
  "container.googleapis.com",
  "dns.googleapis.com",
]
tf_sa_roles = [
  "roles/compute.admin",
  "roles/iam.serviceAccountAdmin",
  "roles/iam.serviceAccountKeyAdmin",
  "roles/iam.serviceAccountTokenCreator",
  "roles/storage.admin",
  "roles/resourcemanager.projectIamAdmin",
  "roles/iam.serviceAccountUser",
  "roles/cloudbuild.builds.editor",
  "roles/source.admin",
  "roles/secretmanager.admin",
  "roles/vpcaccess.admin",
  "roles/container.clusterAdmin",
  "roles/dns.admin",
  "roles/iam.roleAdmin",
  "roles/iam.securityAdmin",
]
ansible_sa_creds_secret_readers = [
  "serviceAccount:234726409239@cloudbuild.gserviceaccount.com"
]
