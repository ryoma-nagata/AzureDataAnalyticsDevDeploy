param location string
param prefix string
param env string
param tags   object
var tagJoin = union(tags, {
  Group:'data apps'
})

// databricks
param isNeedDatabricks bool
var databricksName = '${prefix}-adb-${env}'
param customPrivateSubnetId string
param customPublicSubnetId string
param customVirtualNetworkId string

// datafactory
param isNeedDataFactory bool
var datafactoryName = '${prefix}-adf-${env}'

// SHIRforDataFactory
param isNeedSHIRforDataFactory bool
param runtimeSubnetId string
param vmsku string
param VMAdministratorLogin string 
@minLength(12)
@secure()
param VMAdministratorLoginPassword string
var shirName = 'shir001'
var shirPublicIPAddressName = '${prefix}-ir-ip-${env}'
var shirDnsLabal = replace('${prefix}ir${env}','-','')
var shirNicName = '${prefix}-ir-nic-${env}'
var shirVMName = replace('${prefix}ir${env}','-','')

// azureML
param isNeedMachineLearning bool
var machinelearningName = '${prefix}-ml-${env}'
var applicationinsightName = '${prefix}-mlai-${env}'
var containerRegistryName = '${prefix}-mlcr-${env}'
var amlStorageName = '${prefix}-mlst-${env}'
param WhiteListsCIDRRules array
param mlcomputeSubnetId string
param keyVaultId string

// synapse
param isNeedSynapse bool
var synapseName = '${prefix}-syn-${env}'

param workStorageAccountId string
param sqlAdministratorUsername string
@secure()
param sqlAdministratorPassword string
param AdminGroupName string = ''
param AdminGroupObjectID string 
param WhiteListsStartEndIPs array
param AllowAzure bool
param isDLPEnable bool
// sqlpool
param isNeedSqlPool bool
param collation string 
param sqlPoolBackupType string
param sqlPooldwu string
// SHIR
param isNeedSHIRforSynepse bool
var synshirName = 'shir001'
var synshirPublicIPAddressName = '${prefix}-sir-ip-${env}'
var synshirDnsLabal = replace('${prefix}sir${env}','-','')
var synshirNicName = '${prefix}-sir-nic-${env}'
var synshirVMName = replace('${prefix}sir${env}','-','')

// SQL DB
param isNeedSQL bool
var sqlServerName = '${prefix}-sql-${env}'
var sqlDatabaseName = '${prefix}-sqldb-${env}'

// powerbiGW
param isNeedVMforOnPremiseDataGateway bool
var powerbiGWPublicIPAddressName = '${prefix}-pbi-ip-${env}'
var powerbiGWDnsLabal = replace('${prefix}pbi${env}','-','')
var powerbiGWNicName = '${prefix}-pbi-nic-${env}'
var powerbiGWVMName = replace('${prefix}pbi${env}','-','')

// cognitiveservices
// param isNeedCognitiveServices bool
// var CognitiveServicesName =  '${prefix}-cog-${env}'

module databricks 'services/databricks.bicep' = if (isNeedDatabricks == true) {
  name: databricksName
  params: {
    customPrivateSubnetName: last(split(customPrivateSubnetId,'/'))
    customPublicSubnetName: last(split(customPublicSubnetId,'/'))
    customVirtualNetworkId: customVirtualNetworkId
    databricksWorkspaceName:databricksName 
    location: location
    tags: tagJoin
  }
}
module datafactory 'services/datafactory.bicep' = if (isNeedDataFactory == true) {
  name: datafactoryName
  params: {
    datafactoryName: datafactoryName
    location: location
    selfhostedIRName: shirName
    tags:tagJoin
    isNeedSHIRforDataFactory:isNeedSHIRforDataFactory
    shirDnsLabal:shirDnsLabal
    shirNicName:shirNicName
    shirPublicIPAddressName:shirPublicIPAddressName
    shirSubnetId:runtimeSubnetId
    shirVMName:shirVMName
    VMAdministratorLogin:VMAdministratorLogin
    VMAdministratorLoginPassword:VMAdministratorLoginPassword
    vmsku:vmsku
  }
}

module machinelearning 'services/machinelearning.bicep' =  if (isNeedMachineLearning == true){
  name: 'machinelearning'
  params: {
    location: location
    tags: tagJoin
    WorkspaceName: machinelearningName
    amlStorageName: amlStorageName
    mlcomputeSubnetId: mlcomputeSubnetId
    databricksSubnetId:customPublicSubnetId
    storageIPWhiteLists: WhiteListsCIDRRules
    applicationinsightName: applicationinsightName
    containerRegistryName: containerRegistryName
    keyVaultId: keyVaultId
  }
}

module synapse 'services/synapse.bicep' = if (isNeedSynapse == true) {
  name: 'synapse'
  params: {
    location: location
    tags:tagJoin
    synapseDefaultStorageAccountId:workStorageAccountId
    // workspace
    synapseName: synapseName
    AllowAzure:AllowAzure
    WhiteListsStartEndIPs:WhiteListsStartEndIPs
    administratorUsername:sqlAdministratorUsername
    administratorPassword:sqlAdministratorPassword
    isDLPEnable:isDLPEnable
    // sqlpool
    isNeedSqlPool:isNeedSqlPool
    sqlPoolBackupType:sqlPoolBackupType
    sqlPooldwu:sqlPooldwu
    synapseSqlAdminGroupName:AdminGroupName
    synapseSqlAdminGroupObjectID:AdminGroupObjectID
    collation:collation
    // SHIR
    isNeedSHIRforSynepse : isNeedSHIRforSynepse
    selfhostedIRName:synshirName
    shirDnsLabal:synshirDnsLabal
    shirNicName:synshirNicName
    shirPublicIPAddressName:synshirPublicIPAddressName
    shirSubnetId:runtimeSubnetId
    shirVMName:synshirVMName
    VMAdministratorLogin:VMAdministratorLogin
    VMAdministratorLoginPassword:VMAdministratorLoginPassword
    vmsku:vmsku

  }
}

module sql 'services/sqlserverless.bicep' =  if (isNeedSQL == true){
  name: 'sql'
  params: {
    allowSubnetIds: [
      mlcomputeSubnetId
      customPublicSubnetId
      runtimeSubnetId
    ]
    location: location
    sqlAdministratorLogin: sqlAdministratorUsername
    sqlAdministratorLoginPassword: sqlAdministratorPassword
    sqlDatabaseName: sqlDatabaseName
    sqlIPWhiteLists: WhiteListsStartEndIPs
    sqlServerName: sqlServerName
    tags: tagJoin
    collation:collation
    sqlAdminGroupName:AdminGroupName
    sqlAdminGroupObjectID:AdminGroupObjectID
  }
}


module pbigw 'services/runtime.bicep' =  if (isNeedVMforOnPremiseDataGateway == true){
  name: 'pbigw'
  params: {
    adminPassword: VMAdministratorLoginPassword
    adminUsername: VMAdministratorLogin
    location: location
    nicName: powerbiGWNicName
    publicIpName: powerbiGWPublicIPAddressName
    subnetId: runtimeSubnetId
    tags: tagJoin
    vmName: powerbiGWVMName
    vmSize: vmsku
    dnsLabelPrefix:powerbiGWDnsLabal
    isSHIRMode:false
    publicIPAllocationMethod:'Dynamic'
    publicIpSku:'Basic'
    OSVersion:'2019-Datacenter'
  }
}

// module cognitiveServices 'services/cognitiveServices.bicep' = if (isNeedCognitiveServices == true){
//   name:'cognitiveServices'
//   params:{
//     location: location
//     tags: tagJoin
//     cognitiveAccountName: CognitiveServicesName
//   }
// }

output databricksId string = (isNeedDatabricks == true) ? databricks.outputs.databricksWorkspaceId : ''
output databricksWorkspaceUrl string =  (isNeedDatabricks == true) ? databricks.outputs.databricksWorkspaceUrl: ''
output datafactoryId string = (isNeedDataFactory == true) ? datafactory.outputs.datafactoryId : ''
output datafactoryPrincipalId string = (isNeedDataFactory == true) ? datafactory.outputs.datafactoryPrincipalId : ''
output synapseId string = (isNeedSynapse == true) ? synapse.outputs.synapseId : ''
output synapsePrincipalId string =  (isNeedSynapse == true) ? synapse.outputs.synapsePrincipalId : ''
output sparkPoolId string =  (isNeedSynapse == true) ?  synapse.outputs.sparkPoolId : ''
output machinelearningId string =  (isNeedMachineLearning == true) ? machinelearning.outputs.machinelearningWorkspaceId : ''
output containerRegistryId string = (isNeedMachineLearning == true) ? machinelearning.outputs.containerRegistryId : ''
output mlstorageId string =(isNeedMachineLearning == true) ? machinelearning.outputs.mlstorageId : ''
output machinelearningPrincipalId string = (isNeedSQL == true)? machinelearning.outputs.machinelearningPrincipalId : ''
output sqlServerId string = (isNeedSQL == true)? sql.outputs.sqlServerId : ''
output sqlServerPrincipalId string =  (isNeedSQL == true)? sql.outputs.sqlServerPrincipalId : ''
output sqlDatabaseId string = (isNeedSQL == true)? sql.outputs.sqlDatabaseId : ''
// output CognitiveServicesAccountId string = (isNeedCognitiveServices == true)?  cognitiveServices.outputs.CognitiveServicesAccountId: ''
