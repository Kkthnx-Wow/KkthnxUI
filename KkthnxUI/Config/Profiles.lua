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

	C["Nameplate"]["Auras"] = true
	C["Nameplate"]["ClassIcons"] = true
	C["Nameplate"]["NameAbbreviate"] = false

	C["PulseCD"]["Enable"] = true

	C["Tooltip"]["ItemCount"] = true
	C["Tooltip"]["ItemIcon"] = true
	C["Tooltip"]["QualityBorder"] = true
	C["Tooltip"]["Rank"] = true
	C["Tooltip"]["SpellID"] = true
	C["Tooltip"]["WhoTargetting"] = true

	C["Unitframe"]["ClassIcon"] = true
	C["Unitframe"]["EnhancedFrames"] = true
	C["Unitframe"]["PercentHealth"] = true
	C["Unitframe"]["SmoothBars"] = true

end

-- SWIVER PERSONAL CONFIG
if (K.Name == "Swiverr" or K.Name == "Swiver" or K.Name == "Swifer" or K.Name == "Swiferdan" or K.Name == "Swivers" or K.Name == "Swav" or K.Name == "Swivarr") and (K.Realm == "Stormreaver") then

	C["Position"]["Quest"] = {"TOPLEFT", "UIParent", "TOPLEFT", 21, -2}
	C["Position"]["PetHorizontal"] = {"RIGHT", "UIParent", "RIGHT", -42.4661254882813, -0.600280225276947}
	C["Position"]["RightBars"] = {"RIGHT", "UIParent", "RIGHT", -4.06657457351685, -0.399972349405289}
	C["Position"]["StanceBar"] = {"RIGHT", "UIParent", "RIGHT", -84.1996459960938, -0.999915540218353}
	C["Position"]["PlayerBuffs"] = {"TOPRIGHT", "UIParent", "TOPRIGHT", -160.599853515625, -2.99996113777161}

	C["ActionBar"]["BottomBars"] = 2
	C["ActionBar"]["RightBars"] = 1
	C["ActionBar"]["StanceBarHorizontal"] = false

	C["Announcements"]["Interrupt"] = true
	C["Announcements"]["SaySapped"] = true

	C["Automation"]["DeclineDuel"] = true
	C["Automation"]["Resurrection"] = true
	C["Automation"]["SellGreyRepair"] = true
	C["Automation"]["TabBinder"] = true

	C["Chat"]["Outline"] = true
	C["Chat"]["TabsMouseover"] = false
	C["Chat"]["TabsOutline"] = true

	C["Loot"]["AutoGreed"] = true

	C["Misc"]["ItemLevel"] = true

end