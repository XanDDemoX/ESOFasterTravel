# ESOFasterTravel v1.4.3
An addon for The Elder Scrolls Online which improves the usability of in game travel and teleporting between zones, wayshrines, friends, group and guild members by extending the default world map information/navigation control.

FasterTravel adds two new tabs to the default world map information/navigation control and suggests approximately the closest known wayshrines to your current quest objectives.

[Download the latest version](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel%201.4.3.zip)

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
1. [Download the latest version](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel%201.4.3.zip)
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
* **Version 1.4.3**
  * Added selection of tracked quest by clicking quest icons
  * Added map panning to quests
  * Added support to quest tracker for displaying quest objectives on the recent list.
  * Added sorting of tracked quest objectives to the top of tooltips.
  * Added displaying wayshrine name in tooltip.
  * Added recall cost display to tooltip.
  * Added displaying quest names, objectives and objective icons in tooltip.
  * Improved wayshrine tooltip layout and formatting.
* **Version 1.4.2**
  * Added support to quest tracker for quest objectives potentially spanning multiple wayshrines.
  * Fixed quest tracker potentially not displaying all quest objectives for some quests.
  * Fixed quest tracker displaying all objectives against wayshrines which are closest to one or more objectives.
  * Fixed zone category displaying Tamriel as location in delves and dungeons of Coldharbour
* **Version 1.4.1**
  * Renamed Readme.txt to README to prevent ESO detecting it as an addon
* **Version 1.4.0**
  * Fixed quest tracker not being invalidated on some quest events
* **Version 1.3.9**
  * Fixed quest tracker requesting positions for all quests on each refresh.
* **Version 1.3.8**
  * Filtered quests from other zones being added to keep quests icons and tooltips contextual to the zone.
  * Performance improvement to quest tracker
* **Version 1.3.7**
  * Improved quest closest wayshrine resolution in quest tracker.
  * Fixed issue where zone location could change to the parent zone in areas such as Bal Foyen upon a ui reload.
* **Version 1.3.6**
  * Moved Readme and Licence into FasterTravel folder within zip for users who use Minion. 
* **Version 1.3.5**
  * Fixed error message when opening the store with with the Wayshrines or Players tab displayed.
* **Version 1.3.4**
  * Fixed unformatted strings potentially being saved into saved variables via recent list.
* **Version 1.3.3**
  * Fixed mapIndex for the "Zone" category potentially being resolved to Tamriel within a city map
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
