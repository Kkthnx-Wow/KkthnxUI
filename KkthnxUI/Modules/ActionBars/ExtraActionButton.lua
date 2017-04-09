local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

-- Lua Wow
local _G = _G
local unpack = unpack

--WoW API
local CreateFrame = _G.CreateFrame
local GetActionCooldown = _G.GetActionCooldown
local HasExtraActionBar = _G.HasExtraActionBar
local UIParent = _G.UIParent

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: ExtraActionBarFrame, ZoneAbilityFrame, SplitBarRight

local Movers = K.Movers
local ExtraActionBarHolder, ZoneAbilityHolder

local function FixExtraActionCD(cd)
	local start, duration = GetActionCooldown(cd:GetParent().action)
	cd:SetHideCountdownNumbers(true)
end

local function DisableTexture(self, texture, loop)
	if loop then
		return
	end

	self:SetTexture("", true)
end
hooksecurefunc(ExtraActionButton1.style, "SetTexture", DisableTexture)
hooksecurefunc(ZoneAbilityFrame.SpellButton.Style, "SetTexture", DisableTexture)

local function SetupExtraButton(self)
	ExtraActionBarHolder = CreateFrame("Frame", "ExtraActionBarHolder", UIParent)
	if C.ActionBar.SplitBars then
		ExtraActionBarHolder:SetPoint(C.Position.ExtraButton[1], SplitBarRight, C.Position.ExtraButton[3], C.Position.ExtraButton[4], C.Position.ExtraButton[5])
	else
		ExtraActionBarHolder:SetPoint(unpack(C.Position.ExtraButton))
	end
	ExtraActionBarHolder:SetSize(ExtraActionBarFrame:GetWidth() - 14, ExtraActionBarFrame:GetHeight() - 14)

	ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", ExtraActionBarHolder, "CENTER")
	ExtraActionBarFrame.ignoreFramePositionManager = true

	ZoneAbilityHolder = CreateFrame("Frame", "ZoneAbilityHolder", UIParent)
	if C.ActionBar.SplitBars then
		ZoneAbilityHolder:SetPoint(C.Position.ZoneAbility[1], SplitBarRight, C.Position.ZoneAbility[3], C.Position.ZoneAbility[4], C.Position.ZoneAbility[5])
	else
		ZoneAbilityHolder:SetPoint(unpack(C.Position.ZoneAbility))
	end
	ZoneAbilityHolder:SetSize(ExtraActionBarFrame:GetWidth() - 14, ExtraActionBarFrame:GetHeight() - 14)

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

			self:StyleButton(button, true)
			_G["ExtraActionButton"..i.."Icon"]:SetDrawLayer("ARTWORK")
			local tex = button:CreateTexture(nil, "OVERLAY")
			tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			button:SetCheckedTexture(tex)

			if (button.cooldown) then
				button.cooldown:HookScript("OnShow", FixExtraActionCD)
			end
		end
	end

	local button = ZoneAbilityFrame.SpellButton
	if button then
		button:SetNormalTexture("")
		button:StyleButton(nil, nil, nil, true)
		button:SetTemplate()
		button.Icon:SetDrawLayer("ARTWORK")
		button.Icon:SetTexCoord(unpack(K.TexCoords))
		button.Icon:SetInside()
	end

	if HasExtraActionBar() then
		ExtraActionBarFrame:Show()
	end

	Movers:RegisterFrame(ExtraActionBarHolder)
	Movers:RegisterFrame(ZoneAbilityHolder)
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", SetupExtraButton)