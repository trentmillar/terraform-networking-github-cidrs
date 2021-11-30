# Providers
# https://www.terraform.io/docs/configuration/terraform.html
# https://www.terraform.io/docs/configuration/providers.html
# https://www.terraform.io/docs/configuration/expressions.html
# https://www.terraform.io/docs/configuration/functions.html

terraform { required_version = ">= 0.14.0" }

# Variables
# https://www.terraform.io/docs/configuration/variables.html
# https://www.terraform.io/docs/configuration/types.html

# Locals
# https://www.terraform.io/docs/configuration/locals.html

# Data Sources
# https://www.terraform.io/docs/configuration/data-sources.html

# Modules and Resources
# https://www.terraform.io/docs/configuration/modules.html
# https://www.terraform.io/docs/configuration/resources.html

module "ten" {
  source = "../"

  cidr_type        = "actions"
  cidr_count_limit = 10
}

# Outputs
# https://www.terraform.io/docs/configuration/outputs.html
