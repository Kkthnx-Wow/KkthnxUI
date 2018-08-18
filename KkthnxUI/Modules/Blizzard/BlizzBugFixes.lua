local K = unpack(select(2, ...))
local Module = K:NewModule("BlizzBugFixes", "AceEvent-3.0", "AceHook-3.0")

local _G = _G

local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local PVPReadyDialog = _G.PVPReadyDialog
local ShowUIPanel, HideUIPanel = _G.ShowUIPanel, _G.HideUIPanel
local StaticPopupDialogs = _G.StaticPopupDialogs
local TooltipBagBug = false

local GarbageCollection = CreateFrame("Frame")
GarbageCollection:RegisterEvent("PLAYER_FLAGS_CHANGED")
GarbageCollection:RegisterEvent("PLAYER_ENTERING_WORLD")
GarbageCollection:SetScript("OnEvent", function(self, event, unit)
	if (event == "PLAYER_ENTERING_WORLD") then
		collectgarbage("collect")

		self:UnregisterEvent(event)
	else
		if (unit ~= "player") then
			return
		end

		if UnitIsAFK(unit) then
			collectgarbage("collect")
		end
	end
end)

-- Misclicks for some popups
function Module:MisclickPopups()
	StaticPopupDialogs.RESURRECT.hideOnEscape = false
	StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = false
	StaticPopupDialogs.PARTY_INVITE.hideOnEscape = false
	StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = false
	StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = false
	StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = false
	StaticPopupDialogs.DELETE_ITEM.enterClicksFirstButton = true
	StaticPopupDialogs.DELETE_GOOD_ITEM = StaticPopupDialogs.DELETE_ITEM
	StaticPopupDialogs.CONFIRM_PURCHASE_TOKEN_ITEM.enterClicksFirstButton = true

	_G.PetBattleQueueReadyFrame.hideOnEscape = false

	if (PVPReadyDialog) then
		PVPReadyDialog.leaveButton:Hide()
		PVPReadyDialog.enterButton:ClearAllPoints()
		PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
		PVPReadyDialog.label:SetPoint("TOP", 0, -22)
	end
end

-- Fix blank tooltip
function Module:FixTooltip()
	if GameTooltip:IsForbidden() then
		return
	end

	if GameTooltip:IsShown() then
		TooltipBagBug = true
	end
end

function Module:BAG_UPDATE_DELAYED()
	if GameTooltip:IsForbidden() then
		return
	end

	if StuffingFrameBags and StuffingFrameBags:IsShown() then
		if GameTooltip:IsShown() then
			TooltipBagBug = true
		end
	end
end

function Module:BugTooltipCleared(tt)
	if tt:IsForbidden() then
		return
	end

	if TooltipBagBug and tt:NumLines() == 0 then
		tt:Hide()
		TooltipBagBug = false
	end
end

function Module:OnEnable()
	self:MisclickPopups()

	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "FixTooltip")
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", "FixTooltip")
	self:RegisterEvent("BAG_UPDATE_DELAYED")

	self:SecureHookScript(GameTooltip, "OnTooltipCleared", "BugTooltipCleared")

	-- Fix spellbook taint
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)

	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)
end

function Module:OnDisable()
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	self:UnregisterEvent("BAG_UPDATE_DELAYED")
	self:UnregisterEvent("ADDON_LOADED")
end