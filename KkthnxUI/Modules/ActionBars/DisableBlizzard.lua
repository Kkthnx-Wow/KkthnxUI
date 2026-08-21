--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/DisableBlizzard.lua
	Purpose:
		Fully retire the stock Blizzard bars. Reparenting to an offscreen frame,
		stripping scripts, and shutting down the controller/event frames stops
		Blizzard from ever re-showing or re-paging a bar behind ours. Run once at
		login, out of combat.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local Module = K:GetModule("ActionBars")

local _G = _G
local strmatch = string.match

-- Bars we reparent offscreen so they never draw.
local FRAMES_TO_HIDE = {
	"MainMenuBar",
	"MainActionBar",
	"MultiBarBottomLeft",
	"MultiBarBottomRight",
	"MultiBarLeft",
	"MultiBarRight",
	"MultiBar5",
	"MultiBar6",
	"MultiBar7",
	"PossessActionBar",
	"OverrideActionBar",
}

-- Frames we also silence: unregister events and strip scripts. StanceBar is
-- left alive on purpose: we reuse its buttons in our own stance bar and need
-- Blizzard to keep driving their state.
local FRAMES_TO_DISABLE = {
	"MultiBarBottomLeft",
	"MultiBarBottomRight",
	"MultiBarLeft",
	"MultiBarRight",
	"MultiBar5",
	"MultiBar6",
	"MultiBar7",
	"PossessActionBar",
	"StatusTrackingBarManager",
}

local SCRIPTS = {
	"OnShow", "OnHide", "OnEvent", "OnEnter", "OnLeave",
	"OnUpdate", "OnValueChanged", "OnClick", "OnMouseDown", "OnMouseUp",
}

local function StripScripts(frame)
	for _, script in ipairs(SCRIPTS) do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

-- Keep Blizzard's button event frame from re-registering the default buttons,
-- while still allowing ExtraActionButtons to work.
local function TrimButtonEventFrames(self)
	local frames = self.frames
	if not frames then
		return
	end
	for index = #frames, 1, -1 do
		local frame = frames[index]
		local name = frame:GetName()
		if not (name and strmatch(name, "ExtraActionButton%d")) then
			frames[index] = nil
		end
	end
end

-- Shut down the controller and event frames that drive the stock bars. We keep
-- only the handful of events needed for ExtraActionButton and totems.
local function DisableControllerEvents()
	if _G.ActionBarController then
		_G.ActionBarController:UnregisterAllEvents()
		_G.ActionBarController:RegisterEvent("SETTINGS_LOADED")
		_G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	end
	if _G.ActionBarActionEventsFrame then
		_G.ActionBarActionEventsFrame:UnregisterAllEvents()
	end
	if _G.ActionBarButtonEventsFrame then
		_G.ActionBarButtonEventsFrame:UnregisterAllEvents()
		_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
		_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
		hooksecurefunc(_G.ActionBarButtonEventsFrame, "RegisterFrame", TrimButtonEventFrames)
		TrimButtonEventFrames(_G.ActionBarButtonEventsFrame)
	end
	if _G.MultiActionBar_ShowAllGrids then
		_G.MultiActionBar_ShowAllGrids = K.Noop
	end
end

function Module:DisableBlizzardBars()
	local hidden = _G.KKUI_HiddenParent
	if not hidden then
		hidden = CreateFrame("Frame", "KKUI_HiddenParent", UIParent)
		hidden:SetAllPoints(UIParent)
		hidden:Hide()
	end
	self.hiddenParent = hidden

	for _, name in ipairs(FRAMES_TO_HIDE) do
		local frame = _G[name]
		if frame then
			frame:SetParent(hidden)
		end
	end

	for _, name in ipairs(FRAMES_TO_DISABLE) do
		local frame = _G[name]
		if frame then
			frame:UnregisterAllEvents()
			StripScripts(frame)
		end
	end

	DisableControllerEvents()

	-- The page number and XP/rep status bars are part of the old look too.
	if _G.MainMenuBarPageNumber then
		_G.MainMenuBarPageNumber:Hide()
	end
	if _G.StatusTrackingBarManager then
		_G.StatusTrackingBarManager:Hide()
	end
end
