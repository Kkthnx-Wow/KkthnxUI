--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the player Character frame, paper doll, and equipment slots.
-- - Design: Applies custom borders, textures, and class-specific backgrounds for the character UI.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local select = _G.select
local tinsert = _G.table.insert

local C_Item_IsCosmeticItem = _G.C_Item.IsCosmeticItem
local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local GetInventoryItemLink = _G.GetInventoryItemLink
local InCombatLockdown = _G.InCombatLockdown
local UnitClass = _G.UnitClass
local hooksecurefunc = _G.hooksecurefunc
local issecurevariable = _G.issecurevariable

local CharacterFrame = _G.CharacterFrame
local CharacterHeadSlot = _G.CharacterHeadSlot
local CharacterHandsSlot = _G.CharacterHandsSlot
local CharacterMainHandSlot = _G.CharacterMainHandSlot
local CharacterSecondaryHandSlot = _G.CharacterSecondaryHandSlot
local CharacterModelScene = _G.CharacterModelScene
local CharacterStatsPane = _G.CharacterStatsPane
local CharacterLevelText = _G.CharacterLevelText
local CharacterFrameInsetRight = _G.CharacterFrameInsetRight
local PaperDollFrame = _G.PaperDollFrame

-- Constants (NexEnhance CharacterFrames layout math)
local SLOT_SIZE = 37
local FONT_SIZE_RANK = 13
local FONT_SIZE_ILVL = 20
local CHAR_PAPERDOLL_WIDTH = 640
local CHAR_PAPERDOLL_HEIGHT = 431
local PANEL_DEFAULT_WIDTH = _G.PANEL_DEFAULT_WIDTH or 338
local PANEL_INSET_RIGHT_OFFSET = _G.PANEL_INSET_RIGHT_OFFSET or -6
local PANEL_INSET_BOTTOM_OFFSET = _G.PANEL_INSET_BOTTOM_OFFSET or 4
local CHARACTERFRAME_EXPANDED_WIDTH = _G.CHARACTERFRAME_EXPANDED_WIDTH or 540
-- Paper-doll inset when widened: Blizzard default width + right inset + expand delta.
local CHAR_INSET_OFFSET = PANEL_DEFAULT_WIDTH + PANEL_INSET_RIGHT_OFFSET + (CHAR_PAPERDOLL_WIDTH - CHARACTERFRAME_EXPANDED_WIDTH)
local CHAR_MODEL_ZOOM_SCALE = 1.1

-- Colors
local WHITE_COLOR = { r = 1, g = 1, b = 1 }
local ORANGE_COLOR = { r = 1, g = 0.5, b = 0 }
local GOLD_BORDER_COLOR = { 1, 223 / 255, 0 } -- 255/255 == 1, pre-computed
local GREY_QUALITY_R = K.QualityColors[0].r

-- Paths & Atlases
local DRESSING_ROOM_PATH = "Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom"
local LEAVE_ITEM_TEXTURE = "Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent"
local ATLAS_COSMETIC = "CosmeticIconFrame"
local ATLAS_AZERITE = "AzeriteIconFrame"

-- Pre-compute tex coords used in the hot UpdateSize hook to avoid per-call division
local CHAR_BG_TEX_L = 1 / 512
local CHAR_BG_TEX_R = 479 / 512
local CHAR_BG_TEX_T = 46 / 512
local CHAR_BG_TEX_B = 455 / 512

-- Cache UIFont data for the ilvl hook so GetFont() is never called inside a hot callback
local ilvlFontPath, ilvlFontFlags
local function GetCachedIlvlFont()
	if not ilvlFontPath then
		local _
		ilvlFontPath, _, ilvlFontFlags = select(1, _G.KkthnxUIFont:GetFont()), select(2, _G.KkthnxUIFont:GetFont()), select(3, _G.KkthnxUIFont:GetFont())
		ilvlFontFlags = ilvlFontFlags or ""
	end
	return ilvlFontPath, ilvlFontFlags
end

-- Helper Functions

local function UpdateAzeriteItem(self)
	if not self.styled then
		self.AzeriteTexture:SetAlpha(0)
		self.RankFrame.Texture:SetTexture(nil)

		local label = self.RankFrame.Label
		label:ClearAllPoints()
		label:SetPoint("TOPLEFT", self, 2, -1)
		label:SetTextColor(ORANGE_COLOR.r, ORANGE_COLOR.g, ORANGE_COLOR.b)
		label:SetFontObject(K.UIFontOutline)

		-- Cache font data to avoid multiple GetFont() calls overhead
		local fontPath, _, fontFlags = label:GetFont()
		label:SetFont(fontPath, FONT_SIZE_RANK, fontFlags)

		self.styled = true
	end
end

local function UpdateAzeriteEmpoweredItem(self)
	local texture = self.AzeriteTexture
	texture:SetAtlas(ATLAS_AZERITE)
	texture:SetAllPoints()
	texture:SetDrawLayer("BORDER", 1)
end

local function UpdateCosmetic(self)
	if not self then return end
	local itemLink = GetInventoryItemLink("player", self:GetID())
	self.IconOverlay:SetShown(itemLink and C_Item_IsCosmeticItem(itemLink))
end

local function UpdateIconBorderColor(slot, r, g, b)
	local border = slot.KKUI_Border
	if not border then
		return
	end

	-- Normalize invalid/grey/white colors to pure white for consistent border styling
	if not r or r == GREY_QUALITY_R or (r > 0.99 and g > 0.99 and b > 0.99) then
		border:SetVertexColor(WHITE_COLOR.r, WHITE_COLOR.g, WHITE_COLOR.b)
	else
		border:SetVertexColor(r, g, b)
	end
end

local function ResetIconBorderColor(slot, texture)
	if not texture and slot.KKUI_Border then
		K.SetBorderColor(slot.KKUI_Border)
	end
end

local function ToggleIconBorder(slot, show)
	if not show and slot.KKUI_Border then
		ResetIconBorderColor(slot)
	end
end

-- PERF: Use shared handlers for hooks to avoid closure allocations per slot
local function IconBorder_OnSetVertexColor(self, r, g, b)
	UpdateIconBorderColor(self:GetParent(), r, g, b)
end

local function IconBorder_OnHide(self)
	ResetIconBorderColor(self:GetParent())
end

local function IconBorder_OnSetShown(self, show)
	ToggleIconBorder(self:GetParent(), show)
end

local function StyleEquipmentSlot(slotName)
	local slot = _G[slotName]
	if not slot or slot.KKUI_Styled then
		return
	end

	-- Cache slot elements
	local icon = slot.icon
	local iconBorder = slot.IconBorder
	local cooldown = slot.Cooldown or _G[slotName .. "Cooldown"]
	local iconOverlay = slot.IconOverlay
	local ignoreTexture = slot.ignoreTexture

	-- Apply Skin
	slot:StripTextures()
	slot:SetSize(SLOT_SIZE, SLOT_SIZE)

	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	icon:SetAllPoints()

	iconBorder:SetAlpha(0)
	slot:CreateBorder()

	cooldown:SetAllPoints()

	if ignoreTexture then
		ignoreTexture:SetTexture(LEAVE_ITEM_TEXTURE)
	end

	if iconOverlay then
		iconOverlay:SetAtlas(ATLAS_COSMETIC)
		iconOverlay:SetPoint("TOPLEFT", 1, -1)
		iconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	-- Hook Overrides
	hooksecurefunc(iconBorder, "SetVertexColor", IconBorder_OnSetVertexColor)
	hooksecurefunc(iconBorder, "Hide", IconBorder_OnHide)
	hooksecurefunc(iconBorder, "SetShown", IconBorder_OnSetShown)

	-- Hook Azerite logic
	hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
	hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)

	slot.KKUI_Styled = true
end

local function StyleSidebarTab(tab)
	if not tab then
		return
	end

	if not tab.bg then
		-- Create background frame
		local bg = CreateFrame("Frame", nil, tab)
		bg:SetAllPoints(tab)
		bg:SetFrameLevel(tab:GetFrameLevel())
		bg:CreateBorder(nil, nil, nil, nil, nil, GOLD_BORDER_COLOR)

		-- Adjust existing elements
		if tab.Icon then
			tab.Icon:SetAllPoints(bg)
		end
		if tab.Hider then
			tab.Hider:SetAllPoints(bg)
			tab.Hider:SetColorTexture(0.3, 0.3, 0.3, 0.4)
		end

		if tab.Highlight then
			tab.Highlight:SetPoint("TOPLEFT", bg, "TOPLEFT", 1, -1)
			tab.Highlight:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -1, 1)
			tab.Highlight:SetColorTexture(1, 1, 1, 0.25)
		end

		if tab.TabBg then
			tab.TabBg:SetAlpha(0)
		end

		tab.bg = bg
	end

	if not tab.regionStyled then
		local region = select(1, tab:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
			tab.regionStyled = true
		end
	end
end

local function UpdateSidebarTabs()
	local index = 1
	local tab = _G["PaperDollSidebarTab" .. index]
	while tab do
		StyleSidebarTab(tab)
		index = index + 1
		tab = _G["PaperDollSidebarTab" .. index]
	end
end

local function StyleTitleManagerPaneChild(child)
	if not child.styled then
		child:DisableDrawLayer("BACKGROUND")
		child.styled = true
	end
end

local function HandleTitleManagerScrollBox(scrollBox)
	if scrollBox and scrollBox.ForEachFrame then
		scrollBox:ForEachFrame(StyleTitleManagerPaneChild)
	end
end

-- ---
-- Layout helpers (NexEnhance CharacterFrames — keep gems above paperdoll FX)
-- ---

-- Blizzard's enchant glow is a centered 128x128; stretching it with huge negative
-- offsets bleeds over equipment slots and buries gem/missing-enchant overlays.
local function FitCharacterEnchantAnimationToInset()
	local inset = CharacterFrame and CharacterFrame.Inset
	local enchant = CharacterModelScene and CharacterModelScene.GearEnchantAnimation
	if not (inset and enchant and enchant.FrameFX and enchant.TopFrame) then
		return
	end

	local width = inset:GetWidth()
	local height = inset:GetHeight()
	if not (width and height and width > 0 and height > 0) then
		return
	end

	enchant:ClearAllPoints()
	enchant:SetPoint("TOPLEFT", inset, "TOPLEFT", 1, -1)
	enchant:SetPoint("BOTTOMRIGHT", inset, "BOTTOMRIGHT", -1, 1)
	enchant.FrameFX:ClearAllPoints()
	enchant.FrameFX:SetAllPoints(enchant)
	enchant.TopFrame:ClearAllPoints()
	enchant.TopFrame:SetAllPoints(enchant)

	local glowTextures = {
		enchant.FrameFX.PurpleGlow,
		enchant.FrameFX.BlueGlow,
		enchant.FrameFX.Sparkles,
		enchant.FrameFX.Mask,
		enchant.TopFrame.Frame,
	}
	for i = 1, #glowTextures do
		local tex = glowTextures[i]
		if tex then
			tex:ClearAllPoints()
			tex:SetAllPoints(enchant)
		end
	end
end

local function AdjustCharacterModelZoom()
	local camera = CharacterModelScene and CharacterModelScene.GetActiveCamera and CharacterModelScene:GetActiveCamera()
	if not (camera and camera.GetZoomDistance and camera.SetZoomDistance) then
		return
	end

	local distance = camera:GetZoomDistance()
	if not distance then
		return
	end

	local target = distance * CHAR_MODEL_ZOOM_SCALE
	local maxDistance = camera.GetMaxZoomDistance and camera:GetMaxZoomDistance()
	if maxDistance and maxDistance > 0 and target > maxDistance then
		target = maxDistance
	end

	camera:SetZoomDistance(target)
	if camera.SnapToTargetInterpolationZoom then
		camera:SnapToTargetInterpolationZoom()
	end
end

local function ApplyCharacterPaperdollLayout()
	if InCombatLockdown() or not CharacterFrame then
		return
	end

	local subframe = CharacterFrame.activeSubframe
	local inset = CharacterFrame.Inset
	local bg = inset and inset.Bg

	if subframe == "PaperDollFrame" then
		-- Only widen when the stats sidebar is expanded; collapsed keeps Blizzard width.
		if CharacterFrame.Expanded then
			CharacterFrame:SetSize(CHAR_PAPERDOLL_WIDTH, CHAR_PAPERDOLL_HEIGHT)
			if inset then
				inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", CHAR_INSET_OFFSET, PANEL_INSET_BOTTOM_OFFSET)
			end
		end

		local _, class = UnitClass("player")
		local texturePath = class and (DRESSING_ROOM_PATH .. class)
		if texturePath and bg then
			bg:SetTexture(texturePath)
			bg:SetTexCoord(CHAR_BG_TEX_L, CHAR_BG_TEX_R, CHAR_BG_TEX_T, CHAR_BG_TEX_B)
			bg:SetHorizTile(false)
			bg:SetVertTile(false)
		end

		if CharacterFrame.Background then
			CharacterFrame.Background:Hide()
		end

		FitCharacterEnchantAnimationToInset()
	elseif CharacterFrame.Background then
		CharacterFrame.Background:Show()
	end
end

-- Pawn sits under PaperDollFrame; CharacterStatsPane is a sibling on top and
-- blocks clicks. Raising strata (not just level) clears the hit test.
local pawnHookInstalled = false

local function LiftPawnButton(button, refFrame)
	if not (button and refFrame) then
		return
	end
	button:EnableMouse(true)
	button:SetFrameStrata("HIGH")
	button:SetFrameLevel(refFrame:GetFrameLevel() + 50)
	button:Raise()
end

local function FixInventoryPawnButton()
	local button = _G.PawnUI_InventoryPawnButton
	if not (button and CharacterFrame) then
		return
	end
	LiftPawnButton(button, CharacterStatsPane or CharacterFrame)
end

local function FixInspectPawnButton()
	local button = _G.PawnUI_InspectPawnButton
	local inspectFrame = _G.InspectFrame
	if not (button and inspectFrame) then
		return
	end
	LiftPawnButton(button, inspectFrame)
end

local function FixPawnButtons()
	FixInventoryPawnButton()
	FixInspectPawnButton()
end

local function InstallPawnButtonFix()
	if pawnHookInstalled or not _G.PawnUI_InventoryPawnButton_Move then
		return
	end
	-- Hooking a tainted global propagates taint into us — skip if Pawn already tainted it.
	if not issecurevariable("PawnUI_InventoryPawnButton_Move") then
		return
	end
	pawnHookInstalled = true
	hooksecurefunc("PawnUI_InventoryPawnButton_Move", FixPawnButtons)
end

local function RefreshPawnButtons()
	InstallPawnButtonFix()
	if _G.PawnUI_InventoryPawnButton_Move and issecurevariable("PawnUI_InventoryPawnButton_Move") then
		_G.PawnUI_InventoryPawnButton_Move()
	else
		FixPawnButtons()
	end
end

-- Main Theme Registration

-- REASON: Main entry point for Blizzard Character Frame skinning.
tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	if CharacterFrame and CharacterFrame.KKUI_Skinned then
		return
	end

	-- Clean up CharacterModelScene
	if CharacterModelScene then
		CharacterModelScene:DisableDrawLayer("BACKGROUND")
		CharacterModelScene:DisableDrawLayer("BORDER")
		CharacterModelScene:DisableDrawLayer("OVERLAY")
		CharacterModelScene:StripTextures(true)
	end

	-- Style Slots
	local equipmentSlots = {
		"CharacterBackSlot",
		"CharacterChestSlot",
		"CharacterFeetSlot",
		"CharacterFinger0Slot",
		"CharacterFinger1Slot",
		"CharacterHandsSlot",
		"CharacterHeadSlot",
		"CharacterLegsSlot",
		"CharacterMainHandSlot",
		"CharacterNeckSlot",
		"CharacterSecondaryHandSlot",
		"CharacterShirtSlot",
		"CharacterShoulderSlot",
		"CharacterTabardSlot",
		"CharacterTrinket0Slot",
		"CharacterTrinket1Slot",
		"CharacterWaistSlot",
		"CharacterWristSlot",
	}

	for i = 1, #equipmentSlots do
		StyleEquipmentSlot(equipmentSlots[i])
	end

	-- Hooks
	if CharacterFrame and not CharacterFrame.KKUI_Hooks then
		hooksecurefunc("PaperDollItemSlotButton_Update", UpdateCosmetic)

		if CharacterStatsPane and CharacterStatsPane.ItemLevelFrame then
			local function UpdateItemLevelFont()
				if InCombatLockdown() then
					return
				end

				local ilvlValue = CharacterStatsPane.ItemLevelFrame.Value
				if ilvlValue then
					local path, flags = GetCachedIlvlFont()
					ilvlValue:SetFont(path, FONT_SIZE_ILVL, flags)
				end
			end
			hooksecurefunc("PaperDollFrame_UpdateStats", UpdateItemLevelFont)
			hooksecurefunc("PaperDollFrame_UpdateStats", RefreshPawnButtons)
		end

		-- Defer layout out of the secure UpdateSize path (SetSize there taints health compares).
		hooksecurefunc(CharacterFrame, "UpdateSize", function()
			C_Timer_After(0, function()
				ApplyCharacterPaperdollLayout()
				FitCharacterEnchantAnimationToInset()
			end)
		end)

		hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", UpdateSidebarTabs)

		if PaperDollFrame.TitleManagerPane and PaperDollFrame.TitleManagerPane.ScrollBox then
			hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", HandleTitleManagerScrollBox)
		end

		if _G.PaperDollFrame_SetPlayer then
			hooksecurefunc("PaperDollFrame_SetPlayer", function()
				AdjustCharacterModelZoom()
				FitCharacterEnchantAnimationToInset()
				RefreshPawnButtons()
			end)
		end

		if PaperDollFrame then
			PaperDollFrame:HookScript("OnShow", RefreshPawnButtons)
		end

		CharacterFrame.KKUI_Hooks = true
	end

	if not InCombatLockdown() and CharacterFrame and CharacterFrame.Inset then
		CharacterHeadSlot:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 6, -6)
		CharacterHandsSlot:SetPoint("TOPRIGHT", CharacterFrame.Inset, "TOPRIGHT", -6, -6)
		CharacterMainHandSlot:SetPoint("BOTTOMLEFT", CharacterFrame.Inset, "BOTTOMLEFT", 176, 5)
		CharacterSecondaryHandSlot:ClearAllPoints()
		CharacterSecondaryHandSlot:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -176, 5)

		-- Keep model inside the paper-doll inner frame so gem overlays clear the edges.
		CharacterModelScene:SetSize(0, 0)
		CharacterModelScene:ClearAllPoints()
		CharacterModelScene:SetPoint("TOPLEFT", CharacterFrame.Inset, 46, -4)
		CharacterModelScene:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, -47, 31)
		FitCharacterEnchantAnimationToInset()

		if CharacterLevelText then
			CharacterLevelText:SetFontObject(K.UIFont)
		end

		if CharacterStatsPane and CharacterStatsPane.ClassBackground and CharacterFrameInsetRight then
			CharacterStatsPane.ClassBackground:ClearAllPoints()
			CharacterStatsPane.ClassBackground:SetHeight(CharacterStatsPane.ClassBackground:GetHeight() + 6)
			CharacterStatsPane.ClassBackground:SetParent(CharacterFrameInsetRight)
			CharacterStatsPane.ClassBackground:SetPoint("CENTER")
		end

		ApplyCharacterPaperdollLayout()
		AdjustCharacterModelZoom()
		RefreshPawnButtons()
	end

	if CharacterFrame then
		CharacterFrame.KKUI_Skinned = true
	end
end)
