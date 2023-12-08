# Define variables
# $templateFile = "./src/iac/az-controllers/aiServicesStarterKit.bicep"

$templateFile = "C:\repos\wes\aiadventcalendar\starter-kit-for-microsoft-ai-services\src\iac\az-controllers\aiServicesStarterKit.bicep"
$templateParameterFile = "C:\repos\wes\aiadventcalendar\starter-kit-for-microsoft-ai-services\src\params\starterParams.json"
$resourceGroupName = "dgs-s-cgs-rg001"
$deploymentName = "starter-kit-controller"

# Deploy
az deployment group create `
    --resource-group $resourceGroupName `
    --template-file $templateFile `
    --parameters @$templateParameterFile `
    --name $deploymentName
