local K, C = unpack(select(2, ...))
local Module = K:NewModule("InventoryBar")

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

	K.UIFrameFadeIn(KKUI_BagBar, 0.2, KKUI_BagBar:GetAlpha(), 1)
end

local function OnLeave()
	if not C["Inventory"].BagBarMouseover then
		return
	end

	K.UIFrameFadeOut(KKUI_BagBar, 0.2, KKUI_BagBar:GetAlpha(), 0.25)
end

function Module:SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"]
	bag.oldTex = icon:GetTexture()
	bag.IconBorder:SetAlpha(0)

	bag:CreateBorder(nil, nil, nil, true)
	bag:CreateInnerShadow()
	bag:StyleButton(true)
	icon:SetTexture(bag.oldTex)
	icon:SetAllPoints()
	icon:SetTexCoord(unpack(K.TexCoords))
end

function Module:SizeAndPositionBagBar()
	if not KKUI_BagBar then
		return
	end

	local buttonPadding = 0
	local buttonSpacing = 6
	local bagBarSize = 30

	local visibility = "[petbattle] hide; show"
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]","")
	end

	RegisterStateDriver(KKUI_BagBar, "visibility", visibility)

	if C["Inventory"].BagBarMouseover then
		KKUI_BagBar:SetAlpha(0.25)
	else
		KKUI_BagBar:SetAlpha(1)
	end

	for i = 1, #KKUI_BagBar.buttons do
		local button = KKUI_BagBar.buttons[i]
		local prevButton = KKUI_BagBar.buttons[i - 1]
		button:SetSize(bagBarSize, bagBarSize)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("RIGHT", KKUI_BagBar, "RIGHT", 0, 0)
		elseif prevButton then
			button:SetPoint("RIGHT", prevButton, "LEFT", -buttonSpacing, 0)
		end

		if i ~= 1 then
			button.IconBorder:SetSize(bagBarSize, bagBarSize)
		end
	end

	KKUI_BagBar:SetWidth(bagBarSize * (NUM_BAG_FRAMES + 1) + buttonSpacing * (NUM_BAG_FRAMES) + buttonPadding * 2)
	KKUI_BagBar:SetHeight(bagBarSize + buttonPadding * 2)
end

function Module:OnEnable()
	if not C["ActionBar"].Enable then
		return
	end

	if not C["Inventory"].BagBar then
		return
	end

	local setPosition
	local KKUI_BagBar = CreateFrame("Frame", "KKUI_BagBar", UIParent)
	if C["ActionBar"].MicroBar then
		setPosition = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 38}
	else
		setPosition = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4}
	end
	KKUI_BagBar.buttons = {}
	KKUI_BagBar:EnableMouse(true)
	KKUI_BagBar:SetScript("OnEnter", OnEnter)
	KKUI_BagBar:SetScript("OnLeave", OnLeave)

	_G.MainMenuBarBackpackButton:SetParent(KKUI_BagBar)
	_G.MainMenuBarBackpackButton.SetParent = K.Noop
	_G.MainMenuBarBackpackButton:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:FontTemplate(nil, 11, "OUTLINE")
	_G.MainMenuBarBackpackButtonCount:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:SetPoint("BOTTOMRIGHT", _G.MainMenuBarBackpackButton, "BOTTOMRIGHT", 2, 2)
	_G.MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
	_G.MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)

	table_insert(KKUI_BagBar.buttons, _G.MainMenuBarBackpackButton)
	self:SkinBag(_G.MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES - 1 do
		local b = _G["CharacterBag"..i.."Slot"]
		b:SetParent(KKUI_BagBar)
		b.SetParent = K.Noop
		b:HookScript("OnEnter", OnEnter)
		b:HookScript("OnLeave", OnLeave)

		self:SkinBag(b)
		table_insert(KKUI_BagBar.buttons, b)
	end

	self:SizeAndPositionBagBar()
	K.Mover(KKUI_BagBar, "BagBar", "BagBar", setPosition)
end