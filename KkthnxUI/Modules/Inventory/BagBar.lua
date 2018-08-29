local K, C = unpack(select(2, ...))
local Module = K:NewModule("BagBar", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local unpack = unpack
local tinsert = table.insert

local CreateFrame = CreateFrame
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local RegisterStateDriver = RegisterStateDriver

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

	K.UIFrameFadeOut(KkthnxUIBags, 0.2, KkthnxUIBags:GetAlpha(), 0.25)
end

function Module:SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"]
	bag.oldTex = icon:GetTexture()
	bag.IconBorder:SetAlpha(0)

	bag:StripTextures()
	bag:CreateBorder()
	bag:StyleButton(true)
	icon:SetTexture(bag.oldTex)
	icon:SetInside()
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
end

function Module:SizeAndPositionBagBar()
	if not KkthnxUIBags then
		return
	end

	if C["Inventory"].BagBarMouseover then
		KkthnxUIBags:SetAlpha(0.25)
	else
		KkthnxUIBags:SetAlpha(1)
	end

	for i = 1, #KkthnxUIBags.buttons do
		local button = KkthnxUIBags.buttons[i]
		local prevButton = KkthnxUIBags.buttons[i - 1]
		button:SetSize(30, 30)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("LEFT", KkthnxUIBags, "LEFT", 2, 0)
		elseif prevButton then
			button:SetPoint("LEFT", prevButton, "RIGHT", 6, 0)
		end

		if i ~= 1 then
			button.IconBorder:SetSize(30, 30)
		end
	end

	KkthnxUIBags:SetWidth(30 * NUM_BAG_FRAMES + 58)
	KkthnxUIBags:SetHeight(30 + 4)
end

function Module:OnEnable()
	if C["Inventory"].BagBar ~= true then
		return
	end

	local KkthnxUIBags = CreateFrame("Frame", "KkthnxUIBags", UIParent)
	KkthnxUIBags:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -2, 2)
	KkthnxUIBags.buttons = {}
	KkthnxUIBags:EnableMouse(true)
	KkthnxUIBags:SetScript("OnEnter", OnEnter)
	KkthnxUIBags:SetScript("OnLeave", OnLeave)

	MainMenuBarBackpackButton:SetParent(KkthnxUIBags)
	MainMenuBarBackpackButton.SetParent = K.Noop
	MainMenuBarBackpackButton:ClearAllPoints()
	MainMenuBarBackpackButtonCount:FontTemplate(nil, 10)
	MainMenuBarBackpackButtonCount:ClearAllPoints()
	MainMenuBarBackpackButtonCount:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)
	MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
	MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)

	tinsert(KkthnxUIBags.buttons, MainMenuBarBackpackButton)
	self:SkinBag(MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES-1 do
		local b = _G["CharacterBag" .. i .. "Slot"]
		b:SetParent(KkthnxUIBags)
		b.SetParent = K.Noop
		b:HookScript("OnEnter", OnEnter)
		b:HookScript("OnLeave", OnLeave)

		self:SkinBag(b)
		tinsert(KkthnxUIBags.buttons, b)
	end

	self:SizeAndPositionBagBar()
	K.Movers:RegisterFrame(KkthnxUIBags)
end