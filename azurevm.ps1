# Log in to Azure 
Connect-AzAccount -Identity

# Create a resource group
$resourceGroupName = "test-rg"
$location = "EastUS2"
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a virtual network and a subnet
$vnetName = "vnet-1"
$subnetName = "subnet-1"
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $vnetName -AddressPrefix "10.0.0.0/16"
Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.1.0/24" -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Get the virtual network and subnet
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = $vnet.Subnets | Where-Object { $_.Name -eq $subnetName }

# Create a network interface for the VM
$nicName = "nic-2"
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnet.Id

# Retrieve the credential from Azure Automation
$credential = Get-AutomationPSCredential -Name "VMAdminCredential"
if (-not $credential) {
    throw "Could not retrieve the credential. Ensure that the credential name is correct and that it has been added to the Automation Account."
}

# Create a virtual machine configuration
$vmName = "MyVM"

$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_B2s" | `
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $credential | `
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsDesktop" -Offer "windows-11" -Skus "win11-22h2-pro" -Version "latest" | `
    Add-AzVMNetworkInterface -Id $nic.Id

# Create the virtual machine
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
