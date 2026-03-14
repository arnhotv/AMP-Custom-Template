[CmdletBinding()]
param(
    [Parameter()]
    [string]$AmpInstanceRoot,

    [Parameter()]
    [switch]$DownloadInstaller,

    [Parameter()]
    [switch]$RunInstaller,

    [Parameter()]
    [switch]$UpdateExisting
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $AmpInstanceRoot) {
    $AmpInstanceRoot = Read-Host 'AMP instance root (example: C:\AMPDatastore\Instances\dcs-world-server)'
}

$pageUrl = 'https://www.digitalcombatsimulator.com/en/downloads/world/server/'
$manualDir = Join-Path $AmpInstanceRoot '_manual_steps'
New-Item -ItemType Directory -Path $manualDir -Force | Out-Null

function Get-DcsInstallerUrl {
    param([string]$PageUrl)

    $response = Invoke-WebRequest -Uri $PageUrl

    $link = $null
    if ($response.Links) {
        $link = $response.Links |
            Where-Object { $_.href -match 'DCS_World_Server_modular\.exe$' } |
            Select-Object -ExpandProperty href -First 1
    }

    if (-not $link) {
        $match = [regex]::Match($response.Content, '(?<url>/upload/[^"''<>]+/DCS_World_Server_modular\.exe)')
        if ($match.Success) {
            $link = $match.Groups['url'].Value
        }
    }

    if (-not $link) {
        throw 'Impossible de trouver l\'URL du DCS_World_Server_modular.exe depuis la page officielle.'
    }

    if ($link -notmatch '^https?://') {
        $base = [Uri]$PageUrl
        $link = [Uri]::new($base, $link).AbsoluteUri
    }

    return $link
}

if ($DownloadInstaller -or $RunInstaller) {
    $installerUrl = Get-DcsInstallerUrl -PageUrl $pageUrl
    $installerPath = Join-Path $manualDir 'DCS_World_Server_modular.exe'

    Write-Host "Téléchargement depuis: $installerUrl"
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    Write-Host "Installer téléchargé vers: $installerPath"

    if ($RunInstaller) {
        Write-Host 'Lancement de l\'installateur. Choisis comme dossier d\'installation le root de l\'instance AMP.'
        Write-Host "Cible conseillée: $AmpInstanceRoot"
        Start-Process -FilePath $installerPath -Wait
    }
}

if ($UpdateExisting) {
    $updaterPath = Join-Path $AmpInstanceRoot 'bin\DCS_updater.exe'
    if (-not (Test-Path -LiteralPath $updaterPath)) {
        throw "Impossible de trouver $updaterPath"
    }

    $workingDir = Split-Path -Path $updaterPath -Parent
    Write-Host "Mise à jour via: $updaterPath --quiet update"
    Start-Process -FilePath $updaterPath -ArgumentList '--quiet update' -WorkingDirectory $workingDir -Wait
}

Write-Host ''
Write-Host 'Terminé.'
Write-Host 'Prochaine étape AMP:'
Write-Host '1. Vérifie que bin\DCS_server.exe existe dans le root de l\'instance.'
Write-Host '2. Lance l\'instance AMP.'
Write-Host '3. Configure les missions et le nom du serveur depuis le Web GUI DCS ou Saved Games\<WriteDirName>\Config.'
