--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Nameplates/Core.lua
	Purpose:
		Nameplates built on oUF's own nameplate driver: a bordered health bar,
		threat colouring, target highlight, a small castbar, and personal
		debuffs. Kept lean and combat safe.

		The console variables are set once at login, out of combat, to size and
		space the plates. The look lives in Style.lua.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("Nameplates")

local oUF = K.oUF

local SetCVar = SetCVar
local InCombatLockdown = InCombatLockdown

-- Console variables that shape the plates. Kept conservative and only applied
-- when out of combat, since some of these are protected during combat.
function Module:SetupCVars()
	if InCombatLockdown() then
		return
	end
	local db = C.Nameplate

	SetCVar("nameplateShowAll", 1)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("nameplateShowEnemyMinions", 1)
	SetCVar("nameplateMinScale", 1)
	SetCVar("nameplateMaxScale", 1)
	SetCVar("nameplateSelectedScale", 1.1)
	SetCVar("nameplateMaxDistance", db.MaxDistance)
	SetCVar("nameplateOverlapH", 0.8)
	SetCVar("nameplateOverlapV", 1.1)
	SetCVar("clampTargetNameplateToScreen", 1)
	SetCVar("ShowClassColorInNameplate", 1)
end

function Module:OnEnable()
	if not C.Nameplate.Enable then
		return
	end
	if not self.Style then
		return
	end

	if K.BuildNameplateColors then
		K.BuildNameplateColors()
	end

	oUF:RegisterStyle("KkthnxUI_NamePlate", self.Style)
	oUF:SetActiveStyle("KkthnxUI_NamePlate")

	-- Spawn the plates, then size the clickable footprint on the driver.
	local driver = oUF:SpawnNamePlates("KKUI_NamePlate")
	if driver and driver.SetSize then
		driver:SetSize(C.Nameplate.Width, C.Nameplate.Height + 24)
	end
	self.driver = driver

	self:SetupCVars()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "SetupCVars")

	if self.SetupTargetPower then
		self:SetupTargetPower()
	end
end
