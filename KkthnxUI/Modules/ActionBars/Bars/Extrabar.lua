local K = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local function DisableExtraButtonTexture(self, texture, loop)
	if loop then
		return
	end

	self:SetTexture("", true)
end

function Module:CreateExtrabar()
	local padding, margin, size = 10, 5, 64
	local num = 1
	local buttonList = {}

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ExtraActionBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * size + (num-1) * margin + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 250, 100}
	frame:SetScale(1)

	-- Move The Buttons Into Position And Reparent Them
	ExtraActionBarFrame:SetParent(frame)
	ExtraActionBarFrame:EnableMouse(false)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", 0, 0)
	ExtraActionBarFrame.ignoreFramePositionManager = true

	-- The Extra Button
	local button = ExtraActionButton1
	table_insert(buttonList, button) -- Add The Button Object To The List
	button:SetSize(size,size)

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	frame:SetPoint(frame.Pos[1], frame.Pos[2], frame.Pos[3], frame.Pos[4], frame.Pos[5])
	K.Mover(frame, "ExtraActionButton", "ExtraActionButton", frame.Pos)

	-- Zone Ability
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame.ignoreFramePositionManager = true
	ZoneAbilityFrameNormalTexture:SetAlpha(0)
	ZoneAbilityFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", -250, 100)
	ZoneAbilityFrame:SetSize(64, 64)
	K.Mover(ZoneAbilityFrame, "ZoneAbilityFrame", "ZoneAbilityFrame", {"BOTTOM", UIParent, "BOTTOM", -250, 100}, 64, 64)

	local spellButton = ZoneAbilityFrame.SpellButton
	spellButton.Style:SetAlpha(0)
	spellButton.Icon:SetTexCoord(unpack(K.TexCoords))
	spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	spellButton:CreateBorder()

	hooksecurefunc(ExtraActionButton1.style, "SetTexture", DisableExtraButtonTexture)
	hooksecurefunc(ZoneAbilityFrame.SpellButton.Style, "SetTexture", DisableExtraButtonTexture)
end