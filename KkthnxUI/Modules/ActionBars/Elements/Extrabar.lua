local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local tinsert = tinsert
local padding = 0

function Module:CreateExtrabar()
	local buttonList = {}
	local size = 52

	-- ExtraActionButton
	local frame = CreateFrame("Frame", "KKUI_ActionBarExtra", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(size + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	frame.mover = K.Mover(frame, "Extrabar", "Extrabar", { "BOTTOM", UIParent, "BOTTOM", 294, 100 })

	ExtraActionBarFrame:EnableMouse(false)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", frame)
	ExtraActionBarFrame.ignoreFramePositionManager = true

	hooksecurefunc(ExtraActionBarFrame, "SetParent", function(self, parent)
		if parent == ExtraAbilityContainer then
			self:SetParent(frame)
		end
	end)

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
	ZoneAbilityFrame.ignoreFramePositionManager = true
	ZoneAbilityFrame.Style:SetAlpha(0)

	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
		for spellButton in self.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.styled then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:SetPushedTexture(0) --force it to gain a texture
				spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
				spellButton:GetHighlightTexture():SetInside()
				spellButton.Icon:SetInside()
				-- B.ReskinIcon(spellButton.Icon, true)
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
