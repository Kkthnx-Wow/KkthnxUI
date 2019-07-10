local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

-- Lua
local _G = _G
local hooksecurefunc = _G.hooksecurefunc

local function UpdateAzeriteItem(self)
	if not self.styled then
		self.AzeriteTexture:SetAlpha(0)
		self.RankFrame.Texture:SetTexture()
		self.RankFrame.Label:FontTemplate(nil, nil, "OUTLINE")

		self.styled = true
	end

	self:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	self:GetHighlightTexture():SetAllPoints()
end

local function UpdateAzeriteEmpoweredItem(self)
	self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
	self.AzeriteTexture:SetInside()
	self.AzeriteTexture:SetTexCoord(unpack(K.TexCoords))
	self.AzeriteTexture:SetDrawLayer("BORDER", 1)
end

local function SkinCharacterFrame()
	if CharacterFrame:IsShown() then
		HideUIPanel(CharacterFrame)
	end

	CharacterModelFrame.BackgroundBotLeft:Kill()
	CharacterModelFrame.BackgroundBotRight:Kill()
	CharacterModelFrame.BackgroundOverlay:Kill()
	CharacterModelFrame.BackgroundTopLeft:Kill()
	CharacterModelFrame.BackgroundTopRight:Kill()
	CharacterStatsPane.ClassBackground:Kill()
	PaperDollInnerBorderBottom:Kill()
	PaperDollInnerBorderBottom2:Kill()
	PaperDollInnerBorderBottomLeft:Kill()
	PaperDollInnerBorderBottomRight:Kill()
	PaperDollInnerBorderLeft:Kill()
	PaperDollInnerBorderRight:Kill()
	PaperDollInnerBorderTop:Kill()
	PaperDollInnerBorderTopLeft:Kill()
	PaperDollInnerBorderTopRight:Kill()

	for _, slot in pairs({_G.PaperDollItemsFrame:GetChildren()}) do
		if slot:IsObjectType("Button") or slot:IsObjectType("ItemButton") then
			slot:CreateBorder(nil, nil, nil, true)
			slot:StyleButton(slot)
			slot.icon:SetTexCoord(unpack(K.TexCoords))
			slot:SetSize(36, 36)

			hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
			hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)

			if slot.popoutButton:GetPoint() == "TOP" then
				slot.popoutButton:SetPoint("TOP", slot, "BOTTOM", 0, 2)
			else
				slot.popoutButton:SetPoint("LEFT", slot, "RIGHT", -2, 0)
			end

			slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
			slot.IconBorder:SetAlpha(0)
			hooksecurefunc(slot.IconBorder, "SetVertexColor", function(_, r, g, b)
				slot:SetBackdropBorderColor(r, g, b)
			end)

			hooksecurefunc(slot.IconBorder, "Hide", function()
				slot:SetBackdropBorderColor()
			end)
		end
	end

	CharacterHeadSlot:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 6, -6)
	CharacterHandsSlot:SetPoint("TOPRIGHT", CharacterFrame.Inset, "TOPRIGHT", -6, -6)
	CharacterMainHandSlot:SetPoint("BOTTOMLEFT", CharacterFrame.Inset, "BOTTOMLEFT", 176, 5)
	CharacterSecondaryHandSlot:ClearAllPoints()
	CharacterSecondaryHandSlot:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -176, 5)

	CharacterModelFrame:SetSize(0, 0)
	CharacterModelFrame:ClearAllPoints()
	CharacterModelFrame:SetPoint("TOPLEFT", CharacterFrame.Inset, 0, 0)
	CharacterModelFrame:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, 0, 30)
	CharacterModelFrame:SetCamDistanceScale(1.1)

	hooksecurefunc("CharacterFrame_Expand", function()
		CharacterFrame:SetSize(640, 431) -- 540 + 100, 424 + 7
		CharacterFrame.Inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 432, 4)

		CharacterFrame.Inset.Bg:SetTexture("Interface\\DressUpFrame\\DressingRoom" .. K.Class)
		CharacterFrame.Inset.Bg:SetTexCoord(1 / 512, 479 / 512, 46 / 512, 455 / 512)
		CharacterFrame.Inset.Bg:SetHorizTile(false)
		CharacterFrame.Inset.Bg:SetVertTile(false)
	end)

	hooksecurefunc("CharacterFrame_Collapse", function()
		CharacterFrame:SetHeight(424)
		CharacterFrame.Inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 332, 4)

		CharacterFrame.Inset.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", "REPEAT", "REPEAT")
		CharacterFrame.Inset.Bg:SetTexCoord(0, 1, 0, 1)
		CharacterFrame.Inset.Bg:SetHorizTile(true)
		CharacterFrame.Inset.Bg:SetVertTile(true)
	end)

	_G.CharacterLevelText:FontTemplate()
	_G.CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)
end

table.insert(Module.SkinFuncs["KkthnxUI"], SkinCharacterFrame)