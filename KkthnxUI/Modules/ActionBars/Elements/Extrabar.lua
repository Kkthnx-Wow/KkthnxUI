local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

-- Cache global references
local _G = _G
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local tinsert = _G.table.insert
local RegisterStateDriver = _G.RegisterStateDriver
local hooksecurefunc = _G.hooksecurefunc
local IsUsableAction = _G.IsUsableAction

local padding = 0

function Module:CreateExtrabar()
	local buttonList = {}
	local size = 52

	-- ExtraActionButton
	local frame = CreateFrame("Frame", "KKUI_ActionBarExtra", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(size + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	frame.mover = K.Mover(frame, "Extrabar", "Extrabar", { "BOTTOM", UIParent, "BOTTOM", 294, 100 })

	ExtraAbilityContainer:SetScript("OnShow", nil)
	ExtraAbilityContainer:SetScript("OnUpdate", nil)
	ExtraAbilityContainer.OnUpdate = nil
	ExtraAbilityContainer.IsLayoutFrame = nil
	ExtraAbilityContainer:KillEditMode()

	ExtraActionBarFrame:EnableMouse(false)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", frame)
	ExtraActionBarFrame.ignoreInLayout = true
	ExtraActionBarFrame:SetIgnoreParentScale(true)
	ExtraActionBarFrame:SetScale(UIParent:GetScale())

	local button = ExtraActionButton1
	tinsert(buttonList, button)
	tinsert(Module.buttons, button)
	button:SetSize(size, size)

	frame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- ZoneAbility
	local zoneFrame = CreateFrame("Frame", "KKUI_ActionBarZone", UIParent)
	zoneFrame:SetWidth(size + 2 * padding)
	zoneFrame:SetHeight(size + 2 * padding)
	zoneFrame.mover = K.Mover(zoneFrame, "Zone Ability", "ZoneAbility", { "BOTTOM", UIParent, "BOTTOM", -294, 100 })

	ZoneAbilityFrame:SetParent(zoneFrame)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint("CENTER", zoneFrame)
	ZoneAbilityFrame.ignoreInLayout = true
	ZoneAbilityFrame.Style:SetAlpha(0)

	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
		for spellButton in self.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.styled then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:SetPushedTexture(0)
				spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
				spellButton:GetHighlightTexture():SetAllPoints()
				spellButton.Icon:SetAllPoints()
				spellButton.Icon:SetTexCoord(unpack(K.TexCoords))

				local bg = CreateFrame("Frame", nil, spellButton, "BackdropTemplate")
				bg:SetAllPoints(spellButton)
				bg:SetFrameLevel(spellButton:GetFrameLevel())
				bg:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, { 1, 1, 1 })

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

	-- Extra button range, needs review
	hooksecurefunc("ActionButton_UpdateRangeIndicator", function(self, checksRange, inRange)
		if not self.action then
			return
		end

		if checksRange and not inRange then
			self.icon:SetVertexColor(0.8, 0.1, 0.1)
		else
			local isUsable, notEnoughMana = IsUsableAction(self.action)
			if isUsable then
				self.icon:SetVertexColor(1, 1, 1)
			elseif notEnoughMana then
				self.icon:SetVertexColor(0.5, 0.5, 1)
			else
				self.icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end)
end
