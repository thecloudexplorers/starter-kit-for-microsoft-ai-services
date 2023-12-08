#Requires -modules Az.KeyVault

$keyVaultArgs = @{
    VaultName   = "dgs-s-cgs-kv010"
    Name        = "cognitive-service-key"
    AsPlainText = $true
}
$apiKey = Get-AzKeyVaultSecret @keyVaultArgs

# Azure OpenAI metadata variables
$openAi = @{
    api_base    = 'https://dgs-s-cgs-oai010.openai.azure.com/' # your endpoint should look like the following https://YOUR_RESOURCE_NAME.openai.azure.com/
    api_version = '2023-09-01-preview' # this may change in the future
    name        = 'whisper' #This will correspond to the custom name you chose for your deployment when you deployed a model.
}

# Send a request to generate an answer
$url = "$($openAi.api_base)/openai/deployments/$($openAi.name)/audio/transcriptions?api-version=$($openAi.api_version)"

$filePath = Get-Location | Join-Path -ChildPath "src/scripts/resources/AdventCalendar-Day1-slice.mp4"

# C:\repos\wes\aiadventcalendar\starter-kit-for-microsoft-ai-services
# C:\repos\wes\aiadventcalendar\starter-kit-for-microsoft-ai-services\src\scripts\resources\AdventCalendar-Day1-slice.mp4
# C:\repos\wes\aiadventcalendar\starter-kit-for-microsoft-ai-services\resources\AdventCalendar-Day1-slice.mp4

# Curl command
curl $url `
    -H "api-key: $apiKey" `
    -H "Content-Type: multipart/form-data" `
    -F "file=@$filePath"

# # PowerShell command
# $httpClient = New-Object System.Net.Http.HttpClient
# $httpClient.DefaultRequestHeaders.Add("api-key", $apiKey)

# $fileContent = [System.IO.File]::ReadAllBytes($filePath)

# $content = New-Object System.Net.Http.MultipartFormDataContent
# $fileContent = New-Object System.Net.Http.ByteArrayContent($fileContent, 0, $fileContent.Length)
# $content.Add($fileContent, "file", [System.IO.Path]::GetFileName($filePath))

# $response = $httpClient.PostAsync($url, $content).Result

# $response.Content.ReadAsStringAsync().Result

# Write-Host "Stopped here!!!"
