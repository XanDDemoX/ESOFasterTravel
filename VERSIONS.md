Change Log
=============
* **Version 1.5.8**
  * Fixed keep tooltip error messages when displaying quests in Cyrodiil
* **Version 1.5.7**
  * Fixed incorrect campaignId for Home campaign.
  * Fixed faction order not updating on travel.
* **Version 1.5.6**
  * Added alliance/faction icons for locations
* **Version 1.5.5**
  * Added campaign queue status display on tooltips and icons.
  * Added keep under attack status detection and display.
  * Added of location re-ording user interface.
* **Version 1.5.4**
  * Added campaign display and joining outside of Cyrodiil.
  * Added campaign tooltip for display of campaign population and status. 
  * Fixed Keeps not displaying before visiting a Transitus shrine
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
* **Version 1.4.4**
  * Fixed recall cost display not updating during cooldown.
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