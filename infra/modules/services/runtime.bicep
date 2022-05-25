@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string 

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'

@description('The Windows version for the VM. This will pick a fully patched Gen2 image of this given Windows version.')
@allowed([
 '2019-datacenter-gensecond'
 '2019-datacenter-core-gensecond'
 '2019-datacenter-core-smalldisk-gensecond'
 '2019-datacenter-core-with-containers-gensecond'
 '2019-datacenter-core-with-containers-smalldisk-g2'
 '2019-datacenter-smalldisk-gensecond'
 '2019-datacenter-with-containers-gensecond'
 '2019-datacenter-with-containers-smalldisk-g2'
 '2016-datacenter-gensecond'
 '2019-Datacenter'
])
param OSVersion string = '2019-datacenter-gensecond'

@description('Size of the virtual machine.')
param vmSize string 

@description('Location for all resources.')
param location string 

@description('Name of the virtual machine.')
param vmName string 
param subnetId string
param nicName string

param isSHIRMode bool = false
@secure()
param datafactoryIntegrationRuntimeAuthKey string = ''

param tags object

var osProfile =(isSHIRMode == true) ? {
  computerName: vmName
  adminUsername: adminUsername
  adminPassword: adminPassword
  customData: loadFileAsBase64('../../../code/installSHIRGateway.ps1')
} : {
  computerName: vmName
  adminUsername: adminUsername
  adminPassword: adminPassword
} 

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }

  }
}


resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: osProfile
    diagnosticsProfile:{
      bootDiagnostics:{
        enabled:true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    
  }
}
// 
resource extensionShir 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = if (isSHIRMode) {
  name: 'installGW'
  location:location
  parent:vm
  properties:{
    publisher:'Microsoft.Compute'
    type:'CustomScriptExtension'
    typeHandlerVersion:'1.7'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: []
    }
    protectedSettings: {
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -command "cp c:/azuredata/customdata.bin c:/azuredata/installSHIRGateway.ps1; c:/azuredata/installSHIRGateway.ps1 -gatewayKey "${datafactoryIntegrationRuntimeAuthKey}"'
    }
  }
}

output hostname string = pip.properties.dnsSettings.fqdn
