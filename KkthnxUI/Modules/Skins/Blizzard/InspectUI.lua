local K, C = unpack(KkthnxUI)

-- Lua
local _G = _G

local GetInventoryItemLink = _G.GetInventoryItemLink
local HideUIPanel = _G.HideUIPanel
local IsCosmeticItem = _G.IsCosmeticItem
local PanelTemplates_GetSelectedTab = _G.PanelTemplates_GetSelectedTab
local UnitClass = _G.UnitClass
local hooksecurefunc = _G.hooksecurefunc

C.themes["Blizzard_InspectUI"] = function()
	if InspectFrame:IsShown() then
		HideUIPanel(InspectFrame)
	end

	_G.InspectPaperDollItemsFrame.InspectTalents:ClearAllPoints()
	_G.InspectPaperDollItemsFrame.InspectTalents:SetPoint("TOPRIGHT", _G.InspectFrame, "BOTTOMRIGHT", 0, -1)

	InspectModelFrame:StripTextures(true)

	local slots = {
		"Head",
		"Neck",
		"Shoulder",
		"Shirt",
		"Chest",
		"Waist",
		"Legs",
		"Feet",
		"Wrist",
		"Hands",
		"Finger0",
		"Finger1",
		"Trinket0",
		"Trinket1",
		"Back",
		"MainHand",
		"SecondaryHand",
		"Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Inspect" .. slots[i] .. "Slot"]
		slot:StripTextures()
		slot:SetSize(36, 36)
		slot.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		slot:CreateBorder()
		slot.IconBorder:SetAlpha(0)
		slot.IconOverlay:SetAtlas("CosmeticIconFrame")
		slot.IconOverlay:SetPoint("TOPLEFT", 1, -1)
		slot.IconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)

		hooksecurefunc(slot.IconBorder, "SetVertexColor", function(_, r, g, b)
			slot.KKUI_Border:SetVertexColor(r, g, b)
		end)

		hooksecurefunc(slot.IconBorder, "Hide", function()
			slot.KKUI_Border:SetVertexColor(1, 1, 1)
		end)
	end

	local function UpdateCosmetic(self)
		local unit = InspectFrame.unit
		local itemLink = unit and GetInventoryItemLink(unit, self:GetID())
		self.IconOverlay:SetShown(itemLink and IsCosmeticItem(itemLink))
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		UpdateCosmetic(button)
	end)

	do
		InspectHeadSlot:SetPoint("TOPLEFT", InspectFrame.Inset, "TOPLEFT", 6, -6)
		InspectHandsSlot:SetPoint("TOPRIGHT", InspectFrame.Inset, "TOPRIGHT", -6, -6)
		InspectMainHandSlot:SetPoint("BOTTOMLEFT", InspectFrame.Inset, "BOTTOMLEFT", 176, 5)
		InspectSecondaryHandSlot:ClearAllPoints()
		InspectSecondaryHandSlot:SetPoint("BOTTOMRIGHT", InspectFrame.Inset, "BOTTOMRIGHT", -176, 5)

		InspectModelFrame:SetSize(0, 0)
		InspectModelFrame:ClearAllPoints()
		InspectModelFrame:SetPoint("TOPLEFT", InspectFrame.Inset, 0, 0)
		InspectModelFrame:SetPoint("BOTTOMRIGHT", InspectFrame.Inset, 0, 30)
		InspectModelFrame:SetCamDistanceScale(1.1)
	end

	-- Adjust the inset based on tabs
	local OnInspectSwitchTabs = function(newID)
		local tabID = newID or PanelTemplates_GetSelectedTab(InspectFrame)
		if tabID == 1 then
			InspectFrame:SetSize(438, 431) -- 338 + 100, 424 + 7
			InspectFrame.Inset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 432, 4)

			local _, targetClass = UnitClass("target")
			if targetClass then
				if targetClass == "EVOKER" then
					InspectFrame.Inset.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", "REPEAT", "REPEAT")
					InspectFrame.Inset.Bg:SetTexCoord(0, 1, 0, 1)
					InspectFrame.Inset.Bg:SetHorizTile(true)
					InspectFrame.Inset.Bg:SetVertTile(true)
				else
					InspectFrame.Inset.Bg:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom" .. targetClass)
					InspectFrame.Inset.Bg:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
					InspectFrame.Inset.Bg:SetHorizTile(false)
					InspectFrame.Inset.Bg:SetVertTile(false)
				end
			end
		else
			InspectFrame:SetSize(338, 424)
			InspectFrame.Inset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 332, 4)

			InspectFrame.Inset.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", "REPEAT", "REPEAT")
			InspectFrame.Inset.Bg:SetTexCoord(0, 1, 0, 1)
			InspectFrame.Inset.Bg:SetHorizTile(true)
			InspectFrame.Inset.Bg:SetVertTile(true)
		end
	end

	-- Hook it to tab switches
	hooksecurefunc("InspectSwitchTabs", OnInspectSwitchTabs)
	-- Call it once to apply it from the start
	OnInspectSwitchTabs(1)
end
