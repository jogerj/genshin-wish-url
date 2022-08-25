## Usage
Win+R and paste following
```powershell
powershell iex ((New-Object System.Net.WebClient).DownloadString('https://gist.githubusercontent.com/jogerj/0339e61a92e0de2e360c5212a94854e8/raw/6ddd4d2d7f7feff3d25e767a6272ff48ba1e9cd2/get_wish_url_from_cache.ps1'))
```

## Report bugs/errors
Comment on this gist or send message on [paimon.moe Discord server](https://discord.com/channels/820601523125747712/820601523125747715/1012175730873991228)
* #### Error `Get-ItemPropertyValue : Property InstallPath does not exist at Path`
  Either you did not install Genshin Impact on your computer or you did a fresh install in Windows 11 (fix incoming). Current workaround is to manually specify the installation path. Save this [script](https://gist.github.com/jogerj/0339e61a92e0de2e360c5212a94854e8/raw/cc6187e8f09618ea29e7fa05e7d019ed97729b9d/get_wish_url_from_cache.ps1) below to your computer and modify this line
  ```powershell
  $genshin_path = "C:\Program Files\Genshin Impact\"
  ```
  or wherever you installed your game. Run with `powershell get_wish_url_from_cache.ps1`

## Changelog
<details>

### Version 0.2
* Added date of URL to output
* Add warning for URL older than 24h
### Version 0.1
Initial release
</details>

<details>
  <summary><h2>Original Post</h2></summary>

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