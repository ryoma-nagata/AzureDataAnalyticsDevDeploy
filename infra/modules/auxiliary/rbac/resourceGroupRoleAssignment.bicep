param securityGroupObjectId string
var storageBlobDataOwnerRoleId = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
var keyvaultadmin = '00482a5a-887f-4fb3-b363-3b7fe8e74483'



resource sgToStorageBlobDataContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (!empty(securityGroupObjectId )) {
  name: guid(securityGroupObjectId,resourceGroup().id,storageBlobDataOwnerRoleId,'sgToStorageBlobDataContributor')
  scope:resourceGroup()
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataOwnerRoleId)
    principalId: securityGroupObjectId
    principalType: 'Group'
  }
}

resource sgToKeyvaultAdmin 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (!empty(securityGroupObjectId )) {
  name: guid(securityGroupObjectId,resourceGroup().id,keyvaultadmin,'sgToKeyvaultAdmin')
  scope:resourceGroup()
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyvaultadmin)
    principalId: securityGroupObjectId
    principalType: 'Group'
  }
}
