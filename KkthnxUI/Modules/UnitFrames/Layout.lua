local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local unpack = unpack
local pairs = pairs
local select = select
local remove = table.remove
local IsAddOnLoaded = IsAddOnLoaded
local CreateFrame = CreateFrame
local UIParent = UIParent
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc
local UnitIsPlayer = UnitIsPlayer
local UnitPlayerControlled = UnitPlayerControlled
local UnitClass, GetUnitName = UnitClass, GetUnitName
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitIsEnemy = UnitIsEnemy
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsTapDenied = UnitIsTapDenied
local UnitReaction = UnitReaction
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsConnected = UnitIsConnected

local PlayerAnchor = CreateFrame("Frame", "PlayerFrameAnchor", UIParent)
PlayerAnchor:SetSize(146, 28)
PlayerAnchor:SetPoint(unpack(C.Position.UnitFrames.Player))

local TargetAnchor = CreateFrame("Frame", "TargetFrameAnchor", UIParent)
TargetAnchor:SetSize(146, 28)
TargetAnchor:SetPoint(unpack(C.Position.UnitFrames.Target))

local Unitframes = CreateFrame("Frame", "Unitframes", UIParent)

if C.Unitframe.Enable == true then
	Unitframes:RegisterEvent("ADDON_LOADED")
	Unitframes:SetScript("OnEvent", function(self, event, addon)
		if (addon ~= "KkthnxUI") then return end
		if(InCombatLockdown() == false) then
			if C.Unitframe.ClassHealth ~= true then

				CUSTOM_FACTION_BAR_COLORS = {
					[1] = {r = 255/255, g = 0/255, b = 0/255},
					[2] = {r = 255/255, g = 0/255, b = 0/255},
					[3] = {r = 255/255, g = 255/255, b = 0/255},
					[4] = {r = 255/255, g = 255/255, b = 0/255},
					[5] = {r = 0/255, g = 255/255, b = 0/255},
					[6] = {r = 0/255, g = 255/255, b = 0/255},
					[7] = {r = 0/255, g = 255/255, b = 0/255},
					[8] = {r = 0/255, g = 255/255, b = 0/255},
				}

				hooksecurefunc("UnitFrame_Update", function(self, isParty)
					if not self.name or not self:IsShown() then return end

					local PET_COLOR = { r = 157/255, g = 197/255, b = 255/255 }
					local unit, color = self.unit
					if UnitPlayerControlled(unit) then
						if UnitIsPlayer(unit) then
							color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
						else
							color = PET_COLOR
						end
					elseif UnitIsDeadOrGhost(unit) then
						color = GRAY_FONT_COLOR
					else
						color = CUSTOM_FACTION_BAR_COLORS[UnitIsEnemy(unit, "player") and 1 or UnitReaction(unit, "player") or 5]
					end

					if not color then
						color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)["PRIEST"]
					end

					self.name:SetTextColor(color.r, color.g, color.b)
					if isParty then
						self.name:SetText(GetUnitName(self.overrideName or unit))
					end
				end)
			end

			-- HIDE PET NAME
			PetName:Hide()

			-- UNIT NAME
			for _, FrameNames in pairs({
				PlayerName,
				TargetFrameTextureFrameName,
				FocusFrameTextureFrameName,
			}) do
				if C.Unitframe.Outline then
					FrameNames:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
					FrameNames:SetShadowOffset(0, -0)
				else
					FrameNames:SetFont(C.Media.Font, C.Media.Font_Size)
					FrameNames:SetShadowOffset(K.Mult, -K.Mult)
				end
			end

			-- UNIT HEALTHBARTEXT
			for _, FrameBarText in pairs({
				PlayerFrameHealthBarText,
				PlayerFrameManaBarText,
				TargetFrameTextureFrameHealthBarText,
				TargetFrameTextureFrameManaBarText,
				FocusFrameTextureFrameHealthBarText,
				FocusFrameTextureFrameManaBarText,
				PetFrameHealthBarText,
				PetFrameManaBarText,
			}) do
				if C.Unitframe.Outline then
					FrameBarText:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
					FrameBarText:SetShadowOffset(0, -0)
				else
					FrameBarText:SetFont(C.Media.Font, C.Media.Font_Size)
					FrameBarText:SetShadowOffset(K.Mult, -K.Mult)
				end
			end

			-- PARTY UNIT HEALTHBARTEXT
			for _, PartyBarText in pairs({
				PartyMemberFrame1HealthBarText,
				PartyMemberFrame1ManaBarText,
				PartyMemberFrame2HealthBarText,
				PartyMemberFrame2ManaBarText,
				PartyMemberFrame3HealthBarText,
				PartyMemberFrame3ManaBarText,
				PartyMemberFrame4HealthBarText,
				PartyMemberFrame4ManaBarText,
			}) do
				if C.Unitframe.Outline then
					PartyBarText:SetFont(C.Media.Font, C.Media.Font_Size - 3, C.Media.Font_Style)
					PartyBarText:SetShadowOffset(0, -0)
				else
					PartyBarText:SetFont(C.Media.Font, C.Media.Font_Size - 3)
					PartyBarText:SetShadowOffset(K.Mult, -K.Mult)
				end
			end

			-- UNIT LEVELTEXT
			for _, LevelText in pairs({
				PlayerLevelText,
				TargetFrameTextureFrameLevelText,
				FocusFrameTextureFrameLevelText,
			}) do
				if C.Unitframe.Outline then
					LevelText:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
					LevelText:SetShadowOffset(0, -0)
				else
					LevelText:SetFont(C.Media.Font, C.Media.Font_Size)
					LevelText:SetShadowOffset(K.Mult, -K.Mult)
				end
			end

			-- PlayerFrame
			hooksecurefunc("PlayerFrame_UpdateLevelTextAnchor", function(level)
				if ( level >= 100 ) then
					PlayerLevelText:SetPoint("CENTER", PlayerFrameTexture, "CENTER", -63, -17)
				else
					PlayerLevelText:SetPoint("CENTER", PlayerFrameTexture, "CENTER", -63, -17)
				end
			end)

			-- TARGETFRAME
			hooksecurefunc("TargetFrame_UpdateLevelTextAnchor", function(self, targetLevel)
				if ( targetLevel >= 100 ) then
					self.levelText:SetPoint("CENTER", 63, -17)
				else
					self.levelText:SetPoint("CENTER", 63, -17)
				end
			end)

			-- TWEAK PARTY FRAME
			for i = 1, MAX_PARTY_MEMBERS do
				_G["PartyMemberFrame"..i]:SetScale(C.Unitframe.Scale)
			end
			PartyMemberBuffTooltip:Kill() -- I PERSONALLY HATE THIS SHIT.

			-- TWEAK PLAYER FRAME
			PlayerFrame:SetMovable(true)
			PlayerFrame:ClearAllPoints()
			if not PlayerFrame:IsUserPlaced() then
				PlayerFrame:SetPoint("CENTER", PlayerFrameAnchor, "CENTER", -51, 3)
			end
			PlayerFrame:SetUserPlaced(true)
			PlayerFrame:SetMovable(false)
			PlayerFrame.SetPoint = K.Noop

			-- TWEAK TARGET FRAME
			TargetFrame:SetMovable(true)
			TargetFrame:ClearAllPoints()
			if not TargetFrame:IsUserPlaced() then
				TargetFrame:SetPoint("CENTER", TargetFrameAnchor, "CENTER", 51, 3)
			end
			TargetFrame:SetUserPlaced(true)
			TargetFrame:SetMovable(false)
			TargetFrame.SetPoint = K.Noop

			-- TWEAK NAME BACKGROUND
			TargetFrameNameBackground:SetColorTexture(0/255, 0/255, 0/255, 0.5)
			TargetFrameNameBackground:SetHeight(18)

			-- TWEAK FOCUS FRAME
			FocusFrame:SetMovable(true)
			FocusFrame:ClearAllPoints()
			FocusFrame:SetPoint(unpack(C.Position.UnitFrames.Focus))
			FocusFrame:SetUserPlaced(true)
			FocusFrame:SetMovable(false)
			-- TWEAK NAME BACKGROUND
			FocusFrameNameBackground:SetColorTexture(0/255, 0/255, 0/255, 0.5)
			FocusFrameNameBackground:SetHeight(18)

			for _, FrameScale in pairs({
				PlayerFrame,
				TargetFrame,
				FocusFrame,
			}) do
				FrameScale:SetScale(C.Unitframe.Scale)
			end

			-- BOSS FRAMES
			for i = 1, 5 do
				_G["Boss"..i.."TargetFrame"]:SetParent(UIParent)
				_G["Boss"..i.."TargetFrame"]:SetScale(0.95)
				_G["Boss"..i.."TargetFrame"]:SetFrameStrata("BACKGROUND")
			end
			for i = 2, 5 do
				_G["Boss"..i.."TargetFrame"]:SetPoint("TOPLEFT", _G["Boss"..(i-1).."TargetFrame"], "BOTTOMLEFT", 0, 15)
			end

			-- COMBOFRAME
			if K.Class == "ROGUE" or K.Class == "DRUID" then
				for i = 1, 5 do
					_G["ComboPoint"..i]:SetScale(C.Unitframe.Scale)
				end

				if C.Unitframe.ComboFrame == true then
					ComboFrame:UnregisterAllEvents()
					ComboFrame.Show = K.Dummy
					ComboFrame:Hide()
				end
			end

			self:UnregisterEvent("ADDON_LOADED")
		end
	end)
end

-- CLASS ICONS
if(InCombatLockdown() == false) then
	if C.Unitframe.ClassIcon == true then
		hooksecurefunc("UnitFramePortrait_Update", function(self)
			if self.portrait then
				if UnitIsPlayer(self.unit) then
					local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
					if t then
						self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
						self.portrait:SetTexCoord(unpack(t))
					end
				else
					self.portrait:SetTexCoord(0, 1, 0, 1)
				end
			end
		end)
	end

	-- CLASS COLOR BARS
	if C.Unitframe.ClassHealth == true then
		local function colorHealthBar(statusbar, unit)
			local _, class, color
			if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
				_, class = UnitClass(unit)
				color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				statusbar:SetStatusBarColor(color.r, color.g, color.b)
			end
		end

		hooksecurefunc("UnitFrameHealthBar_Update", colorHealthBar)
		hooksecurefunc("HealthBar_OnValueChanged", function(self)
			colorHealthBar(self, self.unit)
		end)
	end
end

-- REMOVE PORTRAIT DAMAGE SPAM
if C.Unitframe.CombatFeedback == true then
	PlayerHitIndicator:SetText(nil)
	PlayerHitIndicator.SetText = K.Noop
end

-- REMOVE GROUP NUMBER FRAME
if C.Unitframe.GroupNumber == true then
	PlayerFrameGroupIndicator.Show = K.Noop
end

-- REMOVE PVPICONS
if C.Unitframe.PvPIcon == true then
	PlayerPVPIcon:Kill()
	TargetFrameTextureFramePVPIcon:Kill()
	FocusFrameTextureFramePVPIcon:Kill()
	for i = 1, MAX_PARTY_MEMBERS do
		_G["PartyMemberFrame"..i.."PVPIcon"]:Kill()
	end
end

-- STOP RED FLASH RESTING
for _, Textures in ipairs({
	"PlayerAttackGlow",
	"PetAttackModeTexture",
	"PlayerRestGlow",
	"PlayerStatusGlow",
	"PlayerStatusTexture",
	"PlayerAttackBackground"

}) do
	hooksecurefunc("PlayerFrame_UpdateStatus", function()
		if IsResting("player") then
			local Texture = _G[Textures]
			if Texture then
				Texture:Kill()
				Texture.Show = K.Noop
			end
		end
	end)
end

-- JUST BECAUSE I CAN
for _, menu in pairs(UnitPopupMenus) do
	for index = #menu, 1, -1 do
		if menu[index] == "MOVE_PLAYER_FRAME" or menu[index] == "MOVE_TARGET_FRAME" or menu[index] == "MOVE_FOCUS_FRAME" then
			remove(menu, index)
		end
	end
end