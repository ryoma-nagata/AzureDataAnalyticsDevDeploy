param location string 
param datafactoryName string
param isNeedSHIRforDataFactory bool
param tags object

var datafactoryDefaultManagedVnetIntegrationRuntimeName = 'AutoResolveIntegrationRuntime'

// SHIRforDataFactory
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



resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: datafactoryName
  tags: tags
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}
resource datafactoryManagedVirtualNetwork 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  parent: datafactory
  name: 'default'
  properties: {}
}

resource datafactoryManagedIntegrationRuntime001 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  parent: datafactory
  name: datafactoryDefaultManagedVnetIntegrationRuntimeName
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      type: 'ManagedVirtualNetworkReference'
      referenceName: datafactoryManagedVirtualNetwork.name
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
}

resource shir 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if(isNeedSHIRforDataFactory == true) {
  name: selfhostedIRName
  parent:datafactory
  properties: {
    type: 'SelfHosted'
  }
}


module runtime 'runtime.bicep'  = if(isNeedSHIRforDataFactory == true)  {
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
    datafactoryIntegrationRuntimeAuthKey: listAuthKeys(shir.id,shir.apiVersion).authKey1
  }
}

output datafactoryPrincipalId string = datafactory.identity.principalId
output datafactoryId string = datafactory.id

