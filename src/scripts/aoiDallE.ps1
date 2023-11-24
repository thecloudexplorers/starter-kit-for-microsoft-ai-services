#Requires -modules Az.KeyVault

$keyVaultArgs = @{
    VaultName   = "dgs-s-cgs-kv001"
    Name        = "cognitive-service-key"
    AsPlainText = $true
}
$apiKey = Get-AzKeyVaultSecret @keyVaultArgs

# Azure OpenAI metadata variables
$openAIApi = @{
    apiBaseUri     = 'https://dgs-s-cgs-oai007.openai.azure.com/' # your endpoint should look like the following https://YOUR_RESOURCE_NAME.openai.azure.com/
    apiVersion     = '2023-12-01-preview' # this may change in the future
    deploymentName = 'oai-dall-e-3' #This will correspond to the custom name you chose for your deployment when you deployed the DALL-E model.
}

# Text to describe image
$prompt = 'Big person, small person, and a cat. Anime style'

# Header for authentication
$headers = [ordered]@{
    'api-key' = $apiKey
}

# Adjust these values to fine-tune completions
$body = [ordered]@{
    prompt = $prompt
    size   = '1024x1024'
    n      = 1
} | ConvertTo-Json

# Call the API to generate the image and retrieve the response
$url = "$($openAIApi.apiBaseUri)/openai/deployments/$($openAIApi.deploymentName)/images/generations?api-version=$($openAIApi.apiVersion)"

$restMethodArgs = @{
    Uri         = $url
    Headers     = $headers
    Body        = $body
    Method      = 'Post'
    ContentType = 'application/json'
}


$submission = Invoke-RestMethod @restMethodArgs

# Set the directory for the stored image
$imgDirPath = Join-Path -Path $(Get-Location) -ChildPath 'images'

# Create a subdirectory if it doesn't exist, create it
if (-not(Resolve-Path $imgDirPath -ErrorAction Ignore)) {
    New-Item -Path $imgDirPath -ItemType Directory
}

# Initialize the image path (note the filetype should be png)
$executionDate = Get-Date -Format "yyyy-MM-dd_HHmmss"
$imageName = $executionDate + "-gen_image.png"
$imagePath = Join-Path -Path $imgDirPath -ChildPath $imageName

Invoke-WebRequest -Uri $submission.data.url -OutFile $imagePath
