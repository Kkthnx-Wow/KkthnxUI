local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("ExtraActionButtons", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local unpack = unpack

local CreateFrame = CreateFrame
local GetActionCooldown = GetActionCooldown
local HasExtraActionBar = HasExtraActionBar

local ExtraActionBarHolder, ZoneAbilityHolder

local function DisableExtraButtonTexture(self, texture, loop)
	if loop then
		return
	end

	self:SetTexture("", true)
end

function Module:SetupExtraButton(texture, loop)
	ExtraActionBarHolder = CreateFrame("Frame", "ExtraActionBarHolder", UIParent)
	ExtraActionBarHolder:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 150)
	ExtraActionBarHolder:SetSize(ExtraActionButton1:GetWidth(), ExtraActionButton1:GetHeight())

	ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", ExtraActionBarHolder, "CENTER")
	ExtraActionBarFrame.ignoreFramePositionManager = true

	ZoneAbilityHolder = CreateFrame("Frame", "ZoneAbilityHolder", UIParent)
	ZoneAbilityHolder:SetPoint("BOTTOM", ExtraActionBarFrame, "TOP", 0, 2)
	ZoneAbilityHolder:SetSize(ZoneAbilityFrame.SpellButton:GetWidth(), ZoneAbilityFrame.SpellButton:GetHeight())

	ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint("CENTER", ZoneAbilityHolder, "CENTER")
	ZoneAbilityFrame.ignoreFramePositionManager = true

	for i = 1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			button.noResize = true
			button.pushed = true
			button.checked = true

			button:SetTemplate("ActionButton", true)
			_G["ExtraActionButton"..i.."Icon"]:SetDrawLayer("ARTWORK")
			local tex = button:CreateTexture(nil, "OVERLAY")
			tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetAllPoints()
			button:SetCheckedTexture(tex)
		end
	end

	local button = ZoneAbilityFrame.SpellButton
	if button then
		button:SetNormalTexture("")
		button:StyleButton()
		button:SetTemplate("ActionButton", true)
		button.Icon:SetDrawLayer("ARTWORK")
		button.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		button.Icon:SetAllPoints()
	end

	if HasExtraActionBar() then
		ExtraActionBarFrame:Show()
	end

	self:SecureHook(ExtraActionButton1.style, "SetTexture", DisableExtraButtonTexture)
	self:SecureHook(ZoneAbilityFrame.SpellButton.Style, "SetTexture", DisableExtraButtonTexture)

	K["Movers"]:RegisterFrame(ExtraActionBarHolder)
	K["Movers"]:RegisterFrame(ZoneAbilityHolder)
end

function Module:OnEnable()
	self:SetupExtraButton()
end