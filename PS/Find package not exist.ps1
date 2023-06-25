$packagesConfig = "...\packages.config"
$assembliesPath = "...\Release\Packages"
$outputDir = "...\Temp1"

Select-Xml -Path $packagesConfig -XPath "/packages/package" | 
    Select-Object -Property @{Name=$packagesConfig;Expression={"$($_.Node.id).$($_.Node.version).nupkg"}} | 
    Sort-Object $packagesConfig |
    Out-File -FilePath "$($outputDir)\packages.config.txt"

Get-ChildItem -Path $assembliesPath | 
    Select-Object -Property @{Name=$assembliesPath;Expression={$_.Name }} | 
    Sort-Object $assembliesPath |
    Out-File -FilePath "$($outputDir)\release.txt"
