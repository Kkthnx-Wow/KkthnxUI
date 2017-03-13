local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

local Movers = K.Movers
local Button = ExtraActionButton1
local Zone = ZoneAbilityFrame
local ZoneButton = Zone.SpellButton
local Texture = Button.style
local ZoneTexture = ZoneButton.Style
local CreateFrame = CreateFrame

local DisableExtraButtonTexture = function(self, texture, loop)
	if loop then
		return
	end

	self:SetTexture("", true)
end
hooksecurefunc(ExtraActionButton1.style, "SetTexture", DisableExtraButtonTexture)
hooksecurefunc(ZoneAbilityFrame.SpellButton.Style, "SetTexture", DisableExtraButtonTexture)

local SetUpExtraActionButton = function()
	local Holder = CreateFrame("Frame", "ExtraActionButton", UIParent)
	if C.ActionBar.SplitBars and not C.DataText.BottomBar then
		Holder:SetPoint(C.Position.ExtraButton[1], SplitBarRight, C.Position.ExtraButton[3], C.Position.ExtraButton[4], C.Position.ExtraButton[5])
	elseif C.ActionBar.SplitBars and C.DataText.BottomBar then
		Holder:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton12", "BOTTOMRIGHT", 3, -28)
	elseif not C.ActionBar.SplitBars and C.DataText.BottomBar then
		Holder:SetPoint("BOTTOMLEFT", "ActionButton12", "BOTTOMRIGHT", 3, -28)
	else
		Holder:SetPoint(unpack(C.Position.ExtraButton))
	end
	Holder:SetSize(ExtraActionBarFrame:GetSize() - 12, ExtraActionBarFrame:GetSize() - 12)
	Holder:SetPoint("BOTTOM", 0, 250)

	ExtraActionBarFrame:SetParent(UIParent)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", Holder, "CENTER", 0, 0)
	ExtraActionBarFrame.ignoreFramePositionManager = true

	ZoneAbilityFrame:SetParent(UIParent)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint("CENTER", Holder, "CENTER", 0, 0)
	ZoneAbilityFrame.ignoreFramePositionManager = true

	ZoneButton:SetTemplate()
	ZoneButton:StyleButton()
	ZoneButton:SetNormalTexture("")
	ZoneButton.Icon:SetInside()
	ZoneButton.Icon:SetDrawLayer("BACKGROUND", 0)
	ZoneButton.Icon:SetTexCoord(unpack(K.TexCoords))

	Texture:SetTexture("")
	ZoneTexture:SetTexture("")

	Movers:RegisterFrame(Holder)
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", SetUpExtraActionButton)