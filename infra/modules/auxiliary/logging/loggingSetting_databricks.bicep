param loggingStorageId string
param loganalyticsId string


param databricksId string


// databricks
resource databricks 'Microsoft.Databricks/workspaces@2021-04-01-preview' existing = {
  name: last(split(databricksId,'/'))
}
resource databricksworkspaceallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope:databricks
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
