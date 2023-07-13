param name string
@allowed([
  'australiaeast'
  'canadacentral'
  'westeurope'
  'japaneast'
  'uksouth'
  'eastus'
  'eastus2'
  'southcentralus'
  'westus3'
])
param location string = 'australiaeast'

param projectName string = 'development'
param projectUserIds array
param projectAdminIds array = []
@allowed([
  'vs2022win11m365'
])
param image string = 'vs2022win11m365'
@allowed([
  'ssd_256gb'
  'ssd_512gb'
  'ssd_1024gb'
])
param storage string = 'ssd_512gb'

var skuMap = {
  ssd_256gb: 'general_i_8c32gb256ssd_v2'
  ssd_512gb: 'general_i_8c32gb512ssd_v2'
  ssd_1024gb: 'general_i_8c32gb1024ssd_v2'
}
var imageMap = {
  vs2022win11m365: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}
var virtualNetwork = {
  name: 'vnet-${name}'
  location: location
}
var devCenter = {
  name: 'devcen-${name}'
  location: location
  networkConnection: {
    name: 'netcon-${name}'
  }
  gallery: {
    name: 'Default'
    image: imageMap[image]
  }
  devBoxDefinition: {
    name: '${image}-${storage}'
    skuName: skuMap[storage]
    storage: storage
  }
  project: {
    name: projectName
    userIds: projectUserIds
    adminIds: projectAdminIds
    pool: {
      name: 'vs2022'
    }
  }
}
var devBoxUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '45d50f46-0b78-4001-a660-4198cbe8cd05')
var devBoxAdminRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '331c37c6-af14-46d9-b9f4-e1909e1b95a0')

resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: virtualNetwork.name
  location: virtualNetwork.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource vnetsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' = {
  name: 'default'
  parent: vnet
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource devcen 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: devCenter.name
  location: devCenter.location
  identity: {
    type: 'None'
  }
}

resource netcon 'Microsoft.DevCenter/networkconnections@2023-04-01' = {
  name: devCenter.networkConnection.name
  location: devCenter.location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: vnetsubnet.id
    networkingResourceGroupName: 'rg-${name}-nic'
  }
}

resource attnet 'Microsoft.DevCenter/devcenters/attachednetworks@2023-04-01' = {
  name: devCenter.networkConnection.name
  parent: devcen
  properties: {
    networkConnectionId: netcon.id
  }
}

resource gallery 'Microsoft.DevCenter/devcenters/galleries@2023-04-01' existing = {
  name: devCenter.gallery.name
  parent: devcen
}

resource galleryimage 'Microsoft.DevCenter/devcenters/galleries/images@2023-04-01' existing = {
  name: devCenter.gallery.image
  parent: gallery
}

resource devboxdefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01' = {
  name: devCenter.devBoxDefinition.name
  parent: devcen
  location: devCenter.location
  properties: {
    sku: {
      name: devCenter.devBoxDefinition.skuName
    }
    imageReference: {
      id: galleryimage.id
    }
    osStorageType: devCenter.devBoxDefinition.storage
  }
}

resource devprj 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: devCenter.project.name
  location: devCenter.location
  properties: {
    devCenterId: devcen.id
  }
}

resource devprjpool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: devCenter.project.pool.name
  parent: devprj
  location: devCenter.location
  properties: {
    devBoxDefinitionName: devboxdefinition.name
    networkConnectionName: netcon.name
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
  }
}

resource devprjpoolschedule 'Microsoft.DevCenter/projects/pools/schedules@2023-04-01' = {
  name: 'default'
  parent: devprjpool
  properties: {
    type: 'StopDevBox'
    frequency: 'Daily'
    time: '20:00'
    timeZone: 'Asia/Seoul'
    state: 'Enabled'
  }
}

resource devprjusers 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for userId in projectUserIds: {
  scope: devprj
  name: guid(devprj.id, userId, devBoxUserRoleId)
  properties: {
    roleDefinitionId: devBoxUserRoleId
    principalType: 'User'
    principalId: userId
  }
}]

resource devprjadmins 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for adminId in projectAdminIds: {
  scope: devprj
  name: guid(devprj.id, adminId, devBoxAdminRoleId)
  properties: {
    roleDefinitionId: devBoxAdminRoleId
    principalType: 'User'
    principalId: adminId
  }
}]

output devCenterUrl string = devcen.properties.devCenterUri
