Function Remove-SqlDoubleSpace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$file
    )

    $outFile = "$($file).bak"

    $fileTemp = [System.IO.File]::OpenText($file)
    $tempResult = [System.IO.File]::CreateText($outFile)

    $hasUpdates = $false
    $previousLineIsBlank = $false
    while (!$fileTemp.EndOfStream) {
        $curLine = $fileTemp.ReadLine()

        $curLineIsBlank = [string]::IsNullOrWhiteSpace($curLine)

        if ($curLineIsBlank -eq $false -or $previousLineIsBlank -eq $false) {
            $tempResult.WriteLine($curLine)
        }
        else {
            $hasUpdates = $true
        }

        $previousLineIsBlank = $curLineIsBlank
    }

    $fileTemp.Close()
    $tempResult.Close()

    $isCheckedOut = $false
    if ($hasUpdates) {
        tf checkout $file 2>$null

        $isCheckedOut = $true

        Remove-Item -Path $file
        Move-Item -Path $outFile -Destination $file
    }
    else {
        Remove-Item -Path $outFile
    }

    # this is to remove empty lines at end of file

    $content = [System.IO.File]::ReadAllText($file)
    $updatedContent = $content.Trim()

    if ($content.Length -ne $updatedContent.Length) {
        if ($isCheckedOut -eq $false) {
            tf checkout $file 2>$null
        }

        $updatedContent | Set-Content -Path $file
    }
}
