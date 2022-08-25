# script version 0.6
# author: jogerj

$logLocation = "%userprofile%\AppData\LocalLow\miHoYo\Genshin Impact\output_log.txt"
$logPath = [System.Environment]::ExpandEnvironmentVariables($logLocation);
if (-Not [System.IO.File]::Exists($logPath)) {
    Write-Host "Cannot find the log file! Make sure to open the wish history first!" -ForegroundColor Red
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {  
        Write-Host "Do you want to try to run the script as Administrator? Press [ENTER] to continue, or any key to cancel."
        $keyInput = [Console]::ReadKey($true).Key
        if ($keyInput -ne "13") {
            return
        }
        $arguments = "& '" +$myinvocation.mycommand.definition + "'"
        Start-Process powershell -Verb runAs -ArgumentList "-noexit", $arguments
        break
    }
    return
}

Try {
    $logs = Get-Content -Path $logPath -ErrorAction Stop
} Catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "Cannot find Genshin Impact log file! Make sure to run Genshin Impact and open the wish history at least once!" -ForegroundColor Red
    pause
    return
}

$regexPattern = "(?<=^Warmup file )(.*GenshinImpact_Data)(?=.*$)"
$logMatch = $logs -match $regexPattern

if (-Not $logMatch) {
    Write-Host "Cannot find Genshin Impact path in log file! Make sure to run Genshin Impact and open the wish history at least once!" -ForegroundColor Red
    pause
    return
}

$gameDataPath = ($logMatch | Select -Last 1) -match $regexPattern
$gameDataPath = Resolve-Path $Matches[0]

# Credits to PrimeCicada for finding this path
$cachePath = "$gameDataPath\\webCaches\\Service Worker\\CacheStorage\\f944a42103e2b9f8d6ee266c44da97452cde8a7c"
if (Test-Path $cachePath) {
    $cacheFolder = Get-ChildItem $cachePath | sort -Property LastWriteTime -Descending | select -First 1
    $content = Get-Content "$($cacheFolder.FullName)\\00d9a0f4d2a83ce0_0" | Select-String -Pattern "https.*#/log"
    $logEntry = $content[0].ToString()
    $wishUrl = $logEntry -match "https.*#/log"
    
    if ($wishUrl) {
        $wishUrl = $Matches[0]
        Write-Host $wishUrl
    
        $wishUrlDate = $logEntry -match "\w{3}, \d{2} \w{3} \d{4} \d\d:\d\d:\d\d GMT"
        if ($wishUrlDate) {
            $wishUrlDate = $Matches[0] -as [datetime]
            $current = Get-Date
            $timeDiff = New-TimeSpan -Start $wishUrlDate -End $current | % {$_.Hours}
            if ($timeDiff -ge 24) {
            Write-Host "WARNING: Link found is older than 24 hours and might be expired! Open Wish History again to fetch a new link if it doesn't work" -ForegroundColor Yellow
            Read-Host -Prompt "Press ENTER to copy link anyway or CTRL-C to quit" 
            }
        }
        Set-Clipboard -Value $wishUrl
        Write-Host "Link from $wishUrlDate copied to clipboard, paste it back to paimon.moe" -ForegroundColor Green
        return
    }
} 
Write-Host "Using Fallback method" -ForegroundColor Yellow
# fallback old method
$tempPath = mkdir "$env:TEMP\\paimonmoe" -Force
$cachePath = "$gameDataPath\\webCaches\\Cache\\Cache_Data"
# downloads ChromeCacheView
Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/chromecacheview.zip" -OutFile "$tempPath\\chromecacheview.zip"
Expand-Archive "$tempPath\\chromecacheview.zip" -DestinationPath "$tempPath\\chromecacheviewer" -Force
& "$tempPath\chromecacheviewer\\ChromeCacheView.exe" -folder $cachePath /scomma "$tempPath\\cache_data.csv"
# processing cache takes a while
while (!(Test-Path "$tempPath\\cache_data.csv")) { Start-Sleep 1 }
$wishLog = Import-Csv "$tempPath\\cache_data.csv" | select  "Last Accessed", "URL" | ? URL -like "*event/gacha_info/api/getGachaLog*" | Sort-Object -Descending { $_."Last Accessed" -as [datetime] } | select -first 1
$wishUrl = $wishLog | % {$_.URL.Substring(4)}
$wishUrlDate = $wishLog | % {$_."Last Accessed" -as [datetime]}
# clean up 
Remove-Item -Recurse -Force $tempPath
if ($wishUrl) {
    $current = Get-Date
    $timeDiff = New-TimeSpan -Start $wishUrlDate -End $current | % {$_.Hours}

    Write-Host $wishUrl
    if ($timeDiff -ge 24) {
        Write-Host "WARNING: Link found is older than 24 hours and might be expired! Open Wish History again to fetch a new link if it doesn't work" -ForegroundColor Yellow
        Read-Host -Prompt "Press ENTER to copy link anyway or CTRL+C to quit" 
    }
    Set-Clipboard -Value $wishUrl
    Write-Host "Link from $wishUrlDate copied to clipboard, paste it back to paimon.moe" -ForegroundColor Green
} else {
    Write-Host "Link not found! Make sure Genshin Impact is installed and open Wish History page at least once." -ForegroundColor Red
    pause
}