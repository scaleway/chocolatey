import-module au
. $([System.IO.Path]::Combine((Split-Path -Parent $PSScriptRoot), "..", "_scripts", "Get-GithubLatestReleaseLinks.ps1"))


function global:au_SearchReplace {
    @{
        ".\legal\VERIFICATION.txt"      = @{
            "(?i)(\s+x86:).*"        = "`${1} $($Latest.Url32)"
            "(?i)(\s+x64:).*"        = "`${1} $($Latest.Url64)"
            "(?i)(\s+checksum32:).*" = "`${1} $($Latest.Checksum32)"
            "(?i)(\s+checksum64:).*" = "`${1} $($Latest.Checksum64)"
        }
        ".\tools\chocolateyinstall.ps1" = @{
            "(^[$]version\s*=\s*)("".*"")" = "`$1""$($Latest.Version)"""
        }
        ".\scaleway-cli.nuspec"         = @{
            "(?i)(\<releaseNotes\>).*(\<\/releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`${2}"
        }
    }
}

$github_user = "scaleway"
$github_repository = "scaleway-cli"
$github_repository_full = "$github_user/$github_repository"
$github_repository_full_url = "https://github.com/$github_repository_full"

function global:au_GetLatest {
    $rel = (Get-GitHubLatestReleaseLinks -user $github_user -repository $github_repository).Links | ForEach-Object href
    $relative_url = $rel | Where-Object { $_ -match "/$github_repository_full/releases/download/v\d+\.\d+(\.\d+)*/scaleway-cli_\d+\.\d+(\.\d+)*_windows_386\.exe" } | Select-Object -First 1
    $version = ([regex]::Match($relative_url, "/v(\d+\.\d+(\.\d+)*)/")).Groups[1].Value
    @{
        Url32        = "$github_repository_full_url/releases/download/v$version/scaleway-cli_${version}_windows_386.exe"
        Url64        = "$github_repository_full_url/releases/download/v$version/scaleway-cli_${version}_windows_amd64.exe"
        Version      = $version
        ReleaseNotes = "$github_repository_full_url/releases/tag/v$version"
    }
}
function global:au_BeforeUpdate {
    Get-RemoteFiles -Purge -NoSuffix
}

Update-Package -ChecksumFor None
