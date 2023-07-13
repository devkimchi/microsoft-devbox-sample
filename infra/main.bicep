targetScope = 'subscription'

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
@description('comma-delimited user IDs from `az ad signed-in-user show --query "id" -o tsv` or `az ad user show --id "<upn>" --query "id" -o tsv`')
param projectUserIds string
@description('comma-delimited admin IDs from `az ad signed-in-user show --query "id" -o tsv` or `az ad user show --id "<upn>" --query "id" -o tsv`')
param projectAdminIds string = ''
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

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${name}'
  location: location
}

module resources './resources.bicep' = {
  name: 'DevCenter'
  scope: rg
  params: {
    name: name
    location: location
    projectName: projectName
    projectUserIds: split(projectUserIds, ',')
    projectAdminIds: split(projectAdminIds, ',')
    image: image
    storage: storage
  }
}

// output devCenterUrl string = resources.outputs.devCenterUrl
