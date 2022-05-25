param location string
param containerRegistryName string
param tags object
var containerRegistryNameCleaned = replace(containerRegistryName,'-','')

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2017-10-01' = {
  name: containerRegistryNameCleaned
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}
output containerRegistryId string = containerRegistry.id
