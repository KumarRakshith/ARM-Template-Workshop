@description('description')
@minLength(3)
@maxLength(4)
param vmnameprefix string

@description('description')
@minLength(3)
@maxLength(5)
param application string

@description('description')
@allowed([
  'DEV'
  'UAT'
  'PROD'
])
param environment string

@description('description')
param SubnetName string

@description('description')
param SKU string

@description('description')
param username string

@description('description')
@secure()
param password string
param existingvnetname string
param existingvnetrg string

var vmname_var = '${vmnameprefix}-${application}-${environment}'
var pipname_var = '${vmname_var}-pip'
var nsg_var = '${vmname_var}${existingvnetname}${SubnetName}-Nsg'
var nicname_var = '${vmname_var}-nic'
var osdiskname = '${vmname_var}-osdisk'
var vnetId = resourceId(existingvnetrg, 'Microsoft.Network/virtualNetworks', existingvnetname)
var subnetRef = '${vnetId}/subnets/${SubnetName}'

resource pipname 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: pipname_var
  location: resourceGroup().location
  tags: {
    displayName: pipname_var
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: toLower(replace(vmname_var, '-', ''))
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: nsg_var
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'nsgRule1'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource nicname 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicname_var
  location: resourceGroup().location
  tags: {
    displayName: nicname_var
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipname.id
          }
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
}

resource vmname 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmname_var
  location: resourceGroup().location
  tags: {
    displayName: vmname_var
  }
  properties: {
    hardwareProfile: {
      vmSize: SKU
    }
    osProfile: {
      computerName: vmname_var
      adminUsername: username
      adminPassword: password
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2012-R2-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: osdiskname
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicname.id
        }
      ]
    }
  }
}