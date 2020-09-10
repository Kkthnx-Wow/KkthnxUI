local K, _, L = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.extraBar

local _G = _G
local table_insert = _G.table.insert
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local function DisableExtraButtonTexture(self, _, loop)
	if loop then
		return
	end

	self:SetTexture("", true)
end

function Module:CreateExtrabar()
	local padding, margin = 10, 5
	local num = 1
	local buttonList = {}

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KKUI_ExtraActionBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * FilterConfig.size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(FilterConfig.size + 2 * padding)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 272, 34}

	-- Move The Buttons Into Position And Reparent Them
	_G.ExtraActionBarFrame:EnableMouse(false)
	_G.ExtraActionBarFrame:SetParent(frame)
	_G.ExtraActionBarFrame:ClearAllPoints()
	_G.ExtraActionBarFrame:SetPoint("CENTER", 0, 0)
	_G.ExtraActionBarFrame.ignoreFramePositionManager = true

	-- The Extra Button
	local button = _G.ExtraActionButton1
	table_insert(buttonList, button) -- Add The Button Object To The List
	button:SetSize(FilterConfig.size, FilterConfig.size)

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	if K.ActionBars.userPlaced then
		frame.mover = K.Mover(frame, L["Extrabar"], "Extrabar", frame.Pos)
	end

	-- create the mouseover functionality
	if FilterConfig.fader then
		K.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end

	-- Zone Ability
	_G.ZoneAbilityFrame:ClearAllPoints()
	_G.ZoneAbilityFrame.ignoreFramePositionManager = true
	_G.ZoneAbilityFrameNormalTexture:SetAlpha(0)
	K.Mover(_G.ZoneAbilityFrame, "ZoneAbilityFrame", "ZoneAbilityFrame", {"BOTTOM", UIParent, "BOTTOM", 270, 34}, 64, 64)

	local spellButton = _G.ZoneAbilityFrame.SpellButton
	spellButton.Style:SetAlpha(0)
	spellButton.Icon:SetTexCoord(unpack(K.TexCoords))
	spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
	spellButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

	hooksecurefunc(_G.ExtraActionButton1.style, "SetTexture", DisableExtraButtonTexture)
	hooksecurefunc(_G.ZoneAbilityFrame.SpellButton.Style, "SetTexture", DisableExtraButtonTexture)
end