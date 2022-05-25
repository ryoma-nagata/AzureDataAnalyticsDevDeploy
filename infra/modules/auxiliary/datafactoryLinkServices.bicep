param datafactoryId string 
param keyvaultUrl string 
param databricksId string
param databricksWorkspaceUrl string
param adlsUrl string
param amlStorageUrl string
param amlWorkspaceName string 
param SelfhostedIRName string

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: last(split(datafactoryId,'/'))
}

resource linkedServicesAzureKeyVault 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: 'AzureKeyVault'
  properties: {
    annotations: []
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: keyvaultUrl
    }
  }
}

resource linkedServicesAzureDatabricks 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: datafactory
  name: 'AzureDatabricks'
  properties: {
    annotations: []
    type: 'AzureDatabricks'
    typeProperties: {
      domain: databricksWorkspaceUrl
      authentication: 'MSI'
      workspaceResourceId: databricksId
      newClusterNodeType: 'Standard_D16_v3'
      newClusterNumOfWorker: '2:4'
      newClusterSparkEnvVars: {
        PYSPARK_PYTHON: '/databricks/python3/bin/python3'
      }
      newClusterVersion: '7.3.x-scala2.12'
      clusterOption: 'Autoscaling'
    }
  }
}

resource linkedServicesAzureDataLakeStorage 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: 'AzureDataLakeStorage'
  properties: {
    annotations: []
    type: 'AzureBlobFS'
    typeProperties: {
      url: adlsUrl
    }
  }
}

resource linkedServicesAzureMLBlob 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: 'AzureMLBlob'
  properties: {
    annotations: []
    type: 'AzureBlobStorage'
    typeProperties: {
      accountKind:'StorageV2'
      serviceEndpoint:amlStorageUrl
    }
  }
}

resource linkedServicesAzureMLService 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: 'AzureMLService'
  properties: {
    annotations: []
    type: 'AzureMLService'
    typeProperties: {
      subscriptionId: subscription().subscriptionId
      resourceGroupName: resourceGroup().name
      mlWorkspaceName: amlWorkspaceName
      tenant: subscription().tenantId
      authentication: 'MSI'
    }
  }
}

resource adfName_AzureSqlDatabase 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: 'AzureSqlDatabase'
  properties: {
    annotations: []
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: 'AzureKeyVault'
          type: 'LinkedServiceReference'
        }
        secretName: 'sqlConnectionString'
      }
    }
    connectVia: {
      referenceName: SelfhostedIRName
      type: 'IntegrationRuntimeReference'
    }
  }
  dependsOn: [
    linkedServicesAzureKeyVault
  ]
}
