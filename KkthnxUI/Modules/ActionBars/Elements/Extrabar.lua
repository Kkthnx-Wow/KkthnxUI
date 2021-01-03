local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = C.ActionBars.extraBar

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local padding = C.ActionBars.padding

function Module:CreateExtrabar()
	local buttonList = {}
	local size = FilterConfig.size

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KKUI_ExtraActionBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(size + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 270, 42}
	frame.mover = K.Mover(frame, "Extrabar", "Extrabar", frame.Pos)

	ExtraActionBarFrame:EnableMouse(false)
	ExtraAbilityContainer:SetParent(frame)
	ExtraAbilityContainer:ClearAllPoints()
	ExtraAbilityContainer:SetPoint("CENTER", frame, 0, 2 * padding)
	ExtraAbilityContainer.ignoreFramePositionManager = true

	local button = ExtraActionButton1
	table_insert(buttonList, button)
	table_insert(Module.buttons, button)
	button:SetSize(size, size)

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- create the mouseover functionality
	if FilterConfig.fader then
		K.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end

	-- ZoneAbility
	local zoneFrame = CreateFrame("Frame", "KKUI_ActionBarZone", UIParent)
	zoneFrame:SetWidth(size + 2 * padding)
	zoneFrame:SetHeight(size + 2 * padding)
	zoneFrame.Pos = {"BOTTOM", UIParent, "BOTTOM", -270, 42}
	zoneFrame.mover = K.Mover(zoneFrame, "Zone Ability", "Zone Ability", zoneFrame.Pos)

	ZoneAbilityFrame:SetParent(zoneFrame)
	ZoneAbilityFrame:ClearAllPoints()
	if buttonList == nil then
		ZoneAbilityFrame:SetPoint("CENTER", zoneFrame)
	else
		ZoneAbilityFrame:SetPoint("BOTTOM", zoneFrame, "BOTTOM", 0, size / 2)
	end
	ZoneAbilityFrame.ignoreFramePositionManager = true
	ZoneAbilityFrame.Style:SetAlpha(0)

	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
		for spellButton in self.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.styled then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:StyleButton()
				spellButton.Icon:SetTexCoord(unpack(K.TexCoords))
				local bg = CreateFrame("Frame", nil, spellButton)
				bg:SetAllPoints(spellButton.Icon)
				bg:SetFrameLevel(spellButton:GetFrameLevel())
				bg:CreateBorder()

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