Function Remove-PackageReferences {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$project
    )
    Write-Host $project

    tf checkout $project 2>$null

    $xmlDocument = [xml](Get-Content -Path $project)

    $ns = New-Object -TypeName System.Xml.XmlNamespaceManager -ArgumentList $xmlDocument.NameTable
    $ns.AddNamespace("ns", "http://schemas.microsoft.com/developer/msbuild/2003")

    $xpath = "/ns:Project/ns:ItemGroup/ns:Reference[ns:HintPath]"

    $references = $xmlDocument.SelectNodes($xpath, $ns)

    foreach ($reference in $references) {
        [void]$reference.ParentNode.RemoveChild($reference)
    }

    $xmlDocument.Save($project)
}