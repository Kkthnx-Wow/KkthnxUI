# KkthnxUI Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] - [v5.28] - 10:40:06 PM EDT Thursday, September 22, 2016
### Added

## [v5.27] - 10:17:02 PM EDT Friday, September 23, 2016
### Added
- Add resting to auto collapse?.
- Added Combattext module.
- Added spellid and itemcount to tooltip.
- Adjusted spacing between castbar and health for nameplates.
- Attempt to fix castbar resizing issue.
- Attempt to fix unitframes not clickable after vehicle :(.
- Blizzard_CombatText added as OptionalDeps.
- Chat spam list updated.
- Disable.lua rewrote for new functions.
- Fixed filger mover not registering.
- Fixed world quest tooltip issue.
- General cleanup.
- General combat checks for frames and castbars?
- Install image complete added.
- Localization updated.
- Locals updated.
- Media.lua updated.
- More addons added to Disable.lua.
- New Nameplates debuff updated for DemonHunters.
- New functions to check for other addons over mine. (Thanks to Goldpaw)
- Pushed to github for backup.
- Raid auras added to filger.
- Rewrote nameplates.
- Updated Licenses.
- WIP micromenu list to be sorted.

### Changed
- Changed how the castbars are handled with in combat.
- Changed unitframes while in combat.

### Fixed
- Try to fix freezing issue reported. Untested. Im not even sure its my UI?

### Removed
- Removed some code for general cleanup.

## [v5.26] - 3:22:03 PM EDT Tuesday, September 20, 2016
### Added
- KkthnxUI logo for future use.
- A lag bar placed on player cast bar. (very very basic)
- New locales for the new features.
- Dropdown lib, this will prevent dropdown taints.\
- LossControl skinned.
- Threat added to nameplates. Can be toggled on or off.
- Class color nameplates can now be toggled on or off.
- FogOfWar added.
- Filger received ton of spell updates
- Garrison button added to the minimap.
- Added BNToastFrame to /moveui so it can be moved.
- World map taint temp fixed. (by lightspark)
- New function (GetDetailedItemLevelInfo)
- CharacterStats improved.
- New dark flat class icons.
- Readded the ability to hide empty action bar buttons again.

### Changed
- Use PLAYER_LOGIN event for frames again.
- Chatframe width changed from 400 down to 370.
- Another run at the cast bar issues after being in a vehicle. (This is very annoying)
- Chat timestamp color changed to 113/255, 213/255, 255/255 :D.
- UI name color changed.
- Chat spam list updated
- General profile updates.
- The level display on nameplates improved.
- ObjectiveTracker position improved.
- Updated code for range and out of power detection
- Rewrote how the chat frame is setup during install.

### Fixed
- Calendar date will now display on the minimap calendar
- DBM error fixed.
- A ton of fixes for filgers core.
- Capture bar should now be styled once again and fixed position.
- Rare realm name issue fixed on nameplates.
- Actionbar taint while in a vehicle.
- Item levels for slots on the character sheet, bags and tooltip should be working almost perfect by now.

### Removed
- Removed all custom color in the system stat module.
- PLAYER_REGEN_DISABLED and PLAYER_REGEN_ENABLED events removed from cast bars.
- Removed boss frame movers. This is becoming a pain in my ass.