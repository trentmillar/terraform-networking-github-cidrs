terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 2.1"
    }
  }
}

module "github_action_cidrs" {
  source = "../../"

  cidr_type        = "actions"
  cidr_count_limit = 200
}

output "context" {
  value = module.github_action_cidrs.cidrs
}
