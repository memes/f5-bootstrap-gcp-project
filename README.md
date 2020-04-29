# Terraform bootstrap

This repo is used to prepare existing F5 GCP projects for Terraform automation.
During execution the script will create these resources:

1. Terraform GCS bucket for remote state
1. Enables Compute Engine and IAP APIs by default
1. A service account to use for Terraform automation
   - with storage admin rights on Terraform state bucket
   - with an extendible set of roles at project
   - with optional impersonation enabled for AD group(s)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |
| google | ~> 3.14 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.14 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apis | An optional list of GCP APIs to enable in the project. | `list(string)` | <pre>[<br>  "compute.googleapis.com",<br>  "iap.googleapis.com",<br>  "oslogin.googleapis.com",<br>  "iam.googleapis.com",<br>  "iamcredentials.googleapis.com"<br>]</pre> | no |
| oslogin\_groups | A list of groups that will be allowed to use OS Login to VMs.<br>E.g.<br>oslogin\_groups = [<br>  "devsecops@example.com",<br>  "admins@example.com",<br>] | `list(string)` | `[]` | no |
| project\_id | The existing project id that will have a Terraform service account added. | `string` | n/a | yes |
| tf\_bucket\_location | The location where the bucket will be created; this could be a GCE region, or a<br>dual-region or multi-region specifier. Default is to create a multi-region bucket<br>in 'US'. | `string` | `"US"` | no |
| tf\_bucket\_name | The name of a GCS bucket to create for Terraform state storage. This name must be<br>unique in GCP. If blank, (the default), the name will be 'tf-PROJECT\_ID', where<br>PROJECT\_ID is the unique project identifier. | `string` | `""` | no |
| tf\_sa\_impersonate\_groups | A list of groups that will be allowed to impersonate the Terraform service account.<br>If no groups are supplied, impersonation will not be setup by the script.<br>E.g.<br>tf\_sa\_impersonate\_groups = [<br>  "devsecops@example.com",<br>  "admins@example.com",<br>] | `list(string)` | `[]` | no |
| tf\_sa\_name | The name of the service account to add to the project. Default is 'terraform'. | `string` | `"terraform"` | no |
| tf\_sa\_roles | A list of IAM roles to assign to the Terraform service account. Defaults to a set<br>needed to manage Compute resources, GCS buckets, and IAM assignments. | `list(string)` | <pre>[<br>  "roles/compute.admin",<br>  "roles/iam.serviceAccountAdmin",<br>  "roles/iam.serviceAccountKeyAdmin",<br>  "roles/iam.serviceAccountTokenCreator",<br>  "roles/storage.admin",<br>  "roles/resourcemanager.projectIamAdmin"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| tf\_sa | The fully-qualified Terraform service account identifier. |
| tf\_state\_bucket | The GCS bucket that will hold Terraform state. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
