param(
    [string]$ReadmePath = (Join-Path $PSScriptRoot '../README.md'),
    [switch]$CheckLinks
)

$ErrorActionPreference = 'Stop'
$resolvedReadme = (Resolve-Path -LiteralPath $ReadmePath).Path
$readmeRoot = Split-Path -Parent $resolvedReadme
$readme = Get-Content -LiteralPath $resolvedReadme -Raw -Encoding UTF8
if ([string]::IsNullOrWhiteSpace($readme)) { throw "README is empty: $resolvedReadme" }

function Get-CellText([string]$Content) {
    return [System.Net.WebUtility]::HtmlDecode(($Content -replace '<[^>]+>', '')).Trim()
}

function Get-SectionTable([string]$Name) {
    $pattern = '(?ms)^##[^\r\n]*·\s*' + [regex]::Escape($Name) + '[^\r\n]*\r?\n(?<section>.*?)(?=^##\s|\z)'
    $section = [regex]::Match($readme, $pattern)
    $table = [regex]::Match($section.Groups['section'].Value, '(?s)<table\b[^>]*>(?<content>.*?)</table\s*>')
    if (-not $section.Success -or -not $table.Success) { throw "README section/table is missing: $Name" }
    return $table.Groups['content'].Value
}

# Check nesting before extracting rows, so stray closing tags cannot be ignored.
$tagStack = [System.Collections.Generic.List[string]]::new()
$voidTags = @('area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source', 'track', 'wbr')
foreach ($tag in [regex]::Matches($readme, '(?s)<!--.*?-->|</?(?<name>[A-Za-z][A-Za-z0-9-]*)\b[^<>]*>')) {
    if ($tag.Value.StartsWith('<!--')) { continue }
    $name = $tag.Groups['name'].Value.ToLowerInvariant()
    if ($tag.Value.StartsWith('</')) {
        if ($tagStack.Count -eq 0 -or $tagStack[$tagStack.Count - 1] -ne $name) {
            throw "Unexpected or mismatched HTML closing tag: $($tag.Value)"
        }
        $tagStack.RemoveAt($tagStack.Count - 1)
        continue
    }
    $parent = if ($tagStack.Count -gt 0) { $tagStack[$tagStack.Count - 1] } else { '' }
    if ($name -eq 'tr' -and $parent -notin @('table', 'thead', 'tbody', 'tfoot')) { throw 'Table row must be inside a table.' }
    if ($name -in @('td', 'th') -and $parent -ne 'tr') { throw 'Table cell must be inside a row.' }
    if ($parent -eq 'table' -and $name -notin @('tr', 'thead', 'tbody', 'tfoot', 'caption', 'colgroup')) {
        throw "Unexpected element directly inside a table: $name"
    }
    if ($parent -eq 'tr' -and $name -notin @('td', 'th')) { throw "Unexpected element directly inside a table row: $name" }
    if ($name -notin $voidTags -and $tag.Value -notmatch '/\s*>$') { $tagStack.Add($name) }
}
if ($tagStack.Count -gt 0) { throw "Unclosed HTML tags: $($tagStack -join ', ')" }

$projectLinkPattern = '<a\b[^>]*\bhref\s*=\s*["'']https://github\.com/(?<owner>yuchen0x1|Indifference-Project)/(?<slug>[A-Za-z0-9_.-]+)/?["''][^>]*>'
$projectRows = [System.Collections.Generic.List[object]]::new()
$seenSlugs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$statusLabels = @('● 未归档', '⑂ Fork', '○ 已归档')
foreach ($row in [regex]::Matches($readme, '(?s)<tr\b[^>]*>(?<content>.*?)</tr\s*>')) {
    $links = @([regex]::Matches($row.Groups['content'].Value, $projectLinkPattern))
    if ($links.Count -eq 0) { continue }
    $cells = @([regex]::Matches($row.Groups['content'].Value, '(?s)<td\b[^>]*>(?<content>.*?)</td\s*>'))
    if ($links.Count -ne 1 -or $cells.Count -ne 4) { throw 'Each project row must contain one repository link and exactly four cells.' }
    if (-not [regex]::IsMatch($cells[0].Groups['content'].Value, $projectLinkPattern)) {
        throw 'The repository link must be in the first project cell.'
    }
    $owner = $links[0].Groups['owner'].Value
    $slug = $links[0].Groups['slug'].Value
    $key = "$owner/$slug"
    if (($owner -ieq 'yuchen0x1' -and $slug -ieq 'yuchen0x1') -or -not $seenSlugs.Add($key)) { throw "Duplicate project or profile repository in project rows: $key" }
    $status = Get-CellText $cells[3].Groups['content'].Value
    if ($status -notin $statusLabels) { throw "Invalid status for $($slug): $status" }
    $language = Get-CellText $cells[2].Groups['content'].Value
    if ([string]::IsNullOrWhiteSpace($language)) { throw "Missing primary language for $($slug)" }
    $projectRows.Add([pscustomobject]@{ Owner = $owner; Slug = $slug; Key = $key; Language = $language; Status = $status })
}
if ($projectRows.Count -eq 0 -or $projectRows.Count -ne [regex]::Matches($readme, $projectLinkPattern).Count) {
    throw 'All project repository links must be in valid project table rows.'
}

$urls = @(
    [regex]::Matches($readme, 'https?://[^\s)<>\"'']+') |
        ForEach-Object { $_.Value.TrimEnd('.', ',', ';') } | Sort-Object -Unique
)
foreach ($url in $urls) {
    $parsedUri = [System.Uri]::new($url)
    if ($parsedUri.Scheme -notin @('http', 'https') -or [string]::IsNullOrWhiteSpace($parsedUri.Host)) { throw "Invalid external URL: $url" }
}

# Check every local image, including all SVG assets used by the README.
$bannerXml = $null
$checkedImages = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($image in [regex]::Matches($readme, '<img\b[^>]*\bsrc\s*=\s*["''](?<src>[^"'']+)["''][^>]*>')) {
    $source = [System.Net.WebUtility]::HtmlDecode($image.Groups['src'].Value)
    if ($source -match '^(?:https?:)?//') { continue }
    if ([string]::IsNullOrWhiteSpace($source) -or $source -match '^[A-Za-z][A-Za-z0-9+.-]*:') { throw "Unsupported image source: $source" }
    $imagePath = [System.IO.Path]::GetFullPath((Join-Path $readmeRoot ($source -split '[?#]', 2)[0]))
    $relativePath = [System.IO.Path]::GetRelativePath($readmeRoot, $imagePath)
    if ([System.IO.Path]::IsPathRooted($relativePath) -or $relativePath -eq '..' -or $relativePath -match '^\.\.[\\/]') {
        throw "Image path escapes the README directory: $source"
    }
    if (-not (Test-Path -LiteralPath $imagePath -PathType Leaf)) { throw "README image is missing: $source" }
    if (-not $checkedImages.Add($imagePath)) { continue }
    if ([System.IO.Path]::GetExtension($imagePath) -ieq '.svg') {
        $svgXml = [System.Xml.XmlDocument]::new()
        $svgXml.XmlResolver = $null
        $svgXml.Load($imagePath)
        if ($svgXml.DocumentElement.LocalName -ne 'svg' -or $svgXml.DocumentElement.NamespaceURI -ne 'http://www.w3.org/2000/svg') {
            throw "README image is not a valid SVG: $source"
        }
        if ($relativePath.Replace('\', '/') -eq 'assets/profile-banner.svg') { $bannerXml = $svgXml }
    }
}
if ($null -eq $bannerXml) { throw 'README must reference assets/profile-banner.svg.' }

function Get-BannerMetric([string]$Label) {
    $textNodes = @($bannerXml.SelectNodes("//*[local-name()='text']"))
    $values = @(
        for ($index = 0; $index -lt $textNodes.Count; $index++) {
            $value = $textNodes[$index].InnerText.Trim()
            if ($value -match ('^(?<count>\d+)\s+' + [regex]::Escape($Label) + '$')) {
                [int]$Matches['count']
            } elseif ($value -ceq $Label -and $index -gt 0 -and $textNodes[$index - 1].InnerText.Trim() -match '^\d+$') {
                [int]$textNodes[$index - 1].InnerText.Trim()
            }
        }
    )
    if ($values.Count -ne 1) { throw "Banner must contain exactly one numeric metric: $Label" }
    return $values[0]
}

$domainCount = [regex]::Matches((Get-SectionTable 'WHAT I BUILD'), '<td\b').Count
$languageCell = [regex]::Match((Get-SectionTable 'STACK'), '(?s)<td\b[^>]*>(?<content>.*?)</td\s*>')
$languages = @((Get-CellText $languageCell.Groups['content'].Value) -split '\s*·\s*' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($domainCount -eq 0 -or $languages.Count -eq 0 -or @($languages | Sort-Object -Unique).Count -ne $languages.Count) {
    throw 'WHAT I BUILD or STACK has missing or duplicate entries.'
}
$archivedCount = @($projectRows | Where-Object Status -eq '○ 已归档').Count
$forkCount = @($projectRows | Where-Object Status -eq '⑂ Fork').Count
$expectedMetrics = @{
    PROJECTS = $projectRows.Count
    REPOSITORIES = $projectRows.Count + 1
    DOMAINS = $domainCount
    LANGUAGES = $languages.Count
    FORKS = $forkCount
}
foreach ($label in $expectedMetrics.Keys) {
    $actual = Get-BannerMetric $label
    if ($actual -ne $expectedMetrics[$label]) { throw "Banner $label mismatch: $actual shown, $($expectedMetrics[$label]) expected." }
}

# Narrative totals drift independently of the banner; verify both README sentences.
$personalSummary = [regex]::Match($readme, '个人账号有\s*\*\*(?<repos>\d+)\s*个公开仓库\s*·\s*(?<projects>\d+)\s*个项目\*\*（含\s*(?<forks>\d+)\s*个 Fork）')
$indexSummary = [regex]::Match($readme, '本页索引共\s*\*\*(?<repos>\d+)\s*个公开仓库\s*·\s*(?<projects>\d+)\s*个项目\*\*')
if (-not $personalSummary.Success -or -not $indexSummary.Success) { throw 'README project summary counts are missing.' }
$personalProjects = @($projectRows | Where-Object Owner -ieq 'yuchen0x1').Count
$summaryChecks = @(
    @{ Name = 'personal repositories'; Actual = [int]$personalSummary.Groups['repos'].Value; Expected = $personalProjects + 1 },
    @{ Name = 'personal projects'; Actual = [int]$personalSummary.Groups['projects'].Value; Expected = $personalProjects },
    @{ Name = 'personal forks'; Actual = [int]$personalSummary.Groups['forks'].Value; Expected = $forkCount },
    @{ Name = 'index repositories'; Actual = [int]$indexSummary.Groups['repos'].Value; Expected = $projectRows.Count + 1 },
    @{ Name = 'index projects'; Actual = [int]$indexSummary.Groups['projects'].Value; Expected = $projectRows.Count }
)
foreach ($check in $summaryChecks) {
    if ($check.Actual -ne $check.Expected) { throw "README $($check.Name) summary mismatch: $($check.Actual) shown, $($check.Expected) expected." }
}

# The curated Markdown index must cover exactly the same repositories as the profile.
$indexPath = Join-Path $readmeRoot 'repo-descriptions.md'
$index = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8
$indexSlugs = @([regex]::Matches($index, '\]\(https://github\.com/(?<owner>yuchen0x1|Indifference-Project)/(?<slug>[A-Za-z0-9_.-]+)\)') | ForEach-Object { "$($_.Groups['owner'].Value)/$($_.Groups['slug'].Value)" })
$uniqueIndexSlugs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($slug in $indexSlugs) {
    if (-not $uniqueIndexSlugs.Add($slug)) { throw "Duplicate repository in repo-descriptions.md: $slug" }
}
$missingFromIndex = @($projectRows | Where-Object { -not $uniqueIndexSlugs.Contains($_.Key) } | ForEach-Object Key)
$extraInIndex = @($indexSlugs | Where-Object { $_ -ine 'yuchen0x1/yuchen0x1' -and -not $seenSlugs.Contains($_) })
if ($missingFromIndex.Count -gt 0 -or $extraInIndex.Count -gt 0) {
    throw "Repository index differs from README. Missing: $($missingFromIndex -join ', '); extra: $($extraInIndex -join ', ')."
}

# The index repeats project status and language; reject rows that drift from the README.
$indexProfileRows = 0
$indexTableRows = 0
foreach ($line in ($index -split "\r?\n")) {
    $indexLink = [regex]::Match($line, '^\|\s*\[[^\]]+\]\(https://github\.com/(?<owner>yuchen0x1|Indifference-Project)/(?<slug>[A-Za-z0-9_.-]+)\)')
    if (-not $indexLink.Success) { continue }
    $indexTableRows++
    $key = "$($indexLink.Groups['owner'].Value)/$($indexLink.Groups['slug'].Value)"
    $indexCells = @($line.Trim().Trim('|').Split('|'))
    if ($indexCells.Count -ne 5) { throw "Index row must have five columns: $key" }
    $indexLanguageMatch = [regex]::Match($indexCells[2], '`(?<language>[^`]+)`')
    if (-not $indexLanguageMatch.Success) { throw "Index row is missing a primary language: $key" }
    $indexLanguage = $indexLanguageMatch.Groups['language'].Value
    $indexStatus = $indexCells[4].Trim()
    if ($key -ieq 'yuchen0x1/yuchen0x1') {
        $indexProfileRows++
        if ($indexLanguage -cne 'PowerShell' -or $indexStatus -cne '未归档') {
            throw "Profile index row has unexpected language or status: $indexLanguage / $indexStatus"
        }
        continue
    }
    $readmeProject = $projectRows | Where-Object { $_.Key -ieq $key } | Select-Object -First 1
    if ($null -eq $readmeProject) { throw "Index row has no README project: $key" }
    $expectedIndexStatus = switch ($readmeProject.Status) {
        '● 未归档' { '未归档' }
        '⑂ Fork' { 'Fork' }
        '○ 已归档' { '已归档' }
    }
    if ($indexLanguage -cne $readmeProject.Language) {
        throw "Index language mismatch for $($key): $indexLanguage shown, $($readmeProject.Language) expected."
    }
    if ($indexStatus -cne $expectedIndexStatus) {
        throw "Index status mismatch for $($key): $indexStatus shown, $expectedIndexStatus expected."
    }
}
if ($indexProfileRows -ne 1 -or $indexTableRows -ne $projectRows.Count + 1) {
    throw "Index row coverage mismatch: $indexTableRows indexed rows, $($projectRows.Count + 1) expected."
}

$indexPersonalSummary = [regex]::Match($index, '个人账号有\s*\*\*(?<repos>\d+)\s*个公开仓库\*\*：(?<projects>\d+)\s*个项目（含\s*(?<forks>\d+)\s*个 Fork）')
$indexTotalSummary = [regex]::Match($index, '本索引合计覆盖\s*(?<repos>\d+)\s*个公开仓库')
if (-not $indexPersonalSummary.Success -or -not $indexTotalSummary.Success) { throw 'Index summary counts are missing.' }
$indexSummaryChecks = @(
    @{ Name = 'personal repositories'; Actual = [int]$indexPersonalSummary.Groups['repos'].Value; Expected = $personalProjects + 1 },
    @{ Name = 'personal projects'; Actual = [int]$indexPersonalSummary.Groups['projects'].Value; Expected = $personalProjects },
    @{ Name = 'personal forks'; Actual = [int]$indexPersonalSummary.Groups['forks'].Value; Expected = $forkCount },
    @{ Name = 'indexed repositories'; Actual = [int]$indexTotalSummary.Groups['repos'].Value; Expected = $projectRows.Count + 1 }
)
foreach ($check in $indexSummaryChecks) {
    if ($check.Actual -ne $check.Expected) { throw "Index $($check.Name) summary mismatch: $($check.Actual) shown, $($check.Expected) expected." }
}

if ($CheckLinks) {
    $apiHeaders = @{ 'Accept' = 'application/vnd.github+json'; 'User-Agent' = 'profile-readme-health-check' }
    $healthCheckToken = $env:GITHUB_TOKEN
    if ([string]::IsNullOrWhiteSpace($healthCheckToken) -and (Get-Command gh -ErrorAction SilentlyContinue)) {
        $healthCheckToken = [string](& gh auth token 2>$null | Select-Object -First 1)
        $healthCheckToken = $healthCheckToken.Trim()
    }
    if (-not [string]::IsNullOrWhiteSpace($healthCheckToken)) { $apiHeaders['Authorization'] = "Bearer $healthCheckToken" }

    $publicRepositories = @{}
    $page = 1
    do {
        if ($page -gt 100) { throw 'Repository pagination exceeded 100 pages.' }
        $apiUrl = "https://api.github.com/users/yuchen0x1/repos?type=owner&sort=full_name&per_page=100&page=$page"
        $response = Invoke-WebRequest -Uri $apiUrl -Headers $apiHeaders -TimeoutSec 20 -SkipHttpErrorCheck
        if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
            throw "GitHub public repository listing failed with HTTP $($response.StatusCode), page $page."
        }
        $repositoryPayload = $response.Content | ConvertFrom-Json
        $repositories = @($repositoryPayload)
        foreach ($repository in $repositories) {
            if (-not $repository.private) { $publicRepositories["yuchen0x1/$($repository.name)"] = $repository }
        }
        $page++
    } while ($repositories.Count -eq 100)

    $organizationRepositories = @{}
    $organizationUrl = 'https://api.github.com/orgs/Indifference-Project/repos?type=all&sort=full_name&per_page=100'
    $organizationResponse = Invoke-WebRequest -Uri $organizationUrl -Headers $apiHeaders -TimeoutSec 20 -SkipHttpErrorCheck
    if ($organizationResponse.StatusCode -lt 200 -or $organizationResponse.StatusCode -ge 300) {
        throw "GitHub organization repository listing failed with HTTP $($organizationResponse.StatusCode)."
    }
    $organizationPayload = $organizationResponse.Content | ConvertFrom-Json
    foreach ($repository in @($organizationPayload)) {
        if (-not $repository.private) { $organizationRepositories[$repository.name] = $repository }
    }
    $trackedOrganizationRepos = @('Codex-Remote-Bridge', 'Qzone-Archive', 'themes')
    foreach ($name in $trackedOrganizationRepos) {
        if (-not $organizationRepositories.ContainsKey($name)) { throw "Tracked organization repository is missing: Indifference-Project/$name" }
        $publicRepositories["Indifference-Project/$name"] = $organizationRepositories[$name]
    }

    if (-not $publicRepositories.ContainsKey('yuchen0x1/yuchen0x1')) { throw 'The public profile repository was not returned by GitHub.' }
    foreach ($project in $projectRows) {
        if (-not $publicRepositories.ContainsKey($project.Key)) { throw "Project is missing from GitHub's public repository list: $($project.Key)" }
        $repository = $publicRepositories[$project.Key]
        if ($repository.disabled) { throw "GitHub repository is disabled: $($project.Key)" }
        $expectedStatus = if ($repository.archived) { '○ 已归档' } elseif ($repository.fork) { '⑂ Fork' } else { '● 未归档' }
        if ($project.Status -cne $expectedStatus) {
            throw "GitHub status mismatch for $($project.Key): '$($project.Status)' shown, '$expectedStatus' expected."
        }
        $expectedLanguage = if ([string]::IsNullOrWhiteSpace($repository.language)) { '未检测到' } else { $repository.language }
        if ($project.Language -cne $expectedLanguage) {
            throw "GitHub language mismatch for $($project.Key): '$($project.Language)' shown, '$expectedLanguage' expected."
        }
    }
    $missingProjects = @($publicRepositories.Keys | Where-Object { $_ -ine 'yuchen0x1/yuchen0x1' -and -not $seenSlugs.Contains($_) } | Sort-Object)
    if ($missingProjects.Count -gt 0) { throw "Public repositories missing from README: $($missingProjects -join ', ')" }
    if ($publicRepositories.Count -ne $expectedMetrics.REPOSITORIES) {
        throw "Tracked public repository count mismatch: $($publicRepositories.Count) live, $($expectedMetrics.REPOSITORIES) shown."
    }
}

Write-Output "README validation passed: $($projectRows.Count) unique projects, $forkCount forks, $archivedCount archived, $($checkedImages.Count) local images; banner and index match."
if ($CheckLinks) { Write-Output "GitHub public repository coverage and statuses passed: $($publicRepositories.Count) repositories." }
