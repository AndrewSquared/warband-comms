
4.0.0 (Mainline)
    - full internal/external rebrand from RetWBComms to WarbandComms
    - renamed core addon files to WarbandComms.lua, WarbandComms.xml, and WarbandComms.mod
    - updated module metadata and saved variable root to WarbandComms.Settings
    - fixed tracker visibility sync logic so per-tracker toggles always respect global enabled state
    - fixed notification checkbox initialization to read from settings.notifications
    - added slash aliases: /warbandcomms, /wb-comms, /wbc
    - deprecated /ret slash command with in-chat guidance to /wbc
    - deprecated /retwbcomms and /rwc slash commands with in-chat guidance to /wbc
    - added independent text size controls for tracker headers and row text in config
    - finalized text scaling behavior: +/- controls set addon text scale; LayoutEditor resize remains intuitive (box and text scale together)
    - synced LayoutEditor hidden state with tracker visibility toggles
    - hardened LayoutEditor registration to avoid duplicate/phantom entries and clean legacy interupt typo registrations
    - added tracker box width and height controls in config with live apply and clamp limits
    - persisted tracker box width and height settings across reload/restart
    - fixed shared box resize jitter by removing forced window re-anchoring during width/height changes
    - normalized tracker title and row alignment to the current box width for consistent header positioning
    - added resize mode switch for box controls: Uniform (normalize all tracker sizes) or Relative (preserve per-tracker layout deltas)
    - added background opacity controls in config with live apply and persisted setting
    - cleaned up realm-specific protocol tags by using a single comms key: [WBC]
    - temporary compatibility: still accepts incoming legacy tags [RET]/[DEVA] while emitting [WBC]
    - deprecation notice: legacy [RET]/[DEVA] parser path is deprecated and scheduled for removal in a future release
    - fixed tracker row text overflow by constraining name/timer layout and truncating long names inside box bounds
    - row text size control now also scales career icons and keeps icon/name spacing aligned
    - adjusted background opacity clamp to full 0%-100% range
    - simplified tracker headers for readability (plain titles, cleaner spacing, improved contrast)
    - added header emphasis presets in config with live-applied tone and style options for tracker titles
    - refined header emphasis: titles are now left-aligned for steadier strong styling, soft tone removed, and red/green/blue tones added
    - simplified header styles to Clean/Caps (legacy Strong now maps to Caps) and added default title padding/margins
    - increased top header spacing inside tracker boxes and updated LTC title text to "Leading the Charge"


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




