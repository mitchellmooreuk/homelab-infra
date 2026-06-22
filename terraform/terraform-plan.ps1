#!/usr/bin/env pwsh
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$nodeName,

    [Parameter(Mandatory=$true)]
    [string]$keyVaultName,

    [Parameter(Mandatory=$true)]
    [string]$resourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$storageAccountName
)

# Disclaimer: This script was generated with AI. It was reviewed and edited by Mitchell Moore.

$ErrorActionPreference = "Stop"

$currentIp = $(curl -s https://ifconfig.me)

az storage account network-rule add `
  --resource-group $ResourceGroupName `
  --account-name $StorageAccountName `
  --ip-address $currentIp

az keyvault network-rule add `
  --name $KeyVaultName `
  --ip-address $currentIp

Write-Host "=== Fetching configuration and credentials from Azure Key Vault ===" -ForegroundColor Cyan

$backendContainer = az keyvault secret show --name "backend-container-name" --vault-name $KeyVaultName --query value -o tsv
$backendKey       = az keyvault secret show --name "backend-state-key-$nodeName" --vault-name $KeyVaultName --query value -o tsv
$ApiToken         = az keyvault secret show --name "$nodeName-api-token" --vault-name $KeyVaultName --query value -o tsv
$tenantId         = az keyvault secret show --name "tenant-id" --vault-name $KeyVaultName --query value -o tsv

Write-Host "✓ All secrets fetched" -ForegroundColor Green

Write-Host "=== Initializing Terraform with Dynamic Backend ===" -ForegroundColor Cyan
terraform init -reconfigure `
  -backend-config="resource_group_name=$ResourceGroupName" `
  -backend-config="storage_account_name=$StorageAccountName" `
  -backend-config="container_name=$backendContainer" `
  -backend-config="key=$backendKey" `
  -backend-config="use_azuread_auth=true"

Write-Host "=== Running Terraform Plan ===" -ForegroundColor Cyan
terraform plan `
  -var-file="$nodeName.tfvars" `
  -out="tfplan" `
  -var="pve_api_token=$ApiToken" `
  -var="tenant_id=$tenantId"