
# Deploy params, assuming resource group is already present
$deployDataEncryption = @{
    TemplateFile          = "./src/iac/az-controllers/dataEncryption.bicep"
    TemplateParameterFile = "./src/params/dataEncryptionParams.json"
    ResourceGroupName     = "dgs-s-cgs-rg001"
    Name                  = "data-encryption-controller"
}

New-AzResourceGroupDeployment @deployDataEncryption

# Deploy params, assuming resource group is already present
$deployArgs = @{
    TemplateFile          = "./src/iac/az-controllers/aiServicesStarterKit.bicep"
    TemplateParameterFile = "./src/params/aiServicesStarterKitParams.json"
    ResourceGroupName     = "dgs-s-cgs-rg001"
    Name                  = "starter-kit-controller"
}

New-AzResourceGroupDeployment @deployArgs
