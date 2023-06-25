$dbProjPath = "...\Database.sqlproj" 
$xDoc = [System.Xml.Linq.XDocument]::Load($dbProjPath) 

foreach ($itemGroup in $xDoc.Root.Elements().Where({ $_.Name.LocalName -eq "ItemGroup" })) 
{ 
    $orderedItems = $itemGroup.Elements() | 
        Sort-Object { $_.Attribute("Include").Value } | 
        ForEach-Object { 
            #$newElement = [System.Xml.Linq.XElement]::new($_.Name) 
            #$newElement.SetAttributeValue("Include", $_.Attribute("Include").Value) 
            #$newElement 
            $_.DeepClone()
        } 
    
    $itemGroup.RemoveAll() 
    $itemGroup.Add($orderedItems) 
}

$xDoc.Save($dbProjPath)