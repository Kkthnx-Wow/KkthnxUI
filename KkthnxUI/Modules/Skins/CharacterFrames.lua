--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Skins/CharacterFrames.lua
	Purpose:
		Clean up and resize the Character and Inspect frames: strip the Blizzard
		textures, standardise the item slot sizes, reposition the model and slots,
		and swap in a class dressing room background on the gear tab.

		Inspect lives in the load on demand Blizzard_InspectUI, so it is styled on
		load or when its addon fires ADDON_LOADED. Layout changes defer to the next
		tick and respect combat lockdown, since these are secure frames. Retail only
		for now.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("CharacterFrames")

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local HideUIPanel = HideUIPanel
local UnitClass = UnitClass
local PanelTemplates_GetSelectedTab = PanelTemplates_GetSelectedTab
local C_AddOns = C_AddOns
local C_Timer = C_Timer

local StripTextures = K.StripTextures

-- Blizzard panel constants (12.0.7).
local PANEL_DEFAULT_WIDTH = _G.PANEL_DEFAULT_WIDTH or 338
local PANEL_DEFAULT_HEIGHT = _G.PANEL_DEFAULT_HEIGHT or 424
local PANEL_INSET_LEFT_OFFSET = _G.PANEL_INSET_LEFT_OFFSET or 4
local PANEL_INSET_RIGHT_OFFSET = _G.PANEL_INSET_RIGHT_OFFSET or -6
local PANEL_INSET_BOTTOM_OFFSET = _G.PANEL_INSET_BOTTOM_OFFSET or 4
local PANEL_INSET_BOTTOM_BUTTON_OFFSET = _G.PANEL_INSET_BOTTOM_BUTTON_OFFSET or 26
local PANEL_INSET_ATTIC_OFFSET = _G.PANEL_INSET_ATTIC_OFFSET or -60
local CHARACTERFRAME_EXPANDED_WIDTH = _G.CHARACTERFRAME_EXPANDED_WIDTH or 540

local CHAR_PAPERDOLL_WIDTH = 640
local CHAR_PAPERDOLL_HEIGHT = 431
local CHAR_INSET_OFFSET = PANEL_DEFAULT_WIDTH + PANEL_INSET_RIGHT_OFFSET + (CHAR_PAPERDOLL_WIDTH - CHARACTERFRAME_EXPANDED_WIDTH)

local INSPECT_PAPERDOLL_WIDTH = 438
local INSPECT_PAPERDOLL_HEIGHT = 431
local INSPECT_INSET_OFFSET_PAPER = 432
local INSPECT_TAB_GUILD = 3
local SLOT_SIZE = 37
local CHAR_MODEL_ZOOM_SCALE = 1.1
local MARBLE_BG = "Interface\\FrameGeneral\\UI-Background-Marble"

local function ShouldStyle()
	return C.Skins and C.Skins.CharacterFrames
end

-- Pawn sits under PaperDollFrame and the stats pane blocks its clicks. Frame level
-- only orders siblings, so raise the strata on the button instead.
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
	local statsPane = _G.CharacterStatsPane
	local characterFrame = _G.CharacterFrame
	if not (button and characterFrame) then
		return
	end
	LiftPawnButton(button, statsPane or characterFrame)
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
	if not ShouldStyle() then
		return
	end
	FixInventoryPawnButton()
	FixInspectPawnButton()
end

local function InstallPawnButtonFix()
	if pawnHookInstalled or not _G.PawnUI_InventoryPawnButton_Move then
		return
	end
	-- Hooking a tainted global propagates the taint into us and blocks secure code.
	-- Skip the cosmetic reposition rather than taint ourselves.
	if not issecurevariable("PawnUI_InventoryPawnButton_Move") then
		return
	end
	pawnHookInstalled = true
	hooksecurefunc("PawnUI_InventoryPawnButton_Move", FixPawnButtons)
end

local function RefreshPawnButtons()
	if not ShouldStyle() then
		return
	end
	InstallPawnButtonFix()
	if _G.PawnUI_InventoryPawnButton_Move and issecurevariable("PawnUI_InventoryPawnButton_Move") then
		_G.PawnUI_InventoryPawnButton_Move()
	else
		FixPawnButtons()
	end
end

-- Strip a slot's stock frame art but keep the item icon, then crop the icon and
-- add our border. A blanket strip hides the icon too, so it is done by hand here.
local function StyleSlot(slot)
	if slot.kkuiSlot then
		slot:SetSize(SLOT_SIZE, SLOT_SIZE)
		return
	end
	slot.kkuiSlot = true

	local name = slot:GetName()
	local icon = name and _G[name .. "IconTexture"]

	if slot.SetNormalTexture then
		slot:SetNormalTexture(0)
		slot:SetPushedTexture(0)
		slot:SetHighlightTexture(0)
	end
	for _, region in ipairs({ slot:GetRegions() }) do
		if region ~= icon and region.GetObjectType and region:GetObjectType() == "Texture" then
			region:SetAlpha(0)
		end
	end

	slot:SetSize(SLOT_SIZE, SLOT_SIZE)

	if icon then
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	if not slot.KKUI_Border then
		K.CreateBorder(slot)
	end
	Module.UpdateSlotBorder(slot)
end

-- Colour our border by the equipped item's quality (we hid Blizzard's own quality
-- ring). The unit is read from the slot name so inspect slots use the target.
local GetInventoryItemQuality = _G.GetInventoryItemQuality
local C_Item = _G.C_Item

local function SlotUnit(slot)
	local name = slot:GetName() or ""
	if name:find("^Inspect") then
		return _G.InspectFrame and _G.InspectFrame.unit
	end
	return "player"
end

local function UpdateSlotBorder(slot)
	local border = slot.KKUI_Border
	if not border or not GetInventoryItemQuality then
		return
	end
	local id = slot.GetID and slot:GetID()
	local unit = SlotUnit(slot)
	local quality = id and unit and GetInventoryItemQuality(unit, id)
	if quality and not K.IsSecret(quality) and quality > 1 and C_Item and C_Item.GetItemQualityColor then
		local r, g, b = C_Item.GetItemQualityColor(quality)
		border.__customColor = true
		border:SetVertexColor(r, g, b)
	else
		K.ResetBorderColor(border)
	end
end
Module.UpdateSlotBorder = UpdateSlotBorder

-- Only touch equipment slots (name contains "Slot"), never talents and the like.
local function StyleItemSlots(...)
	for i = 1, select("#", ...) do
		local slot = select(i, ...)
		local name = slot and slot.GetName and slot:GetName()
		if name and name:find("Slot") and (slot:IsObjectType("Button") or slot:IsObjectType("ItemButton")) then
			StyleSlot(slot)
		end
	end
end

local function SetMarbleBackground(bg)
	if not bg then
		return
	end
	bg:SetTexture(MARBLE_BG, "REPEAT", "REPEAT")
	bg:SetTexCoord(0, 1, 0, 1)
	bg:SetHorizTile(true)
	bg:SetVertTile(true)
end

local function ApplyDefaultInset(frame, useButtonBar)
	frame.Inset:ClearAllPoints()
	frame.Inset:SetPoint("TOPLEFT", frame, "TOPLEFT", PANEL_INSET_LEFT_OFFSET, PANEL_INSET_ATTIC_OFFSET)
	local bottom = useButtonBar and PANEL_INSET_BOTTOM_BUTTON_OFFSET or PANEL_INSET_BOTTOM_OFFSET
	frame.Inset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, bottom)
end

local function ApplyPaperdollInset(frame, offsetX)
	frame.Inset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", offsetX, PANEL_INSET_BOTTOM_OFFSET)
end

local function AdjustCharacterModelZoom()
	local scene = _G.CharacterModelScene
	local camera = scene and scene.GetActiveCamera and scene:GetActiveCamera()
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

local function FitCharacterEnchantAnimationToInset()
	local CharacterFrame = _G.CharacterFrame
	local CharacterModelScene = _G.CharacterModelScene
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

	-- Blizzard's enchant animation is a centered 128x128 widget. Our layout is
	-- wider, so pin and size it to the inset or the glow hugs the middle.
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

-- ---------------------------------------------------------------------------
-- Character frame layout
-- ---------------------------------------------------------------------------
function Module:ApplyCharacterLayout()
	if InCombatLockdown() or not ShouldStyle() then
		return
	end

	local CharacterFrame = _G.CharacterFrame
	if not CharacterFrame then
		return
	end

	local subframe = CharacterFrame.activeSubframe

	if subframe == "PaperDollFrame" then
		-- Only widen when the stats sidebar is expanded, collapsed gear keeps the
		-- Blizzard width and static inset.
		if CharacterFrame.Expanded then
			CharacterFrame:SetSize(CHAR_PAPERDOLL_WIDTH, CHAR_PAPERDOLL_HEIGHT)
			ApplyPaperdollInset(CharacterFrame, CHAR_INSET_OFFSET)
		end

		local _, class = UnitClass("player")
		if class then
			CharacterFrame.Inset.Bg:SetTexture("Interface\\DressUpFrame\\DressingRoom" .. class)
			CharacterFrame.Inset.Bg:SetTexCoord(1 / 512, 479 / 512, 46 / 512, 455 / 512)
			CharacterFrame.Inset.Bg:SetHorizTile(false)
			CharacterFrame.Inset.Bg:SetVertTile(false)
		end

		CharacterFrame.Background:Hide()
	elseif subframe == "ReputationFrame" or subframe == "TokenFrame" then
		CharacterFrame.Background:Show()
	end
end

function Module:RestoreCharacterLayout()
	if InCombatLockdown() then
		self.pendingCharacterRestore = true
		return
	end

	local CharacterFrame = _G.CharacterFrame
	if not CharacterFrame then
		return
	end

	CharacterFrame.Background:Show()
	if CharacterFrame.UpdateSize then
		CharacterFrame:UpdateSize()
	end
end

function Module:StyleCharacterFrame()
	if self.charStyled then
		self:ApplyCharacterLayout()
		return
	end
	self.charStyled = true

	local CharacterFrame = _G.CharacterFrame
	local CharacterModelScene = _G.CharacterModelScene
	local PaperDollItemsFrame = _G.PaperDollItemsFrame
	local PaperDollFrame = _G.PaperDollFrame
	local CharacterStatsPane = _G.CharacterStatsPane
	local CharacterFrameInsetRight = _G.CharacterFrameInsetRight
	if not (CharacterFrame and CharacterModelScene and PaperDollItemsFrame) then
		return
	end

	if CharacterFrame:IsShown() then
		HideUIPanel(CharacterFrame)
	end

	CharacterModelScene:DisableDrawLayer("BACKGROUND")
	CharacterModelScene:DisableDrawLayer("BORDER")
	CharacterModelScene:DisableDrawLayer("OVERLAY")
	StripTextures(CharacterModelScene)

	StyleItemSlots(PaperDollItemsFrame:GetChildren())

	_G.CharacterHeadSlot:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 6, -6)
	_G.CharacterHandsSlot:SetPoint("TOPRIGHT", CharacterFrame.Inset, "TOPRIGHT", -6, -6)
	-- Centre the two weapon slots with a gap so they never overlap.
	_G.CharacterMainHandSlot:ClearAllPoints()
	_G.CharacterMainHandSlot:SetPoint("BOTTOM", CharacterFrame.Inset, "BOTTOM", -(SLOT_SIZE / 2 + 3), 5)
	_G.CharacterSecondaryHandSlot:ClearAllPoints()
	_G.CharacterSecondaryHandSlot:SetPoint("BOTTOM", CharacterFrame.Inset, "BOTTOM", SLOT_SIZE / 2 + 3, 5)

	CharacterModelScene:SetSize(0, 0)
	CharacterModelScene:ClearAllPoints()
	-- Keep the model scene inside Blizzard's inner frame, not the full inset, or the
	-- enchant animation looks offset.
	CharacterModelScene:SetPoint("TOPLEFT", CharacterFrame.Inset, 46, -4)
	CharacterModelScene:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, -47, 31)
	FitCharacterEnchantAnimationToInset()

	if not self.charUpdateHooked then
		self.charUpdateHooked = true
		hooksecurefunc(CharacterFrame, "UpdateSize", function()
			-- Defer to the next tick. Calling SetSize inside the secure update path
			-- taints it and breaks Blizzard's status bar secret value comparisons.
			C_Timer.After(0, function()
				Module:ApplyCharacterLayout()
				FitCharacterEnchantAnimationToInset()
			end)
		end)
	end

	local itemLevelValue = CharacterStatsPane.ItemLevelFrame.Value
	local ilvlFont, _, ilvlFlags = itemLevelValue:GetFont()
	itemLevelValue:SetFont(ilvlFont, 20, ilvlFlags)

	local function StyleTitleChildren(...)
		for i = 1, select("#", ...) do
			local child = select(i, ...)
			if child and not child.kkuiStyled then
				child:DisableDrawLayer("BACKGROUND")
				child.kkuiStyled = true
			end
		end
	end

	if PaperDollFrame and PaperDollFrame.TitleManagerPane and PaperDollFrame.TitleManagerPane.ScrollBox then
		hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", function(scrollBox)
			if ShouldStyle() then
				StyleTitleChildren(scrollBox.ScrollTarget:GetChildren())
			end
		end)
	end

	CharacterStatsPane.ClassBackground:ClearAllPoints()
	CharacterStatsPane.ClassBackground:SetHeight(CharacterStatsPane.ClassBackground:GetHeight() + 6)
	CharacterStatsPane.ClassBackground:SetParent(CharacterFrameInsetRight)
	CharacterStatsPane.ClassBackground:SetPoint("CENTER")

	-- Recolour a slot border whenever its item changes.
	if _G.PaperDollItemSlotButton_Update then
		hooksecurefunc("PaperDollItemSlotButton_Update", function(slot)
			if ShouldStyle() and slot.KKUI_Border then
				UpdateSlotBorder(slot)
			end
		end)
	end

	if _G.PaperDollFrame_SetPlayer then
		hooksecurefunc("PaperDollFrame_SetPlayer", function()
			if ShouldStyle() then
				AdjustCharacterModelZoom()
				FitCharacterEnchantAnimationToInset()
				RefreshPawnButtons()
			end
		end)
	end

	if PaperDollFrame then
		PaperDollFrame:HookScript("OnShow", RefreshPawnButtons)
		if _G.PaperDollFrame_UpdateStats then
			hooksecurefunc("PaperDollFrame_UpdateStats", RefreshPawnButtons)
		end
	end

	self:ApplyCharacterLayout()
	AdjustCharacterModelZoom()
	FitCharacterEnchantAnimationToInset()
	RefreshPawnButtons()
end

-- ---------------------------------------------------------------------------
-- Inspect frame (Blizzard_InspectUI, load on demand)
-- ---------------------------------------------------------------------------
function Module:ApplyInspectLayout(tabID)
	if InCombatLockdown() or not ShouldStyle() then
		return
	end

	local InspectFrame = _G.InspectFrame
	if not InspectFrame then
		return
	end

	tabID = tabID or PanelTemplates_GetSelectedTab(InspectFrame)
	if tabID == 1 then
		InspectFrame:SetSize(INSPECT_PAPERDOLL_WIDTH, INSPECT_PAPERDOLL_HEIGHT)
		ApplyPaperdollInset(InspectFrame, INSPECT_INSET_OFFSET_PAPER)

		local _, targetClass = UnitClass("target")
		if targetClass then
			InspectFrame.Inset.Bg:SetTexture("Interface\\DressUpFrame\\DressingRoom" .. targetClass)
			InspectFrame.Inset.Bg:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
			InspectFrame.Inset.Bg:SetHorizTile(false)
			InspectFrame.Inset.Bg:SetVertTile(false)
		end
	else
		InspectFrame:SetSize(PANEL_DEFAULT_WIDTH, PANEL_DEFAULT_HEIGHT)
		ApplyDefaultInset(InspectFrame, tabID == INSPECT_TAB_GUILD)
		SetMarbleBackground(InspectFrame.Inset.Bg)
	end
end

function Module:RestoreInspectLayout()
	if InCombatLockdown() then
		self.pendingInspectRestore = true
		return
	end

	local InspectFrame = _G.InspectFrame
	if not InspectFrame then
		return
	end

	InspectFrame:SetSize(PANEL_DEFAULT_WIDTH, PANEL_DEFAULT_HEIGHT)
	local tabID = PanelTemplates_GetSelectedTab(InspectFrame)
	ApplyDefaultInset(InspectFrame, tabID == INSPECT_TAB_GUILD)
	SetMarbleBackground(InspectFrame.Inset.Bg)
end

function Module:StyleInspectFrame()
	if self.inspectStyled then
		self:ApplyInspectLayout()
		return
	end

	local InspectFrame = _G.InspectFrame
	local InspectModelFrame = _G.InspectModelFrame
	local InspectPaperDollItemsFrame = _G.InspectPaperDollItemsFrame
	if not (InspectFrame and InspectModelFrame and InspectPaperDollItemsFrame) then
		return
	end

	self.inspectStyled = true

	if self.SetupGearInfo then
		self:SetupGearInfo()
	end

	if InspectFrame:IsShown() then
		HideUIPanel(InspectFrame)
	end

	InspectPaperDollItemsFrame.InspectTalents:ClearAllPoints()
	InspectPaperDollItemsFrame.InspectTalents:SetPoint("TOPRIGHT", InspectFrame, "BOTTOMRIGHT", 0, -1)

	InspectModelFrame:DisableDrawLayer("BACKGROUND")
	InspectModelFrame:DisableDrawLayer("BORDER")
	InspectModelFrame:DisableDrawLayer("OVERLAY")
	StripTextures(InspectModelFrame)
	StyleItemSlots(InspectPaperDollItemsFrame:GetChildren())

	_G.InspectHeadSlot:SetPoint("TOPLEFT", InspectFrame.Inset, "TOPLEFT", 6, -6)
	_G.InspectHandsSlot:SetPoint("TOPRIGHT", InspectFrame.Inset, "TOPRIGHT", -6, -6)
	_G.InspectMainHandSlot:ClearAllPoints()
	_G.InspectMainHandSlot:SetPoint("BOTTOM", InspectFrame.Inset, "BOTTOM", -(SLOT_SIZE / 2 + 3), 5)
	_G.InspectSecondaryHandSlot:ClearAllPoints()
	_G.InspectSecondaryHandSlot:SetPoint("BOTTOM", InspectFrame.Inset, "BOTTOM", SLOT_SIZE / 2 + 3, 5)

	InspectModelFrame:SetSize(0, 0)
	InspectModelFrame:ClearAllPoints()
	InspectModelFrame:SetPoint("TOPLEFT", InspectFrame.Inset, 0, 0)
	InspectModelFrame:SetPoint("BOTTOMRIGHT", InspectFrame.Inset, 0, 30)
	InspectModelFrame:SetCamDistanceScale(1.1)

	local averageItemLevelText = InspectPaperDollItemsFrame:CreateFontString(nil, "OVERLAY")
	K.SetFont(averageItemLevelText, 12, K.FontOutlineStyle())
	averageItemLevelText:SetJustifyH("CENTER")
	averageItemLevelText:SetPoint("BOTTOM", InspectFrame.Inset, "BOTTOM", 0, 46)
	InspectPaperDollItemsFrame.AverageItemLevelText = averageItemLevelText

	if _G.InspectPaperDollFrame_SetLevel and _G.C_PaperDollInfo and _G.C_PaperDollInfo.GetInspectItemLevel then
		hooksecurefunc("InspectPaperDollFrame_SetLevel", function()
			if not ShouldStyle() then
				return
			end
			local unit = InspectFrame.unit
			if not unit then
				return
			end
			local ilvl = _G.C_PaperDollInfo.GetInspectItemLevel(unit)
			if ilvl then
				averageItemLevelText:SetFormattedText(_G.DUNGEON_SCORE_LINK_ITEM_LEVEL or "Item Level %d", ilvl)
			end
		end)
	end

	if not self.inspectTabHooked then
		self.inspectTabHooked = true
		hooksecurefunc("InspectSwitchTabs", function(newID)
			C_Timer.After(0, function()
				Module:ApplyInspectLayout(newID)
			end)
		end)
	end

	if _G.InspectPaperDollItemSlotButton_Update then
		hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(slot)
			if ShouldStyle() and slot.KKUI_Border then
				UpdateSlotBorder(slot)
			end
		end)
	end

	self:ApplyInspectLayout(1)

	if _G.InspectPaperDollFrame then
		_G.InspectPaperDollFrame:HookScript("OnShow", function()
			RefreshPawnButtons()
			-- Recolour every inspect slot once the target's items are known.
			for _, slot in ipairs({ InspectPaperDollItemsFrame:GetChildren() }) do
				if slot.KKUI_Border then
					UpdateSlotBorder(slot)
				end
			end
		end)
	end
end

-- ---------------------------------------------------------------------------
-- Events / lifecycle
-- ---------------------------------------------------------------------------
function Module:ADDON_LOADED(_, addon)
	if addon == "Pawn" then
		RefreshPawnButtons()
	elseif addon == "Blizzard_InspectUI" and ShouldStyle() then
		self:StyleInspectFrame()
	end
end

function Module:PLAYER_REGEN_ENABLED()
	if self.pendingCharacterRestore then
		self.pendingCharacterRestore = nil
		if not ShouldStyle() then
			self:RestoreCharacterLayout()
		end
	end
	if self.pendingInspectRestore then
		self.pendingInspectRestore = nil
		if not ShouldStyle() then
			self:RestoreInspectLayout()
		end
	end
end

function Module:OnEnable()
	if not ShouldStyle() then
		return
	end

	self:StyleCharacterFrame()

	if self.SetupGearInfo then
		self:SetupGearInfo()
	end

	if C_AddOns.IsAddOnLoaded("Blizzard_InspectUI") then
		self:StyleInspectFrame()
	end
	if C_AddOns.IsAddOnLoaded("Pawn") then
		RefreshPawnButtons()
	end

	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("ADDON_LOADED")
end
