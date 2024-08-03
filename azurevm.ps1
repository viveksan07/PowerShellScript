# Log in to Azure 
Connect-AzAccount -Identity

# Create a resource group
$resourceGroupName = "test1-rg"
$location = "eastus2"
New-AzResourceGroup -Name $resourceGroupName -Location $location



# Retrieve the credential from Azure Automation
$credential = Get-AutomationPSCredential -Name "VMAdminCredential"
if (-not $credential) {
    throw "Could not retrieve the credential. Ensure that the credential name is correct and that it has been added to the Automation Account."
}

# Create a virtual machine configuration
$vmParams = @{
  ResourceGroupName = 'test1-rg'
  Name = 'MyVM'
  Location = 'eastus2'
  ImageName = "MicrosoftWindowsDesktop:windows-11:win11-22h2-pro:latest"
  PublicIpAddressName = 'tutorialPublicIp'
  Credential = $credential
  OpenPorts = 3389
  Size = 'Standard_B2s'
}


# Create the virtual machine
New-AzVM @vmParams    
