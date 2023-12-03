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
$searchServiceName = "dgs-s-cgs-srch001"
$dataSourceName = "dgsscgssa001"
$dataSourceContainerName = "fileupload-kia-ev9"
$searchServicePrimaryKey = Get-AzKeyVaultSecret @ssKeyVaultArgs
$storageAccountConnectionString = Get-AzKeyVaultSecret @saKeyVaultArgs

$defaultSearchIndexDefinition = Get-Content $defaultSearchIndexJsonFilePath
$defaultSearchIndexDefinition = $defaultSearchIndexDefinition.Replace("##{index_name}##", $indexName)

$headers = @{
    'api-key'      = $searchServicePrimaryKey
    'Content-Type' = 'application/json'
    'Accept'       = 'application/json'
}

$url = "https://$searchServiceName.search.windows.net/indexes?api-version=2023-11-01"
Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $defaultSearchIndexDefinition


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
