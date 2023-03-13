# F5 4261 Shared VPC Service project bootstrap.
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
    bucket = "tf-f5-gcs-4261-sales-shrdvpc"
    prefix = "foundations/terraform-bootstrap"
  }
}

module "bootstrap" {
  source     = "../../"
  project_id = "f5-gcs-4261-sales-shrdvpc"
  tf_sa_impersonators = [
    "group:app-gcs_4261_sales_shrdvpc_svcprj_users@f5.com",
    "group:app-gcs_4261_sales_shrdvpc_svcprj_admin@f5.com",
  ]
  oslogin_accounts = [
    "group:app-gcs_4261_sales_shrdvpc_svcprj_users@f5.com",
  ]
}
