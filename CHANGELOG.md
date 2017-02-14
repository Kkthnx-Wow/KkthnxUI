# KkthnxUI Change Log

What makes unicorns cry?

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [v6.16] - 2/13/2017
### Added
- Added a debug lib.
- More features to cast bars added (Interrupted, Holdtime, etc).
- Better taint logging.
- Added more chat channel colors of our own.
- Added some fix scripts from @goldpaw
- Added a developer check script for me.
- Nameplates cast bar now support a hold time of 0.4 and a cast bar spark.
- Unitframe cast bars now supports a hold time of 0.4 and a cast bar spark.
- Skinning to thew BNetToastFrame.

### Fixed
- Fixed conflict with ConsolePort.
- Taint with Moving frames script.
- nil error in Animation.lua resolved finally.
- Fixed chat not being movable after updating our tabs script.

### Removed
- Cleaned up the old chat frame code.
- Found and removed old settings.lua code.
- ClassColor script was removed. Enough AddOns around to handle this. This script was a mess and out of date too.
- Chat background script. We will now work on using the default wow one provided.
- Tutorials.lua
- The vehicle mouseover script is gone now.

### Changed
- Cleaned up XML files, and properly formatted them.
- Aurawatch was completely revamped.
- Raiddebuffs was revamped.
- KkthnxUI Esc menu button rewrote.
- Wow API will now be formatted like so. local UnitName = _G.UnitName. Be sure we always declare _G before hand.
- Adjusted our Engine script.
- Changes to the install script to better suit the new chat changes and cleanup.
- Updated locals
- Changed how some files get loaded and changed the script to be cleaner and smaller.
- Updated nameplate auras.
- Updated formatting of our readme thanks to @goldpaw.
- I moved the /reload script to its own file. Prevents it from being broken in most cases.
- Cleaned the ReputationGain.lua file.

# Archived Changelogs

## [v6.11.7] - 12/27/2016
### Added
- 2 new options for flat texture and blizzard font.
- Can toggle dropdown menus with esc now.
- New LibSpellRange-1.0

### Fixed
- Dropdown list width

### Removed
- Huge font files.
- Old range code for new range code.

### Changed
- Castbars for player and target is 1 global value now. No sense in having 2.
- Mirror timers

## [v6.11.6] - 12/26/2016
### Added
- Locals added corresponding to this update.
- New border textures and code.
- New filger spells added.
- New translations for zhCN, as well a proper font.

### Fixed
- AutoRelease script will now properly disable when turned off.
- Border on raidframes was off by 1
- Fixed checking for channeling on castbars for unit.
- Fixed error on install.
- Resolved 3 nil errors.
- Try to fix hiding of TalkingHeadFrame.

### Removed
- Cleanup uneeded code with new updates as of now.

### Changed
- Added a border around quest buttons.
- Adjusted party/raid positions for better aligning of the UI.
- Animations file code.
- Cleanup/update some code in LibDropDownMenu.
- Functions file and imrpoved the file a bit.
- Renamed a couple functions for better reference.
- Updated spamfilter white/blacklists.

## [v6.11.5] - 12/24/2016
### Added
- Brought back the auto hide feature for garrison icon and calendar. (Can be improved)
- Cached some more globals
- locals for the new time datatext
- Maybe fixed a rare questframe issue. ??
- New animations file to handle fade in and out and flashing.
- PVP dialog timer implemented.

### Fixed
- Border for auras properly have a backdrop
- Bug report fixes for cast bar and pixel perfect script.
- Silly me. I had to calendar code backwards :D

### Removed
- General UI files/code cleanup.
- Script to fix quest frames from sticking removed until I can properly fix it.
- Some event checks were not needed.

### Changed
- Boss names are now white on boss frames.
- Code cleanup in fixes file.
- Globals slowly being coverted a different way so table.insert will be cached like table_insert = table.insert.
- Media changes for certain languages. (Keep an eye on this).
- Recoded/improved the flyout buttons code.
- Time datatext is redone.
