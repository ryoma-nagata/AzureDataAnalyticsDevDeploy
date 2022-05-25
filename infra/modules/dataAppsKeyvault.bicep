param location string
param prefix string
param env string
param tags   object
var tagJoin = union(tags, {
  Group:'data apps'
})

var keyvaultName = '${prefix}-appkv-${env}'

param WhiteListsCIDRRules array

param allowSubnetIds array
var allowSubnetIdsRules = [for allowSubnetId in allowSubnetIds:{
  id:allowSubnetId
  action:'Allow'
} ]

module keyvault 'services/keyvault.bicep' = {
  name: keyvaultName
  params: {
    tags:tagJoin
    keyvaultName:keyvaultName
    location: location

    keyvaultIPWhiteLists: WhiteListsCIDRRules
    virtualNetworkRules: allowSubnetIdsRules
  }
}

output keyvaultId string = keyvault.outputs.keyvaultId
output keyvaultUri string = keyvault.outputs.keyvaultUri
