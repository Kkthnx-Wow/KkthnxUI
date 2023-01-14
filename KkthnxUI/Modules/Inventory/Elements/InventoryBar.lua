local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Bags")

local _G = _G
local ipairs = ipairs
local unpack = unpack
local tinsert = tinsert
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local RegisterStateDriver = RegisterStateDriver
local CalculateTotalNumberOfFreeBagSlots = CalculateTotalNumberOfFreeBagSlots

local NUM_BAG_FRAMES = NUM_BAG_FRAMES

function Module:BagBar_OnEnter()
	return C["Inventory"].BagBarMouseover and UIFrameFadeIn(Module.BagBar, 0.2, Module.BagBar:GetAlpha(), 1)
end

function Module:BagBar_OnLeave()
	return C["Inventory"].BagBarMouseover and UIFrameFadeOut(Module.BagBar, 0.2, Module.BagBar:GetAlpha(), 0)
end

function Module:BagBar_OnEvent(event)
	Module:BagBar_UpdateVisibility()
	Module.BagBar:UnregisterEvent(event)
end

function Module:SkinBag(bag)
	local icon = bag.icon or _G[bag:GetName() .. "IconTexture"]
	bag.oldTex = icon:GetTexture()

	bag:StripTextures(true)
	bag:CreateBorder()
	bag:StyleButton(true)

	bag:GetNormalTexture():SetAlpha(0)
	bag:GetHighlightTexture():SetAlpha(0)
	bag.CircleMask:Hide()

	icon.Show = nil
	icon:Show()

	icon:SetAllPoints()
	icon:SetTexture((not bag.oldTex or bag.oldTex == 1721259) and "Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\Backpack.tga" or bag.oldTex)
	icon:SetTexCoord(unpack(K.TexCoords))
end

function Module:BagBar_UpdateVisibility()
	RegisterStateDriver(Module.BagBar, "visibility", "[petbattle] hide; show")
end

function Module:SetSizeAndPositionBagBar()
	if not Module.BagBar then
		return
	end

	local bagBarSize = C["Inventory"].BagBarSize
	local buttonSpacing = 6
	local growthDirection = C["Inventory"].GrowthDirection.Value
	local sortDirection = C["Inventory"].SortDirection.Value
	local justBackpack = C["Inventory"].JustBackpack

	if InCombatLockdown() then
		Module.BagBar:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		Module:BagBar_UpdateVisibility()
	end

	Module.BagBar:SetAlpha(C["Inventory"].BagBarMouseover and 0 or 1)

	_G.MainMenuBarBackpackButtonCount:SetFontObject(K.UIFontOutline)

	for i, button in ipairs(Module.BagBar.buttons) do
		button:SetSize(bagBarSize, bagBarSize)
		button:ClearAllPoints()
		button:SetShown(not justBackpack or i == 1)

		local prevButton = Module.BagBar.buttons[i - 1]
		if growthDirection == "HORIZONTAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:SetPoint("LEFT", Module.BagBar, "LEFT", 0, 0)
			elseif prevButton then
				button:SetPoint("LEFT", prevButton, "RIGHT", buttonSpacing, 0)
			end
		elseif growthDirection == "VERTICAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:SetPoint("TOP", Module.BagBar, "TOP", 0, -0)
			elseif prevButton then
				button:SetPoint("TOP", prevButton, "BOTTOM", 0, -buttonSpacing)
			end
		elseif growthDirection == "HORIZONTAL" and sortDirection == "DESCENDING" then
			if i == 1 then
				button:SetPoint("RIGHT", Module.BagBar, "RIGHT", -0, 0)
			elseif prevButton then
				button:SetPoint("RIGHT", prevButton, "LEFT", -buttonSpacing, 0)
			end
		else
			if i == 1 then
				button:SetPoint("BOTTOM", Module.BagBar, "BOTTOM", 0, 0)
			elseif prevButton then
				button:SetPoint("BOTTOM", prevButton, "TOP", 0, buttonSpacing)
			end
		end
	end

	local btnSize = bagBarSize * (NUM_BAG_FRAMES + 1)
	local btnSpace = buttonSpacing * NUM_BAG_FRAMES

	if growthDirection == "HORIZONTAL" then
		Module.BagBar:SetSize(btnSize + btnSpace, bagBarSize)
	else
		Module.BagBar:SetSize(bagBarSize, btnSize + btnSpace)
	end

	Module.BagBar.mover:SetSize(Module.BagBar:GetSize())
	Module:UpdateMainButtonCount()
end

function Module:UpdateMainButtonCount()
	local mainCount = Module.BagBar.buttons[1].Count
	mainCount:SetShown(GetCVarBool("displayFreeBagSlots"))
	mainCount:SetText(CalculateTotalNumberOfFreeBagSlots())
end

function Module:BagButton_UpdateTextures()
	local pushed = self:GetPushedTexture()
	pushed:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	pushed:SetDesaturated(true)
	pushed:SetVertexColor(246 / 255, 196 / 255, 66 / 255)
	pushed:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -0)
	pushed:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -0, 0)
	pushed:SetBlendMode("ADD")

	if self.SlotHighlightTexture then
		self.SlotHighlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		self.SlotHighlightTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -0)
		self.SlotHighlightTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -0, 0)
		self.SlotHighlightTexture:SetBlendMode("ADD")
	end
end

local buttonPosition
function Module:CreateInventoryBar()
	if not C["ActionBar"].Enable then
		return
	end

	if not C["Inventory"].BagBar then
		return
	end

	Module.BagBar = CreateFrame("Frame", "KKUI_BagBar", UIParent)
	if C["ActionBar"].MicroMenu then
		buttonPosition = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 38 }
	else
		buttonPosition = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 }
	end
	Module.BagBar:SetScript("OnEnter", Module.BagBar_OnEnter)
	Module.BagBar:SetScript("OnLeave", Module.BagBar_OnLeave)
	Module.BagBar:SetScript("OnEvent", Module.BagBar_OnEvent)
	Module.BagBar:EnableMouse(true)
	Module.BagBar.buttons = {}

	_G.MainMenuBarBackpackButton:SetParent(Module.BagBar)
	_G.MainMenuBarBackpackButton:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:SetFontObject(K.UIFontOutline)
	_G.MainMenuBarBackpackButtonCount:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:SetPoint("BOTTOMRIGHT", _G.MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)
	_G.MainMenuBarBackpackButton:HookScript("OnEnter", Module.BagBar_OnEnter)
	_G.MainMenuBarBackpackButton:HookScript("OnLeave", Module.BagBar_OnLeave)

	tinsert(Module.BagBar.buttons, _G.MainMenuBarBackpackButton)
	Module:SkinBag(_G.MainMenuBarBackpackButton)
	Module.BagButton_UpdateTextures(_G.MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES - 1 do
		local b = _G["CharacterBag" .. i .. "Slot"]
		b:HookScript("OnEnter", Module.BagBar_OnEnter)
		b:HookScript("OnLeave", Module.BagBar_OnLeave)
		b:SetParent(Module.BagBar)
		Module:SkinBag(b)

		hooksecurefunc(b, "UpdateTextures", Module.BagButton_UpdateTextures)

		tinsert(Module.BagBar.buttons, b)
	end

	local ReagentSlot = _G.CharacterReagentBag0Slot
	if ReagentSlot then
		ReagentSlot:SetParent(Module.BagBar)
		ReagentSlot:HookScript("OnEnter", Module.BagBar_OnEnter)
		ReagentSlot:HookScript("OnLeave", Module.BagBar_OnLeave)

		Module:SkinBag(ReagentSlot)

		tinsert(Module.BagBar.buttons, ReagentSlot)

		hooksecurefunc(ReagentSlot, "UpdateTextures", Module.BagButton_UpdateTextures)
		hooksecurefunc(ReagentSlot, "SetBarExpanded", Module.SetSizeAndPositionBagBar)
	end

	K.Mover(Module.BagBar, "BagBar", "BagBar", buttonPosition)
	if not Module.BagBar.mover then
		Module.BagBar.mover = K.Mover(Module.BagBar, "BagBar", "BagBar", buttonPosition)
	else
		Module.BagBar.mover:SetSize(Module.BagBar:GetSize())
	end
	Module.BagBar:SetPoint("BOTTOMLEFT", Module.BagBar.mover)
	K:RegisterEvent("BAG_SLOT_FLAGS_UPDATED", Module.SetSizeAndPositionBagBar)
	K:RegisterEvent("BAG_UPDATE_DELAYED", Module.UpdateMainButtonCount)
	Module:SetSizeAndPositionBagBar()

	if BagBarExpandToggle then
		K.HideInterfaceOption(BagBarExpandToggle)
	end
end
