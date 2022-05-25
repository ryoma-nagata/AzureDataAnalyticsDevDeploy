param loggingStorageId string
var loggingStorageName = last(split(loggingStorageId,'/'))
param loganalyticsId string

param sqlServerId string
param sqldatabaseId string

param vulnerbilityContainerPath string

// sql

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = if(!empty(sqlServerId )){
  name: last(split(sqlServerId,'/'))
}
resource sqldb 'Microsoft.Sql/servers/databases@2021-11-01-preview' existing =  if(!empty(sqldatabaseId )){
  parent: sqlServer
  name: last(split(sqldatabaseId,'/'))
}
resource sqldballLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(!empty(sqldatabaseId )){
  scope:sqldb
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

resource sqlAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2021-11-01-preview' = if(!empty(sqlServerId )){
  parent: sqlServer
  name: 'default'
  properties: {
    auditActionsAndGroups:[
      'BATCH_COMPLETED_GROUP'
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
     ]
    state: 'Enabled'
    storageAccountSubscriptionId:subscription().subscriptionId
    storageEndpoint: 'https://${loggingStorageName}.blob.${environment().suffixes.storage}/'
    isManagedIdentityInUse:true
  }
}

// Defender 有効化が必要なためオミット
// resource sqlVulnerabilityAssessments 'Microsoft.Sql/servers/vulnerabilityAssessments@2018-06-01-preview' = if(!empty(sqlServerId )){
//   parent: sqlServer
//   name: 'default' 
//   properties: {
//     storageContainerPath: vulnerbilityContainerPath
//     recurringScans: {
//       isEnabled: true
//       emailSubscriptionAdmins: false
//     }
//   }
// }



