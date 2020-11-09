local K, C = unpack(select(2, ...))

local _G = _G
local unpack = _G.unpack
local pairs = _G.pairs

local hooksecurefunc = _G.hooksecurefunc

C.themes["Blizzard_ScrappingMachineUI"] = function()
	local MachineFrame = _G.ScrappingMachineFrame

	MachineFrame:StripTextures()
	MachineFrame:CreateBorder()
	MachineFrame.ScrapButton:SkinButton()
	MachineFrame.CloseButton:SkinCloseButton()
	MachineFrame.CloseButton:SetPoint("TOPRIGHT", MachineFrame, "TOPRIGHT", 4, 4)

	local ItemSlots = MachineFrame.ItemSlots
	ItemSlots:StripTextures()

	for button in pairs(ItemSlots.scrapButtons.activeObjects) do
		button:StripTextures()
		button:CreateBorder()

		button.Icon:SetTexCoord(unpack(K.TexCoords))
		button.Icon:SetAllPoints(button)

		button.IconBorder:SetAlpha(0)
		hooksecurefunc(button.IconBorder, "SetVertexColor", function(_, r, g, b)
			button.KKUI_Border:SetVertexColor(r, g, b)
		end)

		hooksecurefunc(button.IconBorder, "Hide", function()
			button.KKUI_Border:SetVertexColor(1, 1, 1)
		end)
	end
end