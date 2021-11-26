# Variables
# https://www.terraform.io/docs/configuration/variables.html
# https://www.terraform.io/docs/configuration/types.html

variable "cidr_count_limit" {
  type        = number
  description = "(optional, default=200) Constrains the CIDRs returned. If there are more CIDRs than this limit CIDRs will be rolled up in Class B or A ranges"
  default     = 200 # maximum ip networking rules allowed for a Storage Account
}

variable "cidr_type" {
  type        = string
  description = "(optional, default=\"actions\") Options are; \"actions\", \"api\", \"hooks\", \"web\", \"git\", \"packages\", \"pages\", \"importer\", \"packages\", \"dependabot\". Specify the service CIDR's returned"
  default     = "actions"
}
