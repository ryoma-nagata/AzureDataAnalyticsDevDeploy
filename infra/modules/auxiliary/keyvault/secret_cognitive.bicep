param keyvaultId string
@secure()

param cognitiveServicesAccountId string

resource keyvault 'Microsoft.KeyVault/vaults@2016-10-01' existing = {
  name: last(split(keyvaultId,'/'))
}

// resource secretsApiKey 'Microsoft.KeyVault/vaults/secrets@2016-10-01' =  {
//   parent: keyvault
//   name: 'COGNITIVE_SERVICES_API_KEY'
//   properties: {
//     value:listKeys(cognitiveServicesAccountId, providers('Microsoft.CognitiveServices', 'accounts').apiVersions[0]).key1
//     attributes: {
//       enabled: true
//     }
//     contentType: 'API key'
//   }
// }
