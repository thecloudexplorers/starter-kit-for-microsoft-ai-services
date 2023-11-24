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
    name        = 'oai-gpt-35-turbo' #This will correspond to the custom name you chose for your deployment when you deployed a model.
}

# Header for authentication
$headers = [ordered]@{
    'api-key' = $apiKey
}


# Completion text
$messages = @()
$messages += @{
    role    = 'system'
    content = 'You are an Xbox customer support agent whose primary goal is to help users with issues they are experiencing with their Xbox devices. You are friendly and concise. You only provide factual answers to queries, and do not provide answers that are not related to Xbox.'
}
# $messages += @{
#     role    = 'user'
#     content = 'How much is a PS5?'
# }

$messages += @{
    role    = 'user'
    content = 'What is hte cheapest version of an Xbox'
}

# Adjust these values to fine-tune completions
$body = [ordered]@{
    messages = $messages
} | ConvertTo-Json

# Send a request to generate an answer
$url = "$($openAi.api_base)/openai/deployments/$($openAi.name)/chat/completions?api-version=$($openAi.api_version)"

$response = Invoke-RestMethod -Uri $url -Headers $headers -Body $body -Method Post -ContentType 'application/json'
$response.choices.message
$response.model
Write-Host "Stopped here!!!"
