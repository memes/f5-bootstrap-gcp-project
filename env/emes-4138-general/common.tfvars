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
  # Default
  "compute.googleapis.com",
  "iap.googleapis.com",
  "oslogin.googleapis.com",
  "iam.googleapis.com",
  "iamcredentials.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "secretmanager.googleapis.com",
  # Cloud build and repos
  "cloudbuild.googleapis.com",
  "sourcerepo.googleapis.com",
  # VPC services
  "vpcaccess.googleapis.com",
  # GKE
  "container.googleapis.com",
  # DNS
  "dns.googleapis.com",
  # Serverless
  "appengine.googleapis.com",
  "cloudfunctions.googleapis.com",
  "run.googleapis.com",
  # NCC
  "networkconnectivity.googleapis.com",
]
tf_sa_roles = [
  # Defaults
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
  # VPC services
  "roles/vpcaccess.admin",
  # GKE
  "roles/container.clusterAdmin",
  # DNS
  "roles/dns.admin",
  # Apply IAM
  "roles/iam.securityAdmin",
  # Serverless
  "roles/appengine.appAdmin",
  "roles/cloudfunctions.admin",
  "roles/run.admin",
  # NCC
  "roles/networkconnectivity.hubAdmin",
]
ansible_sa_creds_secret_readers = [
  "serviceAccount:234726409239@cloudbuild.gserviceaccount.com"
]
