## Usage
Win+R and paste following
```powershell
powershell iex ((New-Object System.Net.WebClient).DownloadString('https://gist.githubusercontent.com/jogerj/0339e61a92e0de2e360c5212a94854e8/raw/6ddd4d2d7f7feff3d25e767a6272ff48ba1e9cd2/get_wish_url_from_cache.ps1'))
```

<details>
<summary>Original concept</summary>

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

</details>