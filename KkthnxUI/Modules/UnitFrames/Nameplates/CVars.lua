--[[-----------------------------------------------------------------------------
-- Nameplate Blizzard CVars, driver sizing, and addon conflict hooks.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local pairs = pairs
local tostring = tostring
local tonumber = tonumber
local GetCVar = GetCVar
local SetCVar = SetCVar
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc
local math_max = math.max

function Module:UpdatePlateCVars()
	Module:CreateUnitTable()
	Module:CreatePowerUnitTable()

	if InCombatLockdown() then
		return
	end

	local curTop, curBottom = GetCVar("nameplateOtherTopInset"), GetCVar("nameplateOtherBottomInset")
	if C["Nameplate"].InsideView then
		if curTop ~= "0.05" then
			SetCVar("nameplateOtherTopInset", 0.05)
		end
		if curBottom ~= "0.08" then
			SetCVar("nameplateOtherBottomInset", 0.08)
		end
	else
		if curTop == "0.05" then
			SetCVar("nameplateOtherTopInset", -1)
		end
		if curBottom == "0.08" then
			SetCVar("nameplateOtherBottomInset", -1)
		end
	end

	local settings = {
		namePlateMinScale = C["Nameplate"].MinScale,
		namePlateMaxScale = C["Nameplate"].MaxScale,
		nameplateMinAlpha = C["Nameplate"].MinAlpha,
		nameplateMaxAlpha = C["Nameplate"].MaxAlpha,
		nameplateOverlapV = C["Nameplate"].VerticalSpacing,
		nameplateShowOnlyNames = C["Nameplate"].CVarOnlyNames and 1 or 0,
		nameplateShowFriendlyNPCs = C["Nameplate"].CVarShowNPCs and 1 or 0,
	}

	for cvar, value in pairs(settings) do
		local cur = GetCVar(cvar)
		local want = tostring(value)
		if cur ~= want then
			SetCVar(cvar, value)
		end
	end
end

function Module:UpdateClickableSize()
	if InCombatLockdown() then
		return
	end

	local driver = Module.NameplateDriver
	if not driver then
		return
	end

	local harmWidth, harmHeight = C["Nameplate"].HarmWidth, C["Nameplate"].HarmHeight
	local helpWidth, helpHeight = C["Nameplate"].HelpWidth, C["Nameplate"].HelpHeight

	driver.enemyNonInteractible = C["Nameplate"].EnemyThru
	driver.friendlyNonInteractible = C["Nameplate"].FriendlyThru
	driver:SetSize(math.max(harmWidth, helpWidth), math.max(harmHeight, helpHeight))
end

function Module:UpdatePlateClickThru()
	Module:UpdateClickableSize()
end

function Module:SetupCVars()
	Module:UpdateExecuteCurve()
	Module:UpdatePlateCVars()

	local settings = {
		nameplateOverlapH = 0.8,
		nameplateSelectedAlpha = 1,
		showQuestTrackingTooltips = 1,
		nameplateSelectedScale = C["Nameplate"].SelectedScale,
		nameplateLargerScale = 1.1,
		nameplateGlobalScale = 1,
		NamePlateHorizontalScale = 1,
		NamePlateVerticalScale = 1,
		NamePlateClassificationScale = 1,
		nameplateShowSelf = 0,
		nameplateResourceOnTarget = 0,
		nameplatePlayerMaxDistance = 60,
	}

	for cvar, value in pairs(settings) do
		local cur = GetCVar(cvar)
		local want = tostring(value)
		if cur ~= want then
			SetCVar(cvar, value)
		end
	end

	Module:UpdateClickableSize()
	hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateSize", Module.UpdateClickableSize)
	Module:UpdatePlateClickThru()
end

-- REASON: When KKUI nameplates are toggled off, reset CVars this module overrides so default plates behave normally.
function Module:RestorePlateCVars()
	if InCombatLockdown() then
		return
	end

	local curTop, curBottom = GetCVar("nameplateOtherTopInset"), GetCVar("nameplateOtherBottomInset")
	if curTop == "0.05" then
		SetCVar("nameplateOtherTopInset", -1)
	end
	if curBottom == "0.08" then
		SetCVar("nameplateOtherBottomInset", -1)
	end

	local defaults = {
		nameplateOverlapH = 0.8,
		nameplateSelectedAlpha = 1,
		nameplateSelectedScale = 1,
		nameplateLargerScale = 1.1,
		nameplateGlobalScale = 1,
		NamePlateHorizontalScale = 1,
		NamePlateVerticalScale = 1,
		NamePlateClassificationScale = 1,
		nameplateShowSelf = 1,
		nameplateResourceOnTarget = 1,
		nameplatePlayerMaxDistance = 41,
	}

	for cvar, value in pairs(defaults) do
		local cur = GetCVar(cvar)
		local want = tostring(value)
		if cur and cur ~= want then
			SetCVar(cvar, value)
		end
	end

	local driver = Module.NameplateDriver
	if driver and driver.SetSize then
		local defaultWidth, defaultHeight = 200, 30
		driver:SetSize(defaultWidth, defaultHeight)
	end

	local blizzDriver = _G.NamePlateDriverFrame
	if blizzDriver and blizzDriver.UpdateNamePlateOptions then
		blizzDriver:UpdateNamePlateOptions()
	end
end

function Module:BlockAddons()
	if not _G.DBM or not _G.DBM.Nameplate then
		return
	end

	if DBM.Options then
		DBM.Options.DontShowNameplateIcons = true
		DBM.Options.DontShowNameplateIconsCD = true
		DBM.Options.DontShowNameplateIconsCast = true
	end

	local function showAurasForDBM(_, _, _, spellID)
		if not tonumber(spellID) then
			return
		end

		if not C.NameplateWhiteList[spellID] then
			C.NameplateWhiteList[spellID] = true
		end
	end
	hooksecurefunc(_G.DBM.Nameplate, "Show", showAurasForDBM)
end
