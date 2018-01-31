local K, C = unpack(select(2, ...))

local _G = _G
local pairs, unpack = pairs, unpack

local GetPrestigeInfo = _G.GetPrestigeInfo
local UnitPrestige = _G.UnitPrestige
local UnitLevel = _G.UnitLevel
local hooksecurefunc = _G.hooksecurefunc

local function LoadSkin()
	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
	}

	for _, slot in pairs(slots) do
		local icon = _G["Inspect"..slot.."IconTexture"]
		slot = _G["Inspect"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
		icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		icon:SetAllPoints()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:CreateBackdrop("Transparent")
		slot.Backdrop:SetAllPoints()
		slot.Backdrop:SetFrameLevel(slot:GetFrameLevel())

		hooksecurefunc(slot.IconBorder, "SetVertexColor", function(self, r, g, b)
			self:GetParent().Backdrop:SetBackdropBorderColor(r, g, b)
			self:SetTexture("")
		end)

		hooksecurefunc(slot.IconBorder, "Hide", function(self)
			self:GetParent().Backdrop:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		end)
	end
end

K.SkinFuncs["Blizzard_InspectUI"] = LoadSkin