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
# parameters!
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
Write-Host "Creating Index [$indexName]"
$getIndexesUri = "https://$searchServiceName.search.windows.net/indexes/$($indexName)?api-version=2023-11-01"
$postIndexesUri = "https://$searchServiceName.search.windows.net/indexes?api-version=2023-11-01"


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
        Write-Exception "Unexpected response code: $httpResponseCodeIndexesApi" -ErrorAction Stop
    }
}

# create data source
Write-Host "Creating Data Source [$dataSourceName]"
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


$getDataSourceUri = "https://$searchServiceName.search.windows.net/datasources/$($dataSourceName)?api-version=2023-11-01"
$postDataSourceUri = "https://$searchServiceName.search.windows.net/datasources?api-version=2023-11-01"

$dataSourceExists = Invoke-RestMethod -Uri $getDataSourceUri -Headers $headers -Method GET -SkipHttpErrorCheck -StatusCodeVariable "httpResponseCodeDataSourcesApi"

switch ($httpResponseCodeDataSourcesApi) {
    '404' {
        # Data Source doest exists
        $dataSourceExists = Invoke-RestMethod -Uri $postDataSourceUri -Headers $headers -Method POST -Body $searchDataSource
        Write-Host "Data Source [$($dataSourceExists.name)] created"
    }
    '200' {
        # Data Source exists
        Write-Host "Data Source [$($dataSourceExists.name)] already exists, skipping creation"
    }
    Default {
        Write-Exception "Unexpected response code: $httpResponseCodeDataSourcesApi" -ErrorAction Stop
    }
}

# create indexer
Write-Host "Creating Indexer [$indexerName]"
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

$getIndexerUri = "https://$searchServiceName.search.windows.net/indexers$($indexerName)?api-version=2023-11-01"
$postIndexerUri = "https://$searchServiceName.search.windows.net/indexers?api-version=2023-11-01"

$indexerExists = Invoke-RestMethod -Uri $getIndexerUri -Headers $headers -Method GET -SkipHttpErrorCheck -StatusCodeVariable "httpResponseCodeIndexerApi"

switch ($httpResponseCodeIndexerApi) {
    '404' {
        # Indexer doest exists
        $indexerExists = Invoke-RestMethod -Uri $postIndexerUri -Headers $headers -Method POST -Body $indexer
        Write-Host "Indexer [$($indexerExists.name)] created"
    }
    '200' {
        # Indexer exists
        Write-Host "Indexer [$($indexerExists.name)] already exists, skipping creation"
    }
    Default {
        Write-Exception "Unexpected response code: $httpResponseCodeIndexerApi" -ErrorAction Stop
    }
}

Write-Host "All done!!!"
