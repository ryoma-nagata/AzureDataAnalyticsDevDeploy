param datafactoryId string

param keyvaultId string 
param keyvaultUri string 
param env string
var keyvaultName = last(split(keyvaultId,'/'))
var keyvaultNameCleaned = replace(replace(keyvaultName,'-${env}','_env'),'-','_')

param uploadStraogeId string
var uploadStraogeName = last(split(uploadStraogeId,'/'))
var uploadStraogeNameCleaned = replace(replace(uploadStraogeName,'upst${env}','upstenv'),'-','_')

param rawLakeId string
var  rawLakeName = last(split(rawLakeId,'/'))
var  rawLakeCleaned = replace(replace(rawLakeName,'raw${env}','rawenv'),'-','_')

param enCurLakeId string
var  enCurLakeName = last(split(enCurLakeId,'/'))
var  enCurLakeNameCleaned = replace(replace(enCurLakeName,'encur${env}','encurenv'),'-','_')

param databricksId string
param databricksWorkspaceUrl string

param machinelearningId string
param mlStorageId string

param sqlDatabaseId string 
param sqlserverId string

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: last(split(datafactoryId,'/'))
}

resource linkedServicesAzureKeyVault 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: keyvaultNameCleaned
  properties: {
    annotations: []
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: keyvaultUri
    }
  }
}
resource linkedServicesUploadBlob 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: uploadStraogeNameCleaned
  properties: {
    annotations: []
    type: 'AzureBlobStorage'
    typeProperties: {
      accountKind:'StorageV2'
      serviceEndpoint:'https://${uploadStraogeName}.blob.${environment().suffixes.storage}'
    }
  }
}


resource linkedServicesRawLake 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: rawLakeCleaned
  properties: {
    annotations: []
    type: 'AzureBlobFS'
    typeProperties: {
      url: 'https://${rawLakeName}.dfs.${environment().suffixes.storage}'
    }
  }
}

resource linkedServicesEnCurLake 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: enCurLakeNameCleaned
  properties: {
    annotations: []
    type: 'AzureBlobFS'
    typeProperties: {
      url: 'https://${enCurLakeName}.dfs.${environment().suffixes.storage}'
    }
  }
}

module datafactoryLinkServices_databricks 'datafactoryLinkServices_databricks.bicep' = if(!empty(databricksId)) {
  name: 'datafactoryLinkServices_databricks'
  params: {
    databricksId: databricksId
    databricksWorkspaceUrl: databricksWorkspaceUrl
    datafactoryId: datafactoryId
    env: env
  }
}

module datafactoryLinkServices_machinelearning 'datafactoryLinkServices_machinelearning.bicep' = if(!empty(machinelearningId)){
  name: 'datafactoryLinkServices_machinelearning'
  params: {
    datafactoryId: datafactoryId
    env: env
    machinelearningId: machinelearningId
    mlStorageId: mlStorageId
  }
}

module datafactoryLinkServices_sql 'datafactoryLinkServices_sql.bicep' = if(!empty(sqlserverId)) {
  name: 'datafactoryLinkServices_sql'
  params: {
    datafactoryId: datafactoryId
    env: env
    sqlDatabaseId: sqlDatabaseId
    sqlserverId: sqlserverId
  }
}
