$packagesConfig = "C:\SourceCode_clients\PPGIndustries\BenefitConnect\Development\Solution\Admin\packages.config"
$assembliesPath = "C:\Assemblies\BenefitConnect\v5\2023.1.169.9\Release\Packages"
$outputDir = "C:\Users\VINCE8110\OneDrive - Willis Towers Watson\Documents\Temp1"

Select-Xml -Path $packagesConfig -XPath "/packages/package" | 
    Select-Object -Property @{Name=$packagesConfig;Expression={"$($_.Node.id).$($_.Node.version).nupkg"}} | 
    Sort-Object $packagesConfig |
    Out-File -FilePath "$($outputDir)\packages.config.txt"

Get-ChildItem -Path $assembliesPath | 
    Select-Object -Property @{Name=$assembliesPath;Expression={$_.Name }} | 
    Sort-Object $assembliesPath |
    Out-File -FilePath "$($outputDir)\release.txt"
