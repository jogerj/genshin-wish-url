# script version 0.9
# author: jogerj


function processWishUrl($wishUrl) {
    # check validity
    if ($wishUrl -match "https:\/\/webstatic") {
        if ($wishUrl -match "hk4e_global") {
            $checkUrl = $wishUrl -replace "https:\/\/webstatic.+html\?", "https://hk4e-api-os.mihoyo.com/event/gacha_info/api/getGachaLog?"
        } else {
            $checkUrl = $wishUrl -replace "https:\/\/webstatic.+html\?", "https://hk4e-api.mihoyo.com/event/gacha_info/api/getGachaLog?"
        }
        $urlResponseMessage = Invoke-RestMethod -URI $checkUrl | % {$_.message}
    } else {
        $urlResponseMessage = Invoke-RestMethod -URI $wishUrl | % {$_.message}
    }
    if ($urlResponseMessage -ne "OK") {
        Write-Host "Link found is expired/invalid! Open Wish History again to fetch a new link" -ForegroundColor Yellow
        return $False
    }
    # OK
    Write-Host $wishURL
    Set-Clipboard -Value $wishURL
    Write-Host "Link copied to clipboard, paste it back to paimon.moe" -ForegroundColor Green
    return $True
}

$reg = $args[0]
$logPath = [System.Environment]::ExpandEnvironmentVariables("%userprofile%\AppData\LocalLow\miHoYo\Genshin Impact\output_log.txt");
if (!(Test-Path $logPath) -or $reg -eq "china") {
    $logPath = [System.Environment]::ExpandEnvironmentVariables("%userprofile%\AppData\LocalLow\miHoYo\$([char]0x539f)$([char]0x795e)\output_log.txt");
    if (!(Test-Path $logPath)) {
        Write-Host "Cannot find Genshin Impact log file! Make sure to run Genshin Impact and open the wish history at least once!" -ForegroundColor Red
        if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {  
            Write-Host "Do you want to try to run the script as Administrator? Press [ENTER] to continue, or any key to cancel."
            $keyInput = [Console]::ReadKey($true).Key
            if ($keyInput -ne "13") {
                return
            }
            $arguments = "& '" +$myinvocation.mycommand.definition + "'"
            Start-Process powershell -Verb runAs -ArgumentList "-noexit $arguments $reg"
            break
        } 
        return
    }
}

$logs = Get-Content -Path $logPath
$regexPattern = "(?m).:/.+(GenshinImpact_Data|YuanShen_Data)"
$logMatch = $logs -match $regexPattern

if (-Not $logMatch) {
    Write-Host "Cannot find Genshin Impact path in log file! Make sure to run Genshin Impact and open the wish history at least once!" -ForegroundColor Red
    pause
    return
}

$gameDataPath = ($logMatch | Select -Last 1) -match $regexPattern
$gameDataPath = Resolve-Path $Matches[0]

# Method 1
$cachePath = "$gameDataPath\\webCaches\\Cache\\Cache_Data\\data_2"
if (Test-Path $cachePath) {
    $tmpFile = "$env:TEMP/ch_data_2"
    Copy-Item $cachePath -Destination $tmpFile
    $content = Get-Content -Encoding UTF8 -Raw $tmpfile
    $splitted = $content -split "1/0/" | Select -Last 1
    $found = $splitted -match "https.+?game_biz=hk4e_(global|cn)"
    Remove-Item $tmpFile
    if ($found) {
        $wishUrl = $Matches[0]
        if (processWishUrl $wishUrl) {
            return
        }
    }
    Write-Host "Retrying using fallback method..." -ForegroundColor Red
}

# Method 2 (Credits to PrimeCicada for finding this path)
$cachePath = "$gameDataPath\\webCaches\\Service Worker\\CacheStorage\\f944a42103e2b9f8d6ee266c44da97452cde8a7c"
if (Test-Path $cachePath) {
    Write-Host "Using Fallback Method (SW)" -ForegroundColor Yellow
    $cacheFolder = Get-ChildItem $cachePath | sort -Property LastWriteTime -Descending | select -First 1
    $content = Get-Content "$($cacheFolder.FullName)\\00d9a0f4d2a83ce0_0" | Select-String -Pattern "https.*#/log"
    $logEntry = $content[0].ToString()
    $wishUrl = $logEntry -match "https.*#/log"
    if ($wishUrl) {
        $wishUrl = $Matches[0]
        if (processWishUrl $wishUrl) {
            return
        }
        
    }
    Write-Host "Fallback Method (SW) failed to find wish history URL! Retrying using second fallback method..." -ForegroundColor Red
}

# Method 3
Write-Host "Using Fallback method (CCV)" -ForegroundColor Yellow
$cachePath = "$gameDataPath\\webCaches\\Cache\\Cache_Data"
$tempPath = mkdir "$env:TEMP\\paimonmoe" -Force
# downloads ChromeCacheView
Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/chromecacheview.zip" -OutFile "$tempPath\\chromecacheview.zip"
Expand-Archive "$tempPath\\chromecacheview.zip" -DestinationPath "$tempPath\\chromecacheviewer" -Force
& "$tempPath\chromecacheviewer\\ChromeCacheView.exe" -folder $cachePath /scomma "$tempPath\\cache_data.csv"
# processing cache takes a while
while (!(Test-Path "$tempPath\\cache_data.csv")) { Start-Sleep 1 }
$wishLog = Import-Csv "$tempPath\\cache_data.csv" | select  "Last Accessed", "URL" | ? URL -like "*event/gacha_info/api/getGachaLog*" | Sort-Object -Descending { $_."Last Accessed" -as [datetime] } | select -first 1
$wishUrl = $wishLog | % {$_.URL.Substring(4)}
# clean up 
Remove-Item -Recurse -Force $tempPath
if ($wishUrl) {
    if (processWishUrl $wishUrl) {
        return
    }
}

Write-Host "Link not found! Make sure Genshin Impact is installed and open Wish History page at least once." -ForegroundColor Red
pause