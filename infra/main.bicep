
targetScope = 'resourceGroup'

// general 
@description('リソースのデプロイリージョン')
@allowed([
  'southcentralus'
  'southeastasia'
  'japaneast'
])
param location string = 'japaneast'

@minLength(3)
@maxLength(7)
@description('リソース名はproject-deployment_id-リソース種類-envとなります')
param project string 
@allowed([
  'demo'
  'poc'
  'dev'
  'test'
  'prod'
  'stg'
])
@description('リソース名はproject-deployment_id-リソース種類-envとなります')
param env string 
@description('リソース名はproject-deployment_id-リソース種類-envとなります')
@maxLength(2)
param deployment_id string = '01'

var prefix  = toLower('${project}-${deployment_id}')

@description('セキュリティグループの名称を入力すると自動で権限が付与されます')
param AdminGroupName string = ''
@description('セキュリティグループのプリンシパルIDを入力すると自動で権限が付与されます')
param AdminGroupObjectID string = ''

@description('各VMのログインID')
param VMAdministratorLogin string 
@description('各VMのログインパスワード')
@minLength(12)
@secure()
param VMAdministratorLoginPassword string


// network
@description('Vnet範囲')
param addressPrefixs array = [
  '10.4.0.0/14'
]

@description('統合ランタイム、Power BI Gateway用VM用サブネット')
param runtimeSubnetPrefix string = '10.4.0.0/26'
@description('Private Endpoint用サブネット')
param privateEndpointSubnetPrefix string = '10.4.0.64/26'
@description('Azure ML用サブネット')
param mlcomputesSubnetPrefix string = '10.4.1.0/24'
@description('Databricks用 Publicサブネット')
param adbPublicSubnetPrefix string = '10.4.2.0/24'
@description('Databricks用 Privateサブネット')
param adbPrivateSubnetPrefix string = '10.4.3.0/24'

@description('許可したいIP開始終了の配列')
param WhiteListsStartEndIPs array = [
  {
    name : 'sampleAllIp'
    startIpAddress:'0.0.0.0'
    endIpAddress:'255.255.255.255' 
  }
]

@description('許可したいCIDR形式IPの配列')
param WhiteListsCIDRs array = [
  '*.*.*.*/*'
  '*.*.*.*'
]
var WhiteListsCIDRRules= [for CIDR in WhiteListsCIDRs:{
  value:CIDR
  action : 'allow'
}]

// databricks
@description('true の場合Databrikcsをデプロイします。')
@allowed([
  true
  false
])
param isNeedDatabricks bool = true
@description('databricks application のobject id')
param databricksAppObjectId string

// datafactory
@description('true の場合DataFactoryをデプロイします。')
@allowed([
  true
  false
])
param isNeedDataFactory bool= true
@description('true の場合DataFactory用セルフホステッド統合ランタイムをデプロイします。isNeedDataFactoryをFalseにした場合は無効です。')
@allowed([
  true
  false
])
param isNeedSHIRforDataFactory bool = false

// azureML
@description('true の場合Azure Machine Learningをデプロイします。')
@allowed([
  true
  false
])
param isNeedMachineLearning bool= true

// synapse
@description('true の場合Synapse Analyticsをデプロイします。')
@allowed([
  true
  false
])
param isNeedSynapse bool= true
@description('true の場合Syanpse workspaceのデータ流出保護を有効にします※一部機能に制限がかかります。')
@allowed([
  true
  false
])
param isDLPEnable bool = false
@description('true の場合Azureからの接続をすべて許可します。Synapse,SQLDBに対して影響します。')
@allowed([
  true
  false
])
param AllowAzure bool =false
@description('sql管理者ユーザー名')
param sqlAdministratorUsername string = 'sqladmin'

@description('sql管理者ユーザーパスワード。空欄可能')
@secure()
param sqlAdministratorPassword string=''

// sqlpool
@description('true の場合専用SQLPoolをデプロイします。')
@allowed([
  true
  false
])
param isNeedSqlPool bool= false
@description('データベースの照合順序。既定：日本語環境での推奨値　SQL DBと共通')
param collation string = 'Japanese_XJIS_100_CI_AS'
@allowed([
  'LRS'
  'GRS'
])
@description('GRSの場合専用SQLPoolのジオバックアップを有効化します。')
param sqlPoolBackupType string = 'GRS'
@allowed([
  'dw100c'
  'dw200c'
  'dw300c'
  'dw400c'
  'dw500c'
])
@description('専用SQLPoolのDWUを設定します。')
param sqlPooldwu string = 'dw100c'


// SHIR
@description('true の場合をSynapse用セルフホステッド統合ランタイムをデプロイします。isNeedSynapseをFalseにした場合は無効です。')
@allowed([
  true
  false
])
param isNeedSHIRforSynepse bool = true

// SQL DB
@description('true の場合をSQLDBをデプロイします。')
@allowed([
  true
  false
])
param isNeedSQL bool = true

// powerbiGW
@description('true の場合Onpremise Data Gateway用VMをデプロイします。デプロイ後のインストールが必要です')
@allowed([
  true
  false
])
param isNeedVMforOnPremiseDataGateway bool =true

// @description('true の場合CognitiveService マルチアカウントをデプロイします。')
// @allowed([
//   true
//   false
// ])
// param isNeedCognitiveServices bool

// general var 
var vmsku = 'Standard_A4_v2'
var tags = {
  Environment : env
  Project : project
  Deployment_id : deployment_id
  DeployMethod : 'bicep'
}

module logging 'modules/logging.bicep' = {
  name: 'logging'
  params: {
    prefix: prefix
    env:env
    location:location 
    WhiteListsCIDRRules: WhiteListsCIDRRules
    tags: tags
  }
}

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    adbPrivateSubnetPrefix: adbPrivateSubnetPrefix
    adbPublicSubnetPrefix: adbPublicSubnetPrefix
    addressPrefixs: addressPrefixs
    AllowRDPWhiteListsCIDRRules: WhiteListsCIDRs
    env: env
    location: location
    mlcomputesSubnetPrefix: mlcomputesSubnetPrefix
    prefix: prefix
    privateEndpointSubnetPrefix: privateEndpointSubnetPrefix
    runtimeSubnetPrefix: runtimeSubnetPrefix
    tags: tags
  }
}

module datalake 'modules/datalakes.bicep' = {
  name: 'datalake'
  params: {
    allowSubnetIds: [
      network.outputs.adbPublicSubnetId
      network.outputs.mlcomputesSubnetId
      network.outputs.runtimeSubnetId
    ]
    env: env
    location: location
    prefix: prefix
    tags: tags
    WhiteListsCIDRRules: WhiteListsCIDRRules
    isNeedSynapse:isNeedSynapse
  }
}
module uploads 'modules/uploadStorage.bicep' = {
  name: 'uploads'
  params: {
    allowSubnetIds: [
      network.outputs.adbPublicSubnetId
      network.outputs.runtimeSubnetId
    ]
    env: env
    location: location
    prefix: prefix
    tags: tags
    WhiteListsCIDRRules: WhiteListsCIDRRules
  }
}

module appKeyvault 'modules/dataAppsKeyvault.bicep' = {
  name: 'appKeyvault'
  params: {
    allowSubnetIds: [
      network.outputs.adbPublicSubnetId
      network.outputs.mlcomputesSubnetId
      network.outputs.runtimeSubnetId
    ]
    env: env
    location: location 
    prefix: prefix
    tags: tags
    WhiteListsCIDRRules: WhiteListsCIDRRules
  }
}

module dataApps 'modules/dataApps.bicep' = {
  name: 'dataApps'
  params: {
    env: env
    location: location
    prefix: prefix
    tags: tags
    // databricks
    isNeedDatabricks: isNeedDatabricks
    customPrivateSubnetId:network.outputs.adbPrivateSubnetId
    customPublicSubnetId: network.outputs.adbPublicSubnetId
    customVirtualNetworkId: network.outputs.vnetId
    // datafactory
    isNeedDataFactory:isNeedDataFactory
    isNeedSHIRforDataFactory:isNeedSHIRforDataFactory
    runtimeSubnetId:network.outputs.runtimeSubnetId
    VMAdministratorLogin:VMAdministratorLogin
    VMAdministratorLoginPassword:VMAdministratorLoginPassword
    vmsku:vmsku
    // machinelearning
    isNeedMachineLearning:isNeedMachineLearning
    keyVaultId:appKeyvault.outputs.keyvaultId
    mlcomputeSubnetId:network.outputs.mlcomputesSubnetId
    WhiteListsCIDRRules:WhiteListsCIDRRules
  
    // synapse
    isNeedSynapse:isNeedSynapse
    workStorageAccountId:datalake.outputs.workLakeId
    WhiteListsStartEndIPs:WhiteListsStartEndIPs
    AllowAzure:AllowAzure
    sqlAdministratorPassword:sqlAdministratorPassword
    sqlAdministratorUsername:sqlAdministratorUsername
    isDLPEnable:isDLPEnable
    // sqlpool
    isNeedSqlPool:isNeedSqlPool
    collation:collation
    AdminGroupObjectID:AdminGroupObjectID
    AdminGroupName:AdminGroupName
    sqlPoolBackupType:sqlPoolBackupType
    sqlPooldwu:sqlPooldwu
    isNeedSHIRforSynepse:isNeedSHIRforSynepse
    // powerbi
    isNeedVMforOnPremiseDataGateway:isNeedVMforOnPremiseDataGateway
    //sql
    isNeedSQL:isNeedSQL
    // cognitive
    // isNeedCognitiveServices:isNeedCognitiveServices
  }
}

module databricksRBAC 'modules/auxiliary/rbac/databricksRoleAssignment.bicep' =  if (isNeedDatabricks == true){
  name: 'databricksRBAC'
  params: {
    databricksWorkspaceId: dataApps.outputs.databricksId
    datafacoryPrincipalId: dataApps.outputs.datafactoryPrincipalId
    synapsePrincipalId: dataApps.outputs.synapsePrincipalId
  }
}

module datalakesRBAC 'modules/auxiliary/rbac/datalakesRoleAssignment.bicep' = {
  name: 'datalakesRBAC'
  params: {
    datafacoryPrincipalId: dataApps.outputs.datafactoryPrincipalId
    enrichCurateStorageId: datalake.outputs.enCurLakeId
    workspaceLakeId:datalake.outputs.workLakeId
    landingRawStorageId: datalake.outputs.landingRawLakeId
    machinelearningPrincipalId: dataApps.outputs.machinelearningPrincipalId
    synapsePrincipalId: dataApps.outputs.synapsePrincipalId
  }
}
module keyvaultRBAC 'modules/auxiliary/rbac/keyvaultRoleAssignment.bicep' = {
  name: 'keyvaultRBAC'
  params: {
    databricksAppObjectId: databricksAppObjectId
    datafacoryPrincipalId: dataApps.outputs.datafactoryPrincipalId
    keyvaultId: appKeyvault.outputs.keyvaultId
    synapsePrincipalId: dataApps.outputs.synapsePrincipalId
  }
}
module loggingRBAC 'modules/auxiliary/rbac/loggingStorageRoleAssignment.bicep' = {
  name: 'loggingRBAC'
  params: {
    loggingStorageId: logging.outputs.LoggingStorageId
    sqlserverPrincipalId: dataApps.outputs.sqlServerPrincipalId
    synapsePrincipalId: dataApps.outputs.synapsePrincipalId
  }
}

module machinelearningRBAC 'modules/auxiliary/rbac/machinelearningRoleAssignment.bicep' = if (isNeedMachineLearning == true){
  name: 'machinelearningRBAC'
  params: {
    datafacoryPrincipalId: dataApps.outputs.datafactoryPrincipalId
    machinelearningId: dataApps.outputs.machinelearningId
    synapsePrincipalId:  dataApps.outputs.synapsePrincipalId
    mlStorageId:dataApps.outputs.mlstorageId
  }
}

module uploadStorageRBAC 'modules/auxiliary/rbac/uploadStorageRoleAssignment.bicep' = {
  name: 'uploadStorageRBAC'
  params: {
    datafacoryPrincipalId: dataApps.outputs.datafactoryPrincipalId
    synapsePrincipalId:  dataApps.outputs.synapsePrincipalId
    uploadStorageId: uploads.outputs.uploadStorageId
  }
}

// module workspaceLakeRBAC 'modules/auxiliary/rbac/workspaceLakeRoleAssignment.bicep' =  if (isNeedSynapse == true){
//   name: 'workspaceLakeRBAC'
//   params: {
//     synapsePrincipalId: dataApps.outputs.synapsePrincipalId
//     workspaceLakeFilesystemId: dataApps.outputs.synapseFilesystemId
//     workspaceLakeId:datalake.outputs.workLakeId
//   }
// }

module resouceGroupRBAC 'modules/auxiliary/rbac/resourceGroupRoleAssignment.bicep' = {
  name: 'resouceGroupRBAC'
  params: {
    securityGroupObjectId: AdminGroupObjectID
  }
}

module loggingsetting 'modules/auxiliary/logging/loggingSetting.bicep' = {
  name: 'loggingsetting'
  dependsOn:[
    loggingRBAC
  ]
  params: {
    databricksId: dataApps.outputs.databricksId
    datafactoryId: dataApps.outputs.datafactoryId
    enrichCurateStorageId: datalake.outputs.enCurLakeId
    keyvaultId: appKeyvault.outputs.keyvaultId
    landingRawStorageId: datalake.outputs.landingRawLakeId
    loganalyticsId: logging.outputs.logAnalyticsWorkspaceId
    loggingStorageId: logging.outputs.LoggingStorageId
    machinelearningId: dataApps.outputs.machinelearningId
    mlStorageId: dataApps.outputs.mlstorageId
    mlAcrId:dataApps.outputs.containerRegistryId
    sparkpoolId: dataApps.outputs.sparkPoolId
    sqldatabaseId: dataApps.outputs.sqlDatabaseId
    sqlServerId: dataApps.outputs.sqlServerId
    synapseId: dataApps.outputs.synapseId
    workStorageId:datalake.outputs.workLakeId
    uploadStorageId: uploads.outputs.uploadStorageId
    vulnerbilityContainerPath:logging.outputs.vulnerabilityscansConteinrNamePath
    // cognitiveservicesId:dataApps.outputs.CognitiveServicesAccountId
  }
}


// module keyvaultSecrets 'modules/auxiliary/keyvault/secretDeploy.bicep' = {
//   name: 'keyvaultSecrets'
//   params: {
//     cognitiveServicesAccountId:dataApps.outputs.CognitiveServicesAccountId 
//     keyvaultId: appKeyvault.outputs.keyvaultId
//   }
// }

module datafactoryLinkServices 'modules/auxiliary/datafactory/datafactoryLinkServices.bicep' = if(isNeedDataFactory == true){
  name: 'datafactoryLinkServices'
  params: {
    databricksId: dataApps.outputs.databricksId
    databricksWorkspaceUrl: dataApps.outputs.databricksWorkspaceUrl
    datafactoryId: dataApps.outputs.datafactoryId 
    enCurLakeId: datalake.outputs.enCurLakeId
    env: env 
    keyvaultId:appKeyvault.outputs.keyvaultId 
    keyvaultUri: appKeyvault.outputs.keyvaultUri
    machinelearningId: dataApps.outputs.machinelearningId
    mlStorageId: dataApps.outputs.mlstorageId
    rawLakeId: datalake.outputs.landingRawLakeId
    sqlDatabaseId: dataApps.outputs.sqlDatabaseId
    sqlserverId: dataApps.outputs.sqlServerId
    uploadStraogeId: uploads.outputs.uploadStorageId
  }
}

module machinelearningSetup 'modules/auxiliary/machinelearning/machinelearningSetup.bicep' = if(isNeedMachineLearning == true) {
  name: 'machinelearningSetup'
  params: {
    machineLearningId: dataApps.outputs.machinelearningId
    tags:tags
    datalakeFileSystemIds:concat(datalake.outputs.enCurLakeFileSystemIds,datalake.outputs.workLakeFileSystemIds)
  }
}
