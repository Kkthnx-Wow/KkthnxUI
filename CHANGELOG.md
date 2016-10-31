# KkthnxUI Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [v6.08] - 1:43:20 PM EDT Monday, October 31, 2016
- Could be some undocumented changes that are not listed!

### Added
- 24-Hour time option
- Add the armory link dialog to the LFG Finder (Thanks, peatah)
- Credits
- DataBars will now change border colors if the option gets enabled
- Files added to git ignore
- FilgerSpells added
- GarrisonLandingPageMinimapButton will hide in instances now.
- Global texture color for buffs border when option is enabled
- Item level slots make a return
- Locales
- More config options for various UI elements.
- ObjectiveTracker skinning
- Option to show you in party
- Protection added for various UI options
- Raid tools
- TestUI option /Test
- Tooltip item level makes a return
- Translation needed text.

### Changed
- Bank and Bags positions updated
- ChatSpam list
- Did some work on oUF nameplates (These are a work in progress)
- HonorBar, ArtifactBar, ReputationBar, ExperienceBar
- Profiles so people can make their own
- Reworked the KkthnxUI_Config button locations
- Reworked the minimap icons
- StyleButton updated and improved
- yOffset for party frames changed to -32 up from -30

### Removed
- Old API code
- Old FilgerSpells removed
- Old Functions code
- Old code, files, and settings
- Whitespaces in various files

### Fixed
- Adjusted ShadowOffset because Blizzard has to mess with things that are not broken.
- BoostUI option now works as intended
- Colorpicker alpha text working again
- FrameStrata for world map tooltips
- Hyperlinks
- Install script
- Minimap location in restricted areas
- Nameplates auras shadow colors
- Nameplates non-threat issue
- Quest level
- The World map in restricted areas
- Tooltip border bug
- Various typos in code

## [v6.02] - 6:14:28 PM EDT Monday, October 17, 2016

### Added
- First, pass on raid frames support (oUF based)
- Added proper border to raid frames.
- Suppport for mouseover actionbars (rightbars, pet, stance) and Vehicle indicator icon
- Started support for config for raid frames.
- Added focus castbar and mover.

### Changed
- Update oUF
- Just some cleanup
- Raid frames config changes
- Toast position
- Orderhall skin changed to reflect the better position and settings.
- Vehicle indicator code into its own file.
- Adjusted how the raid frames are confied
- Tons of clean up
- Changed the Database again.
- Improved cooldown module.
- Redid nameplates again. Reverted to an older version a lot of people liked.

### Removed
- Remove old nameplates
- Remove code that is no longer being used.
- Removed trailing whitespaces.

### Fixed
- Border fixes for Filger.
- Fixed aura timers.
- Border.lua border colors
- Grammar
- ObjectiveTracker mover not showing again after Dugi was disabled after being enabled.
- Fixed name:raid tag for raid frames.
- Fixed the DBM skin.
- Fixed raid frame issue for maxunit
- Cooldown charges
- Try to fix CompactRaidFrameManager taint.

## [v6.01] - Wenseday, October 12, 2016

### Fixed
- ObjectiveTracker resetting
- Fixed errors if Bagnon was loaded or any other bag for that matter.

## [v6.00] - Wenseday, October 12, 2016

- This changelog is gonna be short. So much was changed. Sorry.

### Added
- New bags
- New nameplates
- Protection to some code from other addons
- Movers for all unit frames.

### Changed
- General code format.
- Database variables
- How things get saved
- Unitframes style and code.

### Fixed
- Stutter when in combat on massive pulls.
- Fixed missing textures.
- Fixed most taints by baking in new oUF frames
- Capture bar properly moves now.

### Removed
- Combat text
- Old Nameplates
- All item level support until 7.1

## [v5.28] - 2:07:14 AM EDT Monday, September 26, 2016
### Added
- Nothing new added in this build. Or maybe I just forgot what I have done? :|

### Changed
- AutoCollapse.lua changed to now only collapse in Instances.
- Changed how blizzard frames are hidden.
- Changed the TOC to v5.28 up from v5.27.
- DBM skin updated. Using shadows for this one baby.
- Improved MinimapButtons.lua script.
- Updated ItemIcons.lua

### Fixed
- Attempted to revert code to resolve this ongoing freezing issue.
- Check for the issue with action bars event changeD to PLAYER_ENTERING_WORLD from PLAYER_LOGIN. This fixes the repeated popup.
- Fix an issue with action bar grid state not fully working once turned on or off.
- Fixed DBM moving issue. I forgot to include the option for this in v5.27.
- Fixed the display text being offset by 3 when it needed to be 0.
- Garbage collect issue is now fixed. Titan Gods only knows how long this was broken for and why.
- General code cleanup.

### Removed
- Removed / Reverted a lot of code from a week ago. Pretty pissed off about this. FeelsBadMan :'(.
- Removed the lag bar. This was causing an OnHide issue with the player cast bar. (Could make a return ;))
- Removed the smooth status bar script. This was way too buggy.

## [v5.27] - 10:17:02 PM EDT Friday, September 23, 2016
### Added
- Add resting to auto collapse?.
- Added Combattext module.
- Added spellid and item count to the tooltip.
- The adjusted spacing between cast bar and health for nameplates.
- Attempt to fix cast bar resizing issue.
- Attempt to fix unit frames not clickable after vehicle :(.
- Blizzard_CombatText added as OptionalDeps.
- Chat spam list updated.
- Disable.lua rewrote for new functions.
- Fixed filger mover not registering.
- Fixed world quest tooltip issue.
- General cleanup.
- General combat checks for frames and cast bars?
- Install image complete added.
- Localization updated.
- Locals updated.
- Media.lua updated.
- More add-ons added to Disable.lua.
- New Nameplates debuff updated for DemonHunters.
- New functions to check for other addons over mine. (Thanks to Goldpaw)
- Pushed to GitHub for backup.
- Raid auras added to filger.
- Rewrote nameplates.
- Updated Licenses.
- WIP micro menu list to be sorted.

### Changed
- Changed how the cast bars are handled within combat.
- Changed unit frames while in combat.

### Fixed
- Try to fix the freezing issue reported. Untested. Am I not even sure it's my UI?

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
