local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true or C.DataText.BottomBar ~= true or C.DataText.ThreatBar ~= true then return end

-- Lua API
local floor = math.floor

-- Wow API
local GetNumGroupMembers = GetNumGroupMembers
local HasPetUI = HasPetUI
local InCombatLockdown = InCombatLockdown
local UnitAffectingCombat = UnitAffectingCombat
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitIsDead = UnitIsDead
local UnitName = UnitName

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KkthnxUIDataTextBottomBar

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
		if (InCombatLockdown()) and (Party > 0 or Raid > 0 or Pet) then
			self:Show()
		else
			self:Hide()
		end
	end
end

local OnUpdate = function(self)
	local GetColor = K.ColorGradient

	if UnitAffectingCombat("player") then
		local _, _, ThreatPercent = UnitDetailedThreatSituation("player", "target")
		local ThreatValue = ThreatPercent or 0
		local Text = self.Text
		local Title = self.Title
		local Dead = UnitIsDead("player")

		self:SetValue(ThreatValue)
		Text:SetText(floor(ThreatValue) .. "%")
		Title:SetText((UnitName("target") and UnitName("target") .. ":") or "")

		local R, G, B = GetColor(ThreatValue, 100, 0,.8,0,.8,.8,0,.8,0,0)
		self:SetStatusBarColor(R, G, B)

		if Dead then
			self:SetAlpha(0)
		elseif (ThreatValue > 0) then
			self:SetAlpha(1)
		else
			self:SetAlpha(0)
		end
	end
end

ThreatBar:RegisterEvent("PLAYER_LOGIN")
ThreatBar:SetScript("OnEvent", function(self, event)
	ThreatBar:SetParent(KkthnxUIDataTextBottomBar)

	self:SetPoint("TOPLEFT", 4, -4)
	self:SetPoint("BOTTOMRIGHT", -4, 4)
	self:SetFrameLevel(KkthnxUIDataTextBottomBar:GetFrameLevel() + 2)
	self:SetFrameStrata("HIGH")
	self:SetStatusBarTexture(C.Media.Texture)
	self:SetMinMaxValues(0, 100)
	self:SetAlpha(0)

	self.Text = self:CreateFontString(nil, "OVERLAY")
	self.Text:SetFont(C.Media.Font, 14, C.Media.Font_Style)
	self.Text:SetShadowOffset(0, -0)
	self.Text:SetPoint("RIGHT", self, -30, 0)

	self.Title = self:CreateFontString(nil, "OVERLAY")
	self.Title:SetFont(C.Media.Font, 14, C.Media.Font_Style)
	self.Title:SetPoint("LEFT", self, 30, 0)
	self.Title:SetShadowColor(0, 0, 0)
	self.Title:SetShadowOffset(1.25, -1.25)

	self.Background = self:CreateTexture(nil, "BORDER")
	self.Background:SetPoint("TOPLEFT", self, 0, 0)
	self.Background:SetPoint("BOTTOMRIGHT", self, 0, 0)
	self.Background:SetColorTexture(0.15, 0.15, 0.15)

	self:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)

	self:SetScript("OnHide", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	self:RegisterEvent("PLAYER_DEAD")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:SetScript("OnEvent", OnEvent)

	if event == ("PLAYER_ENTERING_WORLD") then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end)