local K, C, L, _ = select(2, ...):unpack()

--[[

It's important to not overwrite the original table. so if you want to edit, for example,
some of the unitframes default settings, it should be done this way.

C["Unitframe"]["EnhancedFrames"] = true
C["Unitframe"]["PercentHealth"] = true
C["Unitframe"]["ClassIcon"] = true
C["Unitframe"]["SmoothBars"] = true

---------------------------------------
---------------------------------------

Please do not edit settings this way

C["UnitFrames"] = {
	["EnhancedFrames"] = true,
	["PercentHealth"] = true,
	["ClassIcon"] = true,
	["SmoothBars"] = true,
}

--]]

-- Per class config (overwrites general)
-- Class type need to be uppercase -- druid, mage ect ect...
if K.Class == "DRUID" then

end

if K.Role == "Tank" then

end

-- Per character name config (overwrite general and class)
-- Name needs to be case sensitive
if K.Name == "CharacterName" then

end

-- Per max character level config (overwrite general, class and name)
if K.Level ~= MAX_PLAYER_LEVEL then

end

-- Magicnachos personal config
if (K.Name == "Magicnachos") and (K.Realm == "Stormreaver") then

end

-- Kkthnx personal config
if (K.Name == "Pervie" or K.Name == "Aceer" or K.Name == "Kkthnxx" or K.Name == "Tatterdots") and (K.Realm == "Stormreaver") then

	C["ActionBar"]["BottomBars"] = 2
	C["ActionBar"]["EquipBorder"] = true
	C["ActionBar"]["RightBars"] = 1
	C["ActionBar"]["SelfCast"] = true

	C["Announcements"]["BadGear"] = true
	C["Announcements"]["Feasts"] = true
	C["Announcements"]["Interrupt"] = true
	C["Announcements"]["Portals"] = true
	C["Announcements"]["SaySapped"] = true
	C["Announcements"]["Spells"] = true
	C["Announcements"]["SpellsFromAll"] = true
	C["Announcements"]["Toys"] = true

	C["Aura"]["CastBy"] = true

	C["Automation"]["AutoInvite"] = true
	C["Automation"]["DeclineDuel"] = true
	C["Automation"]["LoggingCombat"] = true
	C["Automation"]["Resurrection"] = true
	C["Automation"]["ScreenShot"] = true
	C["Automation"]["TabBinder"] = false

	C["Chat"]["DamageMeterSpam"] = true
	C["Chat"]["Spam"] = true

	C["CombatText"]["KillingBlow"] = true

	C["General"]["CustomLagTolerance"] = true
	C["General"]["TranslateMessage"] = false
	C["General"]["WelcomeMessage"] = true

	C["Loot"]["AutoGreed"] = true
	C["Loot"]["ConfirmDisenchant"] = true

	C["Misc"]["AFKCamera"] = true
	C["Misc"]["AlreadyKnown"] = true
	C["Misc"]["Armory"] = true
	C["Misc"]["BGSpam"] = true
	C["Misc"]["ColorPicker"] = true
	C["Misc"]["DurabilityWarninig"] = true
	C["Misc"]["ItemLevel"] = true
	C["Misc"]["MoveBlizzard"] = true

	C["Nameplate"]["CastbarName"] = true
	C["Nameplate"]["TrackAuras"] = true

	C["PulseCD"]["Enable"] = true

	C["Skins"]["Skada"] = true

	C["Tooltip"]["ItemCount"] = true
	C["Tooltip"]["ItemIcon"] = true
	C["Tooltip"]["SpellID"] = true

	C["Unitframe"]["BetterPowerColors"] = true
	C["Unitframe"]["CastBarScale"] = 1
	C["Unitframe"]["ClassHealth"] = true
	C["Unitframe"]["ClassIcon"] = true
	C["Unitframe"]["CombatFeedback"] = true
	C["Unitframe"]["EnhancedFrames"] = true
	C["Unitframe"]["FlatClassIcons"] = true
	C["Unitframe"]["GroupNumber"] = true
	C["Unitframe"]["Scale"] = 1

	C["WorldMap"]["FogOfWar"] = true

end