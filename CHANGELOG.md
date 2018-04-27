# KkthnxUI Change Log

What makes unicorns cry?
All notable changes to this project will be documented in this file.

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
