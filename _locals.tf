locals {
  suffix = join("-", [var.environment, local.short_location, random_integer.unique_id.result])

  global_settings = merge({
    environment = try(var.global_settings.environment, var.environment)
    passthrough = try(var.global_settings.passthrough, false)
    prefixes    = try(var.global_settings.prefixes, null)
    suffixes    = try(var.global_settings.suffixes, [local.suffix])

    random_length = try(var.global_settings.random_length, 0)
    regions       = try(var.global_settings.regions, null)
    tags          = try(var.global_settings.tags, var.tags)
    use_slug      = try(var.global_settings.use_slug, true)
  }, var.global_settings)

  short_location = try(local.short_locations[var.location], var.location)

  short_locations = {
    eastus         = "eus"
    eastus2        = "eus2"
    westus         = "wus"
    westus2        = "wus2"
    westeurope     = "weu"
    easteurope     = "eeu"
    southcentralus = "scus"
    uksouth        = "uks"
    ukwest         = "ukw"
  }

  base_tags = merge({
    "Terraform"   = true
    "Environment" = local.global_settings.environment
    "Owner"       = var.owner
    "Application" = "Homelab Infrastructure"
  })
}

resource "random_integer" "unique_id" {
  min = 3
  max = 3
}
