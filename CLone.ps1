# Paste this script to your directory where you want your new project to be created

#$templatePath = Read-Host 'Enter your existing project path'
#$textToSearch = Read-Host 'Enter the text you want to replace'
#$projectName = Read-Host 'Enter the text you want to replace it with'

$templatePath = 'C:\Working Directory\DevOps\vgdagpin\Aerish Clone'
$targetPath = 'C:\Working Directory\DevOps\vgdagpin\Aerish Clone 2'
$textToSearch = 'Repositories'
$textToReplace = 'Services'

$exclude = @(".vs", ".git", "obj", "bin", "Clone-Project.ps1", "node_modules", "packages", "Packages.zip", "lib")

Function XCopy-Item {
    param (
        [string]$Path,
        [string]$Destination,
        [string[]]$Exclude
    )

    # Copy item from this folder to destination
    Get-ChildItem -Path $Path -Exclude $Exclude |
        Copy-Item -Destination {
            Join-Path $Destination $_.FullName.Substring($Path.length)
        }

    # Do it recursively excluding from the list
    Get-ChildItem -Path $Path -Directory -Exclude $Exclude | 
        ForEach-Object {
            XCopy-Item -Path "$($_.FullName)\" -Destination "$($Destination)\$($_.FullName.Substring($Path.Length))\" -Exclude $Exclude            
        }
}

Function XRename-Items {
    param (
        [string]$TargetPath,
        [string]$Search,
        [string]$Replace
    )

    # Rename directories
    Get-ChildItem -Path $TargetPath -Recurse -Directory | ForEach-Object  {
        if ($_.FullName.Contains($Search)) {
            $from = $_.FullName;
            $to = $_.FullName.Replace($Search, $Replace);
    
            Try {
                Rename-Item -Path $from -NewName $to
            } Catch {
                Write-Host "Error Copy Directory: $($from) to $($to)"
            }
        }
    }

    # Rename files
    Get-ChildItem -Path $TargetPath -Recurse -File | ForEach-Object  {
        if ($_.FullName.Contains($Search)) {
            $from = $_.FullName;
            $to = $_.FullName.Replace($Search, $Replace);
    
            Try {
                Rename-Item -Path $from -NewName $to
            } Catch {
                Write-Host "Error Copy File: $($from) to $($to)"
            }
        }
    }
}

Function XReplace-Contents {
    param (
        [string]$TargetPath,
        [string]$Search,
        [string]$Replace
    )

    # Replace Contents
    Get-ChildItem -Path $TargetPath -Recurse -File | ForEach-Object {       
        Try {
            $content = (Get-Content -path $_.FullName -Raw);
            if ($content -like "*$($textToSearch)*") {
                ($content -replace $textToSearch,$textToReplace) | Set-Content -Encoding UTF8 -Path $_.FullName -NoNewline
            }
        } Catch {
            Write-Host "Error while replacing content"
        }
    }
}

XCopy-Item -Path $templatePath -Destination $targetPath -Exclude $exclude
XRename-Items -TargetPath $targetPath -Search $textToSearch -Replace $textToReplace
XReplace-Contents -TargetPath $targetPath -Search $textToSearch -Replace $textToReplace
