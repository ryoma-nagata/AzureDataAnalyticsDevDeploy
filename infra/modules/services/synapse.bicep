targetScope = 'resourceGroup'
param location string 
param tags object

// synapseDefaultStorage
param synapseDefaultStorageAccountName string
param WhiteListsCIDRRules array
param allowSubnetIds array
var allowSubnetIdsRules = [for allowSubnetId in allowSubnetIds:{
  id:allowSubnetId
  action:'Allow'
} ]
var ResourceAccessrules = [
  {
    tenantId: subscription().tenantId
    resourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/*/providers/Microsoft.Synapse/workspaces/*'
  }
] 
// synapse
param synapseName string
param administratorUsername string = 'sqladmin'
@secure()
param administratorPassword string = ''
param AllowAzure bool = true
param WhiteListsStartEndIPs array
param synapseSqlAdminGroupName string = ''
param synapseSqlAdminGroupObjectID string = ''
param isDLPEnable bool
var managedVirtualNetworkSettings = (isDLPEnable==true) ? {
  allowedAadTenantIdsForLinking: []
  linkedAccessCheckOnTargetResource: true
  preventDataExfiltration: true
} : {}


// sqlpool
param isNeedSqlPool bool
var sqlPoolName = 'dwh001'
var sqlPoolNameCleaned = replace(sqlPoolName,'-','_')

param sqlPoolBackupType string
param sqlPooldwu string ='dw100'
param collation string  = 'Japanese_XJIS_100_CI_AS'

//sparkpool
var sparkPoolName = 'sparkpool001'
var sparkPoolNameCleaned = replace(sparkPoolName,'-','_')


// SHIRforSynapse
param isNeedSHIRforSynepse bool
param selfhostedIRName string
param shirSubnetId string
param vmsku string
param VMAdministratorLogin string 
@minLength(12)
@secure()
param VMAdministratorLoginPassword string

param shirPublicIPAddressName string
param shirDnsLabal string
param shirNicName string
param shirVMName string

// param purviewId string =''


module synapseDefaultStorage 'storage.bicep' = {
  name: synapseDefaultStorageAccountName
  params: {
    tags:tags
    fileSystemNames: [
      'work-${synapseName}'
    ]
    isHnsEnabled: true
    location: location
    storageIPWhiteLists: WhiteListsCIDRRules
    virtualNetworkRules: allowSubnetIdsRules
    storageName: synapseDefaultStorageAccountName
    storageSKU: 'Standard_ZRS'
    resourceAccessRules:ResourceAccessrules
  }
}

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name:synapseName
  location:location
  identity:{
    type:'SystemAssigned'
  }
  tags:tags
  properties:{
    defaultDataLakeStorage:{
      filesystem:last(split(synapseDefaultStorage.outputs.storageFileSystemIds[0].storageFileSystemId,'/'))
      accountUrl: 'https://${synapseDefaultStorageAccountName}.dfs.${environment().suffixes.storage}'
    }
    sqlAdministratorLogin: administratorUsername
    sqlAdministratorLoginPassword: administratorPassword
    publicNetworkAccess: 'Enabled'
    managedVirtualNetwork:'default'
    managedVirtualNetworkSettings: managedVirtualNetworkSettings
  }
}

resource network 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = if (AllowAzure)  {
  name:'AllowAllWindowsAzureIps'
  parent:synapseWorkspace
  properties:{
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource networkACL 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01'= [for WhiteListsStartEndIP in WhiteListsStartEndIPs: {
  name:WhiteListsStartEndIP.name
  parent:synapseWorkspace
  properties:{
    startIpAddress: WhiteListsStartEndIP.startIpAddress
    endIpAddress: WhiteListsStartEndIP.endIpAddress
  }
}]

resource synapseAadAdministrators 'Microsoft.Synapse/workspaces/administrators@2021-03-01' = if (!empty(synapseSqlAdminGroupName) && !empty(synapseSqlAdminGroupObjectID)) {
  parent: synapseWorkspace
  name: 'activeDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: synapseSqlAdminGroupName
    sid: synapseSqlAdminGroupObjectID
    tenantId: subscription().tenantId
  }
}


module sqlpool '../auxiliary/sqlpool.bicep' = if (isNeedSqlPool==true) {
  name: 'sqlpool'
  params:{
    location: location
    tags: tags
    sqlPooldwu: sqlPooldwu
    collation: collation
    sqlPoolBackupType: sqlPoolBackupType
    sqlPoolName: sqlPoolNameCleaned
    synapseId: synapseWorkspace.id
  }
}



resource synapseBigDataPool001 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {  
  parent: synapseWorkspace
  name: sparkPoolNameCleaned
  location: location
  properties: {
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 12
    }
    customLibraries: []
    nodeSize: 'Small'
    nodeSizeFamily: 'MemoryOptimized'
    sessionLevelPackagesEnabled: true
    sparkVersion: '3.2'
    dynamicExecutorAllocation:{
      enabled:true
      maxExecutors:4
      minExecutors:1
    }

  }
  tags:tags
}

resource shir 'Microsoft.Synapse/workspaces/integrationRuntimes@2021-06-01' = if(isNeedSHIRforSynepse == true) {
  name: selfhostedIRName
  parent:synapseWorkspace
  properties: {
    type: 'SelfHosted'
  }
}



module runtime 'runtime.bicep'  = if(isNeedSHIRforSynepse == true)  {
  name: 'runtime'
  params: {
    adminPassword: VMAdministratorLoginPassword
    adminUsername: VMAdministratorLogin
    tags:tags
    location: location
    nicName: shirNicName
    publicIpName: shirPublicIPAddressName
    subnetId: shirSubnetId
    vmName: shirVMName
    vmSize: vmsku
    dnsLabelPrefix: shirDnsLabal
    isSHIRMode:true
    publicIPAllocationMethod:'Dynamic'
    publicIpSku:'Basic'
    OSVersion:'2019-Datacenter'
    datafactoryIntegrationRuntimeAuthKey: (isNeedSHIRforSynepse == true) ? listAuthKeys(shir.id,shir.apiVersion).authKey1 : ''
  }
}


output synapseId string = synapseWorkspace.id
output sparkPoolId string = synapseBigDataPool001.id
output synapseStorageId string = synapseDefaultStorage.outputs.storageId
output synapsePrincipalId string = synapseWorkspace.identity.principalId
output synapseFilesystemId string = synapseDefaultStorage.outputs.storageFileSystemIds[0].storageFileSystemId
// output sparkDef object = sparkdef
