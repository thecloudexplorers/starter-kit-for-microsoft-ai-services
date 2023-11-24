


# Deploy params, assuming resource group is already present
$deployArgs = @{
    TemplateFile          = "./src/iac/az-controllers/aiServicesStarterKit.bicep"
    TemplateParameterFile = "./src/params/starterParams.json"
    ResourceGroupName     = "dgs-s-cgs-rg001"
    Name                  = "starter-kit-controller"
}

New-AzResourceGroupDeployment @deployArgs
