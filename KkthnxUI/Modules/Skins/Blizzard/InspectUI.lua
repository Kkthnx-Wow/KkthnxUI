local K, C = KkthnxUI[1], KkthnxUI[2]

-- Cache WoW API functions
local GetInventoryItemLink = GetInventoryItemLink
local C_Item_IsCosmeticItem = C_Item.IsCosmeticItem
local PanelTemplates_GetSelectedTab = PanelTemplates_GetSelectedTab
local UnitClass = UnitClass
local hooksecurefunc = hooksecurefunc
local ipairs = ipairs

-- Cache texture paths (avoid string concatenation in loops)
local DRESSING_ROOM_PATH = "Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom"
local MARBLE_TEXTURE = "Interface\\FrameGeneral\\UI-Background-Marble"
local COSMETIC_ATLAS = "CosmeticIconFrame"

-- Constants
local SLOT_SIZE = 36
local FRAME_SIZE_TAB1_WIDTH = 438
local FRAME_SIZE_TAB1_HEIGHT = 431
local FRAME_SIZE_TAB2_WIDTH = 338
local FRAME_SIZE_TAB2_HEIGHT = 424
local WHITE_R, WHITE_G, WHITE_B = 1, 1, 1

C.themes["Blizzard_InspectUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	if InspectFrame and InspectFrame.KKUI_Skinned then
		return
	end

	-- Cache frame references
	local InspectPaperDollItemsFrame = InspectPaperDollItemsFrame
	local InspectModelFrame = InspectModelFrame

	if InspectPaperDollItemsFrame.InspectTalents then
		InspectPaperDollItemsFrame.InspectTalents:ClearAllPoints()
		InspectPaperDollItemsFrame.InspectTalents:SetPoint("TOPRIGHT", InspectFrame, "BOTTOMRIGHT", 0, -1)
	end

	InspectModelFrame:DisableDrawLayer("BACKGROUND")
	InspectModelFrame:DisableDrawLayer("BORDER")
	InspectModelFrame:DisableDrawLayer("OVERLAY")
	InspectModelFrame:StripTextures(true)

	local equipmentSlots = {
		"InspectHeadSlot",
		"InspectNeckSlot",
		"InspectShoulderSlot",
		"InspectShirtSlot",
		"InspectChestSlot",
		"InspectWaistSlot",
		"InspectLegsSlot",
		"InspectFeetSlot",
		"InspectWristSlot",
		"InspectHandsSlot",
		"InspectFinger0Slot",
		"InspectFinger1Slot",
		"InspectTrinket0Slot",
		"InspectTrinket1Slot",
		"InspectBackSlot",
		"InspectMainHandSlot",
		"InspectSecondaryHandSlot",
		"InspectTabardSlot",
	}

	-- Style equipment slots
	for _, slotName in ipairs(equipmentSlots) do
		local slot = _G[slotName]
		if slot and not slot.KKUI_Styled then
			-- Cache slot elements
			local icon = slot.icon
			local iconBorder = slot.IconBorder
			local iconOverlay = slot.IconOverlay

			slot:StripTextures()
			slot:SetSize(SLOT_SIZE, SLOT_SIZE)
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			slot:CreateBorder()
			iconBorder:SetAlpha(0)
			iconOverlay:SetAtlas(COSMETIC_ATLAS)
			iconOverlay:SetPoint("TOPLEFT", 1, -1)
			iconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)

			local border = slot.KKUI_Border

			-- Hook icon border updates
			hooksecurefunc(iconBorder, "SetVertexColor", function(_, r, g, b)
				if border then
					border:SetVertexColor(r, g, b)
				end
			end)

			hooksecurefunc(iconBorder, "Hide", function()
				if border then
					border:SetVertexColor(WHITE_R, WHITE_G, WHITE_B)
				end
			end)

			slot.KKUI_Styled = true
		end
	end

	local function UpdateCosmetic(self)
		local unit = InspectFrame.unit
		local itemLink = unit and GetInventoryItemLink(unit, self:GetID())
		self.IconOverlay:SetShown(itemLink and C_Item_IsCosmeticItem(itemLink))
	end

	if not InspectFrame or not InspectFrame.KKUI_Hooks then
		-- Hook to update cosmetics
		hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
			if button then
				UpdateCosmetic(button)
			end
		end)

		-- Cache slot references
		local headSlot = InspectHeadSlot
		local handsSlot = InspectHandsSlot
		local mainHandSlot = InspectMainHandSlot
		local secondaryHandSlot = InspectSecondaryHandSlot
		local frameInset = InspectFrameInset

		-- Position equipment slots
		headSlot:ClearAllPoints()
		handsSlot:ClearAllPoints()
		mainHandSlot:ClearAllPoints()
		secondaryHandSlot:ClearAllPoints()
		InspectModelFrame:ClearAllPoints()

		headSlot:SetPoint("TOPLEFT", frameInset, "TOPLEFT", 6, -6)
		handsSlot:SetPoint("TOPRIGHT", frameInset, "TOPRIGHT", -6, -6)
		mainHandSlot:SetPoint("BOTTOMLEFT", frameInset, "BOTTOMLEFT", 176, 5)
		secondaryHandSlot:SetPoint("BOTTOMRIGHT", frameInset, "BOTTOMRIGHT", -176, 5)

		InspectModelFrame:SetSize(300, 360)
		InspectModelFrame:SetPoint("TOPLEFT", frameInset, 64, -3)

		local function ApplyInspectFrameLayout()
			local inspectFrame = InspectFrame
			local inset = inspectFrame.Inset
			local bg = inset.Bg

			if PanelTemplates_GetSelectedTab(inspectFrame) == 1 then
				inspectFrame:SetSize(FRAME_SIZE_TAB1_WIDTH, FRAME_SIZE_TAB1_HEIGHT)
				inset:SetPoint("BOTTOMRIGHT", inspectFrame, "BOTTOMLEFT", 432, 4)

				-- Cache target class texture (built once per call)
				local _, targetClass = UnitClass("target")
				if targetClass then
					local classTexture = DRESSING_ROOM_PATH .. targetClass
					bg:SetTexture(classTexture)
					bg:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
					bg:SetHorizTile(false)
					bg:SetVertTile(false)
				end
			else
				inspectFrame:SetSize(FRAME_SIZE_TAB2_WIDTH, FRAME_SIZE_TAB2_HEIGHT)
				inset:SetPoint("BOTTOMRIGHT", inspectFrame, "BOTTOMLEFT", 332, 4)

				bg:SetTexture(MARBLE_TEXTURE, "REPEAT", "REPEAT")
				bg:SetTexCoord(0, 1, 0, 1)
				bg:SetHorizTile(true)
				bg:SetVertTile(true)
			end
		end

		local function OnInspectSwitchTabs(newID)
			ApplyInspectFrameLayout()
		end

		hooksecurefunc("InspectSwitchTabs", OnInspectSwitchTabs)
		OnInspectSwitchTabs(1)

		InspectFrame.KKUI_Hooks = true
	end

	if InspectFrame then
		InspectFrame.KKUI_Skinned = true
	end
end
