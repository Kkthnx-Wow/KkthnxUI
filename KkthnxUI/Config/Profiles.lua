local K, C, L, _ = select(2, ...):unpack()

--[[

IT'S IMPORTANT TO NOT OVERWRITE THE ORIGINAL TABLE. SO IF YOU WANT TO EDIT, FOR EXAMPLE,
SOME OF THE UNITFRAMES DEFAULT SETTINGS, IT SHOULD BE DONE THIS WAY.

C["Unitframe"]["EnhancedFrames"] = true
C["Unitframe"]["PercentHealth"] = true
C["Unitframe"]["ClassIcon"] = true
C["Unitframe"]["SmoothBars"] = true

PLEASE DO NOT EDIT SETTINGS THIS WAY

C["UnitFrames"] = {
	["EnhancedFrames"] = true,
	["PercentHealth"] = true,
	["ClassIcon"] = true,
	["SmoothBars"] = true,
}

]]--

-- PER CLASS CONFIG (OVERWRITES GENERAL)
-- CLASS TYPE NEED TO BE UPPERCASE -- DRUID, MAGE ECT ECT...
if K.Class == "DRUID" then

end

if K.Role == "Tank" then

end

-- PER CHARACTER NAME CONFIG (OVERWRITE GENERAL AND CLASS)
-- NAME NEED TO BE CASE SENSITIVE
if K.Name == "CharacterName" then

end

-- PER MAX CHARACTER LEVEL CONFIG (OVERWRITE GENERAL, CLASS AND NAME)
if K.Level ~= MAX_PLAYER_LEVEL then

end

-- MAGICNACHOS PERSONAL CONFIG
if (K.Name == "Magicnachos") and (K.Realm == "Stormreaver") then

end

-- KKTHNX PERSONAL CONFIG
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
	C["Automation"]["SellGreyRepair"] = true
	C["Automation"]["TabBinder"] = true

	C["Chat"]["DamageMeterSpam"] = true
	C["Chat"]["Spam"] = true

	C["General"]["CustomLagTolerance"] = true
	C["General"]["TranslateMessage"] = false
	C["General"]["WelcomeMessage"] = false

	C["Loot"]["AutoGreed"] = true
	C["Loot"]["ConfirmDisenchant"] = true

	C["Misc"]["AFKCamera"] = true
	C["Misc"]["AlreadyKnown"] = true
	C["Misc"]["Armory"] = true
	C["Misc"]["BGSpam"] = true
	C["Misc"]["DurabilityWarninig"] = true
	C["Misc"]["ItemLevel"] = true
	C["Misc"]["MoveBlizzard"] = true

	C["PulseCD"]["Enable"] = true

	C["Tooltip"]["ItemCount"] = true
	C["Tooltip"]["ItemIcon"] = true
	C["Tooltip"]["QualityBorder"] = true
	C["Tooltip"]["Rank"] = true
	C["Tooltip"]["SpellID"] = true
	C["Tooltip"]["WhoTargetting"] = true

	C["Unitframe"]["ClassIcon"] = true
	C["Unitframe"]["EnhancedFrames"] = true
	C["Unitframe"]["ClassHealth"] = true
	C["Unitframe"]["SmoothBars"] = true

end