# KkthnxUI Change Log

What makes unicorns cry?

All notable changes to this project will be documented in this file.

Format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [v3.35] - 4/16/2017 - Hotfix
### Fixed
- Loot frame returning a nil value on color.

## [v3.34] - 4/16/2017
### Added
- Actionbar toggle button now has tooltip info.
- Actionbar toggle button now plays a sound when pressed.
- CopyChat button now has a tooltip with useful info.
- Event "UPDATE_FLOATING_CHAT_WINDOWS" and "UPDATE_CHAT_WINDOWS" to SetupChatPosAndFont function.
- Latency and Time will now hide on failed or interrupted casts.
- New function K.GetAnchors, Used mainly for tooltips.
- New function K.PostCastFailed for cast bars that fail.
- Reworked minimap buttons.
- TalkingHeadFrame has an alpha value now.

### Fixed
- Chat resizing when tabbing out.
- Cooldown numbers disappearing.
- CopyButton position to better match chat position.
- nil error on UpdatePortraitColor function
- nil value in chat.lua.
- Target frame not able to use the dropdown.

### Removed
- InCombatLockdown() check in Unitframes.lua.

### Changed
- ArtifactBar, HonorBar, ExperienceBar, ReputationBar tooltip anchoring to use K.GetAnchors function.
- Clean dev file.
- Cleaned code in chat.lua.
- CommandBar visual update.
- DataText modules now use K.GetAnchors function.
- Hotfixes and optimizations.
- KkthnxUI/Core/Disable.lua → KkthnxUI/Core/Conflicts.lua.
- ToggleButton changed script from HookScript → SetScript.
- Updated Nameplates ThreatColor function.
- Updated Unit frames AurasFilter blackList.
- Vastly improved the KKTHNXUI_INCOMPATIBLE script.

# Archived Changelogs

## [v6.29] - 3/22/2017
### Added
- Bags will update when you pickup/drop a quest.

### Removed
- Old unit frame config merged into default UI config now.
- Engine[4] = {}.

### Changed
- Reverted some inventory code.
- Frame UpdateCVar script has been updated.
- Improved scaling for 'KkthnxUI/Modules/Blizzard/TalkingHeadFrame.lua'.
- Frame oUFKkthnx script.

## [v6.28] - 3/21/2017
### Added
- More RaidAuraWatch spells.
- Flash for newly obtained items in bags. (Will be improved apon over time.)
- Smoothing for all HealPrediction modules.
- Skip button to skip the installer steps. This will take you directly to the last step.

### Fixed
- Junk icon will propely show on the bag slots.
- Threat showing on player units is now fixed and wont show anymore.
- Backdrops on borders/buttons will respectly stay inside the border/button now. :D

### Removed
- UIErrorFrame code all removed.
- All Tutorial code from installer.

### Changed
- Improved apon tag 'TEXT_LONG' text status for unitframes.
- Used proper global strings for unlocking and locking actionbars.
- oUF.colors.health now defaults to a grey.
- Improved nameplates threat code.
- Debuffs on nameplates will now default to the left. They now grow left to right. ->

## [v6.27] - 3/16/2017
### Fixed
- Spark for absorb has its proper texture.
- Heal prediction mybar has a min and max value now.
- Raid frames scale will default to 1 if no value is found.
- ExtraButton position fixed.
- Cooldown for ExtraButton fixed.
- Function UpdateCVar will fire once again.

### Removed
- Old code removed in KkthnxUI/Modules/ActionBars/ExtraActionButton.lua

### Changed
- UIDebugTools will parent to our UIFrameHider now.
- Shortened some loading OnEvent script functions.
- Castbar spark on Nameplates look more fitting.
- K.PriestColors moved to KkthnxUI/Core/Constants.lua.
- K.TexCoords moved to KkthnxUI/Core/Constants.lua.
- OrderHallCommandBar tweaked and is smaller now.
- Cleaned CheckRole function.

## [v6.26] - 3/14/2017
### Fixed
- UIHider > UIFrameHider. This never threw an error but was wrong since the start.
- Nameplate CVars will now apply properly. This fixes disappearing Nameplates.
- Cooldowns will now hold their proper colors. Gosh who knows how long this was broken for. :(
- ZoneButton border will proper show once again.

### Removed
- K.FormatMoney function. We no longer use this.
- SetCVarBitfield LE_FRAME_TUTORIAL. No need this for. We handle this already.
- Pointless SetCVar in Kill.lua. We handle this in Install.lua

### Changed
- Updated .pkgmeta file.
- K.Role will recnoigze "Tank" or "TANK" either way will work now.
- Nameplates height and width adjustd off feedback.
- Cleaned CheckRole function.
- Cleaned Functions.lua file.
- Added some more CVars to Install.lua.

## [v6.20] - 2/28/2017
### Added
- Adding more globals caching.
- Cleaned up old leftover globals/upvalues.

### Fixed
- AutoInvite script should work properly again
- Party frames and their text vaules will no longer stick after being interacted with.
- K.LockCVars should work once again. We forgot to Register PLAYER_REGEN_ENABLED

### Removed
- Removed option to disable class color for frames.
- Removed old settings left behind from previous cleanups
- AlreadyKnown module
- HyperLink module
- InstanceLock module

### Changed
- Change K.Round function by adding protection.

## [v6.17] - 2/23/2017
### Added
- More _G. for Wow API
- JunkIcon display for bags.
- Combat checks for some cvars and code to prevent errors.
- oUF_Absorb.lua
- More status bars will use K.CreateStatusBar now.
- 2 Fixes from Goldpaw to fix 2 blizzard issues.

### Fixed
- Caching of Global variables in some places we missed. I'm sure there is more.
- Fixed nil error in Chat tabs.
- K.IsDeveloper() and K.IsDeveloperRealm().
- CopyChat for /played command.
- Leak in Minimap.lua
- Minimap no longer goes tot he dark side when we enable flat status bar textures.
- DebuffTypeColor not showing red. Was only showing the default UI border color.
- KkthnxUI welcome message.
- UIScale command from firing in combat.
- DisbandRaidGroup will properly work again.
- Updated SetValueText function to prevent a nil error
- A font was causing some fonts that were black text color to have an outline. This is now fixed.
- A lot of code was optimized and fixed as well as cleaned!
- CheckRole function.
- Couple typos

### Removed This list will mainly hold what modules were removed.
- RaidCD.
- PulseCD.
- EnhancedMail.
- BlizzBugsSuck - People can manually pick this up off curse.
- LagTolerance.
- MerchantItemLevel.
- BlizzMoveFrames
- Filger
- AcceptQuest
- TabBinder
- LootFilter
- Ping
- LFDQueueTimer
- PvPQueueTimer
- AnnounceSpells
- LoggingCombat
- BadGear
- SayThanks
- TranslateMessage
- FogOfWar
- Selfcast
- Nameplate ClassIcons
- SwingBar
- All code/settings / locals related to all removed modules.
- Double SpellRange code. No idea how this happened.
- Fixed SpellRange properly now.
- Manabar vertical code for raid frames
- Removed a fix that would taint our world map. The fix is no longer needed for us.

### Changed
- Change how the Chat frame now works. Less of a cluster fuck.
- The bags now have a damn toggle bag slots button.
- The bags slots now show all bags. Even the MainMenuBarBackpack.
- Range code cleanup
- DebugTools now have correct buttons spacing and align properly.
- Rewrote some of the Hide.lua code.
- Improved K.LockCVar
- Unitframe / raid frame threat code
- Updated AuraWatch code
- Updated and streamlined the install process code.
- Improved the Skada profile settings. This is for /settings skada
- Rewrote the heal prediction handling on unit frames, raid frames, and nameplates.
- Rewrote the vehicle button code
- Rewrote the ExtraActionBar code
- Improved Health PostUpdate and Power PostUpdate code. Related to Unitframes.
- oUF_Smooth.lua. Unitframes, Nameplates, and Raid frames now are smoothed once again.
- Improved K.SetFontString function
- Improved GCD code and placement/style
- Improved KkthnxUI:NameplateLevel oUF Tag

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
