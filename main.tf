# This module adds a Terraform and an Ansible service account to the project,
# and allows members of a group to impersonate the account.
terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.56"
    }
  }
}

locals {
  labels = merge({
    module = "bootstrap-gcp-sales-project"
    owner  = "m_dot_emes_at_f5_dot_com"
  }, var.labels)
  zones = toset([for z in var.domains : lower(trimsuffix(z, "."))])
}

# Enable any GCP APIs needed
resource "google_project_service" "apis" {
  for_each = toset(var.apis)
  project  = var.project_id
  service  = each.value
  # Shared project - don't disable the API on destroy in case someone else has
  # a dependency on it
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Create the Terraform service account
resource "google_service_account" "tf" {
  project      = var.project_id
  account_id   = coalesce(var.tf_sa_name, "terraform")
  display_name = "Emes Terraform automation service account"
  description  = "Service account for Terraform automation. Contact m.emes@f5.com for details."
  depends_on = [
    google_project_service.apis,
  ]
}

locals {
  # The email address for TF and Ansible service account is predictable so we
  # can use it where needed without introducing a cyclic dependency.
  tf_sa_email          = format("%s@%s.iam.gserviceaccount.com", coalesce(var.tf_sa_name, "terraform"), var.project_id)
  tf_sa_id             = format("projects/%s/serviceAccounts/%s", var.project_id, local.tf_sa_email)
  tf_sa_iam_email      = format("serviceAccount:%s", local.tf_sa_email)
  ansible_sa_email     = format("%s@%s.iam.gserviceaccount.com", coalesce(var.ansible_sa_name, "ansible"), var.project_id)
  ansible_sa_id        = format("projects/%s/serviceAccounts/%s", var.project_id, local.ansible_sa_email)
  ansible_sa_iam_email = format("serviceAccount:%s", local.ansible_sa_email)
}

# Bind the impersonation privileges to the Terraform service account if group
# list is not empty.
resource "google_service_account_iam_member" "tf_impersonate_user" {
  for_each           = toset(var.tf_sa_impersonators)
  service_account_id = local.tf_sa_id
  role               = "roles/iam.serviceAccountUser"
  member             = each.value
  depends_on = [
    google_project_service.apis,
    google_service_account.tf,
  ]
}

resource "google_service_account_iam_member" "tf_impersonate_token" {
  for_each           = toset(var.tf_sa_impersonators)
  service_account_id = local.tf_sa_id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
  depends_on = [
    google_project_service.apis,
    google_service_account.tf,
  ]
}

# Create a bucket for Terraform state
resource "google_storage_bucket" "tf_bucket" {
  project  = var.project_id
  name     = coalesce(var.tf_bucket_name, format("tf-%s", var.project_id))
  location = var.tf_bucket_location
  versioning {
    enabled = false
  }
  labels = local.labels
  depends_on = [
    google_project_service.apis,
  ]
}

# Allow the Terraform service account and impersonators to be a storage admin on
# the bucket
#
# NOTE: this does not change associations of other members
resource "google_storage_bucket_iam_member" "tf_bucket_admin" {
  for_each = toset(concat([local.tf_sa_iam_email], var.tf_sa_impersonators))
  bucket   = google_storage_bucket.tf_bucket.name
  role     = "roles/storage.admin"
  member   = each.value
  depends_on = [
    google_project_service.apis,
    google_service_account.tf,
  ]
}

# Assign IAM roles to Terraform service account
#
# NOTE: all these are additive, and will not unassign existing IAM privileges
resource "google_project_iam_member" "tf_sa_roles" {
  for_each = toset(var.tf_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = local.tf_sa_iam_email
  depends_on = [
    google_project_service.apis,
    google_service_account.tf,
  ]
}

# Allow these accounts to use OS Login
resource "google_project_iam_member" "oslogin" {
  for_each = toset(var.oslogin_accounts)
  project  = var.project_id
  role     = "roles/compute.osLogin"
  member   = each.value
  depends_on = [
    google_project_service.apis,
  ]
}

# Create a service account for Ansible
resource "google_service_account" "ansible" {
  project      = var.project_id
  account_id   = coalesce(var.ansible_sa_name, "ansible")
  display_name = "Emes Ansible automation service account"
  description  = "Service account for Ansible automation. Contact m.emes@f5.com for details."
  depends_on = [
    google_project_service.apis,
  ]
}

# Assign IAM roles to Ansible service account
#
# NOTE: all these are additive, and will not unassign existing IAM privileges
resource "google_project_iam_member" "ansible_sa_roles" {
  for_each = toset(var.ansible_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = local.ansible_sa_iam_email
  depends_on = [
    google_project_service.apis,
    google_service_account.ansible,
  ]
}

# OIDC federation for GitHub actions: this bootstrap repo will setup an identity
# pool with a valid
# Add an identity pool for federation if GitHu
resource "google_iam_workload_identity_pool" "automation" {
  count                     = try(var.workload_identity.github, false) ? 1 : 0
  project                   = var.project_id
  workload_identity_pool_id = "emes-automation-pool"
  display_name              = "Emes Automation Pool"
  description               = "Defines a pool of third-party providers that can exchange tokens for automation purposes. Contact m.emes@f5.com for details."
  disabled                  = false
  depends_on = [
    google_project_service.apis,
  ]
}

# Bind the Terraform service account to the workload identity
# principals where the custom attribute 'terraform' is set to true.
resource "google_service_account_iam_member" "bind_tf_workload_identity" {
  for_each           = toset([for pool in google_iam_workload_identity_pool.automation : pool.name])
  service_account_id = google_service_account.tf.name
  member             = format("principalSet://iam.googleapis.com/%s/attribute.terraform/true", each.value)
  role               = "roles/iam.workloadIdentityUser"
}

# Bind the Ansible service account to the workload identity
# principals where the custom attribute 'terraform' is set to true.
resource "google_service_account_iam_member" "bind_ansible_workload_identity" {
  for_each           = toset([for pool in google_iam_workload_identity_pool.automation : pool.name])
  service_account_id = google_service_account.ansible.name
  member             = format("principalSet://iam.googleapis.com/%s/attribute.ansible/true", each.value)
  role               = "roles/iam.workloadIdentityUser"
}

# Add an OIDC provider for GitHub
resource "google_iam_workload_identity_pool_provider" "github_oidc" {
  for_each                           = toset([for pool in google_iam_workload_identity_pool.automation : pool.workload_identity_pool_id if try(var.workload_identity.github, false)])
  project                            = var.project_id
  workload_identity_pool_id          = each.value
  workload_identity_pool_provider_id = "emes-github-provider"
  display_name                       = "Emes GitHub OIDC"
  description                        = "Provider for GitHub automation through OIDC token exchange. Contact m.emes@f5.com for details."
  attribute_mapping = {
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
    "attribute.owner"      = "assertion.repository_owner"
    "google.subject"       = "assertion.sub"
    # Allow GitHub actions to use both Terraform and Ansible service accounts
    "attribute.terraform" = "true"
    "attribute.ansible"   = "true"
  }
  attribute_condition = "attribute.owner in ['memes', 'f5devcentral']"
  oidc {
    # TODO @memes - the effect of an empty list is to impose a match against the
    # fully-qualified workload identity pool name. This should be sufficient but
    # review.
    allowed_audiences = []
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
  depends_on = [
    google_project_service.apis,
  ]
}

# Add an OIDC provider for Terraform Cloud/TFE
resource "google_iam_workload_identity_pool_provider" "terraform_oidc" {
  for_each                           = toset([for pool in google_iam_workload_identity_pool.automation : pool.workload_identity_pool_id if try(var.workload_identity.terraform, false)])
  project                            = var.project_id
  workload_identity_pool_id          = each.value
  workload_identity_pool_provider_id = "emes-terraform-provider"
  display_name                       = "Emes Terraform Cloud/TFE OIDC"
  description                        = "Provider for Terraform Cloud/TFE automation through OIDC token exchange. Contact m.emes@f5.com for details."
  attribute_mapping = {
    "attribute.aud"                         = "assertion.aud",
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
    "attribute.terraform_project_id"        = "assertion.terraform_project_id",
    "attribute.terraform_project_name"      = "assertion.terraform_project_name",
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
    "attribute.terraform_run_id"            = "assertion.terraform_run_id",
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
    "google.subject"                        = "assertion.sub"
    # Limit Terraform Cloud/TFE actions to Terraform service account only
    "attribute.terraform" = "true"
    "attribute.ansible"   = "false"
  }
  attribute_condition = "attribute.terraform_organization_name in ['memes', 'f5-memes', 'acceleratedgcp']"
  oidc {
    # TODO @memes - the effect of an empty list is to impose a match against the
    # fully-qualified workload identity pool name. This should be sufficient but
    # review.
    allowed_audiences = []
    issuer_uri        = "https://app.terraform.io"
  }
  depends_on = [
    google_project_service.apis,
  ]
}

# Add Public Cloud DNS zone for each unique domain
resource "google_dns_managed_zone" "zone" {
  for_each    = local.zones
  project     = var.project_id
  name        = format("public-%s", replace(each.value, "/[^a-z0-9-]/", "-"))
  dns_name    = format("%s.", each.value)
  description = "Bootstrapped DNS zone with DNSSEC"
  dnssec_config {
    kind          = "dns#managedZoneDnsSecConfig"
    state         = "on"
    non_existence = "nsec3"
    default_key_specs {
      kind       = "dns#dnsKeySpec"
      algorithm  = "rsasha256"
      key_length = 2048
      key_type   = "keySigning"
    }
    default_key_specs {
      kind       = "dns#dnsKeySpec"
      algorithm  = "rsasha256"
      key_length = 1024
      key_type   = "zoneSigning"
    }
  }
  visibility = "public"
  labels     = local.labels
  depends_on = [
    google_project_service.apis,
  ]
}
