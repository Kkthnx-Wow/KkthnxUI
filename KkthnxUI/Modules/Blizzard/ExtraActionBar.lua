local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

-- Lua API
local _G = _G
local unpack = unpack

-- WoW API
local CreateFrame = _G.CreateFrame
local GetActionCooldown = _G.GetActionCooldown
local HasExtraActionBar = _G.HasExtraActionBar
local UIParent = _G.UIParent

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: ExtraActionBarFrame, ZoneAbilityFrame

local ExtraActionBarHolder, ZoneAbilityHolder

local Movers = K.Movers

local function FixExtraActionCD(cd)
	local start, duration = GetActionCooldown(cd:GetParent().action)
	cd:SetHideCountdownNumbers(true)
end

local function Extra_SetAlpha()
	for i=1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			button:SetAlpha(1)
		end
	end

	local button = ZoneAbilityFrame.SpellButton
	if button then
		button:SetAlpha(1)
	end
end

local function Extra_SetScale()
	if ExtraActionBarFrame then
		ExtraActionBarFrame:SetScale(1)
		ExtraActionBarHolder:SetSize(ExtraActionBarFrame:GetWidth() * 1, ExtraActionBarFrame:GetHeight() * 1)
	end

	if ZoneAbilityFrame then
		ZoneAbilityFrame:SetScale(1)
		ZoneAbilityHolder:SetSize(ZoneAbilityFrame:GetWidth() * 1, ZoneAbilityFrame:GetHeight() * 1)
	end
end

local function SetupExtraButton()
	ExtraActionBarHolder = CreateFrame("Frame", "ExtraActionBarHolder", UIParent)
	if C.ActionBar.SplitBars and not C.DataText.BottomBar then
		ExtraActionBarHolder:SetPoint(C.Position.ExtraButton[1], SplitBarRight, C.Position.ExtraButton[3], C.Position.ExtraButton[4], C.Position.ExtraButton[5])
	elseif C.ActionBar.SplitBars and C.DataText.BottomBar then
		ExtraActionBarHolder:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton12", "BOTTOMRIGHT", 3, -28)
	elseif not C.ActionBar.SplitBars and C.DataText.BottomBar then
		ExtraActionBarHolder:SetPoint("BOTTOMLEFT", "ActionButton12", "BOTTOMRIGHT", 3, -28)
	else
		ExtraActionBarHolder:SetPoint(unpack(C.Position.ExtraButton))
	end
	ExtraActionBarHolder:SetSize(ExtraActionBarFrame:GetWidth(), ExtraActionBarFrame:GetHeight())

	ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", ExtraActionBarHolder, "CENTER")
	ExtraActionBarFrame.ignoreFramePositionManager = true

	ZoneAbilityHolder = CreateFrame("Frame", "ZoneAbilityHolder", UIParent)
	if C.ActionBar.SplitBars and not C.DataText.BottomBar then
		ZoneAbilityHolder:SetPoint(C.Position.ExtraButton[1], SplitBarRight, C.Position.ExtraButton[3], C.Position.ExtraButton[4], C.Position.ExtraButton[5])
	elseif C.ActionBar.SplitBars and C.DataText.BottomBar then
		ZoneAbilityHolder:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton12", "BOTTOMRIGHT", 3, -28)
	elseif not C.ActionBar.SplitBars and C.DataText.BottomBar then
		ZoneAbilityHolder:SetPoint("BOTTOMLEFT", "ActionButton12", "BOTTOMRIGHT", 3, -28)
	else
		ZoneAbilityHolder:SetPoint(unpack(C.Position.ExtraButton))
	end
	ZoneAbilityHolder:SetSize(ExtraActionBarFrame:GetWidth(), ExtraActionBarFrame:GetHeight())

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

			button:StyleButton()
			button:SetTemplate()
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
		button:StyleButton()
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

	Extra_SetAlpha()
	Extra_SetScale()
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function()
	SetupExtraButton()
end)