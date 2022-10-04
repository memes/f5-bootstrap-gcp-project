variable "project_id" {
  type        = string
  description = <<EOD
The existing project id that will have a Terraform service account added.
EOD
}

variable "tf_sa_name" {
  type        = string
  default     = "terraform"
  description = <<EOD
The name of the Terraform service account to add to the project. Default is
'terraform'.
EOD
}

variable "tf_sa_impersonators" {
  type        = list(string)
  default     = []
  description = <<EOD
A list of fully-qualified IAM accounts that will be allowed to impersonate the
Terraform service account. If no accounts are supplied, impersonation will not
be setup by the script.
E.g.
tf_sa_impersonators = [
  "group:devsecops@example.com",
  "group:admins@example.com",
  "user:jane@example.com",
  "serviceAccount:ci-cd@project.iam.gserviceaccount.com",
]
EOD
}

variable "tf_bucket_name" {
  type        = string
  default     = ""
  description = <<EOD
The name of a GCS bucket to create for Terraform state storage. This name must be
unique in GCP. If blank, (the default), the name will be 'tf-PROJECT_ID', where
PROJECT_ID is the unique project identifier.
EOD
}

variable "tf_bucket_location" {
  type        = string
  default     = "US"
  description = <<EOD
The location where the bucket will be created; this could be a GCE region, or a
dual-region or multi-region specifier. Default is to create a multi-region bucket
in 'US'.
EOD
}

variable "apis" {
  type = list(string)
  default = [
    "compute.googleapis.com",
    "iap.googleapis.com",
    "oslogin.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
  ]
  description = <<EOD
An optional list of GCP APIs to enable in the project.
EOD
}

variable "tf_sa_roles" {
  type = list(string)
  default = [
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/storage.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/secretmanager.admin",
    "roles/iam.roleAdmin",
  ]
  description = <<EOD
A list of IAM roles to assign to the Terraform service account. Defaults to a set
needed to manage Compute resources, GCS buckets, IAM, and Secret Manager assignments.
EOD
}

variable "oslogin_accounts" {
  type        = list(string)
  default     = []
  description = <<EOD
A list of fully-qualified IAM accounts that will be allowed to use OS Login to
VMs.
E.g.
oslogin_accounts = [
  "group:devsecops@example.com",
  "group:admins@example.com",
  "user:jane@example.com",
]
EOD
}

variable "ansible_sa_name" {
  type        = string
  default     = "ansible"
  description = <<EOD
The name of the Ansible service account to add to the project. Default is
'ansible'.
EOD
}

variable "ansible_sa_impersonate_groups" {
  type        = list(string)
  default     = []
  description = <<EOD
A list of groups that will be allowed to impersonate the Ansible service account.
If no groups are supplied, impersonation will not be setup by the script.
E.g.
ansible_sa_impersonate_groups = [
  "devsecops@example.com",
  "admins@example.com",
]
EOD
}

variable "ansible_sa_roles" {
  type = list(string)
  default = [
    "roles/compute.viewer",
    "roles/compute.osLogin",
  ]
  description = <<EOD
A list of IAM roles to assign to the Terraform service account. Defaults to a set
needed to manage Compute resources, GCS buckets, and IAM assignments.
EOD
}
