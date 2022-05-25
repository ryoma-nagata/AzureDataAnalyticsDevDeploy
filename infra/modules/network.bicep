param location string
param prefix string
param env string
param tags   object
var tagJoin = union(tags, {
  Group:'network'
})

param AllowRDPWhiteListsCIDRRules array
param addressPrefixs array 
param runtimeSubnetPrefix string 
param privateEndpointSubnetPrefix string 
param mlcomputesSubnetPrefix string 
param adbPublicSubnetPrefix string 
param adbPrivateSubnetPrefix string 

var adbNsgName = '${prefix}-adb-nsg-${env}'
var runtimeNsgName = '${prefix}-runtime-nsg-${env}'
var vnetName = '${prefix}-vnet-${env}'
var amlNsgName = '${prefix}-aml-nsg-${env}'

var privateEndpointSubnet = {
  name :'privateEndpoints' 
  addressPrefix : privateEndpointSubnetPrefix
}

var runtimeSubnet = {
  name :'runtime' 
  addressPrefix : runtimeSubnetPrefix
}

var mlcomputesSubnet = {
  name :'mlcomputes' 
  addressPrefix : mlcomputesSubnetPrefix
}

var adbPublicSubnet = {
  name :'adb-public-subnet'
  addressPrefix : adbPublicSubnetPrefix
}

var adbPrivateSubnet = {
  name :'adb-private-subnet'
  addressPrefix : adbPrivateSubnetPrefix
}

resource adbNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01'={
  name: adbNsgName
  location:location
  tags:tagJoin
  properties: {
    securityRules: [
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      // no publi ipのため不要
      // {
      //   name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-ssh'
      //   properties: {
      //     description: 'Required for Databricks control plane management of worker nodes.'
      //     protocol: 'Tcp'
      //     sourcePortRange: '*'
      //     destinationPortRange: '22'
      //     sourceAddressPrefix: 'AzureDatabricks'
      //     destinationAddressPrefix: 'VirtualNetwork'
      //     access: 'Allow'
      //     priority: 101
      //     direction: 'Inbound'
      //     sourcePortRanges: []
      //     destinationPortRanges: []
      //     sourceAddressPrefixes: []
      //     destinationAddressPrefixes: []
      //   }
      // }
      // {
      //   name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-proxy'
      //   properties: {
      //     description: 'Required for Databricks control plane communication with worker nodes.'
      //     protocol: 'Tcp'
      //     sourcePortRange: '*'
      //     destinationPortRange: '5557'
      //     sourceAddressPrefix: 'AzureDatabricks'
      //     destinationAddressPrefix: 'VirtualNetwork'
      //     access: 'Allow'
      //     priority: 102
      //     direction: 'Inbound'
      //     sourcePortRanges: []
      //     destinationPortRanges: []
      //     sourceAddressPrefixes: []
      //     destinationAddressPrefixes: []
      //   }
      // }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp'
        properties: {
          description: 'Required for workers communication with Databricks Webapp.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureDatabricks'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql'
        properties: {
          description: 'Required for workers communication with Azure SQL services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 101
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage'
        properties: {
          description: 'Required for workers communication with Azure Storage services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 102
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 103
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub'
        properties: {
          description: 'Required for worker communication with Azure Eventhub services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '9093'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 104
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}


resource runtimeNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: runtimeNsgName
  location: location
  tags:tagJoin
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          sourceAddressPrefixes: AllowRDPWhiteListsCIDRRules
        }
      }
    ]
  }
}

resource amlNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: amlNsgName
  location: location
  tags:tagJoin
  properties: {
    securityRules: [
      {
        name: 'AzureBatch'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '29876-29877'
          sourceAddressPrefix: 'BatchNodeManagement'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1040
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AzureMachineLearning'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '44224'
          sourceAddressPrefix: 'AzureMachineLearning'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1050
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AML'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureMachineLearning'
          access: 'Allow'
          priority: 3850
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AAD'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureActiveDirectory'
          access: 'Allow'
          priority: 3700
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'ARM'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureResourceManager'
          access: 'Allow'
          priority: 3800
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'ACR'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureContainerRegistry'
          access: 'Allow'
          priority: 3900
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Storage'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 3950
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'DenyInternet'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 4000
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AFDFP'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureFrontDoor.FirstParty'
          access: 'Allow'
          priority: 3600
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'https-http'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 3980
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: [
            '443'
            '80'
          ]
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-04-01' = {
  name: vnetName
  location: location
  tags:tagJoin
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixs
    }
    subnets: [
      {
        name: runtimeSubnet.name
        properties: {
          addressPrefix: runtimeSubnet.addressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                location
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: runtimeNsg.id
          }
        }
      }
      {
        name: mlcomputesSubnet.name
        properties: {
          addressPrefix: mlcomputesSubnet.addressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.Sql'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                location
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: amlNsg.id
          }
        }
      }
      {
        name: adbPublicSubnet.name
        properties: {
          addressPrefix: adbPublicSubnet.addressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.Sql'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                location
              ]
            }
          ]
          delegations: [
            {
              name: 'databricks-del-public'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup:{
            id:adbNsg.id
          }
        }
      }
      {
        name: adbPrivateSubnet.name
        properties: {
          addressPrefix: adbPrivateSubnet.addressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.Sql'
              locations: [
                location
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                location
              ]
            }
          ]
          delegations: [
            {
              name: 'databricks-del-private'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup:{
            id:adbNsg.id
          }          
        }
      }
      {
        name: privateEndpointSubnet.name
        properties: {
          addressPrefix: privateEndpointSubnet.addressPrefix
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
    enableVmProtection: false
  }
}

output vnetId string = vnet.id
output mlcomputesSubnetId string ='${vnet.id}/subnets/${mlcomputesSubnet.name}'
output runtimeSubnetId string ='${vnet.id}/subnets/${runtimeSubnet.name}'
output adbPublicSubnetId string = '${vnet.id}/subnets/${adbPublicSubnet.name}'
output adbPrivateSubnetId string = '${vnet.id}/subnets/${adbPrivateSubnet.name}'
output privateEndpointSubnetId string = '${vnet.id}/subnets/${privateEndpointSubnet.name}'
