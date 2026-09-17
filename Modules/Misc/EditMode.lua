--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/EditMode.lua
	Purpose:
		Stop Edit Mode managing the systems we have replaced.

		Edit Mode is left alive on purpose. It still owns everything we do not
		touch, and killing it outright would take the player's own layout with it.
		What it must not do is keep refreshing a system whose frames we have
		already hidden and rebuilt: those refreshes re-show Blizzard frames, undo
		our anchors, and run inside the account settings path where they taint.

		So each refresh is stubbed only when the module that replaced it is on,
		which keeps a partly disabled install working the way the player expects.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("EditMode")

-- Every entry is a method on EditModeAccountSettingsMixin, verified against the
-- client, paired with whether we own that system.
local function BuildList()
	local unitframes = C.Unitframe.Enable
	local actionbars = C.ActionBar.Enable

	return {
		RefreshTargetAndFocus = unitframes,
		RefreshBossFrames = unitframes,
		RefreshArenaFrames = unitframes,
		RefreshPetFrame = unitframes,
		RefreshPartyFrames = unitframes and C.Unitframe.Party and C.Unitframe.Party.Enable,
		RefreshRaidFrames = unitframes and C.Unitframe.Raid and C.Unitframe.Raid.Enable,
		RefreshCastBar = unitframes and C.Unitframe.Castbar and C.Unitframe.Castbar.Enable,

		RefreshActionBarShown = actionbars,
		ResetActionBarShown = actionbars,
		RefreshVehicleLeaveButton = actionbars,
		RefreshEncounterBar = actionbars,
		RefreshExtraAbilities = actionbars,

		RefreshBuffsAndDebuffs = C.Auras.Enable,
	}
end

function Module:OnEnable()
	local manager = _G.EditModeManagerFrame
	local settings = manager and manager.AccountSettings
	if not settings then
		return
	end

	for method, owned in pairs(BuildList()) do
		-- Only stub what the client actually has. A method that goes away in a
		-- later patch should not leave a dead entry behind.
		if owned and settings[method] then
			settings[method] = K.Noop
		end
	end
end
