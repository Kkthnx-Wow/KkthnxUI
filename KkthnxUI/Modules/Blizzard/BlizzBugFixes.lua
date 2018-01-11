local K, C = unpack(select(2, ...))
local Module = K:NewModule("BlizzardFixes", "AceEvent-3.0")

local _G = _G

local BlackoutWorld = _G.BlackoutWorld
local collectgarbage = _G.collectgarbage
local CreateFrame = _G.CreateFrame
local GetCVar = _G.GetCVar
local GetCVarDefault = _G.GetCVarDefault
local PVPReadyDialog = _G.PVPReadyDialog
local StaticPopupDialogs = _G.StaticPopupDialogs
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage

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

-- Garbage collection is being overused and misused, and it's causing lag and performance drops.
do
	local oldcollectgarbage = collectgarbage
	oldcollectgarbage("setpause", 110)
	oldcollectgarbage("setstepmul", 200)

	function collectgarbage(opt, arg)
		if (opt == "collect") or (opt == nil) then
		elseif (opt == "count") then
			return oldcollectgarbage(opt, arg)
		elseif (opt == "setpause") then
			return oldcollectgarbage("setpause", 110)
		elseif opt == "setstepmul" then
			return oldcollectgarbage("setstepmul", 200)
		elseif (opt == "stop") then
		elseif (opt == "restart") then
		elseif (opt == "step") then
			if (arg ~= nil) then
				if (arg <= 10000) then
					return oldcollectgarbage(opt, arg)
				end
			else
				return oldcollectgarbage(opt, arg)
			end
		else
			return oldcollectgarbage(opt, arg)
		end
	end

	-- Memory usage is unrelated to performance, and tracking memory usage does not track "bad" addons.
	-- Developers can uncomment this line to enable the functionality when looking for memory leaks,
	-- but for the average end-user this is a completely pointless thing to track.
	UpdateAddOnMemoryUsage = K.Noop
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