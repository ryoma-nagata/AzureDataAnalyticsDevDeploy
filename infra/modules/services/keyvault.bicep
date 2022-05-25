param location string
param keyvaultName string
param tags object
param virtualNetworkRules array
param keyvaultIPWhiteLists array 

resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyvaultName
  tags:tags
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: keyvaultIPWhiteLists
      virtualNetworkRules:virtualNetworkRules
    }
    enableRbacAuthorization:true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays:90
    enablePurgeProtection:true
  }

  
}

output keyvaultId string =  keyvault.id
output keyvaultUri string = keyvault.properties.vaultUri
output keyvaultProperty object = keyvault.properties
