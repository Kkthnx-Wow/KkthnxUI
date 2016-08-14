local K, C, L, _ = select(2, ...):unpack()

-- PER CLASS CONFIG (OVERWRITES GENERAL)
-- CLASS TYPE NEED TO BE UPPERCASE -- DRUID MAGE ECT ECT...
if K.Class == "DRUID" then

end

if K.Role == "Tank" then

end

-- PER CHARACTER NAME CONFIG (OVERWRITE GENERAL AND CLASS)
-- NAME NEED TO BE CASE SENSITIVE
if K.Name == "CharacterName" then

end

-- PER MAX CHARACTER LEVEL CONFIG (OVERWRITE GENERAL CLASS AND NAME)
if K.Level ~= MAX_PLAYER_LEVEL then

end

-- MAGICNACHOS PERSONAL CONFIG
if (K.Name == "Magicnachos") and (K.Realm == "Stormreaver") then

end

-- KKTHNX PERSONAL CONFIG
if (K.Name == "Pervie") and (K.Realm == "Stormreaver") then

	C["Misc"]["AFKCamera"] = true
	C["Misc"]["BGSpam"] = true
	C["Misc"]["DurabilityWarninig"] = true
	C["Misc"]["Armory"] = true
	C["Misc"]["ItemLevel"] = true
	C["Misc"]["AlreadyKnown"] = true

	C["Tooltip"]["ItemCount"] = true
	C["Tooltip"]["QualityBorder"] = true
	C["Tooltip"]["WhoTargetting"] = true
	C["Tooltip"]["Rank"] = true
	C["Tooltip"]["SpellID"] = true
	C["Tooltip"]["ItemIcon"] = true

	C["ActionBar"]["EquipBorder"] = true
	C["ActionBar"]["SelfCast"] = true
	C["ActionBar"]["BottomBars"] = 2
	C["ActionBar"]["RightBars"] = 1

	C["Announcements"]["BadGear"] = true
	C["Announcements"]["Portals"] = true
	C["Announcements"]["Toys"] = true
	C["Announcements"]["Spells"] = true
	C["Announcements"]["Interrupt"] = true
	C["Announcements"]["SaySapped"] = true
	C["Announcements"]["SpellsFromAll"] = true
	C["Announcements"]["Feasts"] = true

	C["Unitframe"]["EnhancedFrames"] = true
	C["Unitframe"]["PercentHealth"] = true
	C["Unitframe"]["ClassIcon"] = true
	C["Unitframe"]["SmoothBars"] = true

	C["Loot"]["ConfirmDisenchant"] = true
	C["Loot"]["AutoGreed"] = true

	C["Aura"]["CastBy"] = true

	C["Chat"]["DamageMeterSpam"] = true
	C["Chat"]["Spam"] = true

	C["Automation"]["Resurrection"] = true
	C["Automation"]["AutoInvite"] = true
	C["Automation"]["DeclineDuel"] = true
	C["Automation"]["LoggingCombat"] = true
	C["Automation"]["SellGreyRepair"] = true
	C["Automation"]["TabBinder"] = true
	C["Automation"]["ScreenShot"] = true

end