# Paste this script to your directory where you want your new project to be created

#$sourcePath = Read-Host 'Enter your existing project path'
#$textToSearch = Read-Host 'Enter the text you want to replace'
#$projectName = Read-Host 'Enter the text you want to replace it with'

$sourcePath = 'C:\Working Directory\DevOps\vgdagpin\Aerish'
$targetPath = 'C:\Working Directory\DevOps\vgdagpin\Aerish Clone'
$textToSearch = 'WorkerService'
$textToReplace = 'Repository'
$isCaseSensitive = $true
$replaceSourcePath = $true

$exclude = @(".vs", ".git", "obj", "bin", "Clone-Project.ps1", "node_modules", "packages", "Packages.zip", "lib")

Function Copy-CloneItems {
    param (
        [string]$Path,
        [string]$Destination,
        [string[]]$Exclude,
        [bool]$ReplaceSourcePath
    )

    # Copy item from this folder to destination
    Get-ChildItem -Path $Path -Exclude $Exclude |
        Copy-Item -Destination {
            Join-Path $Destination $_.FullName.Substring($Path.length)
        }

    # Do it recursively excluding from the list
    Get-ChildItem -Path $Path -Directory -Exclude $Exclude | 
        ForEach-Object {
            Copy-CloneItems -Path "$($_.FullName)\" -Destination "$($Destination)\$($_.FullName.Substring($Path.Length))\" -Exclude $Exclude            
        }

    if ($ReplaceSourcePath) {
        $sourceFiles = Get-ChildItem -Path $Path -Recurse -Exclude $Exclude

        foreach ($item in $sourceFiles) {
            $testOutPath = $item.FullName.Replace($Path, $Destination)

            if (Test-Path -Path $testOutPath) {
                if ($item.PSIsContainer -eq $false) {
                    Remove-Item -Path $item.FullName -Force
                }
            }
        }

        $hasMoreItems = $false;

        # need to do recursive this ways because 
        # some folders have deep heirarchy and we need to delete it one by one
        do {
            $hasMoreItems = $false;

            $sourceFolders = Get-ChildItem -Path $Path -Directory -Recurse -Exclude $Exclude

            foreach ($folder in $sourceFolders) {
                $testOutPath = $folder.FullName.Replace($Path, $Destination)
    
                if (Test-Path -Path $testOutPath) {
                    if ($folder.PSIsContainer -eq $true) {
                        $folderFiles = Get-ChildItem -Path $folder.FullName
    
                        if ($folderFiles.Count -eq 0) {
                            Remove-Item -Path $folder.FullName -Force

                            $hasMoreItems = $true;
                        }
                    }
                }
            }
        } while ($hasMoreItems);
    }
}

Function Rename-CloneItems {
    param (
        [string]$TargetPath,
        [string]$Search,
        [string]$Replace,
        [bool]$IsCaseSensitive
    )

    # Rename directories
    Get-ChildItem -Path $TargetPath -Recurse -Directory | ForEach-Object  {
        $proceed = $false
        $from = $_.FullName;
        $to = $_.FullName

        if ($IsCaseSensitive) {
            if ($_.FullName -clike "*$($Search)*") {
                $to = $_.FullName -creplace $Search, $Replace
                $proceed = $true;
            }
        } else {
            if ($_.FullName -like "*$($Search)*") {
                $to = $_.FullName -replace $Search, $Replace
                $proceed = $true;
            }
        }

        if ($proceed) {
            Try {
                Write-Host "Rename: $($from)"
                Write-Host "To: $($to)"

                Rename-Item -Path $from -NewName $to
            } Catch {
                Write-Host "Error Copy File: $($from) to $($to)"
            }
        }
    }

    # Rename files
    Get-ChildItem -Path $TargetPath -Recurse -File | ForEach-Object  {
        $proceed = $false
        $from = $_.FullName;
        $to = $_.FullName

        if ($IsCaseSensitive) {
            if ($_.FullName -clike "*$($Search)*") {
                $to = $_.FullName -creplace $Search, $Replace
                $proceed = $true;
            }
        } else {
            if ($_.FullName -like "*$($Search)*") {
                $to = $_.FullName -replace $Search, $Replace
                $proceed = $true;
            }
        }

        if ($proceed) {
            Try {
                Write-Host "Rename: $($from)"
                Write-Host "To: $($to)"

                Rename-Item -Path $from -NewName $to
            } Catch {
                Write-Host "Error Copy File: $($from) to $($to)"
            }
        }
    }
}

Function Update-CloneContents {
    param (
        [string]$TargetPath,
        [string]$Search,
        [string]$Replace,
        [bool]$IsCaseSensitive
    )

    # Replace Contents
    Get-ChildItem -Path $TargetPath -Recurse -File | ForEach-Object {       
        Try {
            $content = (Get-Content -path $_.FullName -Raw);

            if ($IsCaseSensitive) {
                if ($content -clike "*$($textToSearch)*") {
                    ($content -creplace $textToSearch,$textToReplace) | Set-Content -Encoding UTF8 -Path $_.FullName -NoNewline
                }
            } else {
                if ($content -like "*$($textToSearch)*") {
                    ($content -replace $textToSearch,$textToReplace) | Set-Content -Encoding UTF8 -Path $_.FullName -NoNewline
                }
            }
            
        } Catch {
            Write-Host "Error while replacing content"
        }
    }
}

Copy-CloneItems -Path $sourcePath -Destination $targetPath -Exclude $exclude -ReplaceSourcePath $replaceSourcePath
Rename-CloneItems -TargetPath $targetPath -Search $textToSearch -Replace $textToReplace -IsCaseSensitive $isCaseSensitive
Update-CloneContents -TargetPath $targetPath -Search $textToSearch -Replace $textToReplace -IsCaseSensitive $isCaseSensitive

if ($replaceSourcePath) {
    Copy-CloneItems -Path $targetPath -Destination $sourcePath -Exclude $exclude -ReplaceSourcePath $replaceSourcePath

    Remove-Item -Path $targetPath -Force
}