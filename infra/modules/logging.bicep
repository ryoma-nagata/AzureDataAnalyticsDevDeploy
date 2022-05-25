param location string
param prefix string
param env string
param tags   object
var tagJoin = union(tags, {
  Group:'logging'
})

param WhiteListsCIDRRules array

var storageName = '${prefix}-logst-${env}'
var loganalyticsName =  '${prefix}-logws-${env}'

var vulnerabilityscansConteinrName = 'vulnerabilityscans'


module LoggingStorage  'services/loggingStorage.bicep' = {
  name: storageName
  params: {
    fileSystemNames: [
      vulnerabilityscansConteinrName
    ]
    tags:tagJoin
    location: location
    storageIPWhiteLists: WhiteListsCIDRRules
    storageName: storageName
    storageSKU: 'Standard_LRS'
    isLCMonArchive:true
  }
}

module loganalytics 'services/loganalytics.bicep' = {
  name: loganalyticsName
  params: {
    location: location
    logAnanalyticsName: loganalyticsName
    tags: tagJoin
  }
}


output logAnalyticsWorkspaceId string = loganalytics.outputs.logAnalyticsWorkspaceId
output LoggingStorageId string = LoggingStorage.outputs.storageId
output vulnerabilityscansConteinrNamePath string = 'https://${storageName}.blob.${environment().suffixes.storage}/${vulnerabilityscansConteinrName}'

