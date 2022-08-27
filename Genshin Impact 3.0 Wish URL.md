## Usage
Win+R and paste following
* Global/China
```powershell
powershell iex (irm 'https://gist.githubusercontent.com/jogerj/0339e61a92e0de2e360c5212a94854e8/raw/dbfc65a15db519e9fb1bfe2041f537261018b05e/get_wish_url_from_cache.ps1')
```
## Report bugs/errors
Comment on this gist or send message on [paimon.moe Discord server](https://discord.com/channels/820601523125747712/820601523125747715/1012175730873991228)

## Changelog
<details>

## Version 0.8
* Added new method from [MadeBaruna](https://gist.github.com/MadeBaruna/1d75c1d37d19eca71591ec8a31178235/). Now supports 3 different methods (should be totally foolproof 🤞)
* Automatically checks for expired/invalid link
* ~~URL date is now retrieved from URL `timestamp` parameter~~ Removed URL time since it's unnecessary to check for URL expiry


## Version 0.7
* Combined Global and China server scripts. Now will check for Global first before China log files. Can be overriden to force check China server by adding `china` to the parameter like this:
   ```powershell
   powershell iex "&{$(irm 'https://gist.githubusercontent.com/jogerj/0339e61a92e0de2e360c5212a94854e8/raw/92a398edefd0cce4915b9078d52c418b4560d47d/get_wish_url_from_cache.ps1')} china"
   ```
* Pass on args to elevated powershell correctly
* Use more accurate file path pattern from [here](https://gist.github.com/MadeBaruna/1d75c1d37d19eca71591ec8a31178235/)
  
## Version 0.6
* Added back old method as fallback option (when webCache gets destroyed/new install)

### Version 0.5
* Changed game path lookup to search in log file instead of install path
* Added China version (needs testing)
* adjusted URL lookup pattern

### Version 0.4
* ChromeCacheView no longer needed. Script will now read cache files directly
* Credits to @PrimeCicada for finding an alternate path
  
### Version 0.3
* Added handling of different game path
* Fixes issue with older installs of Genshin with different path
* Added fallback option for manual entry of game path. Drag and drop your shortcut or exe file (either launcher or game works), the cache path will be grabbed correctly
  
### Version 0.2
* Added date of URL to output
* Add warning for URL older than 24h
### Version 0.1
* Initial release
</details>

## [Original script](https://gist.github.com/MadeBaruna/1d75c1d37d19eca71591ec8a31178235)

## Original Post
<details>

## Method
I found a less intrusive way to retrieve wish URL, involves reading from cache:
1. Download and open [Chrome Cache View](https://www.nirsoft.net/utils/chromecacheview.zip)
2. Open your genshin folder and locate this folder: e.g.
`C:\Program Files\Genshin Impact\Genshin Impact Game\GenshinImpact_Data\webCaches\Cache\Cache_Data`
![](https://media.discordapp.net/attachments/820601523125747715/1012146279993843793/unknown.png)
3. Ctrl-Q to open quick filter, look for `gacha_info`
4. Sort by `Last Accessed`
5. Right-click the URL cell and `Copy Clicked Cell`
6. Remove the `1/0/` in front of the URL
7. Post to paimon.moe as usual

## Why this works
  Genshin Impact uses [ZFBrowser](https://zenfulcrum.com/browser/docs/Readme.html), which essentially embeds a Chromium web browser into the game. Hence, there's no reason to not believe that it would behave like a normal Google Chrome/Chromium/Edge browser. The structure of the cache folder doesn't let you easily read its contents but luckily [NirSoft](https://www.nirsoft.net/utils/chrome_cache_view.html) here has done the reverse-engineering for us so all we need to do is retrieve the URL of the cache for that JSON file the game retrieved.
  
</details>

