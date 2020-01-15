local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local unpack = _G.unpack

local hooksecurefunc = _G.hooksecurefunc

local function SkinScrappingMachine()
	local MachineFrame = _G.ScrappingMachineFrame

	MachineFrame:CreateBorder(nil, nil, nil, true)
	MachineFrame.ScrapButton:SkinButton()
	MachineFrame.CloseButton:SkinCloseButton()
	MachineFrame.CloseButton:SetPoint("TOPRIGHT", MachineFrame, "TOPRIGHT", 4, 4)

	local ItemSlots = MachineFrame.ItemSlots
	ItemSlots:StripTextures()

	for button in pairs(ItemSlots.scrapButtons.activeObjects) do
		button:CreateBorder(nil, nil, nil, true)

		button.Icon:SetTexCoord(unpack(K.TexCoords))
		button.Icon:SetAllPoints(button)

		button.IconBorder:SetAlpha(0)
		hooksecurefunc(button.IconBorder, "SetVertexColor", function(_, r, g, b)
			button:SetBackdropBorderColor(r, g, b)
		end)

		hooksecurefunc(button.IconBorder, "Hide", function()
			button:SetBackdropBorderColor()
		end)
	end
end

Module.NewSkin["Blizzard_ScrappingMachineUI"] = SkinScrappingMachine