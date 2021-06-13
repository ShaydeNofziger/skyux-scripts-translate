Clear-Host

$ModuleName = 'Skyux.Translate'
$PathToModule = "$PSScriptRoot\${ModuleName}.psm1"
$PathToSourceAssetsLocalesDirectory = "$PSScriptRoot\locales\"

# Install-Module Microsoft.PowerShell.SecretManagement
# Set-Secret -Name 'az_cognitive_services_subscription_key' -SecureStringSecret $SecureString

$SubscriptionKey = Get-Secret -Name 'az_cognitive_services_subscription_key' | ConvertFrom-SecureString -AsPlainText

Remove-Module -Name $ModuleName -ErrorAction SilentlyContinue
Import-Module $PathToModule -ErrorAction Stop


[Hashtable]$TranslationParameters = @{
    SubscriptionRegion           = 'eastus2'
    SourceLanguage               = 'en'
    SourceCountryCode            = 'US'
    SubscriptionKey              = $SubscriptionKey
    PathToAssetsLocalesDirectory = $PathToSourceAssetsLocalesDirectory
}

foreach (
    $item in @(
        [PSCustomObject]@{ targetLanguage = 'es'; targetCountry = 'US' },
        [PSCustomObject]@{ targetLanguage = 'fr'; targetCountry = 'FR' },
        [PSCustomObject]@{ targetLanguage = 'fr-ca'; targetCountry = 'CA' },
        [PSCustomObject]@{ targetLanguage = 'it'; targetCountry = 'IT' }
    )
) {
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Host -Object "BEGIN OPERATION     - Processing Translation: '$($item.targetLanguage)_$($item.targetCountry)'"
    Invoke-SkyuxResourcesTranslation -TargetLanguage $item.targetLanguage -TargetCountryCode $item.targetCountry @TranslationParameters
    Write-Host -Object "COMPLETED OPERATION - Processing Translation: '$($item.targetLanguage)_$($item.targetCountry)'      - Time Elapsed: '$($Stopwatch.Elapsed.TotalSeconds) seconds'"
}
