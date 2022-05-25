param location string
param prefix string
param env string
param tags   object
var tagJoin = union(tags, {
  Group:'upload'
})

var uploadStorageName = '${prefix}-upst-${env}'

param WhiteListsCIDRRules array

param allowSubnetIds array
var allowSubnetIdsRules = [for allowSubnetId in allowSubnetIds:{
  id:allowSubnetId
  action:'Allow'
} ]

var upstResourceAccessrules = [
  {
    tenantId: subscription().tenantId
    resourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/*/providers/Microsoft.Synapse/workspaces/*'
  }
] 

module uploadStorage 'services/storage.bicep' = {
  name: uploadStorageName
  params: {
    tags:tagJoin
    fileSystemNames: [
      'upload001'
    ]
    isHnsEnabled: false
    location: location
    storageIPWhiteLists: WhiteListsCIDRRules
    virtualNetworkRules: allowSubnetIdsRules
    storageName: uploadStorageName
    storageSKU: 'Standard_LRS'
    resourceAccessRules:upstResourceAccessrules
  }
}

output uploadStorageId string = uploadStorage.outputs.storageId
