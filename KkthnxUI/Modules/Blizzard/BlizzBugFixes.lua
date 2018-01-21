local K, C = unpack(select(2, ...))
local Module = K:NewModule("BlizzardFixes")

local _G = _G

local BlackoutWorld = _G.BlackoutWorld
local CreateFrame = _G.CreateFrame
local PVPReadyDialog = _G.PVPReadyDialog
local StaticPopupDialogs = _G.StaticPopupDialogs

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, SpellBookFrame, LFRBrowseFrame, PVPTimerFrame, BATTLEFIELD_SHUTDOWN_TIMER

-- Misclicks for some popups
function Module:FixMisclickPopups()
	StaticPopupDialogs.RESURRECT.hideOnEscape = nil
	StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
	StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
	StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
	StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
	StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
	PetBattleQueueReadyFrame.hideOnEscape = nil
	if (PVPReadyDialog) then
		PVPReadyDialog.leaveButton:Hide()
		PVPReadyDialog.enterButton:ClearAllPoints()
		PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
		PVPReadyDialog.label:SetPoint("TOP", 0, -22)
	end
end

function Module:FixMapBlackOut()
	-- Don't black out the world with the full screen WorldMap,
	-- we want to see what's going on in the background in case of danger!
	if (BlackoutWorld and not C["WorldMap"].Enable) then
		BlackoutWorld:SetAlpha(0)
	end
end

function Module:OnEnable()
	self:FixMapBlackOut()
	self:FixMisclickPopups()

	CreateFrame("Frame"):SetScript("OnUpdate", function(self)
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)
end