# ESOFasterTravel v1.3.1
An addon for The Elder Scrolls Online which improves the usability of in game travel and teleporting between zones, wayshrines, friends, group and guild members by extending the default world map information/navigation control.

FasterTravel adds two new tabs to the default world map information/navigation control and suggests approximately the closest known wayshrines to your current quest objectives.

[Download the latest version](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel%201.3.2.zip)

* Wayshrines
  * Displays the closest known wayshrine to your quests by marking them with the quest's icon from the map when the data is available.
  * Displays quest objective tooltips when the mouse is over quest icons.
  * Fast travel to or recall a recently used wayshrine
  * Fast travel to or recall a wayshrine in the current zone
  * Fast travel to or recall a wayshrine in another
  * All fast travels and recalls use the appropriate standard confirmation dialog.
  
  ![Image of Faster Travel's wayshrines tab](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/images/image03.jpg "Wayshrines Tab")
  
* Players
  * Teleport to players in your group
  * Teleport to players on your friends list
  * Teleport to zones using players on your friends list, in your group or guild
  * Teleport to players in your any of your guilds
  
  ![Image of Faster Travel's players tab](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/images/image02.jpg "Players Tab")
  
Installation
=============
1. [Download the latest version](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel%201.3.2.zip)
2. Extract or copy the "FasterTravel" folder into your addons folder:

"Documents\Elder Scrolls Online\live\Addons"

"Documents\Elder Scrolls Online\liveeu\Addons"

For example:

"Documents\Elder Scrolls Online\live\Addons\FasterTravel"

"Documents\Elder Scrolls Online\liveeu\Addons\FasterTravel"


Usage
=============
* Use a wayshrine or open the world map.

* Slash commands
  * /goto zoneName - attempts to teleport to a zone via a player.
  * /goto @PlayerName - attempts to teleport to a player.
  * /goto CharacterName - attempts to teleport a player using their character name. (only works in a group)
  
Change Log
=============
* **Version 1.3.2**
  * Fixed error message when opening map in an unknown location / main quest dungeon.
* **Version 1.3.1**
  * Multiple fixes and improvements for multi-language compatibility
  * Fixed location detection potentially resolving the current zone incorrectly in some dungeons.
  * Fixed quests markers potentially refreshing whilst world map is hidden
* **Version 1.2.7**
  * Fixed quest markers potentially not appearing following a location change.
  * Fixed location detection potentially resolving Tamriel in a known location.
  * Fixed guild categories on players tab opening in their initial state.
* **Version 1.2.6**
  * Added support for Eyevea
  * Fixed handling of The Harborage
  * Fixed quest tooltip potentially remaining open after closing the map
* **Version 1.2.2**
  * Initial Release

DISCLAIMER
=============
THIS ADDON IS NOT CREATED BY, ENDORSED, MAINTAINED OR SUPPORTED BY ZENIMAX OR ANY OF ITS AFFLIATES.
