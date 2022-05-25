param location string
param applicationinsightName string
param tags object


resource applicationinsight 'Microsoft.Insights/components@2015-05-01' = {
  name: applicationinsightName
  tags:tags
  location: (((location == 'eastus2') || (location == 'westcentralus')) ? 'southcentralus' : location)
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output applicationinsightId string = applicationinsight.id
