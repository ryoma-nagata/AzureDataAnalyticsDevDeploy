param location string

param keyvaultName string
param datafacotryPrincipalId  string
param AzureDatabricksId string
param devOpsAppId string
param adlsId string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string

param sqlDatabaseName string
@secure()
param sqlConnectionString string
param keyvaultProperty object
param sqlServerURL string
param armStId string

param baseTime string = utcNow('u')
var  armStgAccountSasProperties = {
  signedServices: 'b'
  signedPermission: 'acdlpruw'
  signedExpiry: dateTimeAdd(baseTime, 'P1Y')
  signedResourceTypes: 'co'
}

var joinedProperty= union(keyvaultProperty,{
  accessPolicies: [
    {
      tenantId: subscription().tenantId
      objectId: datafacotryPrincipalId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
    {
      tenantId: subscription().tenantId
      objectId: AzureDatabricksId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
    {
      tenantId: subscription().tenantId
      objectId: devOpsAppId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
  ]
})
    

resource keyvault 'Microsoft.KeyVault/vaults@2016-10-01'= {
  name: keyvaultName
  location:location
  properties:joinedProperty
}

resource secretsDatalakeKey 'Microsoft.KeyVault/vaults/secrets@2016-10-01' = {
  parent: keyvault
  name: 'datalakeKey'
  properties: {
    value: listKeys(adlsId, providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]).keys[0].value
    attributes: {
      enabled: true
    }
    contentType: 'Blob Storage Account Key'
  }
}

resource secretsSqladminId 'Microsoft.KeyVault/vaults/secrets@2016-10-01' = {
  parent: keyvault
  name: 'sqladminId'
  properties: {
    value: sqlAdministratorLogin
    attributes: {
      enabled: true
    }
    contentType: 'SQL Administorator Id'
  }
}

resource secretsSqlAdminPassword 'Microsoft.KeyVault/vaults/secrets@2016-10-01' = {
  parent: keyvault
  name: 'sqlAdminPassword'
  properties: {
    value: sqlAdministratorLoginPassword
    attributes: {
      enabled: true
    }
    contentType: 'SQL Administorator Password'
  }
}

resource secretsSqlConnectionString 'Microsoft.KeyVault/vaults/secrets@2016-10-01' = {
  parent: keyvault
  name: 'sqlConnectionString'
  properties: {
    value: sqlConnectionString
    attributes: {
      enabled: true
    }
    contentType: 'SQL Server Connection String'
  }
}

resource secretsARMStorageSaSToken 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  parent: keyvault
  name: 'ARMStorageSaSToken'
  properties: {
    value: '?${listAccountSas(armStId, '2018-07-01', armStgAccountSasProperties).accountSasToken}'
    contentType: 'ARM StageStorageAccount SAS Token'
  }
}

resource secretsSqlServerUrl 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  parent: keyvault
  name: 'sqlServerUrl'
  properties: {
    value: sqlServerURL
    contentType: 'SQL Server URL'
  }
}

resource secretsSqlDatabaseName 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  parent: keyvault
  name: 'sqlDatabaseName'
  properties: {
    value: sqlDatabaseName
    contentType: 'SQL Database Name'
  }
}

resource secretsDataLakeAccountName 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  parent: keyvault
  name: 'DataLakeAccountName'
  properties: {
    value: last(split(adlsId,'/'))
    contentType: 'DataLakeAccountName'
  }
}
