module "key_vault" {
  source = "git@github.com:mitchellmooreuk/terraform-modules.git//azure-keyvault?ref=v1.6.1"

  application_name    = var.application_name
  location            = var.location
  resource_group_name = azurerm_resource_group.homelab.name
  tenant_id           = var.tenant_id
  tags                = local.base_tags
  global_settings     = local.global_settings

  sku_name = "standard"
}
