local K, C = unpack(select(2, ...))
local Module = K:NewModule("Bags")

local _G = _G
local unpack = unpack
local tinsert = tinsert

local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local NUM_BAG_FRAMES = NUM_BAG_FRAMES

local function OnEnter()
	if not C["Inventory"].BagBarMouseover then
		return
	end
	K.UIFrameFadeIn(KkthnxUIBags, 0.2, KkthnxUIBags:GetAlpha(), 1)
end

local function OnLeave()
	if not C["Inventory"].BagBarMouseover then
		return
	end
	K.UIFrameFadeOut(KkthnxUIBags, 0.2, KkthnxUIBags:GetAlpha(), 0)
end

function Module:SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"]
	bag.oldTex = icon:GetTexture()
	bag.IconBorder:SetAlpha(0)

	bag:CreateBorder(nil, nil, nil, true)
	bag:StyleButton(true)
	icon:SetTexture(bag.oldTex)
	icon:SetInside()
	icon:SetTexCoord(unpack(K.TexCoords))
end

function Module:SizeAndPositionBagBar()
	if not KkthnxUIBags then
		return
	end

	local buttonPadding = 0
	local buttonSpacing = 6
	local bagBarSize = 30

	local visibility = "[petbattle] hide; show"
	if visibility and visibility:match("[\n\r]") then
		visibility = visibility:gsub("[\n\r]","")
	end

	RegisterStateDriver(KkthnxUIBags, "visibility", visibility)

	if C["Inventory"].BagBarMouseover then
		KkthnxUIBags:SetAlpha(0)
	else
		KkthnxUIBags:SetAlpha(1)
	end

	for i = 1, #KkthnxUIBags.buttons do
		local button = KkthnxUIBags.buttons[i]
		local prevButton = KkthnxUIBags.buttons[i-1]
		button:SetSize(bagBarSize, bagBarSize)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("RIGHT", KkthnxUIBags, "RIGHT", 0, 0)
		elseif prevButton then
			button:SetPoint("RIGHT", prevButton, "LEFT", -buttonSpacing, 0)
		end

		if i ~= 1 then
			button.IconBorder:SetSize(bagBarSize, bagBarSize)
		end
	end

	KkthnxUIBags:SetWidth(bagBarSize * (NUM_BAG_FRAMES + 1) + buttonSpacing * (NUM_BAG_FRAMES) + buttonPadding * 2)
	KkthnxUIBags:SetHeight(bagBarSize + buttonPadding * 2)
end

function Module:OnEnable()
	if not C["ActionBar"].Enable then
		return
	end

	if not C["Inventory"].BagBar then
		return
	end

	local setPosition
	local KkthnxUIBags = CreateFrame("Frame", "KkthnxUIBags", UIParent)
	if C["ActionBar"].MicroBar then
		setPosition = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 38}
	else
		setPosition = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4}
	end
	KkthnxUIBags.buttons = {}
	KkthnxUIBags:EnableMouse(true)
	KkthnxUIBags:SetScript("OnEnter", OnEnter)
	KkthnxUIBags:SetScript("OnLeave", OnLeave)

	_G.MainMenuBarBackpackButton:SetParent(KkthnxUIBags)
	_G.MainMenuBarBackpackButton.SetParent = K.Noop
	_G.MainMenuBarBackpackButton:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:FontTemplate(nil, 11, "OUTLINE")
	_G.MainMenuBarBackpackButtonCount:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:SetPoint("BOTTOMRIGHT", _G.MainMenuBarBackpackButton, "BOTTOMRIGHT", 4, 2)
	_G.MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
	_G.MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)

	tinsert(KkthnxUIBags.buttons, _G.MainMenuBarBackpackButton)
	self:SkinBag(_G.MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES-1 do
		local b = _G["CharacterBag"..i.."Slot"]
		b:SetParent(KkthnxUIBags)
		b.SetParent = K.Noop
		b:HookScript("OnEnter", OnEnter)
		b:HookScript("OnLeave", OnLeave)

		self:SkinBag(b)
		tinsert(KkthnxUIBags.buttons, b)
	end

	-- Hide And Show To Update Assignment Textures On First Load
	KkthnxUIBags:Hide()
	KkthnxUIBags:Show()

	self:SizeAndPositionBagBar()
	K.Mover(KkthnxUIBags, "BagBar", "BagBar", setPosition)
end