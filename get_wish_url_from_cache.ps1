# script version 0.3
# author: jogerj

Try {
    $genshinPath = Get-ItemPropertyValue -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Genshin Impact   aaaaaa" -Name InstallPath -ErrorAction Stop
} Catch [System.Management.Automation.ItemNotFoundException]{
    Try {
    # possibly older install
    $genshinPath = Get-ItemPropertyValue -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\launcher" -Name InstPath -ErrorAction Stop
    } Catch [System.Management.Automation.ItemNotFoundException] {
        Write-Host "Could not find Genshin Impact installation files!" -ForegroundColor Yellow
        $genshinExe = Read-Host -Prompt "Drag and drop your Genshin Impact game/launcher shortcut/exe file here and press ENTER"
        $genshinExe = $genshinExe.Replace('"', '')
        if ($genshinExe.EndsWith(".lnk")) {
            echo $lnk
            # extract path from shortcut
            $wshell = New-Object -ComObject WScript.Shell
            $genshinExe = Get-ChildItem -Path $genshinExe | ForEach-Object {$wshell.CreateShortcut($_.Fullname).TargetPath}
        }
        if ($genshinExe.EndsWith("launcher.exe")){
            $genshinPath = "$genshinExe\\.."
        } elseif ($genshinExe.EndsWith("GenshinImpact.exe")){
            $gamePath = "$genshinExe\\.."
        } else {
            Write-Host "Could not find Genshin Impact game files. Please put a valid shortcut/exe file path." -ForegroundColor Red
            Write-Host "If you think this is an error, please comment in https://gist.github.com/jogerj/0339e61a92e0de2e360c5212a94854e8" -ForegroundColor Red
            pause
            exit
        }
    }
}

if (!($gamePath)) {
    $configPath = "$genshinPath\\config.ini"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | Select-String -Pattern "game_install_path"
        $gamePath = $config[0].ToString() -replace "game_install_path=", ""
        $gamePath = (Resolve-Path $gamePath).Path
    }
    
}

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

$cachePath = "$gamePath\\GenshinImpact_Data\\webCaches\\Cache\\Cache_Data"
$tempDir = New-TemporaryDirectory
cd $tempDir

# downloads ChromeCacheView
Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/chromecacheview.zip" -OutFile chromecacheview.zip
Expand-Archive chromecacheview.zip -DestinationPath chromecacheview
cd chromecacheview

.\ChromeCacheView.exe -folder $cachePath /scomma cache_data.csv
# processing cache takes a while
while (!(Test-Path cache_data.csv)) { Start-Sleep 1 }
$wishLog = Import-Csv cache_data.csv | select  "Last Accessed", "URL" | ? URL -like "*event/gacha_info/api/getGachaLog*" | Sort-Object -Descending { $_."Last Accessed" -as [datetime] } | select -first 1
$wishUrl = $wishLog | % {$_.URL.Substring(4)}
$wishUrlDate = $wishLog | % {$_."Last Accessed" -as [datetime]}

# clean up 
#cd ..
#Remove-Item -Recurse -Force chromecacheview

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