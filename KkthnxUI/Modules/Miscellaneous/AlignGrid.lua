local K = unpack(select(2, ...))
local Module = K:NewModule("AlignGrid")

local _G = _G

local GetScreenHeight = _G.GetScreenHeight
local CreateFrame = _G.CreateFrame
local GetScreenWidth = _G.GetScreenWidth

Module.Enable = false
Module.BoxSize = 128

function Module:Show()
	if not self.Frame then
		Module:Create()
	elseif self.Frame.boxSize ~= Module.BoxSize then
		self.Frame:Hide()
		Module:Create()
	else
		self.Frame:Show()
	end
end

function Module:Hide()
	if self.Frame then
		self.Frame:Hide()
	end
end

function Module:Create()
	self.Frame = CreateFrame("Frame", nil, UIParent)
	self.Frame.boxSize = Module.BoxSize
	self.Frame:SetAllPoints(UIParent)

	local Size = 2
	local Width = GetScreenWidth()
	local Ratio = Width / GetScreenHeight()
	local Height = GetScreenHeight() * Ratio
	local WidthStep = Width / Module.BoxSize
	local HeightStep = Height / Module.BoxSize

	for i = 0, Module.BoxSize do
		local Texture = self.Frame:CreateTexture(nil, "BACKGROUND")
		if i == Module.BoxSize / 2 then
			Texture:SetColorTexture(1, 0, 0, 0.8)
		else
			Texture:SetColorTexture(0, 0, 0, 0.8)
		end

		Texture:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", i * WidthStep - (Size / 2), 0)
		Texture:SetPoint("BOTTOMRIGHT", self.Frame, "BOTTOMLEFT", i * WidthStep + (Size / 2), 0)
	end

	Height = GetScreenHeight()

	do
		local Texture = self.Frame:CreateTexture(nil, "BACKGROUND")
		Texture:SetColorTexture(1, 0, 0, 0.8)
		Texture:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 0, -(Height / 2) + (Size / 2))
		Texture:SetPoint("BOTTOMRIGHT", self.Frame, "TOPRIGHT", 0, -(Height / 2 + Size / 2))
	end

	for i = 1, math.floor((Height / 2) / HeightStep) do
		local Texture = self.Frame:CreateTexture(nil, "BACKGROUND")
		Texture:SetColorTexture(0, 0, 0, 0.8)

		Texture:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 0, -(Height / 2 + i * HeightStep) + (Size / 2))
		Texture:SetPoint("BOTTOMRIGHT", self.Frame, "TOPRIGHT", 0, -(Height / 2 + i * HeightStep + Size / 2))

		Texture = self.Frame:CreateTexture(nil, "BACKGROUND")
		Texture:SetColorTexture(0, 0, 0, 0.8)

		Texture:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 0, -(Height / 2 - i * HeightStep) + (Size / 2))
		Texture:SetPoint("BOTTOMRIGHT", self.Frame, "TOPRIGHT", 0, -(Height / 2 - i * HeightStep + Size / 2))
	end
end

SLASH_TOGGLEGRID1 = "/showgrid"
SlashCmdList["TOGGLEGRID"] = function(arg)
	if Module.Enable then
		Module:Hide()
		Module.Enable = false
	else
		Module.BoxSize = (math.ceil((tonumber(arg) or Module.BoxSize) / 32) * 32)
		if Module.BoxSize > 256 then
			Module.BoxSize = 256
        end

		Module:Show()
		Module.Enable = true
	end
end