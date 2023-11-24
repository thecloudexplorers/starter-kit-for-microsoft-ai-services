#Requires -modules Az.KeyVault

$keyVaultArgs = @{
    VaultName   = "dgs-s-cgs-kv001"
    Name        = "cognitive-service-key"
    AsPlainText = $true
}
$apiKey = Get-AzKeyVaultSecret @keyVaultArgs

# Azure OpenAI metadata variables
$openAi = @{
    api_base    = 'https://dgs-s-cgs-oai007.openai.azure.com/' # your endpoint should look like the following https://YOUR_RESOURCE_NAME.openai.azure.com/
    api_version = '2023-05-15' # this may change in the future
    name        = 'davinci-002' #This will correspond to the custom name you chose for your deployment when you deployed a model.
}

# Header for authentication
$headers = [ordered]@{
    'api-key' = $apiKey
}

# Completion text
$prompt = 'Once upon a time...'

# Adjust these values to fine-tune completions
$body = [ordered]@{
    prompt      = $prompt
    max_tokens  = 30
    temperature = 2
    top_p       = 0.5
} | ConvertTo-Json

# Send a completion call to generate an answer
$url = "$($openai.api_base)/openai/deployments/$($openai.name)/completions?api-version=$($openai.api_version)"

$restMethodArgs = @{
    Uri         = $url
    Headers     = $headers
    Body        = $body
    Method      = 'Post'
    ContentType = 'application/json'
}

$response = Invoke-RestMethod @restMethodArgs
Write-Host $response.choices.text
Write-Host "Stopped here!!!"
