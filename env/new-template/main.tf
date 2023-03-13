# Configure an F5 project.
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
  # backend "gcs" {
  #   bucket = "tf-PROJECT_ID"
  #   prefix = "foundations/terraform-bootstrap"
  # }
}

module "bootstrap" {
  source     = "../../"
  project_id = "PROJECT_ID"
}
