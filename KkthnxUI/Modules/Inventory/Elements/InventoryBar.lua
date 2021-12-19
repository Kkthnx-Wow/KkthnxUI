local K, C = unpack(select(2, ...))
local Module = K:GetModule("Bags")

local _G = _G
local table_insert = _G.table.insert
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local NUM_BAG_FRAMES = _G.NUM_BAG_FRAMES or 4
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local function OnEnter()
	if not C["Inventory"].BagBarMouseover then
		return
	end

	UIFrameFadeIn(Module.BagBar, 0.2, Module.BagBar:GetAlpha(), 1)
end

local function OnLeave()
	if not C["Inventory"].BagBarMouseover then
		return
	end

	UIFrameFadeOut(Module.BagBar, 0.2, Module.BagBar:GetAlpha(), 0)
end

function Module:SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"]
	bag.oldTex = icon:GetTexture()
	bag.IconBorder:SetAlpha(0)

	bag:StripTextures()
	bag:CreateBorder()
	bag:StyleButton(true)
	bag.IconBorder:Kill()

	icon:SetAllPoints()
	icon:SetTexture(bag.oldTex == 1721259 and "Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\Backpack.tga" or bag.oldTex)
	icon:SetTexCoord(unpack(K.TexCoords))
end

function Module:SizeAndPositionBagBar()
	if not Module.BagBar then
		return
	end

	local buttonPadding = 0
	local buttonSpacing = 6
	local bagBarSize = 30

	local visibility = "[petbattle] hide; show"
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]", "")
	end

	RegisterStateDriver(Module.BagBar, "visibility", visibility)
	Module.BagBar:SetAlpha(C["Inventory"].BagBarMouseover and 0 or 1)

	for i, button in ipairs(Module.BagBar.buttons) do
		local prevButton = Module.BagBar.buttons[i - 1]
		button:SetSize(bagBarSize, bagBarSize)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("RIGHT", Module.BagBar, "RIGHT", 0, 0)
		elseif prevButton then
			button:SetPoint("RIGHT", prevButton, "LEFT", -buttonSpacing, 0)
		end

		if i ~= 1 then
			button.IconBorder:SetSize(bagBarSize, bagBarSize)
		end
	end

	Module.BagBar:SetWidth(bagBarSize * (NUM_BAG_FRAMES + 1) + buttonSpacing * (NUM_BAG_FRAMES) + buttonPadding * 2)
	Module.BagBar:SetHeight(bagBarSize + buttonPadding * 2)
end

function Module:CreateInventoryBar()
	if not C["ActionBar"].Enable then
		return
	end

	if not C["Inventory"].BagBar then
		return
	end

	local setPosition
	Module.BagBar = CreateFrame("Frame", "KKUI_BagBar", UIParent)
	if C["ActionBar"].MicroBar then
		setPosition = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 38}
	else
		setPosition = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4}
	end
	Module.BagBar.buttons = {}
	Module.BagBar:EnableMouse(true)
	Module.BagBar:SetScript("OnEnter", OnEnter)
	Module.BagBar:SetScript("OnLeave", OnLeave)

	_G.MainMenuBarBackpackButton:SetParent(Module.BagBar)
	_G.MainMenuBarBackpackButton:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:SetFontObject(KkthnxUIFontOutline)
	_G.MainMenuBarBackpackButtonCount:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:SetPoint("BOTTOMRIGHT", _G.MainMenuBarBackpackButton, "BOTTOMRIGHT", 2, 2)
	_G.MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
	_G.MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)

	table_insert(Module.BagBar.buttons, _G.MainMenuBarBackpackButton)
	self:SkinBag(_G.MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES - 1 do
		local b = _G["CharacterBag"..i.."Slot"]
		b:SetParent(Module.BagBar)
		b:HookScript("OnEnter", OnEnter)
		b:HookScript("OnLeave", OnLeave)

		self:SkinBag(b)
		table_insert(Module.BagBar.buttons, b)
	end

	self:SizeAndPositionBagBar()
	K.Mover(Module.BagBar, "BagBar", "BagBar", setPosition)
	K:RegisterEvent("BAG_SLOT_FLAGS_UPDATED", Module.SizeAndPositionBagBar)
end