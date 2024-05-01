# script version 0.12.2
# author: jogerj


function processWishUrl($wishUrl) {
    # check validity
    if ($wishUrl -match "https:\/\/webstatic") {
        if ($wishUrl -match "hk4e_global") {
            $checkUrl = $wishUrl -replace "https:\/\/webstatic.+html\?", "https://hk4e-api-os.mihoyo.com/gacha_info/api/getGachaLog?"
        } else {
            $checkUrl = $wishUrl -replace "https:\/\/webstatic.+html\?", "https://public-operation-hk4e.mihoyo.com/gacha_info/api/getGachaLog?"
        }
        $urlResponseMessage = Invoke-RestMethod -URI $checkUrl | % {$_.message}
    } else {
        $urlResponseMessage = Invoke-RestMethod -URI $wishUrl | % {$_.message}
    }
    if ($urlResponseMessage -ne "OK") {
        Write-Host "Link found but it is expired/invalid! Open Wish History again to fetch a new link" -ForegroundColor Yellow
        return $False
    }
    # OK
    Write-Host $wishURL
    Set-Clipboard -Value $wishURL
    Write-Host "Link copied to clipboard, paste it back to paimon.moe" -ForegroundColor Green
    return $True
}

$logPathGlobal = [System.Environment]::ExpandEnvironmentVariables("%userprofile%/AppData/LocalLow/miHoYo/Genshin Impact/output_log.txt");
$logPathChina = [System.Environment]::ExpandEnvironmentVariables("%userprofile%/AppData/LocalLow/miHoYo/$([char]0x539f)$([char]0x795e)/output_log.txt");
$globalExists = Test-Path $logPathGlobal;
$cnExists = Test-Path $logPathChina;

if ($globalExists) {
    if ($cnExists) {
        # both exists, pick newest one
        if ((Get-Item $logPathGlobal).LastWriteTime -ge (Get-Item $logPathChina).LastWriteTime) {
            $logPath = $logPathGlobal;
        } else {
            $logPath = $logPathChina;
        }
    } else {
        $logPath = $logPathGlobal;
    } 
} else {
    if ($cnExists) {
        $logPath = $logPathChina;
    } else {
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


$webcachePath = Resolve-Path "$gameDataPath/webCaches"
$cacheVerPath = Get-Item (Get-ChildItem -Path $webcachePath | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
$cachePath = Resolve-Path "$cacheVerPath/Cache/Cache_Data/data_2"

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
    Write-Host "No valid link found! Make sure Genshin Impact is installed and open Wish History page at least once." -ForegroundColor Red
    pause
} else {
    Write-Host "Genshin Impact cache not found! Make sure Genshin Impact is installed and open Wish History page at least once." -ForegroundColor Red
    pause
}
