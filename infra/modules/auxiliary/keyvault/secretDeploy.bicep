param cognitiveServicesAccountId string
param keyvaultId string

module cognitiveSecret 'secret_cognitive.bicep' = if(!empty(cognitiveServicesAccountId)) {
  name: 'cognitiveSecret'
  params: {
    cognitiveServicesAccountId:cognitiveServicesAccountId 
    keyvaultId: keyvaultId
  }
}
