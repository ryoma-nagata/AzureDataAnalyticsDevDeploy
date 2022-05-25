param datafactoryId string 
param sqlserverId string
param sqlDatabaseId string
param env string 

var sqlServerName = last(split(sqlserverId,'/'))
var sqlDatabaseName = last(split(sqlDatabaseId,'/'))
var connectionString = 'Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=${sqlServerName}${environment().suffixes.sqlServerHostname};Initial Catalog=${sqlDatabaseName}'

var sqlDatabaseNameCleaned = replace(replace(sqlDatabaseName,'-${env}','_env'),'-','_')

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: last(split(datafactoryId,'/'))
}
resource adfName_AzureSqlDatabase 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: sqlDatabaseNameCleaned
  properties: {
    annotations: []
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: connectionString
    }
    connectVia: {
      referenceName: 'AutoResolveIntegrationRuntime'
      type: 'IntegrationRuntimeReference'
    }
  }
}
