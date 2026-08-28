--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Skins/Loot.lua
	Purpose:
		Give the loot window our border and gradient, and clean each item row: our
		border on the icon tinted to the item quality, and the stock plate art
		blanked. Built on the 12.x scroll-box loot frame.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("LootFrameSkin")

local _G = _G
local hooksecurefunc = hooksecurefunc

-- Skin one item row of the loot scroll box.
local function SkinElement(button)
	local item = button.Item
	if item and not item.KKUI_Skinned then
		item.KKUI_Skinned = true
		if K.StripTextures then
			K.StripTextures(item)
		end
		if item.icon then
			item.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			K.CreateBorder(item)
		end
		if item.NormalTexture then
			item.NormalTexture:SetAlpha(0)
		end
		if item.IconBorder then
			item.IconBorder:SetAlpha(0)
		end
	end

	-- Tint the icon border to the item quality, read off the name text colour the
	-- client already set.
	if item and item.KKUI_Border and button.Text then
		local r, g, b = button.Text:GetVertexColor()
		if r then
			item.KKUI_Border:SetVertexColor(r, g, b)
		end
	end

	-- Blank the leftover row plates.
	for _, region in ipairs({
		button.NameFrame,
		button.IconQuestTexture,
		button.BorderFrame,
		button.HighlightNameFrame,
		button.PushedNameFrame,
	}) do
		if region then
			region:SetAlpha(0)
		end
	end
end

local function LootFrameUpdate(scrollBox)
	if scrollBox.ForEachFrame then
		scrollBox:ForEachFrame(SkinElement)
	end
end

function Module:OnEnable()
	if not C.Skins.LootFrame then
		return
	end
	local LootFrame = _G.LootFrame
	if not LootFrame then
		return
	end

	if K.StripTextures then
		K.StripTextures(LootFrame)
	end
	if LootFrame.Bg then
		LootFrame.Bg:SetAlpha(0)
	end
	if LootFrame.NineSlice then
		LootFrame.NineSlice:SetAlpha(0)
	end
	K.CreateGradientBackground(LootFrame, 0.95)
	K.CreateBorder(LootFrame)

	if LootFrame.ClosePanelButton and K.SkinCloseButton then
		K.SkinCloseButton(LootFrame.ClosePanelButton)
	end
	if LootFrame.ScrollBox then
		hooksecurefunc(LootFrame.ScrollBox, "Update", LootFrameUpdate)
	end
end
