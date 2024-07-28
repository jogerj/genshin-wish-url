# Usage
Win+R and paste following
* All versions (Global/China)
```powershell
powershell iex (irm 'https://gist.githubusercontent.com/jogerj/0339e61a92e0de2e360c5212a94854e8/raw/get_wish_url_from_cache.ps1')
```
* for (Powershell 6+)
```powershell
pwsh -Command iex (irm 'https://gist.githubusercontent.com/jogerj/0339e61a92e0de2e360c5212a94854e8/raw/get_wish_url_from_cache.ps1')
```

* \*NEW\* shortened URL which redirects here
```powershell
iex (irm 'https://genshin.jogerj.com/wishurl')
```

### [Click here for getting wish URL from Genshin Impact on Android](https://gist.github.com/jogerj/2372d0e5bee51e001a6d8956240d527b)

# Report bugs/errors
Comment on this gist or send message on [paimon.moe Discord server](https://discord.com/channels/820601523125747712/820601523125747715/1012175730873991228)

Officially supported: **Powershell 5.1 and above** (Default installed on **Windows 10 and above**). Older OS will not be supported, but you may try [upgrading your powershell version](https://www.microsoft.com/en-us/download/details.aspx?id=54616).

# Changelog
<details> 

## Version 0.13.0
* Fix for new API URL in 4.8 (Global)
* Rework checks. Now returned URL defaults to Character Wish Banner

## Version 0.12.2
* Fix for new API URL in 4.6 (CN)
* Added short URL
 
## Version 0.12.1
* Typo message fix
   
## Version 0.12.0
* Deprecated and removed fallback methods
* Now cache path lookup checks for latest modified subfolder
   
## Version 0.11.1
* Fix for Genshin 4.0
   
## Version 0.11.0
* Fix for Genshin 3.8

## Version 0.10.0
* Now if a user has both global and china version of the game, it will load the URL from whichever is last open.

## Version 0.9.0
* Fix CN suffix to `game_biz=hk4e_cn`
* Fix check validity for URLs beginning with `https://webstatic...`

## Version 0.8.0
* Added new method from [MadeBaruna](https://gist.github.com/MadeBaruna/1d75c1d37d19eca71591ec8a31178235/). Now supports 3 different methods (should be totally foolproof 🤞)
* Automatically checks for expired/invalid link
* ~~URL date is now retrieved from URL `timestamp` parameter~~ Removed URL time since it's unnecessary to check for URL expiry


## Version 0.7.0
* Combined Global and China server scripts. Now will check for Global first before China log files. Can be overriden to force check China server by adding `china` to the parameter like this:
   ```powershell
   powershell iex "&{$(irm 'https://gist.githubusercontent.com/jogerj/0339e61a92e0de2e360c5212a94854e8/raw/get_wish_url_from_cache.ps1')} china"
   ```
* Pass on args to elevated powershell correctly
* Use more accurate file path pattern from [here](https://gist.github.com/MadeBaruna/1d75c1d37d19eca71591ec8a31178235/)
  
## Version 0.6.0
* Added back old method as fallback option (when webCache gets destroyed/new install)

### Version 0.5.0
* Changed game path lookup to search in log file instead of install path
* Added China version (needs testing)
* adjusted URL lookup pattern

### Version 0.4.0
* ChromeCacheView no longer needed. Script will now read cache files directly
* Credits to @PrimeCicada for finding an alternate path
  
### Version 0.3.0
* Added handling of different game path
* Fixes issue with older installs of Genshin with different path
* Added fallback option for manual entry of game path. Drag and drop your shortcut or exe file (either launcher or game works), the cache path will be grabbed correctly
  
### Version 0.2.0
* Added date of URL to output
* Add warning for URL older than 24h
### Version 0.1.0
* Initial release
</details>

## [Original script](https://gist.github.com/MadeBaruna/1d75c1d37d19eca71591ec8a31178235)
