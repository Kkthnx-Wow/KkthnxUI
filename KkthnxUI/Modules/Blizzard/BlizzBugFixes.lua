local K, C = unpack(select(2, ...))
local Module = K:NewModule("BlizzardFixes")

local _G = _G

local BlackoutWorld = _G.BlackoutWorld
local collectgarbage = _G.collectgarbage
local CreateFrame = _G.CreateFrame
local PVPReadyDialog = _G.PVPReadyDialog
local StaticPopupDialogs = _G.StaticPopupDialogs
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage

local blizzardCollectgarbage = collectgarbage

-- Garbage collection is being overused and misused,
-- and it's causing lag and performance drops.
blizzardCollectgarbage("setpause", 110)
blizzardCollectgarbage("setstepmul", 200)

function Module:CollectGarbage(opt, arg)
	if (opt == "collect") or (opt == nil) then
	elseif (opt == "count") then
		return blizzardCollectgarbage(opt, arg)
	elseif (opt == "setpause") then
		return blizzardCollectgarbage("setpause", 110)
	elseif opt == "setstepmul" then
		return blizzardCollectgarbage("setstepmul", 200)
	elseif (opt == "stop") then
	elseif (opt == "restart") then
	elseif (opt == "step") then
		if (arg ~= nil) then
			if (arg <= 10000) then
				return blizzardCollectgarbage(opt, arg)
			end
		else
			return blizzardCollectgarbage(opt, arg)
		end
	else
		return blizzardCollectgarbage(opt, arg)
	end
end

-- Memory usage is unrelated to performance, and tracking memory usage does not track "bad" addons.
-- Developers can uncomment this line to enable the functionality when looking for memory leaks,
-- but for the average end-user this is a completely pointless thing to track.
UpdateAddOnMemoryUsage = function() end

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

function Module:OnEnable()
	self:CollectGarbage()
	self:FixMisclickPopups()

	CreateFrame("Frame"):SetScript("OnUpdate", function(self)
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)
end