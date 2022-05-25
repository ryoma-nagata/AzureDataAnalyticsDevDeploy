param location string
param sqlServerName string
param sqlDatabaseName string

param allowSubnetIds array 


param sqlIPWhiteLists array 


param sqlAdministratorLogin string 
@secure()
param sqlAdministratorLoginPassword string

@description('日本語環境での推奨値です')
param collation string = 'Japanese_XJIS_100_CI_AS'
param tags object



resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    
  }
}



resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 4
  }
  properties: {
    collation: collation
    maxSizeBytes: 268435456000
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 60    
  }
}

resource sqlServerSecurityAlertPolicies 'Microsoft.Sql/servers/securityAlertPolicies@2017-03-01-preview' = {
  parent: sqlServer
  name: 'Default'
  properties: {
    state: 'Enabled'
    emailAccountAdmins: false
  }
}



resource sqlServerVirtualNetworkRules 'Microsoft.Sql/servers/virtualNetworkRules@2015-05-01-preview' = [for id in allowSubnetIds: {
  parent: sqlServer
  name: last(split(id,'/'))
  properties: {
    virtualNetworkSubnetId: id
    ignoreMissingVnetServiceEndpoint: false
  }
}]


resource firewallRules 'Microsoft.Sql/servers/firewallRules@2021-05-01-preview' = [for sqlIPWhiteList in sqlIPWhiteLists: {
  name:sqlIPWhiteList.name
  parent:sqlServer
  properties:{
    startIpAddress: sqlIPWhiteList.startIpAddress
    endIpAddress: sqlIPWhiteList.endIpAddress
  }
}]


output sqlDatabaseId string = sqlDatabase.id
output sqlServerId string = sqlServer.id
output sqlServerPrincipalId string = sqlServer.identity.principalId
