param datafactoryId string 
param databricksId string
param databricksWorkspaceUrl string
param env string

var databricksName = last(split(databricksId,'/'))
var databricksNameCleaned = replace(replace(databricksName,'-${env}','_env'),'-','_')

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: last(split(datafactoryId,'/'))
}

resource linkedServicesAzureDatabricks 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: datafactory
  name: databricksNameCleaned
  properties: {
    annotations: []
    type: 'AzureDatabricks'
    typeProperties: {
      domain: 'https://${databricksWorkspaceUrl}'
      authentication: 'MSI'
      workspaceResourceId: databricksId
      newClusterNodeType: 'Standard_E8_v3'
      newClusterNumOfWorker: '2:4'
      newClusterSparkEnvVars: {
        PYSPARK_PYTHON: '/databricks/python3/bin/python3'
      }
      newClusterVersion: '10.4.x-photon-scala2.12'
      clusterOption: 'Autoscaling'
    }
  }
}
