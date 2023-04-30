local K, C = KkthnxUI[1], KkthnxUI[2]

-- Lua

local GetInventoryItemLink = GetInventoryItemLink
local HideUIPanel = HideUIPanel
local IsCosmeticItem = IsCosmeticItem
local PanelTemplates_GetSelectedTab = PanelTemplates_GetSelectedTab
local UnitClass = UnitClass
local hooksecurefunc = hooksecurefunc

C.themes["Blizzard_InspectUI"] = function()
	-- if InspectFrame and InspectFrame:IsShown() then
	-- 	HideUIPanel(InspectFrame)
	-- end

	local InspectPaperDollItemsFrame = InspectPaperDollItemsFrame
	local InspectModelFrame = InspectModelFrame

	if InspectPaperDollItemsFrame.InspectTalents then
		InspectPaperDollItemsFrame.InspectTalents:ClearAllPoints()
		InspectPaperDollItemsFrame.InspectTalents:SetPoint("TOPRIGHT", InspectFrame, "BOTTOMRIGHT", 0, -1)
	end

	InspectModelFrame:StripTextures(true)

	local equipmentSlots = {
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

	local numEquipmentSlots = #equipmentSlots

	for i = 1, numEquipmentSlots do
		local slot = _G["Inspect" .. equipmentSlots[i] .. "Slot"]
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

	local InspectHeadSlot = InspectHeadSlot
	local InspectHandsSlot = InspectHandsSlot
	local InspectMainHandSlot = InspectMainHandSlot
	local InspectSecondaryHandSlot = InspectSecondaryHandSlot
	local InspectModelFrame = InspectModelFrame
	local InspectFrameInset = InspectFrame.Inset

	InspectHeadSlot:SetPoint("TOPLEFT", InspectFrameInset, "TOPLEFT", 6, -6)
	InspectHandsSlot:SetPoint("TOPRIGHT", InspectFrameInset, "TOPRIGHT", -6, -6)
	InspectMainHandSlot:SetPoint("BOTTOMLEFT", InspectFrameInset, "BOTTOMLEFT", 176, 5)
	InspectSecondaryHandSlot:ClearAllPoints()
	InspectSecondaryHandSlot:SetPoint("BOTTOMRIGHT", InspectFrameInset, "BOTTOMRIGHT", -176, 5)

	InspectModelFrame:SetSize(0, 0)
	InspectModelFrame:ClearAllPoints()
	InspectModelFrame:SetPoint("TOPLEFT", InspectFrameInset, 0, 0)
	InspectModelFrame:SetPoint("BOTTOMRIGHT", InspectFrameInset, 0, 30)
	InspectModelFrame:SetCamDistanceScale(1.1)

	local function ApplyInspectFrameLayout(isExpanded)
		local InspectFrame = InspectFrame
		local InspectFrameInset = InspectFrame.Inset

		if isExpanded then
			InspectFrame:SetSize(438, 431) -- 338 + 100, 424 + 7
			InspectFrameInset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 432, 4)

			local _, targetClass = UnitClass("target")
			if targetClass then
				InspectFrameInset.Bg:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom" .. targetClass)
				InspectFrameInset.Bg:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
				InspectFrameInset.Bg:SetHorizTile(false)
				InspectFrameInset.Bg:SetVertTile(false)
			end
		else
			InspectFrame:SetSize(338, 424)
			InspectFrameInset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 332, 4)

			InspectFrameInset.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", "REPEAT", "REPEAT")
			InspectFrameInset.Bg:SetTexCoord(0, 1, 0, 1)
			InspectFrameInset.Bg:SetHorizTile(true)
			InspectFrameInset.Bg:SetVertTile(true)
		end
	end

	-- Adjust the inset based on tabs
	local function OnInspectSwitchTabs(newID)
		local tabID = newID or PanelTemplates_GetSelectedTab(InspectFrame)
		ApplyInspectFrameLayout(tabID == 1)
	end

	-- Hook it to tab switches
	hooksecurefunc("InspectSwitchTabs", OnInspectSwitchTabs)
	-- Call it once to apply it from the start
	OnInspectSwitchTabs(1)
end
