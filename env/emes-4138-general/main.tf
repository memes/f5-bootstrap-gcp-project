# Configure F5 4138 Sales project.
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
    bucket = "tf-f5-gcs-4138-sales-cloud-sales"
    prefix = "foundations/terraform-bootstrap"
  }
}

module "bootstrap" {
  source     = "../../"
  project_id = "f5-gcs-4138-sales-cloud-sales"
  tf_sa_impersonators = [
    "group:app-gcs_4138_sales_cloud_sales_users@f5.com",
    "group:app-gcs_4138_sales_cloud_sales_admin@f5.com",
  ]
  oslogin_accounts = [
    "group:app-gcs_4138_sales_cloud_sales_users@f5.com",
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
    # Artifact registry
    "artifactregistry.googleapis.com",
    # Security Token Service
    "sts.googleapis.com",
    # Certificate Manager
    "certificatemanager.googleapis.com",
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
    # Allow repo management
    "roles/artifactregistry.admin",
    # STS administration
    "roles/iam.workloadIdentityPoolAdmin",
    # Manage Certifacates
    "roles/certificatemanager.editor",
  ]
  workload_identity = {
    github    = true
    terraform = true
  }
  domains = [
    "ephemeral.strangelambda.app",
  ]
}
