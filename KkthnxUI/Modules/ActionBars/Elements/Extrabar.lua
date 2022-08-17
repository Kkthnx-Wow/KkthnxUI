local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local cfg = C.Bars.BarExtra
local padding = C.Bars.BarPadding

function Module:CreateExtrabar()
	local buttonList = {}
	local size = cfg.size
	local ZoneAbilityFrame = _G.ZoneAbilityFrame
	local ExtraAbilityContainer = _G.ExtraAbilityContainer

	local frame = CreateFrame("Frame", "KKUI_ActionBarExtra", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(size + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	frame.mover = K.Mover(frame, "Extrabar", "Extrabar", { "BOTTOM", UIParent, "BOTTOM", 270, 48 })

	_G.ExtraActionBarFrame:EnableMouse(false)
	_G.ExtraAbilityContainer:SetParent(frame)
	_G.ExtraAbilityContainer:ClearAllPoints()
	_G.ExtraAbilityContainer:SetPoint("CENTER", frame, 0, 2 * padding)
	_G.ExtraAbilityContainer.ignoreFramePositionManager = true

	local button = _G.ExtraActionButton1
	table_insert(buttonList, button)
	table_insert(Module.buttons, button)
	button:SetSize(size, size)

	frame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	local zoneFrame = CreateFrame("Frame", "KKUI_ActionBarZone", UIParent)
	zoneFrame:SetWidth(size + 2 * padding)
	zoneFrame:SetHeight(size + 2 * padding)
	zoneFrame.mover = K.Mover(zoneFrame, "Zone Ability", "ZoneAbility", { "BOTTOM", UIParent, "BOTTOM", -270, 44 })

	ZoneAbilityFrame:SetParent(zoneFrame)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint("CENTER", zoneFrame)
	ZoneAbilityFrame.ignoreFramePositionManager = true
	ZoneAbilityFrame.Style:SetAlpha(0)

	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
		for spellButton in self.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.styled then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:StyleButton()
				spellButton.Icon:SetAllPoints()
				spellButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

				local Border = CreateFrame("Frame", nil, spellButton)
				Border:SetAllPoints(spellButton.Icon)
				Border:SetFrameLevel(spellButton:GetFrameLevel())
				Border:CreateBorder()

				spellButton.styled = true
			end
		end
	end)

	hooksecurefunc(ZoneAbilityFrame, "SetParent", function(self, parent)
		if parent == ExtraAbilityContainer then
			self:SetParent(zoneFrame)
		end
	end)
end
