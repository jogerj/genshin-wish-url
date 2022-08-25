# script version 0.4
# author: jogerj

Try {
    $genshinPath = Get-ItemPropertyValue -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Genshin Impact" -Name InstallPath -ErrorAction Stop
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

# Credits to PrimeCicada for finding this path
$cachePath = "$gamePath\\GenshinImpact_Data\\webCaches\\Service Worker\\CacheStorage\\f944a42103e2b9f8d6ee266c44da97452cde8a7c"
cd $cachePath

$cacheFolder = Get-ChildItem | sort -Property LastWriteTime -Descending | select -First 1
$content = Get-Content "$($cache_folder.FullName)\\00d9a0f4d2a83ce0_0" | Select-String -Pattern "https://webstatic-sea.hoyoverse.com/genshin/event/e20190909gacha-v2/"
$logEntry = $content[1].ToString()
$wishUrl = $logEntry -match "https.*log"

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
} else {
    Write-Host "Link not found! Make sure to open Wish History page at least once before running." -ForegroundColor Red
    pause
}