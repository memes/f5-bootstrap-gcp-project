# F5 bootstrap project

Use these files to prepare existing F5 GCP projects for Terraform and Ansible
automation. During execution, Terraform will bootstrap the project to create
these resources:

1. Terraform GCS bucket for remote state
1. Enables Compute Engine and IAP APIs by default
1. Enables OS Login for GCE instances at the project level
1. A service account to use for Terraform automation
   - with storage admin rights on Terraform state bucket
   - with an extendible set of roles at project level
   - with optional impersonation enabled for AD group(s)
1. A service account to use for Ansible automation
   - with an extendible set of roles at project level
   - with optional impersonation enabled for AD group(s)

## Usage

This repo uses file based environment configurations in preference to Terraform
workspaces. Per-environment configurations are stored in
`env/ENV/main.tf`, where ENV and name represents the GCP project
environment to manage.

### To make a change to an **existing** project

To make changes to an existing project to add additional impersonation groups,
or to enable other GCP APIs

1. Fork the repo
1. Edit the relevant environment `main.tf` file
1. Execute standard Terraform process

   ```shell
   terraform init
   terraform plan
   terraform apply
   ```

1. Push the changes to GitHub and open a PR to merge to `main`

### To bootstrap a **new** project

If you need to bootstrap a new GCP project to support Terraform automation, you
must apply the Terraform twice.

#### A. Bootstrap project

1. Fork the repo
1. Create a new `env` folder for the project, using the contents of `env/new-template`
   as a starting point.
1. Edit `main.tf` so that:
   - GCS backend is disabled (lines 18-21); this will be reverted after the state
     bucket is bootstrapped.
   - Set `project_id` variable to match the target GCP project id
1. Add other overrides as needed by setting the corresponding module variable
   - Add AD groups that will be granted the ability to impersonate Terraform
     service account
   - *Optional:* Add any Google Cloud APIs that need to be enabled
   - *Optional:* Add any additional roles that should be granted to the
     Terraform and/or Ansible service accounts
1. Execute Terraform to create the new resources

   ```shell
   terraform init
   terraform apply
   ```

   ```shell
   ...
   tf_sa = terraform@PROJECT_ID.iam.gserviceccount.com
   ...
   tf_state_bucket = TF_BUCKET_NAME
   ```

At this point a the service accounts are created and a new GCS bucket is ready to manage Terraform state.

#### B. Transfer state to new GCS bucket

1. Uncomment lines 18-21 of [`main.tf`](main.tf#L18) to (re-)enable GCS backend
1. Set the `bucket` parameter to match the Terraform state bucket that was an
   output from step A.4
1. Add a unique prefix for the bootstrap state.

   E.g.

   ```hcl
   ...
     backend "gcs" {
       bucket = "TF_BUCKET_NAME"
       prefix = "foundations/terraform-bootstrap"
     }
   }
   ```

1. Reinitialise Terraform to migrate the state to GCS bucket

   ```shell
   terraform init -migrate-state
   ```

   ```shell
   ...
   Initializing the backend...
   Do you want to copy existing state to the new backend?
      Pre-existing state was found while migrating the previous "local" backend to the newly configured "gcs" backend. No existing state was found in the newly configured "gcs" backend. Do you want to copy this state to the new "gcs" backend? Enter "yes" to copy and "no" to start with an empty state.

      Enter a value: yes

   Successfully configured the backend "gcs"! Terraform will automatically use this backend unless the backend configuration changes.
   ...
   ```

   The Terraform state is now stored in GCS bucket and can be shared by others that are managing the project.

1. Commit and push the changes to GitHub, and open a PR to merge to `main`

## Optional next-steps (not automated)

In my article I talked about the recommendations usually provided by a true
Project Factory module, but I decided not to include all of those in this script
because it may break existing deployments or interfere with another SEs
resources. If you are certain that it is safe to do so, use these commands to
disable the Default Compute service account, and remove the `default` network.

### Disable Default Compute service account

1. Get the target project number from UI, or command line

   ```shell
   gcloud projects describe PROJECT_ID --format 'value(projectNumber)'
   ```

   ```shell
   nnnnnnnnnnnn
   ```

1. Disable the Default Compute service account

   ```shell
   gcloud iam service-accounts disable nnnnnnnnnnnn-compute@developer.gserviceaccount.com --project PROJECT_ID
   ```

   ```shell
   Disabled service account [nnnnnnnnnnnn-compute@developer.gserviceaccount.com].
   ```

<!-- markdownlint-disable no-inline-html -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.56 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html -->
