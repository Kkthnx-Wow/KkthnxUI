local K, C, L, _ = select(2, ...):unpack()

-- LUA WOW
local _G = _G
local unpack = unpack
local pairs = pairs
local select = select
local remove = table.remove

-- WOW API
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
local UnitReaction = UnitReaction
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsConnected = UnitIsConnected

local PetColor = {157/255, 197/255, 255/255}

if C.Unitframe.Enable == true then
	local PlayerAnchor = CreateFrame("Frame", "PlayerFrameAnchor", UIParent)
	PlayerAnchor:SetSize(146, 28)
	PlayerAnchor:SetPoint(unpack(C.Position.UnitFrames.Player))

	local TargetAnchor = CreateFrame("Frame", "TargetFrameAnchor", UIParent)
	TargetAnchor:SetSize(146, 28)
	TargetAnchor:SetPoint(unpack(C.Position.UnitFrames.Target))

	local Unitframes = CreateFrame("Frame", "Unitframes", UIParent)

	Unitframes:RegisterEvent("ADDON_LOADED")
	Unitframes:SetScript("OnEvent", function(self, event, addon)
		if (addon ~= "KkthnxUI") or (InCombatLockdown()) then return end

		if C.Unitframe.ClassHealth ~= true then
			hooksecurefunc("UnitFrame_Update", function(self, isParty)
				if (not self.name or not self:IsShown()) then return end

				local unit, color = self.unit
				if UnitPlayerControlled(unit) then
					if UnitIsPlayer(unit) then
						local Class = select(2, UnitClass(unit))
						color = BETTER_RAID_CLASS_COLORS[Class]
					else
						color = PetColor
					end
				elseif UnitIsDeadOrGhost(unit) then
					color = GRAY_FONT_COLOR
				else
					color = BETTER_REACTION_COLORS[UnitIsEnemy(unit, "player") and 1 or UnitReaction(unit, "player") or 5]
				end

				if not color then
					color = (CUSTOM_CLASS_COLORS or BETTER_RAID_CLASS_COLORS)["PRIEST"]
				end

				self.name:SetTextColor(color[1], color[2], color[3])
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
			PlayerFrameHealthBarTextLeft,
			PlayerFrameHealthBarTextRight,
			TargetFrameTextureFrameHealthBarTextLeft,
			TargetFrameTextureFrameHealthBarTextRight,
			PlayerFrameManaBarTextLeft,
			PlayerFrameManaBarTextRight,
			TargetFrameTextureFrameManaBarTextLeft,
			TargetFrameTextureFrameManaBarTextRight,
			PartyMemberFrame1HealthBarTextRight,
			PartyMemberFrame1HealthBarTextLeft,
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


		for i = 1, MAX_PARTY_MEMBERS do
			if not InCombatLockdown() then
				if C.Unitframe.Outline then
					_G["PartyMemberFrame"..i.."Name"]:SetFont(C.Media.Font, C.Media.Font_Size - 2, C.Media.Font_Style)
					_G["PartyMemberFrame"..i.."Name"]:SetShadowOffset(0, -0)

					_G["PartyMemberFrame"..i.."HealthBarText"]:SetFont(C.Media.Font, C.Media.Font_Size - 3, C.Media.Font_Style)
					_G["PartyMemberFrame"..i.."HealthBarText"]:SetShadowOffset(0, -0)

					_G["PartyMemberFrame"..i.."HealthBarTextLeft"]:SetFont(C.Media.Font, C.Media.Font_Size - 3, C.Media.Font_Style)
					_G["PartyMemberFrame"..i.."HealthBarTextLeft"]:SetShadowOffset(0, -0)

					_G["PartyMemberFrame"..i.."HealthBarTextRight"]:SetFont(C.Media.Font, C.Media.Font_Size - 3, C.Media.Font_Style)
					_G["PartyMemberFrame"..i.."HealthBarTextRight"]:SetShadowOffset(0, -0)

					_G["PartyMemberFrame"..i.."ManaBarTextLeft"]:SetFont(C.Media.Font, C.Media.Font_Size - 3, C.Media.Font_Style)
					_G["PartyMemberFrame"..i.."ManaBarTextLeft"]:SetShadowOffset(0, -0)

					_G["PartyMemberFrame"..i.."ManaBarTextRight"]:SetFont(C.Media.Font, C.Media.Font_Size - 3, C.Media.Font_Style)
					_G["PartyMemberFrame"..i.."ManaBarTextRight"]:SetShadowOffset(0, -0)

					_G["PartyMemberFrame"..i.."ManaBarText"]:SetFont(C.Media.Font, C.Media.Font_Size - 3, C.Media.Font_Style)
					_G["PartyMemberFrame"..i.."ManaBarText"]:SetShadowOffset(0, -0)
				else
					_G["PartyMemberFrame"..i.."Name"]:SetFont(C.Media.Font, C.Media.Font_Size - 2)
					_G["PartyMemberFrame"..i.."Name"]:SetShadowOffset(K.Mult, -K.Mult)

					_G["PartyMemberFrame"..i.."HealthBarText"]:SetFont(C.Media.Font, C.Media.Font_Size - 3)
					_G["PartyMemberFrame"..i.."HealthBarText"]:SetShadowOffset(K.Mult, -K.Mult)

					_G["PartyMemberFrame"..i.."HealthBarTextLeft"]:SetFont(C.Media.Font, C.Media.Font_Size - 3)
					_G["PartyMemberFrame"..i.."HealthBarTextLeft"]:SetShadowOffset(K.Mult, -K.Mult)

					_G["PartyMemberFrame"..i.."HealthBarTextRight"]:SetFont(C.Media.Font, C.Media.Font_Size - 3)
					_G["PartyMemberFrame"..i.."HealthBarTextRight"]:SetShadowOffset(K.Mult, -K.Mult)

					_G["PartyMemberFrame"..i.."ManaBarTextLeft"]:SetFont(C.Media.Font, C.Media.Font_Size - 3)
					_G["PartyMemberFrame"..i.."ManaBarTextLeft"]:SetShadowOffset(K.Mult, -K.Mult)

					_G["PartyMemberFrame"..i.."ManaBarTextRight"]:SetFont(C.Media.Font, C.Media.Font_Size - 3)
					_G["PartyMemberFrame"..i.."ManaBarTextRight"]:SetShadowOffset(K.Mult, -K.Mult)

					_G["PartyMemberFrame"..i.."ManaBarText"]:SetFont(C.Media.Font, C.Media.Font_Size - 3)
					_G["PartyMemberFrame"..i.."ManaBarText"]:SetShadowOffset(K.Mult, -K.Mult)
				end
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
			if not InCombatLockdown() then
				_G["PartyMemberFrame"..i]:SetScale(C.Unitframe.Scale)
			end
		end

		-- TWEAK PLAYER FRAME
		if (not InCombatLockdown() and not UnitHasVehicleUI("player")) then
			K.ModifyFrame(PlayerFrame, "CENTER", PlayerFrameAnchor, -51, 3, C.Unitframe.Scale)
		end

		-- TWEAK TARGET FRAME
		if (not InCombatLockdown()) then
			K.ModifyFrame(TargetFrame, "CENTER", TargetFrameAnchor, 51, 3, C.Unitframe.Scale)

			-- TWEAK NAME BACKGROUND
			TargetFrameNameBackground:SetColorTexture(0/255, 0/255, 0/255, 0.5)

			-- TWEAK FOCUS FRAME
			K.ModifyFrame(FocusFrame, "TOP", PlayerFrame, 0, 200, C.Unitframe.Scale)

			-- TWEAK NAME BACKGROUND
			FocusFrameNameBackground:SetColorTexture(0/255, 0/255, 0/255, 0.5)
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
			--[[ ARENA FRAMES -- This taints the shit out of the UI.
			if (IsAddOnLoaded("Blizzard_ArenaUI")) then
				for i = 1, 5 do
					_G["ArenaPrepFrame"..i]:SetScale(C.Unitframe.Scale)
				end
				ArenaEnemyFrames:SetParent(UIParent)
				ArenaEnemyFrames:SetScale(C.Unitframe.Scale)
				K.ModifyBasicFrame(ArenaEnemyFrames, unpack(C.Position.UnitFrames.Arena), C.Unitframe.Scale)
			end
			]]--
		end

		self:UnregisterEvent("ADDON_LOADED")
	end)
end

-- CLASS ICONS
if C.Unitframe.ClassIcon then
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
if C.Unitframe.ClassHealth then
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

-- HIDE CLASS RESOURCES OPTION
-- WE ADD THIS SINCE WE CAN ALREADY PROVIDE THIS SINCE 7.0.3 PREPATCH
if C.Unitframe.ClassResources == true then
	for _, ClassResources in pairs({
		WarlockPowerFrame,
		PaladinPowerBarFrame,
		ComboPointPlayerFrame,
		RuneFrame,
	}) do
		ClassResources:UnregisterAllEvents()
		ClassResources.Show = K.Noop
		ClassResources:Hide()
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
		if not InCombatLockdown() then
			_G["PartyMemberFrame"..i.."PVPIcon"]:Kill()
		end
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
		if (not InCombatLockdown() and IsResting("player")) then
			local Texture = _G[Textures]
			if Texture then
				Texture:Kill()
				Texture.Show = K.Noop
			end
		end
	end)
end

-- JUST BECAUSE I CAN
if C.Misc.Armory == true then return end
for _, menu in pairs(UnitPopupMenus) do
	for index = #menu, 1, -1 do
		if menu[index] == "MOVE_PLAYER_FRAME" or menu[index] == "MOVE_TARGET_FRAME" or menu[index] == "MOVE_FOCUS_FRAME" then
			remove(menu, index)
		end
	end
end