$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $repositoryRoot 'scripts/validate-readme.ps1'
$temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$fixtureRoot = Join-Path $temporaryRoot ('profile-readme-tests-' + [guid]::NewGuid().ToString('N'))
$sourceFiles = @{}
foreach ($relativePath in @('README.md', 'repo-descriptions.md', 'assets/profile-banner.svg', 'assets/gold-rule.svg', 'assets/mark.svg')) {
    $sourceFiles[$relativePath] = [System.IO.File]::ReadAllText((Join-Path $repositoryRoot $relativePath))
}
$previousToken = $env:GITHUB_TOKEN
$passed = 0
$failed = [System.Collections.Generic.List[string]]::new()
$testState = @{}

function Write-Fixture([string]$RelativePath, [string]$Content) {
    [System.IO.File]::WriteAllText((Join-Path $fixtureRoot $RelativePath), $Content, [System.Text.UTF8Encoding]::new($true))
}

function Edit-Fixture([string]$RelativePath, [scriptblock]$Edit) {
    $path = Join-Path $fixtureRoot $RelativePath
    Write-Fixture $RelativePath (& $Edit ([System.IO.File]::ReadAllText($path)))
}

function Set-ProjectStatus([string]$Owner, [string]$Slug, [string]$Status, [string]$IndexStatus) {
    $url = "https://github.com/$Owner/$Slug"
    Edit-Fixture 'README.md' {
        param($content)
        [regex]::Replace($content, '(?s)<tr\b[^>]*>.*?</tr\s*>', [System.Text.RegularExpressions.MatchEvaluator]{
            param($row)
            if (-not $row.Value.Contains('href="' + $url + '"')) { return $row.Value }
            return [regex]::Replace($row.Value, '(?<prefix><td\b[^>]*>)(?:○ 已归档|⑂ Fork|● 未归档)(?<suffix></td>)', '${prefix}' + $Status + '${suffix}')
        })
    }
    Edit-Fixture 'repo-descriptions.md' {
        param($content)
        ($content -split "`n" | ForEach-Object {
            if ($_.Contains("]($url)")) { $_ -replace '\|\s*(?:已归档|Fork|未归档)\s*\|\s*$', "| $IndexStatus |" } else { $_ }
        }) -join "`n"
    }
}

function Set-BannerForks([int]$Count) {
    Edit-Fixture 'assets/profile-banner.svg' {
        param($content)
        $content = [regex]::Replace($content, '(?s)(<text\b[^>]*>)\d+(</text>\s*<text\b[^>]*>FORKS</text>)', '${1}' + $Count.ToString('00') + '${2}')
        [regex]::Replace($content, '\b\d+ active forks\b', "$Count active forks")
    }
}

function Read-FixtureRepositories {
    $testState.RepositoryData = @{ personal = [System.Collections.Generic.List[object]]::new(); organization = [System.Collections.Generic.List[object]]::new() }
    $readme = [System.IO.File]::ReadAllText((Join-Path $fixtureRoot 'README.md'))
    foreach ($row in [regex]::Matches($readme, '(?s)<tr\b[^>]*>(?<content>.*?)</tr\s*>')) {
        $link = [regex]::Match($row.Value, 'href="https://github\.com/(?<owner>yuchen0x1|Indifference-Project)/(?<slug>[A-Za-z0-9_.-]+)"')
        if (-not $link.Success) { continue }
        $cells = @([regex]::Matches($row.Value, '(?s)<td\b[^>]*>(?<content>.*?)</td\s*>'))
        $status = [regex]::Replace($cells[3].Groups['content'].Value, '<[^>]+>', '').Trim()
        $language = [regex]::Replace($cells[2].Groups['content'].Value, '<[^>]+>', '').Trim()
        $slug = $link.Groups['slug'].Value
        $kind = if ($link.Groups['owner'].Value -eq 'yuchen0x1') { 'personal' } else { 'organization' }
        $testState.RepositoryData[$kind].Add([pscustomobject]@{
            name = $slug; private = $false; language = $language; disabled = $false
            archived = $status -eq '○ 已归档'; fork = $status -eq '⑂ Fork' -or $slug -eq $testState.ArchivedFork
        })
    }
    $testState.RepositoryData.personal.Add([pscustomobject]@{
        name = 'yuchen0x1'; private = $false; language = 'PowerShell'; archived = $false; fork = $false; disabled = $false
    })
}

# All HTTP calls made by the child script resolve to this local mock.
function Invoke-WebRequest {
    param([string]$Uri, [hashtable]$Headers, [int]$TimeoutSec, [switch]$SkipHttpErrorCheck)
    if ($Uri -notmatch '^https://api\.github\.com/(?<kind>users/yuchen0x1|orgs/Indifference-Project)/repos\?.*?&page=(?<page>\d+)$') {
        throw "Unexpected HTTP request in offline regression test: $Uri"
    }
    $kind = if ($Matches['kind'].StartsWith('orgs/')) { 'organization' } else { 'personal' }
    $page = [int]$Matches['page']
    $testState.Requests.Add("$kind/$page")
    if ($kind -eq 'organization' -and $Uri -notmatch '[?&]type=public(?:&|$)') { throw 'Organization listing must request only public repositories.' }
    if ($testState.ApiMode -eq "$kind-http-error") { return @{ StatusCode = 403; Content = '{"message":"Forbidden"}' } }
    if ($testState.ApiMode -eq "$kind-object") { return @{ StatusCode = 200; Content = '{"message":"unexpected object"}' } }
    if ($testState.ApiMode -eq "$kind-null") { return @{ StatusCode = 200; Content = 'null' } }
    if ($testState.ApiMode -eq "$kind-invalid-repository") { return @{ StatusCode = 200; Content = '[{"name":"invalid"}]' } }
    if ($testState.ApiMode -eq "$kind-invalid-json") { return @{ StatusCode = 200; Content = '[invalid' } }
    $multiPage = if ($kind -eq 'personal') { $testState.MultiPersonal } else { $testState.MultiOrganization }
    if ($multiPage -and $page -eq 1) {
        # Private entries also prove that a broader future endpoint cannot leak them into coverage.
        $payload = @(1..100 | ForEach-Object { @{ name = "untracked-$_"; private = $kind -eq 'personal' } })
    } elseif ($page -eq $(if ($multiPage) { 2 } else { 1 })) {
        $payload = @($testState.RepositoryData[$kind].ToArray())
        if ($testState.IncludePrivate) { $payload += @{ name = 'private-repository'; private = $true } }
    } else {
        throw "Unexpected pagination request: $kind/$page"
    }
    return @{ StatusCode = 200; Content = ConvertTo-Json -InputObject $payload -Depth 5 -Compress }
}

function Test-Validation([string]$Name, [scriptblock]$Arrange = {}, [switch]$Online, [string]$ExpectedError, [string[]]$ExpectedRequests = @()) {
    foreach ($relativePath in $sourceFiles.Keys) { Write-Fixture $relativePath $sourceFiles[$relativePath] }
    $testState.ApiMode = ''
    $testState.MultiPersonal = $false
    $testState.MultiOrganization = $false
    $testState.IncludePrivate = $false
    $testState.ArchivedFork = ''
    $testState.Requests = [System.Collections.Generic.List[string]]::new()
    try {
        & $Arrange
        Read-FixtureRepositories
        $validationError = $null
        try { $null = & $validator -ReadmePath (Join-Path $fixtureRoot 'README.md') -CheckLinks:$Online } catch { $validationError = $_ }
        if ($ExpectedError) {
            if ($null -eq $validationError -or $validationError.Exception.Message -notmatch $ExpectedError) {
                throw "Expected error '$ExpectedError'; actual: $validationError"
            }
        } elseif ($null -ne $validationError) { throw "$validationError at $($validationError.ScriptStackTrace)" }
        foreach ($request in $ExpectedRequests) {
            if (-not $testState.Requests.Contains($request)) { throw "Expected request was not made: $request" }
        }
        $script:passed++
        Write-Output "PASS $Name"
    } catch {
        $script:failed.Add("${Name}: $($_.Exception.Message)")
        Write-Output "FAIL ${Name}: $($_.Exception.Message)"
    }
}

try {
    $null = New-Item -ItemType Directory -Path (Join-Path $fixtureRoot 'assets') -Force
    $env:GITHUB_TOKEN = 'offline-regression-test'
    Test-Validation 'current local content'
    Test-Validation 'current online metadata (mocked)' -Online -ExpectedRequests @('personal/1', 'organization/1')
    Test-Validation 'personal pagination and private filtering' { $testState.MultiPersonal = $true } -Online -ExpectedRequests @('personal/2')
    Test-Validation 'organization pagination beyond 100 repositories' { $testState.MultiOrganization = $true } -Online -ExpectedRequests @('organization/2')
    Test-Validation 'ignore private repositories' { $testState.IncludePrivate = $true } -Online
    foreach ($kind in @('personal', 'organization')) {
        Test-Validation "$kind rejects object payload" { $testState.ApiMode = "$kind-object" } -Online -ExpectedError 'must be a JSON array'
        Test-Validation "$kind rejects null payload" { $testState.ApiMode = "$kind-null" } -Online -ExpectedError 'must be a JSON array'
        Test-Validation "$kind rejects invalid repository payload" { $testState.ApiMode = "$kind-invalid-repository" } -Online -ExpectedError 'invalid repository'
        Test-Validation "$kind rejects HTTP error" { $testState.ApiMode = "$kind-http-error" } -Online -ExpectedError 'HTTP 403'
    }
    Test-Validation 'reject malformed JSON' { $testState.ApiMode = 'personal-invalid-json' } -Online -ExpectedError 'JSON'
    Test-Validation 'reject stale visible banner count' {
        Edit-Fixture 'assets/profile-banner.svg' { param($content) $content -replace '\b\d+ REPOSITORIES\b', '999 REPOSITORIES' }
    } -ExpectedError 'Banner REPOSITORIES mismatch'
    Test-Validation 'reject stale accessible repository count' {
        Edit-Fixture 'assets/profile-banner.svg' { param($content) $content -replace '\b\d+ indexed public repositories\b', '999 indexed public repositories' }
    } -ExpectedError 'Banner description REPOSITORIES'
    Test-Validation 'reject stale accessible fork count' {
        Edit-Fixture 'assets/profile-banner.svg' { param($content) $content -replace '\b\d+ active forks\b', '999 active forks' }
    } -ExpectedError 'Banner description FORKS'
    Test-Validation 'reject stale accessible date' {
        Edit-Fixture 'assets/profile-banner.svg' { param($content) $content -replace '\bUpdated \d{4}-\d{2}-\d{2}\b', 'Updated 2000-01-01' }
    } -ExpectedError 'description date'
    Test-Validation 'reject README personal summary mismatch' {
        Edit-Fixture 'README.md' { param($content) $content -replace '(个人账号有\s*\*\*)\d+', '${1}999' }
    } -ExpectedError 'personal repositories summary mismatch'
    Test-Validation 'reject index fork summary mismatch' {
        Edit-Fixture 'repo-descriptions.md' { param($content) $content -replace '含 \d+ 个 Fork', '含 999 个 Fork' }
    } -ExpectedError 'personal forks summary mismatch'
    Test-Validation 'organization forks do not inflate personal summary' {
        Set-ProjectStatus 'Indifference-Project' 'themes' '⑂ Fork' 'Fork'
        Set-BannerForks 3
    } -Online
    Test-Validation 'archived personal forks remain counted in personal summary' {
        Set-ProjectStatus 'yuchen0x1' 'GFPGAN' '○ 已归档' '已归档'
        Set-BannerForks 1
        $testState.ArchivedFork = 'GFPGAN'
    } -Online
    Test-Validation 'online metadata resolves ambiguous archived fork summary' {
        Set-ProjectStatus 'yuchen0x1' 'GFPGAN' '○ 已归档' '已归档'
        Set-BannerForks 1
        $testState.ArchivedFork = 'GFPGAN'
        Edit-Fixture 'README.md' { param($content) $content -replace '含 2 个 Fork', '含 1 个 Fork' }
        Edit-Fixture 'repo-descriptions.md' { param($content) $content -replace '含 2 个 Fork', '含 1 个 Fork' }
    } -Online -ExpectedError 'GitHub personal forks summary mismatch'
} finally {
    $env:GITHUB_TOKEN = $previousToken
    $resolvedFixtureRoot = [System.IO.Path]::GetFullPath($fixtureRoot)
    $tempPrefix = $temporaryRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $resolvedFixtureRoot.StartsWith($tempPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Refusing to remove a fixture outside the temporary directory.' }
    if (Test-Path -LiteralPath $resolvedFixtureRoot) { Remove-Item -LiteralPath $resolvedFixtureRoot -Recurse -Force }
}
if ($failed.Count -gt 0) { throw "$($failed.Count) validation regression tests failed: $($failed -join '; ')" }
Write-Output "Validation regression tests passed: $passed cases; no network access."
