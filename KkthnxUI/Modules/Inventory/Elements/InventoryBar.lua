local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Bags")

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local MainMenuBarBackpackButton = _G.MainMenuBarBackpackButton
local MainMenuBarBackpackButtonCount = _G.MainMenuBarBackpackButtonCount
local NUM_BAG_FRAMES = _G.NUM_BAG_FRAMES or 4
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local buttonPosition
local buttonList = {}

local function OnEnter()
	local KKUI_BB = _G.KKUI_BagBar
	return C["Inventory"].BagBarMouseover and UIFrameFadeIn(KKUI_BB, 0.2, KKUI_BB:GetAlpha(), 1)
end

local function OnLeave()
	local KKUI_BB = _G.KKUI_BagBar
	return C["Inventory"].BagBarMouseover and UIFrameFadeOut(KKUI_BB, 0.2, KKUI_BB:GetAlpha(), 0)
end

function Module:SkinBag(bag)
	local icon = _G[bag:GetName() .. "IconTexture"]
	bag.oldTex = icon:GetTexture()

	bag.IconBorder:SetAlpha(0)
	bag:StripTextures()
	bag:CreateBorder()

	icon:SetAllPoints()
	icon:SetTexture(bag.oldTex == 1721259 and "Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\Backpack.tga" or bag.oldTex)
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
end

function Module:SizeAndPositionBagBar()
	local KKUI_BB = _G.KKUI_BagBar
	if not KKUI_BB then
		return
	end

	RegisterStateDriver(KKUI_BB, "visibility", "[petbattle] hide; show")
	KKUI_BB:SetAlpha(C["Inventory"].BagBarMouseover and 0 or 1)

	for i, button in ipairs(buttonList) do
		local prevButton = buttonList[i - 1]
		button:SetSize(30, 30)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("RIGHT", KKUI_BB, "RIGHT", 0, 0)
		elseif prevButton then
			button:SetPoint("RIGHT", prevButton, "LEFT", -6, 0)
		end
	end
end

function Module:CreateInventoryBar()
	if not C["ActionBar"].Enable then
		return
	end

	if not C["Inventory"].BagBar then
		return
	end

	local menubar = CreateFrame("Frame", "KKUI_BagBar", UIParent)
	menubar:SetSize(174, 30)
	if C["ActionBar"].MicroBar then
		buttonPosition = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 38 }
	else
		buttonPosition = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 }
	end
	menubar:SetScript("OnEnter", OnEnter)
	menubar:SetScript("OnLeave", OnLeave)

	MainMenuBarBackpackButton:SetParent(menubar)
	MainMenuBarBackpackButton:ClearAllPoints()

	MainMenuBarBackpackButtonCount:SetFontObject(K.UIFontOutline)
	MainMenuBarBackpackButtonCount:ClearAllPoints()
	MainMenuBarBackpackButtonCount:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", 2, 2)

	MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
	MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)
	MainMenuBarBackpackButton:UnregisterEvent("ITEM_PUSH") -- Gets rid of the loot anims

	table_insert(buttonList, MainMenuBarBackpackButton)
	Module:SkinBag(MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES - 1 do
		local CharacterBagSlot = _G["CharacterBag" .. i .. "Slot"]
		CharacterBagSlot:SetParent(menubar)
		CharacterBagSlot:HookScript("OnEnter", OnEnter)
		CharacterBagSlot:HookScript("OnLeave", OnLeave)
		CharacterBagSlot:UnregisterEvent("ITEM_PUSH") -- Gets rid of the loot anims

		Module:SkinBag(CharacterBagSlot)
		table_insert(buttonList, CharacterBagSlot)
	end

	Module:SizeAndPositionBagBar()
	K.Mover(menubar, "BagBar", "BagBar", buttonPosition)
	K:RegisterEvent("BAG_SLOT_FLAGS_UPDATED", Module.SizeAndPositionBagBar)
end
