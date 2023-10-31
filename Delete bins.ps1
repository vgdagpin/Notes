Get-ChildItem .\ -Include bin,obj,packages,TestResults,node_modules `
    -Recurse | ForEach-Object ($_) { 
        Remove-Item $_.fullname -Force -Recurse 
    }