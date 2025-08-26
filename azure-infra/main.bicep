// Azure Infrastructure for Blog Application
// Creates: Resource Group, Container Registry, AKS Cluster

param location string = 'East US'
param resourceGroupName string = 'rg-blog-app'
param acrName string = 'acrblogapp${uniqueString(subscription().subscriptionId)}'
param aksName string = 'aks-blog-app'
param nodeCount int = 2
param vmSize string = 'Standard_D2s_v3'

targetScope = 'subscription'

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: {
    project: 'blog-app'
    environment: 'production'
  }
}

// Azure Container Registry
module acr 'modules/acr.bicep' = {
  name: 'acrDeployment'
  scope: rg
  params: {
    acrName: acrName
    location: location
  }
}

// Azure Kubernetes Service
module aks 'modules/aks.bicep' = {
  name: 'aksDeployment'
  scope: rg
  params: {
    aksName: aksName
    location: location
    nodeCount: nodeCount
    vmSize: vmSize
  }
  dependsOn: [
    acr
  ]
}

// Outputs
output resourceGroupName string = rg.name
output acrName string = acr.outputs.acrName
output acrLoginServer string = acr.outputs.loginServer
output aksName string = aks.outputs.aksName
output aksNodeResourceGroup string = aks.outputs.nodeResourceGroup
