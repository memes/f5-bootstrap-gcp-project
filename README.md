# F5 bootstrap project

**OBSOLETE: This repo creates resources that follow best practices but are against
F5 CISO rulesets.**

> NOTE: this repo is a poor substitute for a true GCP Project Factory and
> Organization policy. I recommend Google's published
> [Terraform modules](https://registry.terraform.io/modules/terraform-google-modules)
> to implement a fully defined approach to project creation and birthright
> accounts.

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
1. Create a new `env` folder for the project, using the contents of [env/new-template](env/new-template/)
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

1. Uncomment lines 18-21 of [main.tf](env/new-template/main.tf#L18) to (re-)enable GCS backend
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

No modules.

## Resources

| Name | Type |
|------|------|
| [google_dns_managed_zone.zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_iam_workload_identity_pool.automation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.github_oidc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_iam_workload_identity_pool_provider.terraform_oidc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_iam_member.ansible_sa_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.oslogin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.tf_sa_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.ansible](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.tf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.bind_ansible_workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.bind_tf_workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.tf_impersonate_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.tf_impersonate_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket.tf_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.tf_bucket_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The existing project id that will have a Terraform service account added. | `string` | n/a | yes |
| <a name="input_ansible_sa_impersonate_groups"></a> [ansible\_sa\_impersonate\_groups](#input\_ansible\_sa\_impersonate\_groups) | A list of groups that will be allowed to impersonate the Ansible service account.<br>If no groups are supplied, impersonation will not be setup by the script.<br>E.g.<br>ansible\_sa\_impersonate\_groups = [<br>  "devsecops@example.com",<br>  "admins@example.com",<br>] | `list(string)` | `[]` | no |
| <a name="input_ansible_sa_name"></a> [ansible\_sa\_name](#input\_ansible\_sa\_name) | The name of the Ansible service account to add to the project. Default is<br>'ansible'. | `string` | `"ansible"` | no |
| <a name="input_ansible_sa_roles"></a> [ansible\_sa\_roles](#input\_ansible\_sa\_roles) | A list of IAM roles to assign to the Terraform service account. Defaults to a set<br>needed to manage Compute resources, GCS buckets, and IAM assignments. | `list(string)` | <pre>[<br>  "roles/compute.viewer",<br>  "roles/compute.osLogin"<br>]</pre> | no |
| <a name="input_apis"></a> [apis](#input\_apis) | An optional list of GCP APIs to enable in the project. | `list(string)` | <pre>[<br>  "storage-api.googleapis.com",<br>  "storage-component.googleapis.com",<br>  "compute.googleapis.com",<br>  "iap.googleapis.com",<br>  "oslogin.googleapis.com",<br>  "iam.googleapis.com",<br>  "iamcredentials.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "secretmanager.googleapis.com"<br>]</pre> | no |
| <a name="input_domains"></a> [domains](#input\_domains) | An optional set of DNS domains to create in the project. Default is empty list. | `list(string)` | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional set of key:value string pairs that will be added to resources. | `map(string)` | `{}` | no |
| <a name="input_oslogin_accounts"></a> [oslogin\_accounts](#input\_oslogin\_accounts) | A list of fully-qualified IAM accounts that will be allowed to use OS Login to<br>VMs.<br>E.g.<br>oslogin\_accounts = [<br>  "group:devsecops@example.com",<br>  "group:admins@example.com",<br>  "user:jane@example.com",<br>] | `list(string)` | `[]` | no |
| <a name="input_tf_bucket_location"></a> [tf\_bucket\_location](#input\_tf\_bucket\_location) | The location where the bucket will be created; this could be a GCE region, or a<br>dual-region or multi-region specifier. Default is to create a multi-region bucket<br>in 'US'. | `string` | `"US"` | no |
| <a name="input_tf_bucket_name"></a> [tf\_bucket\_name](#input\_tf\_bucket\_name) | The name of a GCS bucket to create for Terraform state storage. This name must be<br>unique in GCP. If blank, (the default), the name will be 'tf-PROJECT\_ID', where<br>PROJECT\_ID is the unique project identifier. | `string` | `""` | no |
| <a name="input_tf_sa_impersonators"></a> [tf\_sa\_impersonators](#input\_tf\_sa\_impersonators) | A list of fully-qualified IAM accounts that will be allowed to impersonate the<br>Terraform service account. If no accounts are supplied, impersonation will not<br>be setup by the script.<br>E.g.<br>tf\_sa\_impersonators = [<br>  "group:devsecops@example.com",<br>  "group:admins@example.com",<br>  "user:jane@example.com",<br>  "serviceAccount:ci-cd@project.iam.gserviceaccount.com",<br>] | `list(string)` | `[]` | no |
| <a name="input_tf_sa_name"></a> [tf\_sa\_name](#input\_tf\_sa\_name) | The name of the Terraform service account to add to the project. Default is<br>'terraform'. | `string` | `"terraform"` | no |
| <a name="input_tf_sa_roles"></a> [tf\_sa\_roles](#input\_tf\_sa\_roles) | A list of IAM roles to assign to the Terraform service account. Defaults to a set<br>needed to manage Compute resources, GCS buckets, IAM, and Secret Manager assignments. | `list(string)` | <pre>[<br>  "roles/compute.admin",<br>  "roles/iam.serviceAccountAdmin",<br>  "roles/iam.serviceAccountKeyAdmin",<br>  "roles/storage.admin",<br>  "roles/resourcemanager.projectIamAdmin",<br>  "roles/secretmanager.admin",<br>  "roles/iam.roleAdmin"<br>]</pre> | no |
| <a name="input_workload_identity"></a> [workload\_identity](#input\_workload\_identity) | If any field is true, enable a workload identity pool and establish an OIDC<br>provider for each enabled provider. Default value does not enable workload identity. | <pre>object({<br>    github    = bool<br>    terraform = bool<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_sa"></a> [ansible\_sa](#output\_ansible\_sa) | The fully-qualified Ansible service account identifier. |
| <a name="output_tf_sa"></a> [tf\_sa](#output\_tf\_sa) | The fully-qualified Terraform service account identifier. |
| <a name="output_tf_state_bucket"></a> [tf\_state\_bucket](#output\_tf\_state\_bucket) | The GCS bucket that will hold Terraform state. |
| <a name="output_workload_identity_pool"></a> [workload\_identity\_pool](#output\_workload\_identity\_pool) | The full-qualified workload identity pool name, if created. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html -->
