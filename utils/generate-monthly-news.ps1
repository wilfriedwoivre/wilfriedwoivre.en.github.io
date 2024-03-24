Param(
    [int]$monthTosubstract = 1
)
$ErrorActionPreference = "Stop"


$currentDate = Get-Date

$startDate = $currentDate.AddMonths(-$monthTosubstract).ToString("yyyy-MM-01")
$endDate = (Get-Date($startDate)).AddMonths(1).AddDays(-1).ToString("yyyy-MM-dd")


$news = gh issue list --repo wilfriedwoivre/feedly -L 1000  --state closed --search "label:publish created:$startDate..$endDate" --json title,body,createdAt | convertfrom-json 

Write-Output "Found $($news.Length) news"

if ($news.Length -eq 0) {
    Write-Output "No news found for the period $startDate to $endDate"
    exit
}

$currentMonth = Get-Date($startDate) -UFormat %m
$month = (Get-Culture -Name "en-US").DateTimeFormat.GetMonthName($currentMonth)
$title = "My reading news for $month $((Get-Date($startDate)).ToString('yyyy'))"

$category = '"Other"'

$newPost = "---
layout: news
title: $title
date: $((Get-Date($endDate)).AddDays(1).ToString('yyyy-MM-dd'))
---

Here is a the list of reading news i share on $month $((Get-Date($startDate)).ToString('yyyy')).

All of this list are a little messy, in the future i will try to sort them by category.

"

foreach ($new in $news | Sort-Object -Property createdAt) {
    $response = Invoke-WebRequest $new.body -SkipHttpErrorCheck
    if ($response.StatusCode -ne 200) {
        Write-Output "Error while fetching $($new.title) $($new.body)"
    }
    else {
        $newPost += "- [$($new.title)]($($new.body))"
        $newPost += [System.Environment]::NewLine
    }
}


$fileName = "$((Get-Date($endDate)).AddDays(1).ToString('yyyy-MM-dd'))-";
$temp = $title.ToLowerInvariant().Normalize([System.Text.NormalizationForm]::FormD)

$temp.ToCharArray() | %{ 
    $unicodeCategory = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($_)
    
    $character = $_

    switch ( $unicodeCategory ) {
        LowercaseLetter { $fileName += $character }
        DecimalDigitNumber { $fileName += $character }
        SpaceSeparator { if ($fileName[$fileName.Length - 1] -ne '-') { $fileName += '-' }}
    }
}

if ($fileName[$fileName.Length - 1] -eq '-') {
    $fileName = $fileName.Remove($fileName.Length - 1, 1)
}

$fileName += ".md"

$newPost = $newPost -replace 'ΓÇô', '-'
$newPost = $newPost -replace 'ΓÇö', "-"


$filePath = "$PSScriptRoot\..\_news\$fileName"

New-Item $filePath

$newPost | Out-File $filePath -Encoding utf8