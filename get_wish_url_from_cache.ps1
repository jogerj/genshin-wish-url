# script version 0.2
# author: jogerj
function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

$genshin_path = Get-ItemPropertyValue -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Genshin Impact" -Name InstallPath
$cache_path = "$genshin_path\\Genshin Impact Game\\GenshinImpact_Data\\webCaches\\Cache\\Cache_Data"
$temp_dir = New-TemporaryDirectory
cd $temp_dir

# downloads ChromeCacheView
Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/chromecacheview.zip" -OutFile chromecacheview.zip
Expand-Archive chromecacheview.zip -DestinationPath chromecacheview
cd chromecacheview

.\ChromeCacheView.exe -folder $cache_path /scomma cache_data.csv
# processing cache takes a while
while (!(Test-Path cache_data.csv)) { Start-Sleep 1 }
$wish_log = Import-Csv cache_data.csv | select  "Last Accessed", "URL" | ? URL -like "*event/gacha_info/api/getGachaLog*" | Sort-Object -Descending { $_."Last Accessed" -as [datetime] } | select -first 1
$wish_url = $wish_log | % {$_.URL.Substring(4)}
$wish_url_date = $wish_log | % {$_."Last Accessed" -as [datetime]}

# clean up 
cd ..
Remove-Item -Recurse -Force chromecacheview

if ($wish_url) {
    $current = Get-Date
    $time_diff = New-TimeSpan -Start $wish_url_date -End $current | % {$_.Hours}

    Write-Host $wish_url
    if ($time_diff -ge 24) {
        Write-Host "WARNING: Link found is older than 24 hours and might be expired! Open Wish History again to fetch a new link if it doesn't work" -ForegroundColor Yellow
        Read-Host -Prompt "Press ENTER to copy link anyway or CTRL+C to quit" 
    }
    Set-Clipboard -Value $wish_url
    Write-Host "Link from $wish_url_date copied to clipboard, paste it back to paimon.moe" -ForegroundColor Green
} else {
    Write-Host "Link not found! Make sure Genshin Impact is installed and open Wish History page at least once." -ForegroundColor Red
    pause
}