local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local pairs = pairs

local hooksecurefunc = _G.hooksecurefunc

local function LoadSkin()
	local MachineFrame = _G.ScrappingMachineFrame

	MachineFrame:CreateBorder(nil, nil, nil, true)

	local ItemSlots = MachineFrame.ItemSlots
	ItemSlots:StripTextures()

	for button in pairs(ItemSlots.scrapButtons.activeObjects) do
		if not button.isSkinned then
			button:CreateBorder(nil, nil, nil, true)
			button.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			button.IconBorder:SetAlpha(0)

			hooksecurefunc(button.IconBorder, "SetVertexColor", function(_, r, g, b)
				button:SetBackdropBorderColor(r, g, b)
			end)

			hooksecurefunc(button.IconBorder, "Hide", function()
				button:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
			end)

			button.isSkinned = true
		end
	end

	MachineFrame.ScrapButton:SkinButton()
	ScrappingMachineFrameCloseButton:SkinCloseButton()

	-- Temp mover
	MachineFrame:SetMovable(true)
	MachineFrame:RegisterForDrag("LeftButton")
	MachineFrame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)

	MachineFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)
end

Module.SkinFuncs["Blizzard_ScrappingMachineUI"] = LoadSkin