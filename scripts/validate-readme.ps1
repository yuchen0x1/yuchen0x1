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
$projectRowPattern = '^\| \[[^\]]+\]\(https://github\.com/yuchen0x1/[A-Za-z0-9_.-]+\) \| .+ \| [^|]+ \| 正常更新 \|$'
$projectRows = @($lines | Where-Object { $_ -match $projectRowPattern })

if ($projectRows.Count -lt 1) {
    throw 'No project rows with the expected format were found.'
}

$statusRows = @($lines | Where-Object { $_ -match '^\| \[' })
$invalidStatusRows = @($statusRows | Where-Object { $_ -notmatch '\| 正常更新 \|$' })
if ($invalidStatusRows.Count -gt 0) {
    throw "Found project rows without the 正常更新 status: $($invalidStatusRows -join '; ')"
}

if ($readme -match '暂停功能开发|暂停开发|停止开发|归档保留') {
    throw 'Deprecated project-status wording was found.'
}

$urls = @(
    [regex]::Matches($readme, 'https?://[^\s)<>]+') |
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

Write-Output "README validation passed: $($projectRows.Count) project rows, $($githubSlugs.Count) GitHub repository links."
if ($CheckLinks) {
    Write-Output 'GitHub repository link health checks passed.'
}
