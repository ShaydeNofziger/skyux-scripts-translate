<#
.SYNOPSIS
Create a translated resources.json file, given a source resources.json file

.DESCRIPTION
Utilize Azure Cognitive Service's translate api to auto-generate translations of resource strings to a target language.
Outputs a resources.json file for the specified target language/country alongside the source resources.json file at the directory specified.

.PARAMETER TargetLanguage
The language to translate to

.PARAMETER TargetCountryCode
The country code to use when outputting results to the resources.json file

.PARAMETER PathToAssetsLocalesDirectory
The absolute path to your skyux assets/locales directory where the resource.json files are placed

.PARAMETER SourceLanguage
The source language from the existing file to translate from

.PARAMETER SourceCountryCode
The source country code from the existing file to translate from

.PARAMETER SubscriptionKey
Azure Cognitive Services instance subscription key

.PARAMETER SubscriptionRegion
Azure Cognitive Services instance region

.PARAMETER TextType
Specify whether the source text is 'plain' or 'html'.

.EXAMPLE
Invoke-SkyuxResourcesTranslation -SourceLanguage 'en' -SourceCountryCode 'US' -TargetLanguage 'es' -TargetCountryCode 'US' -TextType 'html' -SubscriptionRegion 'eastus2' -SubscriptionKey '*****' -PathToAssetsLocalesDirectory 'D:\Repos\skyux-spa-signin\src\assets\resources_en_US.json'

.NOTES
See README.md at the root of this module's containing directory for more information.
#>
function Invoke-SkyuxResourcesTranslation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'af', 'sq', 'am', 'ar', 'hy', 'as', 'az', 'bn', 'bs', 'bg', 'yue', 'ca', 'zh-Hans', 'zh-Hant', 'hr',
            'cs', 'da', 'prs', 'nl', 'en', 'et', 'fj', 'fil', 'fi', 'fr', 'fr-ca', 'de', 'el', 'gu', 'ht',
            'he', 'hi', 'mww', 'hu', 'is', 'id', 'iu', 'ga', 'it', 'ja', 'kn', 'kk', 'km', 'tlh-Latn',
            'tlh-Piqd', 'ko', 'ku', 'kmr', 'lo', 'lv', 'lt', 'mg', 'ms', 'ml', 'mt', 'mi', 'mr', 'my', 'ne',
            'nb', 'or', 'ps', 'fa', 'pl', 'pt', 'pt-pt', 'pa', 'otq', 'ro', 'ru', 'sm', 'sr-Cyrl', 'sr-Latn',
            'sk', 'sl', 'es', 'sw', 'sv', 'ty', 'ta', 'te', 'th', 'ti', 'to', 'tr', 'uk', 'ur', 'vi', 'cy', 'yua'
        )]
        [string] $TargetLanguage,

        [Parameter(Mandatory = $false)]
        [ValidateLength(2, 2)]
        [string] $TargetCountryCode = 'US',

        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-Path -Path $_ })]
        [string] $PathToAssetsLocalesDirectory,

        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'af', 'sq', 'am', 'ar', 'hy', 'as', 'az', 'bn', 'bs', 'bg', 'yue', 'ca', 'zh-Hans', 'zh-Hant', 'hr',
            'cs', 'da', 'prs', 'nl', 'en', 'et', 'fj', 'fil', 'fi', 'fr', 'fr-ca', 'de', 'el', 'gu', 'ht',
            'he', 'hi', 'mww', 'hu', 'is', 'id', 'iu', 'ga', 'it', 'ja', 'kn', 'kk', 'km', 'tlh-Latn',
            'tlh-Piqd', 'ko', 'ku', 'kmr', 'lo', 'lv', 'lt', 'mg', 'ms', 'ml', 'mt', 'mi', 'mr', 'my', 'ne',
            'nb', 'or', 'ps', 'fa', 'pl', 'pt', 'pt-pt', 'pa', 'otq', 'ro', 'ru', 'sm', 'sr-Cyrl', 'sr-Latn',
            'sk', 'sl', 'es', 'sw', 'sv', 'ty', 'ta', 'te', 'th', 'ti', 'to', 'tr', 'uk', 'ur', 'vi', 'cy', 'yua'
        )]
        [string] $SourceLanguage = 'en',

        [Parameter(Mandatory = $false)]
        [ValidateLength(2, 2)]
        [string] $SourceCountryCode = 'US',

        [Parameter(Mandatory = $true)]
        [string] $SubscriptionKey,

        [Parameter(Mandatory = $true)]
        [string] $SubscriptionRegion,

        [Parameter(Mandatory = $false)]
        [ValidateSet('html', 'plain')]
        [string] $TextType = 'plain'
    )

    begin {
        $TargetCountryCode = $TargetCountryCode.ToUpper()
        $SourceCountryCode = $SourceCountryCode.ToUpper()
        [string]$SourceResourcesFilePath = Join-Path -Path $PathToAssetsLocalesDirectory -ChildPath "resources_${SourceLanguage}_${SourceCountryCode}.json"

        [Hashtable]$Headers = @{
            'Ocp-Apim-Subscription-Key'    = $SubscriptionKey
            'Ocp-Apim-Subscription-Region' = $SubscriptionRegion
            'Content-Type'                 = 'application/json'
        }

        if (-not (Test-Path -Path $SourceResourcesFilePath)) {
            throw "Path to source language file does not exist! Path: '$SourceResourcesFilePath'"
        }
    }

    process {
        [string]$BaseUrl = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=${SourceLanguage}&textType=${TextType}&to=${TargetLanguage}"
        [string]$OutputFilePath = Join-Path -Path $PathToAssetsLocalesDirectory -ChildPath "resources_${TargetLanguage}_${TargetCountryCode}.json"

        $SourceResources = Get-Content -Path $SourceResourcesFilePath -Raw | ConvertFrom-Json

        $ResourceStrings = $SourceResources.PSObject.Properties | Where-Object -Property 'MemberType' -eq 'NoteProperty' `
        | Select-Object -Property @(
            'Name',
            @{ Name = 'Description'; Expression = { $_.Value.'_description' } },
            @{ Name = 'Message'; Expression = { $_.Value.'message' } }
        )

        $BodyArray = @()

        foreach ($resourceString in $ResourceStrings) {
            $BodyArray += [PSCustomObject]@{
                'Text' = $resourceString.'message'
            }
        }

        $ChunkedRequests = Split-ArrayInChunks -InputArray $BodyArray -NumberOfChunks ([Math]::Ceiling($BodyArray.Count / 50))


        $Results = New-Object -TypeName 'System.Collections.ArrayList'

        foreach ($chunkedRequest in $ChunkedRequests) {
            Start-Sleep -Seconds 0.5
            $Response = Invoke-RestMethod -Uri $BaseUrl -Method 'Post' -Headers $Headers -Body ($chunkedRequest | ConvertTo-Json)
            $Results.AddRange($Response)
        }


        $TranslatedResults = [PSCustomObject]@{ }

        for ($i = 0; $i -lt $Results.Count; $i++) {
            Add-Member -InputObject $TranslatedResults -NotePropertyName $ResourceStrings[$i].'Name' -NotePropertyValue ([PSCustomObject]@{
                    '_description' = $ResourceStrings[$i].'Description'
                    'message'      = ($Results[$i].'translations'.'text').Replace('&apos;', "'").Replace('&quot;', "'")
                })
        }

        $TranslatedResults | ConvertTo-Json | Out-File -FilePath $OutputFilePath -Force
    }

    end {

    }
}

Export-ModuleMember -Function 'Invoke-SkyuxResourcesTranslation'
