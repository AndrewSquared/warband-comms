
4.0.0 (Mainline)
    - full internal/external rebrand from RetWBComms to WarbandComms
    - renamed core addon files to WarbandComms.lua, WarbandComms.xml, and WarbandComms.mod
    - updated module metadata and saved variable root to WarbandComms.Settings
    - fixed tracker visibility sync logic so per-tracker toggles always respect global enabled state
    - fixed notification checkbox initialization to read from settings.notifications
    - added slash aliases: /warbandcomms, /wb-comms, /wbc
    - deprecated /ret slash command with in-chat guidance to /wbc
    - deprecated /retwbcomms and /rwc slash commands with in-chat guidance to /wbc


1.0 LTC Window(Mainline)
2.0 Challenge Window (Enlil)
2.1 (Mainline)
    - fixed LTC active time from >170 to >110
    - fixed Challenge active time from >20 to >23
    - Add LTC summary window (intended for non tanks for quick status check)
    - Add config options for LTC summary, LTC Notifications, Challenge UI
    - Right aligned timer text in UI
    - Add function to map warband members to dictionary
    - Register for OnBattleGroupUpdated and trigger check that "List members" are in warband.
    - Removed Challenge notifications (to center screen)
    - add /slash command to clear all list
    - add /wbcomms as alias command to /rwc
    - made config menu moveable
    - made ui winows movable
    - moved config func to new file config.lua
    - moved util funcs to new file utils.lua
2.2 (Mainline)
    - reworked UpdateUI() to loop over WarbandMap (members) to provide consistent ordering and remove ppl who left warband.
    - add tests.lua for updating UI.  /script WarbandComms.StartTest()
    - removed LTC Summary Window (for now, maybe forever)
    - added versioning to Saved Setting
    - do not show on startup after first time
2.2.1 (Mainline)
    - fixes chat message name type - aka sender. Chat not read correctly. Added test for reading from /chat.
3.0.0 (Enlil)
    - fixed adding players to the list when using challenges and LTC while in wb
    - Add Channeling window for dps channeling abilities
    - Add cd tracker for Whirling Axe (white lion ability) only
3.1.0 (Mainline)
    - update test to incorporate adding players fix from 3.0.0
    - add test for Annihilate
    - add Whilring Axe, Retribution and Annihilate + Wrecking Ball as DPS Channels Tracker
3.1.1 (Mainline)
    - moved ui functions to new file ui.lua
    - condition chat_key on player's realm (["RET"] or ["DEVA"])
    - removed obsolete .Test() function
3.2.3 (Mainline)
    - refactor: CreateUI(tracker) to loop over Trackers array
    - fixed CreateUI() always using ltc settings
    - removed rezzes
    - normalised commsKey (aka chat_key) (instead of healer_key and tank_key)
    - refactor OnUpdate(), OnCast() and TextArrived() to DRY functions based off super trackedAbilities list
    - prevented double chat messages on casting channels ("not averageLatency")
    - gets cooldown data from action bar for tracked/enabled abilities :star:
    - dynamically create UI windows from ui-template.xml
    - adds "Into The Fray" to LTC tracker (Tank/Onslaught)
3.3.0 (Mainline)
    - added /ret to slash commands
    - ensure 8 names fit in windows (reduce row height, increase and hardode window height, smaller windows+++)
    - fixed test to work with change to ability:duration:cooldown format from per 3.2.3
    - added more test abilities to ensure at least 8 names appear
    - added Destro Tank Challenges (Enlil)
    - added career Icons to UI
3.3.1 (Mainline)
    - Fix if new cooldown has not triggered and logged cooldown is only 1.5-2s
    - Move solo WarbandMap to MapWarbandMembers()
    - add Sorc's channel Disastrous Cascade (needs testing)
    - add sort ordering warbandmap - use case it put Longest DPS channels top of list
3.4.1 (Mainline)
    - try fix cooldowns put in chat with value of 0 or 2
    - moved /slash stuff to new flie: slash.lua and added some test slash commands
    - only use /say if selfTest is true
    - some local table performance updates (use local tinsert, tsort)
    - some more perfomance optimisations (via ChatGPT)
    - refactored config window to create tracker settings dynamically
    - added global "enabled" settings
    - added Interrupts Tracker (SM, WL, Mara)
3.5.3 (Mainline)
    - fixed Marauder Interrupt Mouth of Tzeentch ability id
    - refactored "Notifications" to be dynamical created (DRY), so extendable
    - debounce OnBattleGroupUpdated client hook (performance optimisation)
    - added code for fixedCooldowns (for abilities not on proper action bars, e.g. morale)




