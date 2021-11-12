param sqlServerName string
param sqlServerDatabase1 string

var dbarray = split(sqlServerDatabase1,',')

resource sqlServer 'Microsoft.Sql/servers@2014-04-01' ={
  name: sqlServerName
  location: resourceGroup().location
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2014-04-01' = [for (database,i) in dbarray:{
  parent: sqlServer
  name: '$(database)-${i}'
  location: resourceGroup().location
  properties: {
    collation: 'collation'
    edition: 'Basic'
    maxSizeBytes: 'maxSizeBytes'
    requestedServiceObjectiveName: 'Basic'
  }
}]
