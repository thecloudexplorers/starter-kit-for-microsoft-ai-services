#Requires -modules Az.KeyVault

$ssKeyVaultArgs = @{
    VaultName   = "dgs-s-cgs-kv001"
    Name        = "search-service-key"
    AsPlainText = $true
}

$keyVaultArgs = @{
    VaultName   = "dgs-s-cgs-kv001"
    Name        = "cognitive-service-key"
    AsPlainText = $true
}

$searchServicePrimaryKey = Get-AzKeyVaultSecret @ssKeyVaultArgs
$apiKey = Get-AzKeyVaultSecret @keyVaultArgs

# Azure OpenAI metadata variables
$openAi = @{
    api_base    = 'https://dgs-s-cgs-oai007.openai.azure.com/' # your endpoint should look like the following https://YOUR_RESOURCE_NAME.openai.azure.com/
    api_version = '2023-05-15' # this may change in the future
    name        = 'oai-gpt-35-turbo-1106' #This will correspond to the custom name you chose for your deployment when you deployed a model.
}

$acs = @{
    search_endpoint = 'https://dgs-s-cgs-srch007.search.windows.net' # your endpoint should look like the following https://YOUR_RESOURCE_NAME.search.windows.net/
    search_index    = 'kia-ev9-index' # the name of your ACS index
}

# Completion text
$body = @{
    dataSources = @(
        @{
            type       = 'AzureCognitiveSearch'
            parameters = @{
                endpoint  = $acs.search_endpoint
                key       = $searchServicePrimaryKey
                indexName = $acs.search_index
            }
        }
    )
    messages    = @(
        @{
            role    = 'user'
            content = 'How much power does an ev9 have?'
        }
    )
} | ConvertTo-Json -depth 5

# Header for authentication
$headers = [ordered]@{
    'api-key' = $apiKey
}

# Send a completion call to generate an answer
$url = "$($openAi.api_base)openai/deployments/$($openAi.name)/extensions/chat/completions?api-version=2023-07-01-preview"

$response = Invoke-RestMethod -Uri $url -Headers $headers -Body $body -Method Post -ContentType 'application/json'
Write-Host $response.choices.messages[1].content
