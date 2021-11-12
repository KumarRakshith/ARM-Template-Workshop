param vnetname string
param vnetrange string
@description('Please provide the comma separated value')
param subnets string

var subnetarray = split(subnets,',')
var subnetnameprefix = '${vnetname}-subnet'
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetname
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetrange
      ]
    }
    subnets: [for (subnet,i) in subnetarray:{
        name: '${subnetnameprefix}-${i}'
        properties: {
          addressPrefix: subnet
        }
      }]
  }
}
