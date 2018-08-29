# KkthnxUI Change Log

What makes unicorns cry?
All notable changes to this project will be documented in this file.

**Version 8.17 [August nil, 2018]**

Added `FixGarbageCollect` setting
Increaed the delay on Version Checking
Removed `function K.Comma(value)`
Cleanup `Init.lua`
Add `Libraries\oUF_Plugins\oUF_DebuffHighlight.lua`
Change how AutoCollapse works
Cleanup `Blizzard/BlizzBugFixes.lua`
Change how we check for Max Level stuff in Databars
Cleanup `Skin/Blizzard/Tooltip.lua`
Cleanup `Skins/Core.lua`
Cleanup `Tooltip/Tooltip.lua`
Increaed yOffset for Partyframes if buffs are shown
Adjust debuffs size for partyframes
Add `Module:CreateDebuffHighlight()` for Unitframes
Removed MasterLooter from `Unitframes/Groups/Raid.lua`
Nameplates are being tested for `DebuffHighlight` and `PvPIndicator`

___

**Version 7.19 [April 30th 2018]**

**New:**
Raid frames have a width and height config now. This applies tio DAMAGER and HEALER layout together.
Locales added for 3 new options for raid frames. (Width, Height and RaidGroups)

**Fixes:**
Fix issue #95. This error was caused because of a missing arg before the second arg.
Fixed ROGUE combo points if they were to have the talent to give more than 5 combopoints.

**Miscellaneous:**
5 Files cleaned up throughout the UI.

___

**Version 7.18 [April 29th 2018]**

**New:**
CreateBackdrop now supports the strip arg.
CODE_OF_CONDUCT.md added to files on GitHub.

**Fixes:**
Fixed CopyURL not applying URL into editbox.
Fixed issue #94 by Mcbooze. (bank slot purchase issue)
Fix Arena prep frames using wrong parent.

**Miscellaneous:**
Cleanup numerous files.
Removed LibDialog-1.0 completely.

___

**Version 7.17 [April 27th 2018]**

**New:**
Added oUF_CombatFader Plugin. This only affects Player and Pet frames.
Unitframes have been split into their own files.
Loot will now show quest color on the loot frame when looting items if it is a quest item.
Add an option to disable automatic page switching on Bar1 for druids and rogues.
Added texture to indicate what config group is currently active.


**Fixes:**
Fix `Party as Raid` option.
Fix non-3d portraits frame level.
Try to properly fix nameplate aura size.
Fixed issue with K.PostUpdateHealth function.
Fixed config dropdown overflow being hidden
Fix maintank and maintanktarget.
Fixed mover issues with (some) empty unitframe group headers.
Fix healer raid frame position issue to its parent.


**Miscellaneous:**
Reworked raid frame code to support a `HEALER` and a `DAMAGER` layout.
Added a config check for new `TargetHighlight` feature.
Updated Animation file.
Removed Lib LibButtonGlow-1.0.
Updated Filger anchors.
Core Locales for Actionbars.
Cleanup local oUF = oUF or K.oUF.
___
