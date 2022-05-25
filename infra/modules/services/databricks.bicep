param location string
param databricksWorkspaceName string

param customVirtualNetworkId string
param customPublicSubnetName string
param customPrivateSubnetName string
param tags object

var managedResourceGroupId = '${subscription().id}/resourceGroups/databricks-rg-${databricksWorkspaceName}-${uniqueString(databricksWorkspaceName, resourceGroup().id)}'

resource databricksWorkspace 'Microsoft.Databricks/workspaces@2021-04-01-preview' = {
  location: location
  name: databricksWorkspaceName
  tags: tags
  sku: {
    name: 'premium'
  }
  properties: {
    
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      enableNoPublicIp:{
        value: true
      }
      customVirtualNetworkId: {
        value: customVirtualNetworkId
      }
      customPublicSubnetName: {
        value: customPublicSubnetName
      }
      customPrivateSubnetName: {
        value: customPrivateSubnetName
      }
    }
  }
}

output databricksWorkspaceId string = databricksWorkspace.id
output databricksWorkspaceUrl string = databricksWorkspace.properties.workspaceUrl
