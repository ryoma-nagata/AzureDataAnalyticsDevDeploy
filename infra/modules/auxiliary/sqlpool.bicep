param synapseId string
param sqlPoolName string
param location string 
param tags object
param sqlPooldwu string
param collation string
param sqlPoolBackupType string

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: last(split(synapseId,'/'))
}

resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01'= {
  parent: synapseWorkspace
  name: sqlPoolName
  location:location
  tags:tags
  sku:{
    name: sqlPooldwu
  }
  properties:{
    collation:collation
    storageAccountType:sqlPoolBackupType
    
  }
}

resource tde 'Microsoft.Synapse/workspaces/sqlPools/transparentDataEncryption@2021-06-01' = {
  name: 'current'
  parent:sqlpool
  properties:{
    status:'Enabled'
  } 
}
