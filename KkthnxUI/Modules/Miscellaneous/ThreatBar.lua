local K, C, L = select(2, ...):unpack()
if C.DataText.BottomBar ~= true then return end

local floor = math.floor
local GetNumGroupMembers = GetNumGroupMembers
local HasPetUI = HasPetUI
local UnitAffectingCombat = UnitAffectingCombat
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitName = UnitName
local UnitIsDead = UnitIsDead
local InCombatLockdown = InCombatLockdown
local KkthnxUIDataTextBottomBar = KkthnxUIDataTextBottomBar

local ThreatBar = CreateFrame("StatusBar", nil, UIParent)

local OnEvent = function(self, event)
	local Party = GetNumGroupMembers()
	local Raid = GetNumGroupMembers()
	local Pet = HasPetUI()

	if (event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_DEAD") then
		self:Hide()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		self:Hide()
	elseif (event == "PLAYER_REGEN_DISABLED") then
		if (Party > 0 or Raid > 0 or Pet) then
			self:Show()
		else
			self:Hide()
		end
	else
		if ((InCombatLockdown()) and (Party > 0 or Raid > 0 or Pet)) then
			self:Show()
		else
			self:Hide()
		end
	end
end

local OnUpdate = function(self)
	if (not UnitAffectingCombat("player")) then
		return
	end

	local _, _, ThreatPercent = UnitDetailedThreatSituation("player", "target")
	local ThreatPercent = ThreatPercent or 0
	local Text = self.Text
	local Title = self.Title
	local Dead = UnitIsDead("player")

	self:SetValue(ThreatPercent)
	Title:SetText((UnitName("target") and UnitName("target") .. ":") or "")
	Text:SetText(floor(ThreatPercent) .. "%")

	local R, G, B = K.ColorGradient(ThreatPercent, 100, 0, 0.8, 0, 0.8, 0.8, 0, 0.8, 0, 0)
	self:SetStatusBarColor(R, G, B)

	if (Dead) then
		self:SetAlpha(0)
	elseif (ThreatPercent > 0) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0)
	end
end

local CreateBar = function()
	if (not KkthnxUIDataTextBottomBar) then
		return
	end

	ThreatBar:SetStatusBarTexture(C.Media.Texture)
	ThreatBar:SetInside(KkthnxUIDataTextBottomBar, 3.9, 3.9)
	ThreatBar:SetFrameStrata("HIGH")
	ThreatBar:SetFrameLevel(KkthnxUIDataTextBottomBar:GetFrameLevel() + 1)
	ThreatBar:SetAlpha(0)

	ThreatBar.Background = ThreatBar:CreateTexture(nil, "BORDER")
	ThreatBar.Background:SetPoint("TOPLEFT", ThreatBar, 0, 0)
	ThreatBar.Background:SetPoint("BOTTOMRIGHT", ThreatBar, 0, 0)
	ThreatBar.Background:SetColorTexture(0.15, 0.15, 0.15)

	ThreatBar.Title = K.SetFontString(ThreatBar, C.Media.Font, 14, "OUTLINE", "CENTER", true)
	ThreatBar.Title:SetPoint("LEFT", ThreatBar, "LEFT", 15, 0)

	ThreatBar.Text = K.SetFontString(ThreatBar, C.Media.Font, 14, "OUTLINE", "CENTER", true)
	ThreatBar.Text:SetPoint("RIGHT", ThreatBar, "RIGHT", -15, 0)

	ThreatBar:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)

	ThreatBar:SetScript("OnHide", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	ThreatBar:RegisterEvent("PLAYER_DEAD")
	ThreatBar:RegisterEvent("PLAYER_ENTERING_WORLD")
	ThreatBar:RegisterEvent("PLAYER_REGEN_ENABLED")
	ThreatBar:RegisterEvent("PLAYER_REGEN_DISABLED")
	ThreatBar:SetScript("OnEvent", OnEvent)
end

ThreatBar:RegisterEvent("PLAYER_LOGIN")
ThreatBar:SetScript("OnEvent", CreateBar)
