param tags object
param cognitiveAccountName string
param location string

resource cognitivemulti 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: cognitiveAccountName
  location:location
  tags:tags
  kind:'CognitiveServices'
  sku:{
    name:'S0'
  }
  properties: {
    apiProperties:{}
  }
  identity:{
    type:'SystemAssigned'
  }
}


output CognitiveServicesAccountId string = cognitivemulti.id

