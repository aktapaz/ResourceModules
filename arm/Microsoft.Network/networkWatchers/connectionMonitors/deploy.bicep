@description('Optional. Name of the network watcher resource. Must be in the resource group where the Flow log will be created and same region as the NSG')
param networkWatcherName string = 'NetworkWatcher_${resourceGroup().location}'

@description('Optional. Name of the resource.')
param name string

@description('Optional. List of connection monitor endpoints.')
param endpoints array = []

@description('Optional. List of connection monitor test configurations.')
param testConfigurations array = []

@description('Optional.	List of connection monitor test groups.')
param testGroups array = []

@description('Optional.	Monitoring interval in seconds.')
param monitoringInterval int = 30

@description('Optional.	Address of the connection monitor destination (IP or domain name).')
param destinationAddress string = ''

@description('Optional.	The destination port used by connection monitor.')
param destinationPort int = 80

@description('Optional. The ID of the resource used as the destination by connection monitor.')
param destinationResourceId string = ''

@description('Required.	The ID of the resource used as the source by connection monitor.')
param sourceResourceId string

@description('Optional.	The source port used by connection monitor.')
param sourcePort int = 80

@description('Optional.	The ID of the resource used as the source by connection monitor.')
param notes string = ''

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Specify the Log Analytics Workspace Resource ID')
param workspaceResourceId string = ''

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered')
param cuaId string = ''

var outputs = !empty(workspaceResourceId) ? [
  {
    type: 'Workspace'
    workspaceSettings: {
      workspaceResourceId: workspaceResourceId
    }
  }
] : null

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource connectionMonitor 'Microsoft.Network/networkWatchers/connectionMonitors@2021-03-01' = {
  name: '${networkWatcherName}/${name}'
  tags: tags
  properties: {
    autoStart: false
    destination: {
      address: !empty(destinationAddress) ? destinationAddress : null
      port: destinationPort
      resourceId: !empty(destinationResourceId) ? destinationResourceId : null
    }
    monitoringIntervalInSeconds: monitoringInterval
    notes: notes
    source: {
      resourceId: sourceResourceId
      port: sourcePort
    }
    endpoints: !empty(endpoints) ? endpoints : null
    testConfigurations: !empty(testConfigurations) ? testConfigurations : null
    testGroups: !empty(testGroups) ? testGroups : null
    outputs: outputs
  }
}

@description('The name of the deployed connection monitor')
output connectionMonitorName string = connectionMonitor.name

@description('The resourceId of the deployed connection monitor')
output connectionMonitorResourceId string = connectionMonitor.id

@description('The resource group the connection monitor was deployed into')
output connectionMonitorResourceGroup string = resourceGroup().name
