
param location string
param baseName string
param tags object

param storageIPWhiteLists array
param sqlIPWhiteLists array 

param vnetId string
param mlcomputeSubnetName string
param gatewaySubentName string
param adbPublicSubnetName string

param VMAdministratorLogin string
@secure()
param VMAdministratorLoginPassword string 
param vmsku string

param gatewaySubnetName string
var sqlServerName = '${toLower(baseName)}-sql'
var sqlDatabaseName = '${toLower(baseName)}-db'

var pbigwPublicIPAddressName = '${substring(toLower(baseName), 0, 7)}-pbi-ip'
var pbigwDnsLabal = '${substring(toLower(baseName), 0, 7)}-pbi'
var pbigwNicName = '${substring(toLower(baseName), 0, 7)}-pbi-nic'
var pbigwVMName = '${substring(toLower(baseName), 0, 7)}-pbi-vm'


param sqlAdministratorLogin string 
@secure()
param sqlAdministratorLoginPassword string

var mlcomputeSubnetId = '${vnetId}/subnets/${mlcomputeSubnetName}'
var gatewaySubentId = '${vnetId}/subnets/${gatewaySubentName}'
var adbPublicSubnetId =  '${vnetId}/subnets/${adbPublicSubnetName}'
 
var amlStorageName = '${replace(toLower(baseName), '-', '')}amlsa'
var kevalutName = '${baseName}-aml-kv'
var applicationinsightName = '${baseName}-aml-ai'
var containerRegistoryName = '${replace(toLower(baseName), '-', '')}amlcr'
var amlWorkspaceName = '${toLower(baseName)}-aml-ws'


module amlStorage 'module_service_storage.bicep' = {
  name: amlStorageName
  params: {
    tags:tags
    fileSystemNames: []
    isHnsEnabled: false
    location: location
    storageIPWhiteLists: storageIPWhiteLists
    storageName: amlStorageName
    storageSKU: 'Standard_RAGRS'
    virtualNetworkRules: [
      {
        id: mlcomputeSubnetId
        action: 'Allow'
      }
    ]
    isNeedAMLResourceAccessrules: true
  }
}
module amlApplicationInsight 'module_service_applicationinsight.bicep' = {
  name: applicationinsightName
  params: {
    tags:tags
    applicationinsightName: applicationinsightName
    location: location
  }
}

module amlContainerRegistory 'module_service_containerregistry.bicep' = {
  name: containerRegistoryName
  params: {
    tags:tags
    containerRegistoryName: containerRegistoryName
    location: location
  }
}

module amlKeyvault 'module_service_keyvault.bicep' = {
  name: kevalutName
  params: {
    tags:tags
    accessPolicies: []
    keyvaultName: kevalutName
    location: location
    virtualNetworkRules:[]
    storageIPWhiteLists:storageIPWhiteLists
  }
}


module machinelearning 'module_service_machinelearning.bicep' = {
  name: amlWorkspaceName
  params: {
    tags:tags
    applicationInsightsId: amlApplicationInsight.outputs.applicationinsightId
    containerRegistryId: amlContainerRegistory.outputs.containerRegistoryId
    keyVaultId: amlKeyvault.outputs.keyvaultId
    location: location
    storageAccountId: amlStorage.outputs.storageId
    WorkspaceName:amlWorkspaceName
  }
}

module sql 'module_service_sqlserverless.bicep' ={
  name: 'sql'
  params: {
    tags:tags
    allowSubnetIds: [
      {
        name:gatewaySubentName
        id:gatewaySubentId
      }
      {
        name:adbPublicSubnetName
        id:adbPublicSubnetId
      }
      {
        name:mlcomputeSubnetName
        id:mlcomputeSubnetId
      }
    ]
    location: location
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    sqlDatabaseName: sqlDatabaseName
    sqlIPWhiteLists: sqlIPWhiteLists
    sqlServerName: sqlServerName
  }
}

module powerbiGatewayvm 'module_service_gateway.bicep' ={
  name: pbigwVMName
  params: {
    tags:tags
    adminPassword: VMAdministratorLoginPassword
    adminUsername: VMAdministratorLogin
    location: location
    nicName: pbigwNicName
    dnsLabelPrefix:pbigwDnsLabal
    publicIpName: pbigwPublicIPAddressName
    subnetId: '${vnetId}/subnets/${gatewaySubnetName}'
    vmName: pbigwVMName
    vmSize: vmsku
    OSVersion:'2019-Datacenter'
  }
}

output amlStorageId string = amlStorage.outputs.storageId
output amlWorkspaceId string = machinelearning.outputs.machinelearningWorkspaceId
output sqlServerId string = sql.outputs.sqlServerId
output sqlDatabaseId string = sql.outputs.sqlDatabaseId
output sqlServerPrincipalId string = sql.outputs.sqlServerPrincipalId
output amlkeyvaultId string = amlKeyvault.outputs.keyvaultId
