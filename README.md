# ESOFasterTravel v1.5.4
An addon for The Elder Scrolls Online which improves the usability of in game travel and teleporting between zones, wayshrines, friends, group and guild members by extending the default world map information/navigation control.

FasterTravel adds two new tabs to the default world map information/navigation control and suggests approximately the closest known wayshrines to your current quest objectives.

[Download the latest stable version](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel%201.4.6.zip)

[Try the latest beta version (1.5.4)](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel-latest-beta.zip)

* **Wayshrines**
  * Displays the closest known wayshrine to your quests by marking them with the quest's icon from the map when the data is available.
  * Displays quest objective tooltips when the mouse is over quest icons.
  * Fast travel to or recall a recently used wayshrine
  * Fast travel to or recall a wayshrine in the current zone
  * Fast travel to or recall a wayshrine in another
  * All fast travels and recalls use the appropriate standard confirmation dialog.
  * Now supports Transitus Wayshrines in Cyrodiil!
* **Players**
  * Teleport to players in your group
  * Teleport to players on your friends list
  * Teleport to zones using players on your friends list, in your group or guild
  * Teleport to players in your any of your guilds
  
  ![Image of Faster Travel's wayshrines tab](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/images/image04-cropped.jpg "Wayshrines Tab")

  ![Image of Faster Travel's wayshrines tab](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/images/image07-cropped.jpg "Wayshrines Tab")

  ![Image of Faster Travel's players tab](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/images/image02-cropped.jpg "Players Tab")
  
Installation
=============
1. [Download the latest stable version](https://raw.githubusercontent.com/XanDDemoX/ESOFasterTravel/master/zips/Faster%20Travel%201.4.6.zip)
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
  * /goto group - attempts to teleport to the group leader or a player in your group (if you are the group leader)
  * /goto UnitTag - attempts to teleport to a player using their unit tag (group1 ,group2 group3 etc)

Recent Change Log
=============
* **Version 1.5.4**
  * Added campaign display and joining outside of Cyrodiil.
  * Added campaign tooltip for display of campaign population and status. 
* **Version 1.5.3**
  * Added panning to keeps.
  * Performance improvements to quest tracker.
  * Fixed wayshrines / quests not being invalidated on campaign state initialised.
  * Implemented quest display for Keep tooltips.
  * Fixed Cyrodiil detection preventing display of keeps on initial entry.
  * Fixed Cyrodiil detection in quest tracker
* **Version 1.5.2**
  * Added zone ordering support.
  * Fixed recall confirmation not message being displayed outside of Cyrodiil preventing recall.
  * Fixed quest selection context menu not being hidden on world map hide.
  * Fixed error message attempting to teleport within a group where player is the leader and all other players are offline.
* **Version 1.5.1**
  * Added display keep tooltip instead of wayshrine tooltip on mouse over keep rows 
  * Added recall cooldown time display 
* **Version 1.5.0**
  * Added "Fast Travel Here" text. 
  * Fixed incorrect display of Cyrodiil wayshrines whilst player is not in Cyrodiil
  * Fixed Transitus shrines not being displayed under the "Cyrodiil" heading whilst the player is in Cyrodiil
* **Version 1.4.9**
  * Added Transitus shrine support in Cyrodiil 
  * Fixed tooltip display within Cyrodiil not displaying recall disallowed. 
  * Fixed confirmation travel confirmation message being displayed when recall / travel disallowed.
* **Version 1.4.8**
  * Fixed Main Quest and Crafting quest markers not appearing.
  * Added pan map to wayshrine on click
* **Version 1.4.7**
  * Added teleport to unit tag (group1 ,group2 group3 etc) via /goto slash command 
* **Version 1.4.6**
  * Fixed error message on attempting to focus quests from recent list.
* **Version 1.4.5**
  * Fixed multiple tracked quest icons being displayed when the tracked quest has been changed
  * Fixed setting map to quest objectives potentially changing the current map inside a delve / city.
  * Fixed ordering of quest objectives potentially not updating when the tracked quest has been changed.

[View Full Change Log](https://github.com/XanDDemoX/ESOFasterTravel/blob/master/VERSIONS.md)

DISCLAIMER
=============
THIS ADDON IS NOT CREATED BY, ENDORSED, MAINTAINED OR SUPPORTED BY ZENIMAX OR ANY OF ITS AFFLIATES.
