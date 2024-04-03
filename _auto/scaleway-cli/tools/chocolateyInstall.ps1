$ErrorActionPreference = 'Stop'
$version = "2.29.0"
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$removeFile = "$toolsDir\scaleway-cli_${version}_windows_386.exe"
$renameFile = "$toolsDir\scaleway-cli_${version}_windows_amd64.exe"

if ((Get-OSArchitectureWidth -Compare 32) -or $env:ChocolateyForceX86) {
    $removeFile = "$toolsDir\scaleway-cli_${version}_windows_amd64.exe"
    $renameFile = "$toolsDir\scaleway-cli_${version}_windows_386.exe"
}

Remove-Item `
    -Path "$toolsDir\scw.exe", $removeFile `
    -Force `
    -ErrorAction SilentlyContinue

Rename-Item `
    -Path $renameFile `
    -NewName "scw.exe" `
    -Force
