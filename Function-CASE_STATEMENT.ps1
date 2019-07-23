Function ChangingCountries {
# Fancy Case switch to fix country to ISO 3166-1 Standard
    $Script:NewCountry = $name.'Work Address Country Name'  # Remove after testing
    Write-Host "Old Country Code "$NewCountry #Remove after Testing

   Switch ($NewCountry){
        Australia {$Script:NewCountry = "AU"}
        Canada {$Script:NewCountry = "CA"}
        China {$Script:NewCountry = "CN"}
        Germany {$Script:NewCountry = "DE"}
        "Hong Kong" {$Script:NewCountry = "HK"}
        India {$Script:NewCountry = "IN"}
        Ireland {$Script:NewCountry = "IE"}
        Japan {$Script:NewCountry = "JP"}
        "New Zealand" {$Script:NewCountry = "NZ"}
        Poland {$Script:NewCountry = "PL"}
        Singapore {$Script:NewCountry = "SG"}
        Switzerland {$Script:NewCountry = "SZ"}
        "United Kingdom" {$Script:NewCountry = "UK"}
        "United States of America" {$Script:NewCountry = "US"}
        "United States" {$Script:NewCountry = "US"}
        Default {$Script:NewCountry = "AQ"} #Sets Default to Antartica incase it doesnt detect the Country Properly
   }

   Write-Host "New Country Code "$NewCountry #Remove after testing
