<#
.SYNOPSIS
  This script extracts the latest wish URL from Genshin Impact ($([char]0x539f)$([char]0x795e)) cache file.
.DESCRIPTION
  Usage:
  1. Run Genshin Impact and open the "Wish History" page at least once.
  2. Run this script to extract the latest wish URL from the cache file.
  3. The wish URL will be copied to the clipboard.
.EXAMPLE
  # On Windows
  PS C:\Users\Alice> .\Get-WishUrl.ps1

  # Directly from github
  PS C:\Users\Alice> iex (irm 'https://github.com/jogerj/genshin-wish-url/raw/main/Get-WishUrl.ps1')
.NOTES
  Version:  0.14.0
  Author:   jogerj
  License:  MIT
#>

function Get-ValidatedWishUrl {
  param (
    [string]$WishUrl
  )
  # Character wish banner, latest 5 pulls
  $WishUrl = "$WishUrl&page=1&size=5&gacha_type=301"
  # If webpage, rewrite URL to call API directly
  if ($WishUrl -match "hk4e_global") {
    # Global
    $WishUrl = $WishUrl -replace "https:\/\/gs.hoyoverse.com.+html\?", "https://public-operation-hk4e-sg.hoyoverse.com/gacha_info/api/getGachaLog?"
  }
  else {
    # CN
    $WishUrl = $WishUrl -replace "https:\/\/webstatic.+html\?", "https://public-operation-hk4e.mihoyo.com/gacha_info/api/getGachaLog?"
  }
  # Check validity
  try {
    $urlResponse = Invoke-RestMethod -URI $WishUrl -ContentType 'application/json' -Method Get
    # Test OK
    if ($urlResponse.message -ne "OK") {
      Write-Host "URL found but it is expired/invalid! Open `"Wish History`" page again to fetch a new URL!" -ForegroundColor Yellow
      return $null
    }
    return $WishUrl
  }
  catch {
    Write-Host "Could not validate wish URL! Make sure you have a working internet connection." -ForegroundColor Red
    return $null
  }
}

function Get-GenshinLogPath {
  $logPathGlobal = [System.Environment]::ExpandEnvironmentVariables("%userprofile%/AppData/LocalLow/miHoYo/Genshin Impact/output_log.txt")
  $logPathChina = [System.Environment]::ExpandEnvironmentVariables("%userprofile%/AppData/LocalLow/miHoYo/$([char]0x539f)$([char]0x795e)/output_log.txt")
  $globalExists = Test-Path $logPathGlobal
  $cnExists = Test-Path $logPathChina

  function Write-FoundGlobal { Write-Host "Found Genshin Impact (Global) log file!" -ForegroundColor Green }
  function Write-FoundCN { Write-Host "Found $([char]0x539f)$([char]0x795e) (CN) log file!" -ForegroundColor Green }

  if ($globalExists) {
    if ($cnExists) {
      # both exists, pick newest one
      if ((Get-Item $logPathGlobal).LastWriteTime -ge (Get-Item $logPathChina).LastWriteTime) {
        Write-FoundGlobal
        return $logPathGlobal
      }
      else {
        Write-FoundCN
        return $logPathChina
      }
    }
    else {
      Write-FoundGlobal
      return $logPathGlobal
    }
  }
  else {
    if ($cnExists) {
      Write-FoundCN
      return $logPathChina
    }
    else {
      return $null
    }
  }
}

function Invoke-RunAsAdminPrompt {
  if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Do you want to try to run the script as Administrator? Press [ENTER] to continue, or any key to cancel." -ForegroundColor DarkBlue
    $keyInput = [Console]::ReadKey($true).Key
    if ($keyInput -ne "13") {
      return
    }
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList "-noexit $arguments $reg"
  }
  else {
    Write-Host "Make sure Genshin Impact is installed and open `"Wish History`" page at least once." -ForegroundColor Red
  }
}

function Stop-BrowserProcessSilently {
  [CmdletBinding(SupportsShouldProcess)]
  param ()
  $retryLimit = 5
  $retryCount = 0
  while ($retryCount -lt $retryLimit) {
    $zfBrowser = Get-Process -Name "ZFGameBrowser" -ErrorAction SilentlyContinue
    if ($zfBrowser) {
      $zfBrowser | Stop-Process -Force
      Start-Sleep 2
      $retryCount++
    }
    else {
      break
    }
  }
  if ($retryCount -gt 0) {
    # if retried, then browser was running
    Write-Host "Waiting for in-game browser process to close..." -ForegroundColor Yellow
    # Wait for file lock to release
    Start-Sleep 10
  } # else no need to wait
}

function Remove-CacheFolder {
  [CmdletBinding(SupportsShouldProcess)]
  param (
    [string]$CacheFolderPath
  )
  $retryLimit = 5
  $retryCount = 0
  while ((Test-Path "$CacheFolderPath") -and ($retryCount -lt $retryLimit)) {
    Remove-Item -Recurse -Force "$CacheFolderPath" -ErrorAction SilentlyContinue
    $retryCount++
    Start-Sleep 2
  }
}

function Invoke-PromptClearCache {
  param (
    [string]$CacheFolderPath
  )
  Write-Host "Do you want to try to clear the cache folder? This will require restarting Genshin Impact if the game is running.
(This will force the game to generate a new cache file)
Press [ENTER] to continue, or any key to cancel." -ForegroundColor DarkBlue
  $keyInput = [Console]::ReadKey($true).Key
  if ($keyInput -eq "13") {
    # kill browser if Genshin is running
    Stop-BrowserProcessSilently
    # remove webCaches folder to force game to generate new cache
    Remove-CacheFolder "$CacheFolderPath"
    Write-Host "Cache folder cleared! Please restart Genshin Impact and reopen `"Wish History`"!" -ForegroundColor Red
  }
  else {
    Write-Host "Please reopen `"Wish History`" to fetch new URL!" -ForegroundColor Red
  }
}

function Get-GenshinWishUrl {
  $LogPath = Get-GenshinLogPath
  if (-not $LogPath) {
    Write-Host "Cannot find Genshin Impact log file! Make sure to run Genshin Impact and open the wish history at least once!" -ForegroundColor Red
    Invoke-RunAsAdminPrompt
    return $null
  }

  $LogsContent = Get-Content -Path $LogPath
  $GameDataPathRegexPattern = "(?m).:/.+(GenshinImpact_Data|YuanShen_Data)"
  $LogMatch = $LogsContent -match $GameDataPathRegexPattern

  if (-not $LogMatch) {
    Write-Host "Cannot find Genshin Impact path in log file! Make sure to run Genshin Impact and open the wish history at least once!" -ForegroundColor Red
    Pause
    return $null
  }

  $GameDataPath = ($LogMatch | Select-Object -Last 1) -match $GameDataPathRegexPattern
  $GameDataPath = $Matches[0]
  $CacheFolderPath = "$GameDataPath/webCaches"
  try {
    if (Test-Path "$CacheFolderPath") {
      Write-Host "Cache folder found! Trying to extract latest cache file..." -ForegroundColor Green
      try {
        $cacheVerPath = Get-Item (Get-ChildItem -Path "$GameDataPath/webCaches" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
        $cachePath = "$cacheVerPath/Cache/Cache_Data/data_2"

        if (-not (Test-Path $cachePath)) {
          throw "Cache file not found!"
        }

        # check cache not older than 2 days
        if ((Get-Item $cachePath).LastWriteTime -le $(Get-Date).AddDays(-2)) {
          throw "Cache file is too old!"
        }

        $tmpFile = "$env:TEMP/ch_data_2"
        Copy-Item $cachePath -Destination $tmpFile
        $content = Get-Content -Encoding UTF8 -Raw $tmpfile
        Remove-Item $tmpFile

        $splitted = $content -split "1/0/" | Select-Object -Last 1
        $found = $splitted -match "https.+?game_biz=hk4e_(global|cn)"
        if ($found) {
          $cacheVer = Split-Path $cacheVerPath -Leaf
          Write-Host "Wish URL file found in $cacheVer cache! Validating wish URL..." -ForegroundColor Green
          $wishUrl = Get-ValidatedWishUrl $Matches[0]
          if ($wishUrl) {
            Write-Host "Wish URL validated!" -ForegroundColor Green
            Set-Clipboard -Value $WishUrl
            Write-Host "URL copied to clipboard, paste it on any Genshin Impact ($([char]0x539f)$([char]0x795e)) wish tracker`nor Ctrl-Click to open in web browser." -ForegroundColor Green
            return $wishUrl
          }
        }
        throw "No valid URL found in cache!"
      }
      catch {
        Write-Host "Encountered error: "$_.Exception.Message -ForegroundColor Yellow
        Write-Host "Cache folder was found but could not find valid wish URL in the files!" -ForegroundColor Yellow
        Invoke-PromptClearCache "$CacheFolderPath"
      }
    }
    else {
      throw "Cache folder was not found! Please restart Genshin Impact and reopen `"Wish History`"!"
    }
  }
  catch {
    Write-Host "Encountered error: "$_.Exception.Message -ForegroundColor Red
    Pause
  }
  return $null
}

# Run the script
Get-GenshinWishUrl
