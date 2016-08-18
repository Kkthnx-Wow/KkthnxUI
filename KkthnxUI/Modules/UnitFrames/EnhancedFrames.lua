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
local EnhancedFrames = CreateFrame("Frame")
local EnhancedPartyFrames = CreateFrame("Frame")

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

-- Event listener to make sure we enable the addon at the right time
function EnhancedFrames:PLAYER_ENTERING_WORLD()

	EnableEnhancedFrames()
	--EnableEnhancedPartyFrames()
end

function EnableEnhancedFrames()
	-- GENERIC STATUS TEXT HOOK
	hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", EnhancedFrames_UpdateTextStringWithValues)

	-- HOOK PLAYERFRAME FUNCTIONS
	hooksecurefunc("PlayerFrame_ToPlayerArt", EnhancedFrames_PlayerFrame_ToPlayerArt)
	hooksecurefunc("PlayerFrame_ToVehicleArt", EnhancedFrames_PlayerFrame_ToVehicleArt)

	-- HOOK TARGETFRAME FUNCTIONS
	hooksecurefunc("TargetFrame_CheckDead", EnhancedFrames_TargetFrame_Update)
	hooksecurefunc("TargetFrame_Update", EnhancedFrames_TargetFrame_Update)
	hooksecurefunc("TargetFrame_CheckFaction", EnhancedFrames_TargetFrame_CheckFaction)
	hooksecurefunc("TargetFrame_CheckClassification", EnhancedFrames_Target_Classification)
	hooksecurefunc("TargetofTarget_Update", EnhancedFrames_TargetFrame_Update)

	-- BOSSFRAME HOOKS
	hooksecurefunc("BossTargetFrame_OnLoad", EnhancedFrames_BossTargetFrame_Style)
	
	hooksecurefunc("PartyMemberFrame_ToPlayerArt", EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt)
	hooksecurefunc("PartyMemberFrame_ToVehicleArt", EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt)

	-- SET UP SOME STYLINGS
	EnhancedFrames_Style_PlayerFrame()
	EnhancedFrames_BossTargetFrame_Style(Boss1TargetFrame)
	EnhancedFrames_BossTargetFrame_Style(Boss2TargetFrame)
	EnhancedFrames_BossTargetFrame_Style(Boss3TargetFrame)
	EnhancedFrames_BossTargetFrame_Style(Boss4TargetFrame)
	EnhancedFrames_Style_TargetFrame(TargetFrame)
	EnhancedFrames_Style_TargetFrame(FocusFrame)

	-- UPDATE SOME VALUES
	TextStatusBar_UpdateTextString(PlayerFrame.healthbar)
	TextStatusBar_UpdateTextString(PlayerFrame.manabar)
end

function EnhancedFrames_Style_PlayerFrame()
	if not InCombatLockdown() then
		PlayerName:SetWidth(0.01)

		PlayerFrameHealthBar.capNumericDisplay = true
		PlayerFrameHealthBar:SetSize(119, 29)
		PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -22)
		PlayerFrameHealthBarText:SetPoint("CENTER", 50, 12)
	end

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
		self.name:SetPoint("TOPLEFT", 16, -10)

		self.healthbar:SetHeight(29)
		self.healthbar:SetPoint("TOPLEFT", 7, -22)
		self.healthbar.TextString:SetPoint("CENTER", -50, 12)
		self.deadText:SetPoint("CENTER", -50, 12)
		self.nameBackground:Hide()
		self.Background:SetPoint("TOPLEFT", 7, -22)
	end

	self.healthbar:SetWidth(119)
end

function EnhancedFrames_BossTargetFrame_Style(self)
	self.borderTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\UI-UnitFrame-Boss")

	EnhancedFrames_Style_TargetFrame(self)
end

function EnhancedFrames_UpdateTextStringWithValues(statusFrame, textString, value, valueMin, valueMax)
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
end

function EnhancedFrames_PlayerFrame_ToPlayerArt(self)
	if not InCombatLockdown() then
		EnhancedFrames_Style_PlayerFrame()
	end
end

function EnhancedFrames_PlayerFrame_ToVehicleArt(self)
	if not InCombatLockdown() then
		PlayerFrameHealthBar:SetHeight(12)
		PlayerFrameHealthBarText:SetPoint("CENTER", 50, 3)
	end
end

function EnhancedFrames_TargetFrame_Update(self)
	-- Set back color of health bar
	if (not UnitPlayerControlled(self.unit) and UnitIsTapDenied(self.unit)) then
		-- Gray if npc is tapped by other player
		self.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
	end
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

-- STYLE - PARTY MEMEBER FRAME STYLE CHANGES
function EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt(self)
	if not InCombatLockdown() then
		for i = 1, MAX_PARTY_MEMBERS do
			_G["PartyMemberFrame"..i.."HealthBarText"]:SetPoint("CENTER", _G["PartyMemberFrame"..i.."HealthBar"], "CENTER", 0, 1)

			_G["PartyMemberFrame"..i.."Name"]:SetPoint("TOP", 0, 20)
			_G["PartyMemberFrame"..i.."Name"]:SetFont(C.Media.Font, 10)

			_G["PartyMemberFrame"..i.."Texture"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\PartyFrame")
			_G["PartyMemberFrame"..i.."Texture"]:SetPoint("TOPLEFT", 0, 6)

			_G["PartyMemberFrame"..i.."Flash"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\PartyFrameFlash")
			_G["PartyMemberFrame"..i.."Flash"]:SetPoint("TOPLEFT", 0, 6)

			_G["PartyMemberFrame"..i.."HealthBar"]:SetPoint("TOPLEFT", 47, -3)
			_G["PartyMemberFrame"..i.."HealthBar"]:SetHeight(17)

			_G["PartyMemberFrame"..i.."Background"]:SetPoint("TOPLEFT", 46, -3)
			_G["PartyMemberFrame"..i.."Background"]:SetSize(70, 24)
			_G["PartyMemberFrame"..i.."Background"]:SetPoint("TOPLEFT", 47, -3)
		end
	end
end

-- UPDATE SETTINGS SPECIFIC TO PARTY MEMBER UNIT FRAMES WHEN IN VEHICLES
function EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt(self)
	if not InCombatLockdown() then
		PartyMemberFrame1VehicleTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\VehiclePartyFrame")
		PartyMemberFrame2VehicleTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\VehiclePartyFrame")
		PartyMemberFrame3VehicleTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\VehiclePartyFrame")
		PartyMemberFrame4VehicleTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\VehiclePartyFrame")
	end
end

-- BOOTSTRAP
function EnhancedFrames_StartUp(self)
	self:SetScript("OnEvent", function(self, event) self[event](self) end)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

EnhancedFrames_StartUp(EnhancedFrames)
--EnhancedPartyFrames_StartUp(EnhancedPartyFrames)

--[[
----------------------------------------------------------------------
-- HERE TO START OUR PARTYFRAMES. WE SHOULD MERGE ALL THIS CODE LATER.
----------------------------------------------------------------------

-- EVENT LISTENER TO MAKE SURE WE ENABLE THE ADDON AT THE RIGHT TIME
function EnhancedPartyFrames:PLAYER_ENTERING_WORLD()
	EnableEnhancedPartyFrames()
end

-- HOOKING GAME FUNCTIONS AND SETTING THEM TO FIRE ADDON FUNCTION
function EnableEnhancedPartyFrames()
	hooksecurefunc("PartyMemberFrame_ToPlayerArt", EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt)
	hooksecurefunc("PartyMemberFrame_ToVehicleArt", EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt)
end

-- STYLE - PARTY MEMEBER FRAME STYLE CHANGES
function EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt(self)
	if not InCombatLockdown() then
		for i = 1, MAX_PARTY_MEMBERS do
			_G["PartyMemberFrame"..i.."HealthBarText"]:SetPoint("CENTER", _G["PartyMemberFrame"..i.."HealthBar"], "CENTER", 0, 1)

			_G["PartyMemberFrame"..i.."Name"]:SetPoint("TOP", 0, 20)
			_G["PartyMemberFrame"..i.."Name"]:SetFont(C.Media.Font, 10)

			_G["PartyMemberFrame"..i.."Texture"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\PartyFrame")
			_G["PartyMemberFrame"..i.."Texture"]:SetPoint("TOPLEFT", 0, 6)

			_G["PartyMemberFrame"..i.."Flash"]:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\PartyFrameFlash")
			_G["PartyMemberFrame"..i.."Flash"]:SetPoint("TOPLEFT", 0, 6)

			_G["PartyMemberFrame"..i.."HealthBar"]:SetPoint("TOPLEFT", 47, -3)
			_G["PartyMemberFrame"..i.."HealthBar"]:SetHeight(17)

			_G["PartyMemberFrame"..i.."Background"]:SetPoint("TOPLEFT", 46, -3)
			_G["PartyMemberFrame"..i.."Background"]:SetSize(70, 24)
			_G["PartyMemberFrame"..i.."Background"]:SetPoint("TOPLEFT", 47, -3)
		end
	end
end

-- UPDATE SETTINGS SPECIFIC TO PARTY MEMBER UNIT FRAMES WHEN IN VEHICLES
function EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt(self)
	if not InCombatLockdown() then
		PartyMemberFrame1VehicleTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\VehiclePartyFrame")
		PartyMemberFrame2VehicleTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\VehiclePartyFrame")
		PartyMemberFrame3VehicleTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\VehiclePartyFrame")
		PartyMemberFrame4VehicleTexture:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Unitframes\\VehiclePartyFrame")
	end
end

-- BOOTSTRAP
function EnhancedPartyFrames_StartUp(self)
	self:SetScript("OnEvent", function(self, event) self[event](self) end)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

EnhancedPartyFrames_StartUp(EnhancedPartyFrames)
]]--