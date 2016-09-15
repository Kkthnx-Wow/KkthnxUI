local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.EnhancedFrames ~= true then return end

local CombatLock = false

-- LUA API
local _G = _G

-- WOW API
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local UnitIsTapDenied = UnitIsTapDenied
local InCombatLockdown = InCombatLockdown
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS
local GetCVar = GetCVar
local UnitClassification = UnitClassification

local Shorts = {
	{ 1e10, 1e9, "%.0fB" }, -- 10B+ AS 12B
	{ 1e9, 1e9, "%.1fB" }, -- 1B+ AS 8.3B
	{ 1e7, 1e6, "%.0fM" }, -- 10M+ AS 14M
	{ 1e6, 1e6, "%.1fM" }, -- 1M+ AS 7.4M
	{ 1e5, 1e3, "%.0fK" }, -- 100K+ AS 840K
	{ 1e3, 1e3, "%.1fK" }, -- 1K+ AS 2.5K
	{ 0, 1, "%d" }, -- < 1K AS 974
}
for i = 1, #Shorts do
	Shorts[i][4] = Shorts[i][3] .. " (%.0f%%)"
end

local EnhancedFrames = CreateFrame("Frame")

function EnhancedFrames:Setup()
	-- GENERIC STATUS TEXT HOOK
	hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", EnhancedFrames_TextStatusBarUpdateTextStringWithValues)

	-- HOOK PLAYERFRAME FUNCTIONS
	hooksecurefunc("PlayerFrame_ToPlayerArt", EnhancedFrames_PlayerFrame_ToPlayerArt)
	hooksecurefunc("PlayerFrame_ToVehicleArt", EnhancedFrames_PlayerFrame_ToVehicleArt)

	-- HOOK TARGETFRAME FUNCTIONS
	hooksecurefunc("TargetFrame_CheckFaction", EnhancedFrames_TargetFrame_CheckFaction)
	hooksecurefunc("TargetFrame_CheckClassification", EnhancedFrames_Target_Classification)

	-- BOSSFRAME HOOKS
	hooksecurefunc("BossTargetFrame_OnLoad", EnhancedFrames_BossTargetFrame_Style)

	-- PARTYFRAME HOOKS
	hooksecurefunc("PartyMemberFrame_ToPlayerArt", EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt)
	hooksecurefunc("PartyMemberFrame_ToVehicleArt", EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt)

	-- SET UP SOME STYLINGS
	EnhancedFrames_Style_PlayerFrame()
	EnhancedFrames_BossTargetFrame_Style()
	EnhancedFrames_Style_TargetFrame(TargetFrame)
	EnhancedFrames_Style_TargetFrame(FocusFrame)

	-- UPDATE SOME VALUES
	TextStatusBar_UpdateTextString(PlayerFrame.healthbar)
	TextStatusBar_UpdateTextString(PlayerFrame.manabar)
end

function EnhancedFrames_Style_PlayerFrame()
	PlayerName:SetWidth(0.01)

	PlayerFrameHealthBar.capNumericDisplay = true
	PlayerFrameHealthBar:SetSize(119, 29)
	PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -22)
	PlayerFrameHealthBarText:SetPoint("CENTER", 50, 12)

	PlayerRestIcon:ClearAllPoints()
	PlayerRestIcon:SetPoint("CENTER", PlayerLevelText, -1, 1)
	PlayerRestIcon:SetSize(31, 34)

	PlayerFrameTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame")
	PlayerStatusTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-Player-Status")
end

function EnhancedFrames_Style_TargetFrame(self)
	local classification = UnitClassification(self.unit)
	if (classification == "minus") then
		self.healthbar:SetHeight(12)
		self.healthbar:SetPoint("TOPLEFT", 7, -41)
		self.healthbar.TextString:SetPoint("CENTER", -50, 4)
		self.deadText:SetPoint("CENTER", -50, 4)
		self.Background:SetPoint("TOPLEFT", 7, -41)
	else
		self.name:SetPoint("TOPLEFT", 16, -8)

		self.healthbar:SetHeight(29)
		self.healthbar:SetPoint("TOPLEFT", 7, -22)
		self.healthbar.TextString:SetPoint("CENTER", -50, 12)
		self.deadText:SetPoint("CENTER", -50, 12)
		self.nameBackground:Hide()
		self.Background:SetPoint("TOPLEFT", 7, -22)
	end

	self.healthbar:SetWidth(119)
end

function EnhancedFrames_BossTargetFrame_Style()
	for i = 1, MAX_BOSS_FRAMES do
		_G["Boss"..i.."TargetFrameTextureFrameTexture"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-UnitFrame-Boss")
	end
end

--[[
	MAKE SURE TO SET STATUS TEXT TO NUMERIC VALUES IN INTERFACE OPTIONS FOR THIS TO WORK
	"PERCENT" and "NUMERIC"
	GetCVarDefault("statusTextDisplay") -> "NUMERIC"
	GetCVarDefault("statusText") -> "0"
]]--
-- FORCE NUMERIC FOR HEALTHBAR FIX
SetCVar("statusTextDisplay", "NONE")
function EnhancedFrames_TextStatusBarUpdateTextStringWithValues(statusBar, textString, value, valueMin, valueMax)
	if value == 0 then
		return textString:SetText("")
	end

	local style = GetCVar("statusTextDisplay")
	if style == "PERCENT" then
		return textString:SetFormattedText("%.0f%%", value / valueMax * 100)
	end
	for i = 1, #Shorts do
		local t = Shorts[i]
		if value >= t[1] then
			if style == "BOTH" then
				return textString:SetFormattedText(t[4], value / t[2], value / valueMax * 100)
			else
				if value < valueMax then
					for j = 1, #Shorts do
						local v = Shorts[j]
						if valueMax >= v[1] then
							return textString:SetFormattedText(t[3] .. " / " .. v[3], value / t[2], valueMax / v[2])
						end
					end
				end
				return textString:SetFormattedText(t[3], value / t[2])
			end
		end
	end
end

function EnhancedFrames_PlayerFrame_ToPlayerArt(self)
	EnhancedFrames_Style_PlayerFrame()
end

function EnhancedFrames_PlayerFrame_ToVehicleArt(self)
	PlayerFrameHealthBar:SetHeight(12)
	PlayerFrameHealthBarText:SetPoint("CENTER", 50, 3)
end

function EnhancedFrames_Target_Classification(self, forceNormalTexture)
	local texture
	local classification = UnitClassification(self.unit)
	if (classification == "worldboss" or classification == "elite") then
		texture = "Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame-Elite"
	elseif (classification == "rareelite") then
		texture = "Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame-Rare-Elite"
	elseif (classification == "rare") then
		texture = "Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame-Rare"
	end
	if (texture and not forceNormalTexture) then
		self.borderTexture:SetTexture(texture)
	else
		if (not (classification == "minus")) then
			self.borderTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-TargetingFrame")
		end
	end

	self.nameBackground:Hide()
end

function EnhancedFrames_TargetFrame_CheckFaction(self)
	local factionGroup = UnitFactionGroup(self.unit)
	if (UnitIsPVPFreeForAll(self.unit)) then
		self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self.pvpIcon:Show()
	elseif (factionGroup and UnitIsPVP(self.unit) and UnitIsEnemy("player", self.unit)) then
		self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self.pvpIcon:Show()
	elseif (factionGroup == "Alliance" or factionGroup == "Horde") then
		self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
		self.pvpIcon:Show()
	else
		self.pvpIcon:Hide()
	end

	EnhancedFrames_Style_TargetFrame(self)
end

-- STYLE PARTY MEMEBER FRAME STYLE CHANGES
function EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt(self)
	for i = 1, MAX_PARTY_MEMBERS do
		_G["PartyMemberFrame"..i.."HealthBarText"]:SetPoint("CENTER", _G["PartyMemberFrame"..i.."HealthBar"], "CENTER", 0, 1)

		_G["PartyMemberFrame"..i.."Name"]:SetPoint("TOP", 0, 20)

		_G["PartyMemberFrame"..i.."Texture"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\PartyFrame")
		_G["PartyMemberFrame"..i.."Texture"]:SetPoint("TOPLEFT", 0, 6)

		_G["PartyMemberFrame"..i.."Flash"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\PartyFrameFlash")
		_G["PartyMemberFrame"..i.."Flash"]:SetPoint("TOPLEFT", 0, 6)

		_G["PartyMemberFrame"..i.."HealthBar"]:SetPoint("TOPLEFT", 47, -3)
		_G["PartyMemberFrame"..i.."HealthBar"]:SetHeight(17)

		_G["PartyMemberFrame"..i.."Background"]:SetPoint("TOPLEFT", 46, -3)
		_G["PartyMemberFrame"..i.."Background"]:SetSize(70, 24)
		_G["PartyMemberFrame"..i.."Background"]:SetPoint("TOPLEFT", 47, -3)

		_G["PartyMemberFrame"..i.."HealthBarTextLeft"]:SetPoint("LEFT", _G["PartyMemberFrame"..i.."HealthBar"], "LEFT", 4, 0)
		_G["PartyMemberFrame"..i.."HealthBarTextRight"]:SetPoint("RIGHT", _G["PartyMemberFrame"..i.."HealthBar"], "RIGHT", -2, 0)

		_G["PartyMemberFrame"..i.."NotPresentIcon"]:ClearAllPoints()
		_G["PartyMemberFrame"..i.."NotPresentIcon"]:SetPoint("TOP", _G["PartyMemberFrame"..i.."Portrait"], "BOTTOM", 12, 13)
		_G["PartyMemberFrame"..i.."NotPresentIcon"]:SetFrameLevel(4)
		_G["PartyMemberFrame"..i.."NotPresentIcon"]:SetScale(0.60)
	end
end

-- IDK WHAT I WANNA DO WITH THIS YET :D
PlayerFrameHealthBarTextLeft:ClearAllPoints()
PlayerFrameHealthBarTextLeft:SetPoint("LEFT", PlayerFrameHealthBar, "LEFT", 4, -3)

PlayerFrameHealthBarTextRight:ClearAllPoints()
PlayerFrameHealthBarTextRight:SetPoint("RIGHT", PlayerFrameHealthBar, "RIGHT", -2, -3)

TargetFrameTextureFrameHealthBarTextLeft:ClearAllPoints()
TargetFrameTextureFrameHealthBarTextLeft:SetPoint("LEFT", TargetFrameHealthBar, "LEFT", 1, -3)

TargetFrameTextureFrameHealthBarTextRight:ClearAllPoints()
TargetFrameTextureFrameHealthBarTextRight:SetPoint("RIGHT", TargetFrameHealthBar, "RIGHT", -2, -3)

-- UPDATE SETTINGS SPECIFIC TO PARTY MEMBER UNIT FRAMES WHEN IN VEHICLES
function EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt(self)
	for i = 1, 4 do
		_G["PartyMemberFrame"..i.."VehicleTexture"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\VehiclePartyFrame")
	end
end

function EnhancedFrames:OnEvent(event)
	if (event == "PLAYER_LOGIN") then
		if (CombatLock == false) then
			EnhancedFrames:Setup()
			startTimer = true
		end
	end

	if (event == "UNIT_EXITED_VEHICLE") then
		if (CombatLock == false) then
			local isInVehicle = UnitControllingVehicle("player")
			if (isInVehicle == false) then
				EnhancedFrames:Setup()
			end

			if (not UnitHasVehiclePlayerFrameUI("player")) then
				EnhancedFrames:Setup()
			end
		end
	end

	if (event == "PLAYER_REGEN_DISABLED") then
		CombatLock = true
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		CombatLock = false
	end
end

EnhancedFrames:RegisterEvent("PLAYER_LOGIN")
EnhancedFrames:RegisterEvent("UNIT_EXITED_VEHICLE")
EnhancedFrames:RegisterEvent("PLAYER_REGEN_DISABLED")
EnhancedFrames:RegisterEvent("PLAYER_REGEN_ENABLED")
EnhancedFrames:SetScript("OnEvent", EnhancedFrames.OnEvent)