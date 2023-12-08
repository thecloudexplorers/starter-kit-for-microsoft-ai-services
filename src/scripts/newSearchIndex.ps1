#Requires -modules Az.KeyVault

$ssKeyVaultArgs = @{
    VaultName   = "dgs-s-cgs-kv001"
    Name        = "search-service-key"
    AsPlainText = $true
}

$saKeyVaultArgs = @{
    VaultName   = "dgs-s-cgs-kv001"
    Name        = "storage-account-connection-string"
    AsPlainText = $true
}

$indexName = "kia-ev9-index"
$indexerName = "kia-ev9-indexer"
$defaultSearchIndexJsonFilePath = "./src/params/defaultSearchIndex.json"
$searchServiceName = "dgs-s-cgs-srch007"
$dataSourceName = "dgsscgssa007"
$dataSourceContainerName = "fileupload-index-007"
$searchServicePrimaryKey = Get-AzKeyVaultSecret @ssKeyVaultArgs
$storageAccountConnectionString = Get-AzKeyVaultSecret @saKeyVaultArgs

$defaultSearchIndexDefinition = Get-Content $defaultSearchIndexJsonFilePath
$defaultSearchIndexDefinition = $defaultSearchIndexDefinition.Replace("##{index_name}##", $indexName)

$headers = @{
    'api-key'      = $searchServicePrimaryKey
    'Content-Type' = 'application/json'
    'Accept'       = 'application/json'
}

# create index
$postIndexesUri = "https://$searchServiceName.search.windows.net/indexes?api-version=2023-11-01"
$getIndexesUri = "https://$searchServiceName.search.windows.net/indexes/$($indexName)?api-version=2023-11-01"

$indexExists = Invoke-RestMethod -Uri $getIndexesUri -Headers $headers -Method GET -SkipHttpErrorCheck -StatusCodeVariable "httpResponseCodeIndexesApi"

switch ($httpResponseCodeIndexesApi) {
    '404' {
        # Index doest exists
        $indexExists = Invoke-RestMethod -Uri $postIndexesUri -Headers $headers -Method POST -Body $defaultSearchIndexDefinition
        Write-Host "Index [$($indexExists.name)] created"
    }
    '200' {
        # Index exists
        Write-Host "Index [$($indexExists.name)] already exists, skipping creation"
    }
    Default {
        Write-Exception "Unexpected response code: $httpResponseCode" -ErrorAction Stop
    }
}

# create data source
$jsonSearchDataSource = @{
    name                        = $dataSourceName
    description                 = $null
    type                        = "azureblob"
    subtype                     = $null
    credentials                 = @{
        connectionString = $storageAccountConnectionString
    }
    container                   = @{
        name  = $dataSourceContainerName
        query = $null
    }
    dataChangeDetectionPolicy   = $null
    dataDeletionDetectionPolicy = $null
    encryptionKey               = $null
}

$searchDataSource = $jsonSearchDataSource | ConvertTo-Json


$url = "https://$searchServiceName.search.windows.net/datasources?api-version=2023-11-01"

Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $searchDataSource

# create indexer
$jsonIndexer = @{
    name            = $indexerName
    dataSourceName  = $dataSourceName
    targetIndexName = $indexName
    parameters      = @{
        configuration = @{
            dataToExtract = "contentAndMetadata"
        }
    }
}

$indexer = $jsonIndexer | ConvertTo-Json

$url = "https://$searchServiceName.search.windows.net/indexers?api-version=2023-11-01"

Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $indexer

Write-Host "Stopped here!!!"
