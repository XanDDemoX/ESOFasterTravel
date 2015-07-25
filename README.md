# ESOFasterTravel v2.0.4
An addon for The Elder Scrolls Online which improves the usability of in game travel and teleporting between zones, wayshrines, friends, group and guild members by extending the default world map information/navigation control.

FasterTravel adds two new tabs to the default world map information/navigation control and suggests approximately the closest known wayshrines to your current quest objectives.

[Download the latest stable version](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel%202.0.4.zip)
<!---
[Try the latest beta version (2.0.0)](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel-latest-beta.zip)
-->

* **Wayshrines**
  * Displays the closest known wayshrine to your quests by marking them with the quest's icon from the map when the data is available.
  * Displays quest objective tooltips when the mouse is over quest icons.
  * Fast travel to or recall a recently used wayshrine
  * Fast travel to or recall a wayshrine in the current zone
  * Fast travel to or recall a wayshrine in another zone
  * All fast travels and recalls use the appropriate standard confirmation dialog.
  * Now supports Cyrodiil campaigns and Transitus Wayshrines including queuing, entering, travelling and tooltip display!
  * New Favourites Category!
* **Players**
  * Teleport to players in your group
  * Teleport to players on your friends list
  * Teleport to zones using players on your friends list, in your group or guild
  * Teleport to players in your any of your guilds
  
  ![Image of Faster Travel's wayshrines tab](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/images/image16-cropped.jpg "Wayshrines Tab")

  ![Image of Faster Travel's wayshrines tab](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/images/image12-cropped.jpg "Wayshrines Tab")
  
  ![Image of Faster Travel's wayshrines tab](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/images/image15-cropped.jpg "Wayshrines Tab")

  ![Image of Faster Travel's players tab](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/images/image02-cropped.jpg "Players Tab")
  
Installation
=============
1. [Download the latest stable version](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel%202.0.4.zip)
2. Extract or copy the "FasterTravel" folder into your addons folder:

"Documents\Elder Scrolls Online\live\Addons"

"Documents\Elder Scrolls Online\liveeu\Addons"

For example:

"Documents\Elder Scrolls Online\live\Addons\FasterTravel"

"Documents\Elder Scrolls Online\liveeu\Addons\FasterTravel"


Usage
=============
* Use a wayshrine or open the world map.
* Right Click in Wayshrines Menu to Add or Remove Favourites.

* Slash commands
  * /goto zoneName - attempts to teleport to a zone via a player.
  * /goto @PlayerName - attempts to teleport to a player.
  * /goto CharacterName - attempts to teleport a player using their character name. (only works in a group)
  * /goto group - attempts to teleport to the group leader or a player in your group (if you are the group leader)
  * /goto UnitTag - attempts to teleport to a player using their unit tag (group1 ,group2 group3 etc)

Recent Change Log
=============
* **Version 2.0.4**
  * Fixed teleport during interaction fall through map bug. 
* **Version 2.0.3**
  * Added favourites category and right click menu.
  * Added partial Zone Name matching for /goto command
* **Version 2.0.2**
  * Added Craglorn Trial wayshrine support.
  * Added teleport error detection and attempt next player upon failure when teleporting by zone name.
* **Version 2.0.1**
  * Fixed intermittent display of incorrect focussed quest icon
  * Removed prefix from Cyrodiil queue status displays. 
  * Fixed potential error message when clearing icons on world map open.
  * Fixed AD faction order table in LocationData.
* **Version 2.0.0**
  * Cyrodiil campaigns and Transitus Wayshrines support
  * Fixed Keep names for multi-language.
  * Switched to string ids for sort order text for localisation.
  * Fixed Alliance level ordering descending moving Cyrodiil to the bottom of the list.
  * Added check to ensure keeps under attack do not have their icon switched to a quest icon.

[View Full Change Log](https://github.com/XanDDemoX/ESOFasterTravel/blob/master/VERSIONS.md)

DISCLAIMER
=============
THIS ADDON IS NOT CREATED BY, ENDORSED, MAINTAINED OR SUPPORTED BY ZENIMAX OR ANY OF ITS AFFLIATES.
