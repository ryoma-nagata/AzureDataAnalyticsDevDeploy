param loggingStorageId string
var loggingStorageName = last(split(loggingStorageId,'/'))
param loganalyticsId string

param synapseId string
param sparkpoolId string 



param vulnerbilityContainerPath string


// synapse
resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' existing = if (!empty(synapseId )){
  name:  last(split(synapseId,'/'))
}

resource synapseallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(synapseId )){
  scope:synapse
  name: 'allLogs'
  properties:{
    storageAccountId:loggingStorageId
    workspaceId:loganalyticsId
    logs:[
      {
        categoryGroup:'allLogs'
        enabled: true
      }
    ]
  }
}


// Defender 有効化が必要なためオミット
// resource synapseVulnerabilityAssessments 'Microsoft.Synapse/workspaces/vulnerabilityAssessments@2021-06-01' = if (!empty(synapseId )){
//   parent: synapse
//   name: 'default' 
//   properties: {
//     storageContainerPath: vulnerbilityContainerPath
//     recurringScans: {
//       isEnabled: true
//       emailSubscriptionAdmins: false
//     }
//   }
// }



// sqlpool
resource sqlpoolAuditingSettings 'Microsoft.Synapse/workspaces/auditingSettings@2021-06-01' = if (!empty(synapseId )){
  name:  'default'
  parent:synapse
  properties:{
    state:  'Enabled'
    auditActionsAndGroups:[
      'BATCH_COMPLETED_GROUP'
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
     ]
     storageAccountSubscriptionId:subscription().subscriptionId
     storageEndpoint:'https://${loggingStorageName}.blob.${environment().suffixes.storage}/'
     isAzureMonitorTargetEnabled:true
  }
}
//sparkpool
resource sparkpool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' existing = if (!empty(sparkpoolId )){
  parent:synapse
  name: last(split(sparkpoolId,'/'))
}
resource sparkpoolallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(sparkpoolId )){
  scope:sparkpool
  name: 'allLogs'
  properties:{
    storageAccountId:loggingStorageId
    workspaceId:loganalyticsId
    logs:[
      {
        categoryGroup:'allLogs'
        enabled: true
      }
    ]
  }
}
