--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/HideTips.lua
	Purpose:
		Turn off the tutorial pop ups: the glowing help tips that point at buttons,
		and the round "i" buttons on panels that open a guided tour.

		Help tips are marked as seen the same way Blizzard marks them when you click
		the close button, so they stay gone. The "i" buttons are hidden as panels
		open, found by the method they share, and are never touched again once
		hidden. Everything is a post hook that runs after Blizzard has finished, and
		the buttons are only hidden, never changed.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local pcall = pcall
local select = select
local hooksecurefunc = hooksecurefunc
local setmetatable = setmetatable

local hidden = setmetatable({}, { __mode = "k" })
local pendingScan

-- The round "i" buttons all use one mixin, so that mixin's tooltip method marks
-- them. The mixin lives in a load on demand addon, so it is looked up when needed.
local function IsHelpButton(frame)
	local mixin = _G.MainHelpPlateButtonMixin
	return mixin and frame.ShowTooltip == mixin.ShowTooltip
end

local ScanChildren

local function Scan(root)
	if IsHelpButton(root) and not hidden[root] then
		hidden[root] = true
		root:SetAlpha(0)
		root:EnableMouse(false)
	end
	if root.GetChildren then
		-- A few Blizzard frames refuse GetChildren from addon code. Skip just that
		-- branch rather than abort the walk.
		pcall(ScanChildren, root)
	end
end

-- GetChildren is called once and its values are walked as a list. Asking for it
-- again for every index would rebuild the whole list for each child.
local function ScanList(...)
	for index = 1, select("#", ...) do
		Scan((select(index, ...)))
	end
end

function ScanChildren(root)
	ScanList(root:GetChildren())
end

-- Tips are collected first and hidden afterwards, because hiding one hands its
-- frame back to Blizzard's pool and that changes the set being walked.
local activeTips = {}

local function CloseHelpTips()
	local tips = _G.HelpTip
	if not (tips and tips.framePool) then
		return
	end
	for tip in tips.framePool:EnumerateActive() do
		activeTips[#activeTips + 1] = tip
	end
	for index = #activeTips, 1, -1 do
		local tip = activeTips[index]
		activeTips[index] = nil
		local info = tip.info
		if tip:IsShown() and info and info.cvarBitfield and info.bitfieldFlag then
			SetCVarBitfield(info.cvarBitfield, info.bitfieldFlag, true)
		end
		tip:Hide()
	end
end

-- Panels and tips are handled on the next frame, never inside the call that is
-- showing them, so nothing here runs in the middle of a Blizzard update.
local queuedPanels = {}

local function Drain()
	pendingScan = nil
	for index = 1, #queuedPanels do
		local frame = queuedPanels[index]
		queuedPanels[index] = nil
		Scan(frame)
	end
	CloseHelpTips()
end

local function Schedule(frame)
	if frame then
		queuedPanels[#queuedPanels + 1] = frame
	end
	if not pendingScan then
		pendingScan = true
		C_Timer.After(0, Drain)
	end
end

function Module:SetupHideTips()
	-- Stays at 0 after the option is turned off again. Tutorials can be switched
	-- back on in the game's own interface options.
	SetCVar("showTutorials", "0")

	if _G.HelpTip and _G.HelpTip.Show then
		hooksecurefunc(_G.HelpTip, "Show", function()
			Schedule()
		end)
	end
	hooksecurefunc("ShowUIPanel", Schedule)
	CloseHelpTips()
end
