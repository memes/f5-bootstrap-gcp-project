# F5 project bootstrap

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
1. Initialises Secret Manager and stores the JSON credential files for Terraform
   and Ansible service accounts

## Usage

This repo uses file based environment configurations in preference to Terraform
workspaces. Per-environment configurations are stored in
`env/ENV/common.{config,tfvars}`, where ENV and name represents the GCP project
environment to manage.

### To make a change to an **existing** project

To make changes to an existing project to add additional impersonation groups,
or to enable other GCP APIs

1. Fork the repo
1. Edit the relevant environment `tfvars` file
1. Execute standard Terraform process

   ```shell
   terraform init -backend-config env/ENV/common.config
   terraform plan -var-file env/ENV/common.tfvars
   terraform apply -var-file env/ENV/common.tfvars
   ```

1. Push the changes to GitHub and open a PR to merge to `main`

### To bootstrap a **new** project

If you need to bootstrap a new GCP project to support Terraform automation, you must apply the Terraform twice.

#### A. Bootstrap project

1. Fork the repo
1. Create a new `env` folder for the project, with a `config` and `tfvar` file.
   - Edit the new `tfvar` file and set `project_id` to match the target GCP
     project id
   - Add AD groups that will be granted the ability to impersonate Terraform
     service account
   - Add AD groups that will be able to retrieve Ansible service account
     credentials from Secret Manager
   - *Optional:* Add any Google Cloud APIs that need to be enabled
   - *Optional:* Add any additional roles that should be granted to the
     Terraform and/or Ansible service accounts
1. Comment out line 12 [`main.tf`](main.tf#L12) to disable the GCS backend; this
   will be reverted after the state bucket is bootstrapped.
1. Execute Terraform to create the new resources

   ```shell
   rm -rf .terraform
   terraform init -backend-config env/ENV/common.config
   terraform apply -var-file env/ENV/common.tfvars
   ```

   ```shell
   ...
   tf_sa = terraform@PROJECT_ID.iam.gserviceccount.com
   ...
   tf_state_bucket = TF_BUCKET_NAME
   ```

At this point a the service accounts are created and a new GCS bucket is ready to manage Terraform state.

#### B. Transfer state to new GCS bucket

1. Uncomment line 12 [`main.tf`](main.tf#L12) to enable GCS backend
1. Edit the new `config` environment file and add the Terraform state bucket that was an ouput from step A.4
1. Add a unique prefix for the bootstrap state.
   E.g.

   ```hcl
   bucket = "TF_BUCKET_NAME"
   prefix = "foundations/terraform-bootstrap"
   ```

1. Reinitialise Terraform to migrate the state to GCS bucket

   ```shell
   terraform init -backend-config env/ENV/name.config -migrate-state
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

1. Commit and push the changes to GitHub, and open a PR to merge to `master`

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

## Environments

1. [F5 Sales project](env/f5-sales/)
   Non-Shared VPC project used by multiple engineers in the Sales organization.
1. [F5 Sales Shared VPC projects](env/f5-sales-shared-vpc/)
   Projects setup as a Shared VPC host and service pair. Note that this environment has separate config pairs for the host and service project.

<!-- markdownlint-disable no-inline-html -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.ansible_sa_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.oslogin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.tf_sa_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.ansible_creds](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.tf_creds](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.ansible_creds](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_iam_member.tf_creds](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.ansible_creds](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.tf_creds](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.ansible](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.tf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.tf_default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.tf_impersonate_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.tf_impersonate_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_key.ansible](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_service_account_key.tf_creds](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.tf_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.tf_bucket_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_app_engine_default_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/app_engine_default_service_account) | data source |
| [google_compute_default_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_default_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The existing project id that will have a Terraform service account added. | `string` | n/a | yes |
| <a name="input_ansible_sa_creds_secret_id"></a> [ansible\_sa\_creds\_secret\_id](#input\_ansible\_sa\_creds\_secret\_id) | The unique identifier to use for Ansible credential store in Secret Manager.<br>Default is 'ansible-creds'. | `string` | `"ansible-creds"` | no |
| <a name="input_ansible_sa_creds_secret_readers"></a> [ansible\_sa\_creds\_secret\_readers](#input\_ansible\_sa\_creds\_secret\_readers) | A list of accounts that will be granted read-only access to the Ansible JSON<br>credentials in Secret Manager. Default is an empty list.<br><br>NOTE: this variable is less opinionated and is a raw list of accounts that will<br>be granted read-only access; each account must be prefixed with 'group:',<br>'serviceAccount:', or 'user:' as appropriate.<br><br>E.g.<br>ansible\_sa\_creds\_secret\_readers = [<br>  "group:devsecops@example.com",<br>  "serviceAccount:my-service@PROJECT\_ID.iam.gserviceaccount.com",<br>  "user:jane\_doe@example.com",<br>] | `list(string)` | `[]` | no |
| <a name="input_ansible_sa_impersonate_groups"></a> [ansible\_sa\_impersonate\_groups](#input\_ansible\_sa\_impersonate\_groups) | A list of groups that will be allowed to impersonate the Ansible service account.<br>If no groups are supplied, impersonation will not be setup by the script.<br><br>NOTE: Ansible does not directly support impersonation; prefer<br>`ansible_sa_creds_secret_readers` to add accounts permitted to read the Ansible<br>SA JSON credentials.<br><br>E.g.<br>ansible\_sa\_impersonate\_groups = [<br>  "devsecops@example.com",<br>  "admins@example.com",<br>] | `list(string)` | `[]` | no |
| <a name="input_ansible_sa_name"></a> [ansible\_sa\_name](#input\_ansible\_sa\_name) | The name of the Ansible service account to add to the project. Default is<br>'ansible'. | `string` | `"ansible"` | no |
| <a name="input_ansible_sa_roles"></a> [ansible\_sa\_roles](#input\_ansible\_sa\_roles) | A list of IAM roles to assign to the Terraform service account. Defaults to a set<br>needed to manage Compute resources, GCS buckets, and IAM assignments. | `list(string)` | <pre>[<br>  "roles/compute.viewer",<br>  "roles/compute.osLogin"<br>]</pre> | no |
| <a name="input_apis"></a> [apis](#input\_apis) | An optional list of GCP APIs to enable in the project. | `list(string)` | <pre>[<br>  "compute.googleapis.com",<br>  "iap.googleapis.com",<br>  "oslogin.googleapis.com",<br>  "iam.googleapis.com",<br>  "iamcredentials.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "secretmanager.googleapis.com"<br>]</pre> | no |
| <a name="input_oslogin_accounts"></a> [oslogin\_accounts](#input\_oslogin\_accounts) | A list of fully-qualified IAM accounts that will be allowed to use OS Login to<br>VMs.<br>E.g.<br>oslogin\_accounts = [<br>  "group:devsecops@example.com",<br>  "group:admins@example.com",<br>  "user:jane@example.com",<br>] | `list(string)` | `[]` | no |
| <a name="input_tf_bucket_location"></a> [tf\_bucket\_location](#input\_tf\_bucket\_location) | The location where the bucket will be created; this could be a GCE region, or a<br>dual-region or multi-region specifier. Default is to create a multi-region bucket<br>in 'US'. | `string` | `"US"` | no |
| <a name="input_tf_bucket_name"></a> [tf\_bucket\_name](#input\_tf\_bucket\_name) | The name of a GCS bucket to create for Terraform state storage. This name must be<br>unique in GCP. If blank, (the default), the name will be 'tf-PROJECT\_ID', where<br>PROJECT\_ID is the unique project identifier. | `string` | `""` | no |
| <a name="input_tf_sa_creds_secret_id"></a> [tf\_sa\_creds\_secret\_id](#input\_tf\_sa\_creds\_secret\_id) | The unique identifier to use for Terraform credential store in Secret Manager.<br>Default is 'terraform-creds'. | `string` | `"terraform-creds"` | no |
| <a name="input_tf_sa_creds_secret_readers"></a> [tf\_sa\_creds\_secret\_readers](#input\_tf\_sa\_creds\_secret\_readers) | A list of accounts that will be granted read-only access to the Terraform JSON<br>credentials in Secret Manager. Default is an empty list. Terraform fully<br>supports impersonation; prefer `tf_sa_impersonate_groups` to add groups<br>permitted to impersonate Terraform SA.<br><br>NOTE: this variable is less opinionated and is a raw list of accounts that will<br>be granted read-only access; each account must be prefixed with 'group:',<br>'serviceAccount:', or 'user:' as appropriate.<br><br>E.g.<br>tf\_sa\_creds\_secret\_readers = [<br>  "group:devsecops@example.com",<br>  "serviceAccount:my-service@PROJECT\_ID.iam.gserviceaccount.com",<br>  "user:jane\_doe@example.com",<br>] | `list(string)` | `[]` | no |
| <a name="input_tf_sa_impersonators"></a> [tf\_sa\_impersonators](#input\_tf\_sa\_impersonators) | A list of fully-qualified IAM accounts that will be allowed to impersonate the<br>Terraform service account. If no accounts are supplied, impersonation will not<br>be setup by the script.<br>E.g.<br>tf\_sa\_impersonators = [<br>  "group:devsecops@example.com",<br>  "group:admins@example.com",<br>  "user:jane@example.com",<br>  "serviceAccount:ci-cd@project.iam.gserviceaccount.com",<br>] | `list(string)` | `[]` | no |
| <a name="input_tf_sa_name"></a> [tf\_sa\_name](#input\_tf\_sa\_name) | The name of the Terraform service account to add to the project. Default is<br>'terraform'. | `string` | `"terraform"` | no |
| <a name="input_tf_sa_roles"></a> [tf\_sa\_roles](#input\_tf\_sa\_roles) | A list of IAM roles to assign to the Terraform service account. Defaults to a set<br>needed to manage Compute resources, GCS buckets, IAM, and Secret Manager assignments. | `list(string)` | <pre>[<br>  "roles/compute.admin",<br>  "roles/iam.serviceAccountAdmin",<br>  "roles/iam.serviceAccountKeyAdmin",<br>  "roles/iam.serviceAccountTokenCreator",<br>  "roles/storage.admin",<br>  "roles/resourcemanager.projectIamAdmin",<br>  "roles/iam.serviceAccountUser",<br>  "roles/secretmanager.admin",<br>  "roles/iam.roleAdmin"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_sa"></a> [ansible\_sa](#output\_ansible\_sa) | The fully-qualified Ansible service account identifier. |
| <a name="output_ansible_sa_secret_id"></a> [ansible\_sa\_secret\_id](#output\_ansible\_sa\_secret\_id) | The unique secret ID to access Ansible JSON credentials. |
| <a name="output_tf_sa"></a> [tf\_sa](#output\_tf\_sa) | The fully-qualified Terraform service account identifier. |
| <a name="output_tf_sa_secret_id"></a> [tf\_sa\_secret\_id](#output\_tf\_sa\_secret\_id) | The unique secret ID to access Terraform JSON credentials. |
| <a name="output_tf_state_bucket"></a> [tf\_state\_bucket](#output\_tf\_state\_bucket) | The GCS bucket that will hold Terraform state. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html -->
