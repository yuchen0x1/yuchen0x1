param(
    [string]$ReadmePath = (Join-Path $PSScriptRoot '..\README.md'),
    [switch]$CheckLinks
)

$ErrorActionPreference = 'Stop'

$resolvedReadme = (Resolve-Path -LiteralPath $ReadmePath).Path
$readme = Get-Content -LiteralPath $resolvedReadme -Raw -Encoding UTF8

if ([string]::IsNullOrWhiteSpace($readme)) {
    throw "README is empty: $resolvedReadme"
}

$lines = @($readme -split "`r?`n")
$projectItemPattern = '^[-*] \*\*\[[^\]]+\]\(https://github\.com/yuchen0x1/[A-Za-z0-9_.-]+\)\*\* — .+ · `[^`]+` · 正常更新$'
$projectItems = @($lines | Where-Object { $_ -match $projectItemPattern })

if ($projectItems.Count -lt 1) {
    throw 'No project items with the expected format were found.'
}

$statusCount = ([regex]::Matches($readme, ' · 正常更新$','Multiline')).Count
if ($statusCount -ne $projectItems.Count) {
    throw "Project item/status count mismatch: $($projectItems.Count) items, $statusCount statuses."
}

if ($readme -match '暂停功能开发|暂停开发|停止开发|归档保留') {
    throw 'Deprecated project-status wording was found.'
}

$urls = @(
    [regex]::Matches($readme, 'https?://[^\s)<>\"]+') |
        ForEach-Object { $_.Value.TrimEnd('.', ',', ';') } |
        Sort-Object -Unique
)

foreach ($url in $urls) {
    $parsedUri = [System.Uri]::new($url)
    if ($parsedUri.Scheme -notin @('http', 'https') -or [string]::IsNullOrWhiteSpace($parsedUri.Host)) {
        throw "Invalid external URL: $url"
    }
}

$githubSlugs = @(
    [regex]::Matches($readme, 'https://github\.com/yuchen0x1/([A-Za-z0-9_.-]+)') |
        ForEach-Object { $_.Groups[1].Value -replace '\.git$', '' } |
        Sort-Object -Unique
)

$bannerPath = Join-Path (Split-Path -Parent $resolvedReadme) 'assets\profile-banner.svg'
if (-not (Test-Path -LiteralPath $bannerPath)) {
    throw "Profile banner is missing: $bannerPath"
}
$bannerXml = [System.Xml.XmlDocument]::new()
$bannerXml.Load((Resolve-Path -LiteralPath $bannerPath).Path)
if ($bannerXml.DocumentElement.Name -ne 'svg') {
    throw "Profile banner is not a valid SVG: $bannerPath"
}

if ($CheckLinks) {
    $apiHeaders = @{
        'Accept' = 'application/vnd.github+json'
        'User-Agent' = 'profile-readme-health-check'
    }

    $healthCheckToken = $env:GITHUB_TOKEN
    if ([string]::IsNullOrWhiteSpace($healthCheckToken) -and (Get-Command gh -ErrorAction SilentlyContinue)) {
        $healthCheckToken = [string](& gh auth token 2>$null | Select-Object -First 1)
        $healthCheckToken = $healthCheckToken.Trim()
    }
    if (-not [string]::IsNullOrWhiteSpace($healthCheckToken)) {
        $apiHeaders['Authorization'] = "Bearer $healthCheckToken"
    }

    foreach ($slug in $githubSlugs) {
        $apiUrl = "https://api.github.com/repos/yuchen0x1/$slug"
        $response = Invoke-WebRequest -Uri $apiUrl -Headers $apiHeaders -TimeoutSec 20 -SkipHttpErrorCheck

        if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
            throw "GitHub repository link failed with HTTP $($response.StatusCode): $slug"
        }

        $repository = $response.Content | ConvertFrom-Json
        if ($repository.archived -or $repository.disabled) {
            throw "GitHub repository is archived or disabled: $slug"
        }
    }
}

Write-Output "README validation passed: $($projectItems.Count) project items, $($githubSlugs.Count) GitHub repository links."
if ($CheckLinks) {
    Write-Output 'GitHub repository link health checks passed.'
}
