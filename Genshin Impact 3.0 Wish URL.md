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