local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.extraBar

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

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
	--table_insert(Module.buttons, button)
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

	-- ZoneAbility
	local zoneFrame = CreateFrame("Frame", "NDui_ActionBarZone", UIParent)
	zoneFrame:SetWidth(FilterConfig.size + 2 * padding)
	zoneFrame:SetHeight(FilterConfig.size + 2 * padding)
	zoneFrame.Pos = {"BOTTOM", UIParent, "BOTTOM", -250, 100}
	zoneFrame.mover = K.Mover(zoneFrame, "Zone Ability", "ZoneAbility", zoneFrame.Pos)

	ZoneAbilityFrame:SetParent(zoneFrame)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint("CENTER", zoneFrame)
	ZoneAbilityFrame.ignoreFramePositionManager = true
	ZoneAbilityFrame.Style:SetAlpha(0)

	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
		for spellButton in self.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.styled then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:SetPushedTexture(C["Media"].Texture) -- force it to gain a texture
				spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				--B.ReskinIcon(spellButton.Icon, true)
				spellButton.styled = true
			end
		end
	end)

	-- Fix button visibility
	hooksecurefunc(ZoneAbilityFrame, "SetParent", function(self, parent)
		if parent == ExtraAbilityContainer then
			self:SetParent(zoneFrame)
		end
	end)
end