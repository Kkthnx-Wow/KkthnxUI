local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.EnhancedFrames ~= true then return end

local _G = _G
local tostring = tostring
local tonumber = tonumber
local ceil = math.ceil
local IsResting = IsResting
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS

local shorts = {
	{ 1e10, 1e9, "%.0fB" }, -- 10b+ as 12B
	{ 1e9, 1e9, "%.1fB" }, -- 1b+ as 8.3B
	{ 1e7, 1e6, "%.0fM" }, -- 10m+ as 14M
	{ 1e6, 1e6, "%.1fM" }, -- 1m+ as 7.4M
	{ 1e5, 1e3, "%.0fK" }, -- 100k+ as 840K
	{ 1e3, 1e3, "%.1fK" }, -- 1k+ as 2.5K
	{ 0, 1, "%d" }, -- < 1k as 974
}
for i = 1, #shorts do
	shorts[i][4] = shorts[i][3] .. " (%.0f%%)"
end

if (PlayerFrame) then
	PlayerFrameTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame")
	PlayerStatusTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-Player-Status")
end

hooksecurefunc("TargetFrame_CheckClassification", function (self, forceNormalTexture)
	--if(InCombatLockdown() == false) then
		local Classification = UnitClassification(self.unit)

		if forceNormalTexture then
			self.borderTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame")
		elseif Classification == "minus" then
			self.borderTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-Targeting-MinusFrame")
			self.nameBackground:Hide()
			self.manabar:Hide()
			self.manabar.TextString:Hide()
			forceNormalTexture = true
		elseif Classification == "worldboss" or Classification == "elite" then
			self.borderTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame-Elite")
		elseif Classification == "rareelite" then
			self.borderTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame-Rare-Elite")
		elseif Classification == "rare" then
			self.borderTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame-Rare")
		else
			self.borderTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame")
			forceNormalTexture = true
		end
	--end
end)

for i = 1, MAX_PARTY_MEMBERS do
	if(InCombatLockdown() == false) then
		_G["PartyMemberFrame"..i.."Texture"]:SetSize(128, 64)
		_G["PartyMemberFrame"..i.."Texture"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-PartyFrame")

		_G["PartyMemberFrame"..i.."HealthBar"]:SetSize(69, 12)
		_G["PartyMemberFrame"..i.."HealthBar"]:ClearAllPoints()
		_G["PartyMemberFrame"..i.."HealthBar"]:SetPoint("CENTER", 17, 7)

		_G["PartyMemberFrame"..i.."ManaBar"]:SetSize(70, 7)
		_G["PartyMemberFrame"..i.."ManaBar"]:ClearAllPoints()
		_G["PartyMemberFrame"..i.."ManaBar"]:SetPoint("CENTER", 17, -2)

		_G["PartyMemberFrame"..i.."HealthBarText"]:ClearAllPoints()
		_G["PartyMemberFrame"..i.."HealthBarText"]:SetPoint("CENTER", _G["PartyMemberFrame"..i.."HealthBar"], "CENTER", 0, 1)

		_G["PartyMemberFrame"..i.."ManaBarText"]:ClearAllPoints()
		_G["PartyMemberFrame"..i.."ManaBarText"]:SetPoint("CENTER", _G["PartyMemberFrame"..i.."ManaBar"], "CENTER", 0, 0)

		_G["PartyMemberFrame"..i.."Flash"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\Party-Flash")
	end
end

hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function(statusBar, textString, value, valueMin, valueMax)
	if value == 0 then
		return textString:SetText("")
	end

	local style = GetCVar("statusTextDisplay")
	if style == "PERCENT" then
		return textString:SetFormattedText("%.0f%%", value / valueMax * 100)
	end
	for i = 1, #shorts do
		local t = shorts[i]
		if value >= t[1] then
			if style == "BOTH" then
				return textString:SetFormattedText(t[4], value / t[2], value / valueMax * 100)
			else
				if value < valueMax then
					for j = 1, #shorts do
						local v = shorts[j]
						if valueMax >= v[1] then
							return textString:SetFormattedText(t[3] .. " / " .. v[3], value / t[2], valueMax / v[2])
						end
					end
				end
				return textString:SetFormattedText(t[3], value / t[2])
			end
		end
	end
end)

if(InCombatLockdown() == false) then
	FocusFrameToT:ClearAllPoints()
	FocusFrameToT:SetPoint("CENTER", FocusFrame, "CENTER", 60, -45)

	-- NAMES
	PlayerName:SetWidth(0.01)

	TargetFrame.name:ClearAllPoints()
	TargetFrame.name:SetPoint("CENTER", TargetFrame, "CENTER", -50, 35)
	TargetFrame.name.SetPoint = K.Noop

	FocusFrame.name:ClearAllPoints()
	FocusFrame.name:SetPoint("CENTER", FocusFrame, "CENTER", -45, 35)
	FocusFrame.name.SetPoint = K.Noop

	-- PLAYER BARS
	PlayerFrameHealthBar:SetHeight(27)
	PlayerFrameHealthBar:ClearAllPoints()
	PlayerFrameHealthBar:SetPoint("CENTER", PlayerFrame, "CENTER", 50, 14)
	PlayerFrameHealthBar.SetPoint = K.Noop

	PlayerFrameManaBar:ClearAllPoints()
	PlayerFrameManaBar:SetPoint("CENTER", PlayerFrame, "CENTER", 51, -7)
	PlayerFrameManaBar.SetPoint = K.Noop

	-- TARGET BARS
	TargetFrameHealthBar:SetHeight(27)
	TargetFrameHealthBar:ClearAllPoints()
	TargetFrameHealthBar:SetPoint("CENTER", TargetFrame, "CENTER", -50, 14)
	TargetFrameHealthBar.SetPoint = K.Noop

	TargetFrameTextureFrameDeadText:ClearAllPoints()
	TargetFrameTextureFrameDeadText:SetPoint("CENTER", TargetFrameHealthBar, "CENTER", 0, 0)
	TargetFrameTextureFrameDeadText.SetPoint = K.Noop

	TargetFrameManaBar:ClearAllPoints()
	TargetFrameManaBar:SetPoint("CENTER", TargetFrame, "CENTER", -51, -7)
	TargetFrameManaBar.SetPoint = K.Noop

	TargetFrameNumericalThreat:SetScale(0.9)
	TargetFrameNumericalThreat:ClearAllPoints()
	TargetFrameNumericalThreat:SetPoint("BOTTOM", PlayerFrame, "TOP", 75, -23)
	TargetFrameNumericalThreat.SetPoint = K.Noop

	-- FOCUS BARS
	FocusFrameHealthBar:SetHeight(27)
	FocusFrameHealthBar:ClearAllPoints()
	FocusFrameHealthBar:SetPoint("CENTER", FocusFrame, "CENTER", -50, 14)
	FocusFrameHealthBar.SetPoint = K.Noop

	FocusFrameTextureFrameDeadText:ClearAllPoints()
	FocusFrameTextureFrameDeadText:SetPoint("CENTER", FocusFrameHealthBar, "CENTER", 0, 0)
	FocusFrameTextureFrameDeadText.SetPoint = K.Noop

	FocusFrameManaBar:ClearAllPoints()
	FocusFrameManaBar:SetPoint("CENTER", FocusFrame, "CENTER", -51, -7)
	FocusFrameManaBar.SetPoint = K.Noop

	FocusFrameNumericalThreat:ClearAllPoints()
	FocusFrameNumericalThreat:SetPoint("CENTER", FocusFrame, "CENTER", 44, 48)
	FocusFrameNumericalThreat.SetPoint = K.Noop

	-- TEXTSTRINGS
	TargetFrameHealthBar.TextString:ClearAllPoints()
	TargetFrameHealthBar.TextString:SetPoint("CENTER", TargetFrame, "CENTER", -53, 12)
	TargetFrameHealthBar.TextString.SetPoint = K.Noop

	PlayerFrameHealthBar.TextString:ClearAllPoints()
	PlayerFrameHealthBar.TextString:SetPoint("CENTER", PlayerFrame, "CENTER", 53, 12)
	PlayerFrameHealthBar.TextString.SetPoint = K.Noop

	PlayerFrameHealthBarTextRight:ClearAllPoints()
	PlayerFrameHealthBarTextRight:SetPoint("RIGHT", PlayerFrame, "RIGHT", -8, 12)
	PlayerFrameHealthBarTextRight.SetPoint = K.Noop

	PlayerFrameHealthBarTextLeft:ClearAllPoints()
	PlayerFrameHealthBarTextLeft:SetPoint("CENTER", PlayerFrame, "CENTER", 8, 12)
	PlayerFrameHealthBarTextLeft.SetPoint = K.Noop

	TargetFrameTextureFrameHealthBarTextRight:ClearAllPoints()
	TargetFrameTextureFrameHealthBarTextRight:SetPoint("CENTER", TargetFrame, "CENTER", -13, 12)
	TargetFrameTextureFrameHealthBarTextRight.SetPoint = K.Noop

	TargetFrameTextureFrameHealthBarTextLeft:ClearAllPoints()
	TargetFrameTextureFrameHealthBarTextLeft:SetPoint("LEFT", TargetFrame, "LEFT", 7, 12)
	TargetFrameTextureFrameHealthBarTextLeft.SetPoint = K.Noop

	FocusFrameHealthBar.TextString:ClearAllPoints()
	FocusFrameHealthBar.TextString:SetPoint("CENTER", FocusFrame, "CENTER", -53, 12)
	FocusFrameHealthBar.TextString.SetPoint = K.Noop

	PlayerFrameManaBar.TextString:ClearAllPoints()
	PlayerFrameManaBar.TextString:SetPoint("CENTER", PlayerFrame, "CENTER", 53, -7)
	PlayerFrameManaBar.TextString.SetPoint = K.Noop

	TargetFrameManaBar.TextString:ClearAllPoints()
	TargetFrameManaBar.TextString:SetPoint("CENTER", TargetFrame, "CENTER", -53, -7)
	TargetFrameManaBar.TextString.SetPoint = K.Noop

	FocusFrameManaBar.TextString:ClearAllPoints()
	FocusFrameManaBar.TextString:SetPoint("CENTER", FocusFrame, "CENTER", -53, -7)
	FocusFrameManaBar.TextString.SetPoint = K.Noop
end