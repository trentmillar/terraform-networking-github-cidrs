# Providers
# https://www.terraform.io/docs/configuration/terraform.html
# https://www.terraform.io/docs/configuration/providers.html
# https://www.terraform.io/docs/configuration/expressions.html
# https://www.terraform.io/docs/configuration/functions.html

terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 2.1"
    }
  }
}

# Variables
# https://www.terraform.io/docs/configuration/variables.html
# https://www.terraform.io/docs/configuration/types.html


# Data Sources
# https://www.terraform.io/docs/configuration/data-sources.html

data "http" "cidrs" {
  url = "https://api.github.com/meta"
  request_headers = {
    Accept = "application/json"
  }
}

# Modules and Resources
# https://www.terraform.io/docs/configuration/modules.html
# https://www.terraform.io/docs/configuration/resources.html


# Locals
# https://www.terraform.io/docs/configuration/locals.html

locals {
  cidr_types = ["actions", "api", "hooks", "web", "git", "packages", "pages", "importer", "packages", "dependabot"]

  # throw exception if invalid type
  noop = index(local.cidr_types, var.cidr_type)

  # all the possible GitHub cidr ranges 
  github_cidrs = [for ip in jsondecode(data.http.cidrs.body)[var.cidr_type] :
    ip if length(regexall("(([0-9]{0,3})(\\.|(\\/[0-9]{0,2})$)){4}", ip)) == 1
  ]

  # class A's are too broad - using class B's instead
  class_As = { for k, v in {
    for cidr in distinct([for cidr in local.github_cidrs : regex("^\\d{1,3}", cidr)]) : cidr => []
    } : k => [
    for cidr in local.github_cidrs : cidr if regex("^\\d{1,3}", cidr) == k
  ] }

  # create all the class B's based on the GitHub Action CIDRs
  class_Bs = { for k, v in {
    for cidr in distinct([for cidr in local.github_cidrs : regex("(^(\\d{1,3}|\\.){3})", cidr)[0]]) : cidr => []
    } : k => [
    for cidr in local.github_cidrs : cidr if regex("(^(\\d{1,3}|\\.){3})", cidr)[0] == k
  ] }

  # if the offset is <=0 then we have room in the Stg.Act. FW to fit all the class B's  
  offset = length(local.class_Bs) - var.cidr_count_limit

  # find the class B's that can roll up to a class A to fit into the FW
  drops = local.offset >= 0 ? [for k, v in {
    for e in [for e in keys(local.class_Bs) : e] : regex("^\\d{1,3}", e) => regex("^\\d{1,3}", e)...
  } : k if length(v) > local.offset] : []

  # create the cidrs that will fit into the FW's allowed IPs
  cidrs = length(local.drops) == 0 ? {
    for k, v in local.class_Bs : format("%s.0.0/16", k) => 1
    } : (
    merge({
      for k, v in local.class_Bs : format("%s.0.0/16", k) => 1 if regex("^\\d{1,3}", k) != regex("^\\d{1,3}", element(local.drops, length(local.drops) - 1))
      }, {
      format("%s.0.0.0/8", regex("^\\d{1,3}", element(local.drops, length(local.drops) - 1))) = 1
    })
  )
}
