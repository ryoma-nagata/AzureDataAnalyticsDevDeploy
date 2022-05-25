param location string
param prefix string
param env string
param tags   object
var tagJoin = union(tags, {
  Group:'datalakes'
})

var RawLakeName = '${prefix}-raw-${env}'
var EnCurLakeName = '${prefix}-encur-${env}'

param WhiteListsCIDRRules array

param allowSubnetIds array
var allowSubnetIdsRules = [for allowSubnetId in allowSubnetIds:{
  id:allowSubnetId
  action:'Allow'
} ]

var landingRawResourceAccessrules = [
  {
    tenantId: subscription().tenantId
    resourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/*/providers/Microsoft.Synapse/workspaces/*'
  }
] 


var encurResourceAccessrules = [
  {
    tenantId: subscription().tenantId
    resourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/*/providers/Microsoft.MachineLearningServices/workspaces/*'
  }
  {
    tenantId: subscription().tenantId
    resourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/*/providers/Microsoft.Synapse/workspaces/*'
  }
] 

module landingRawLake 'services/storage.bicep' = {
  name: RawLakeName
  params: {
    tags:tagJoin
    fileSystemNames: [
      '10-landing'
      '20-raw'
    ]
    isHnsEnabled: true
    location: location
    storageIPWhiteLists: WhiteListsCIDRRules
    virtualNetworkRules: allowSubnetIdsRules
    storageName: RawLakeName
    storageSKU: 'Standard_RAGRS'
    resourceAccessRules:landingRawResourceAccessrules
  }
}


module enCurLake 'services/storage.bicep' = {
  name: EnCurLakeName
  params: {
    tags:tagJoin
    fileSystemNames: [
      '30-enrich'
      '40-curate'
    ]
    isHnsEnabled: true
    location: location
    storageIPWhiteLists: WhiteListsCIDRRules
    virtualNetworkRules: allowSubnetIdsRules
    storageName: EnCurLakeName
    storageSKU: 'Standard_ZRS'
    resourceAccessRules:encurResourceAccessrules
  }
}

output landingRawLakeId string = landingRawLake.outputs.storageId
output landingRawLakeFileSystemIds array = landingRawLake.outputs.storageFileSystemIds
output enCurLakeId string = enCurLake.outputs.storageId
output enCurLakeFileSystemIds array = enCurLake.outputs.storageFileSystemIds

