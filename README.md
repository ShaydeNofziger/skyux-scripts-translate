# Skyux.Translate PowerShell Module

This is a PowerShell module intended to be used to auto-generate Skyux Resource json files translations based on a source language file.

The source language file is usually 'src/assets/locales/resources_en_US.json' but the cmdlet is generic enough to work with any source language.

## Usage

```powershell

# Import the module for use at any location in the terminal
Import-Module .\Skyux.Translate.psm1

# These are the configuration values for the Azure Cognitive Services instance that can be created/configured via Azure Portal
$SubscriptionRegion = 'eastus2'
$SubscriptionKey = 'SuperSecretKey'

# The absolute path to the directory containing your 'resources_*_*.json' files
$PathToAssetsLocalesDirectory = 'D:\Repos\skyux-spa-signin\src\assets\locales\'

# Cognitive Services supports 'plain' and 'html' text translations.
# If any of your resource strings contain html tags, such as '<a href=...>',
# be sure to set this to 'html' so those attributes are not translated.
# If all of the values are plaintext, set the value to 'plain'.
$TextType = 'html'

# TargetLanguage and TargetCountryCode are specified here as examples.
# By default, SourceLanguage and SourceCountryCode are assumed to be 'en' and 'US' unless otherwise provided.
Invoke-SkyuxResourcesTranslation -TargetLanguage 'es' -TargetCountryCode 'US' -SubscriptionRegion $SubscriptionRegion -SubscriptionKey $SubscriptionKey -PathToAssetsLocalesDirectory $PathToAssetsLocalesDirectory

```

## Limitations

At this time, Azure Cognitive Services has limited support for differentiation by Country Code (i.e. uk english vs us english). The 'TargetCountryCode' you provide to the cmdlet is currently only used for the output file naming.

## Example output

See the files under the /locales directory at this location for example input/output. For the translations, the 'resources_en_US.json' file was used as the source, and the 'es', 'fr', and 'it' files were specified as the targets.
