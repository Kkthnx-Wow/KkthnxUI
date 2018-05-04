local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Unitframe_Functions", "AceEvent-3.0")
if C["Unitframe"].Enable ~= true and C["Raidframe"].Enable ~= true then
	return
end

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping oUF Functions.lua code!")
	return
end

-- Lua API
local _G = _G
local pairs = pairs
local table_insert = table.insert
local select = select
local ipairs = ipairs
local unpack = unpack

-- Wow API
local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CreateFrame = _G.CreateFrame
local DEAD = _G.DEAD
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local PlaySound = _G.PlaySound
local PlaySoundKitID = _G.PlaySoundKitID
local SOUNDKIT = _G.SOUNDKIT
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitHealth = _G.UnitHealth
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UIParent = _G.UIParent

local colors = K["Colors"]

-- AuraWatch
local RaidBuffsPosition = {
	BOTTOM = {0, 0},
	BOTTOMLEFT = {6, 1},
	BOTTOMRIGHT = {-6, 1},
	LEFT = {6, 1},
	RIGHT = {-6, 1},
	TOP = {0, 0},
	TOPLEFT = {6, 1},
	TOPRIGHT = {-6, 1},
}

function K.UpdateClassPortraits(self, unit)
	local _, unitClass = UnitClass(unit)
	if (unitClass and UnitIsPlayer(unit)) and C["Unitframe"].PortraitStyle.Value == "ClassPortraits" then
		self:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
		self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
	elseif (unitClass and UnitIsPlayer(unit)) and C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
		self:SetTexture(C["Media"].NewClassPortraits)
		self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
	else
		self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	end
end

local function UpdatePortraitColor(self, unit, min, max)
	if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
		return
	end

	if (not UnitIsConnected(unit)) then
		self.Portrait:SetVertexColor(0.5, 0.5, 0.5, 0.7)
	elseif (UnitIsDead(unit)) then
		self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 0.7)
	elseif (UnitIsGhost(unit)) then
		self.Portrait:SetVertexColor(0.3, 0.3, 0.9, 0.7)
	elseif (max == 0 or min / max * 100 < 25) then
		if (UnitIsPlayer(unit)) then
			if (unit ~= "player") then
				self.Portrait:SetVertexColor(1, 0, 0, 0.7)
			end
		end
	else
		self.Portrait:SetVertexColor(1, 1, 1, 1)
	end
end

-- PostUpdateHealth
function K.PostUpdateHealth(self, unit, cur, max)
	if self.__owner.Portrait and C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" then
		UpdatePortraitColor(self.__owner, unit, cur, max)
	end
end

function K.CreateAuraWatchIcon(icon)
	if icon.icon and not icon.hideIcon then
		icon:SetBackdrop(K.TwoPixelBorder)
		icon.icon:SetPoint("TOPLEFT", icon, 1, -1)
		icon.icon:SetPoint("BOTTOMRIGHT", icon, -1, 1)
		icon.icon:SetTexCoord(.08, .92, .08, .92)
		icon.icon:SetDrawLayer("ARTWORK")

		if (icon.cd) then
			icon.cd:SetHideCountdownNumbers(true)
			icon.cd:SetReverse(true)
		end

		if icon.overlay then
			icon.overlay:SetTexture()
		end
	end
end

function K.CreateAuraWatch(self)
	local auras = CreateFrame("Frame", nil, self)
	auras:SetPoint("TOPLEFT", self.Health, 2, -2)
	auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.icons = {}
	auras.PostCreateIcon = K.CreateAuraWatchIcon
	auras.strictMatching = true

	local buffs = {}

	if K.RaidBuffs["ALL"] then
		for key, value in pairs(K.RaidBuffs["ALL"]) do
			table_insert(buffs, value)
		end
	end

	if K.RaidBuffs[K.Class] then
		for key, value in pairs(K.RaidBuffs[K.Class]) do
			table_insert(buffs, value)
		end
	end

	if buffs then
		for key, spell in pairs(buffs) do
			local icon = CreateFrame("Frame", nil, auras)
			icon.spellID = spell[1]
			icon.anyUnit = spell[4]
			icon:SetWidth(C["Raidframe"].AuraWatchIconSize)
			icon:SetHeight(C["Raidframe"].AuraWatchIconSize)
			icon:SetPoint(spell[2], 0, 0)

			local tex = icon:CreateTexture(nil, "OVERLAY")
			tex:SetAllPoints(icon)
			tex:SetTexture(C["Media"].Blank)
			if spell[3] then
				tex:SetVertexColor(unpack(spell[3]))
			else
				tex:SetVertexColor(0.8, 0.8, 0.8)
			end

			local count = icon:CreateFontString(nil, "OVERLAY")
			count:SetFont(C["Media"].Font, 8, "THINOUTLINE")
			count:SetPoint("CENTER", unpack(RaidBuffsPosition[spell[2]]))
			icon.count = count

			auras.icons[spell[1]] = icon
		end
	end

	self.AuraWatch = auras
end

function K.CreateArenaPrep()
	if (C["Unitframe"].ShowArena) then
		local arenaprep = {}
		for i = 1, 5 do
			arenaprep[i] = CreateFrame("Frame", "oUF_ArenaPrep"..i, UIParent)
			arenaprep[i]:SetAllPoints(_G["oUF_Arena"..i])
			arenaprep[i]:SetFrameStrata("BACKGROUND")

			arenaprep[i].Health = CreateFrame("StatusBar", nil, arenaprep[i])
			arenaprep[i].Health:SetAllPoints()
			arenaprep[i].Health:SetStatusBarTexture(C["Media"].Texture)
			arenaprep[i].Health:SetTemplate("Transparent", true)

			arenaprep[i].Spec = K.SetFontString(arenaprep[i].Health, C["Media"].Font, 14, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
			arenaprep[i].Spec:SetPoint("CENTER")
			arenaprep[i]:Hide()
		end

		local arenaprepupdate = CreateFrame("Frame")
		arenaprepupdate:RegisterEvent("PLAYER_LOGIN")
		arenaprepupdate:RegisterEvent("PLAYER_ENTERING_WORLD")
		arenaprepupdate:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
		arenaprepupdate:RegisterEvent("ARENA_OPPONENT_UPDATE")
		arenaprepupdate:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_LOGIN" then
				for i = 1, 5 do
					arenaprep[i]:SetAllPoints(_G["oUF_ArenaFrame"..i])
				end
			elseif event == "ARENA_OPPONENT_UPDATE" then
				for i = 1, 5 do
					arenaprep[i]:Hide()
				end
			else
				local numOpps = GetNumArenaOpponentSpecs()
				if numOpps > 0 then
					for i = 1, 5 do
						local f = arenaprep[i]

						if i <= numOpps then
							local s = GetArenaOpponentSpec(i)
							local _, spec, class = nil, "UNKNOWN", "UNKNOWN"

							if s and s > 0 then
								_, spec, _, _, _, class = GetSpecializationInfoByID(s)
							end

							if class and spec then
								local color = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)[class]
								if color then
									f.Health:SetStatusBarColor(color.r, color.g, color.b)
								else
									f.Health:SetStatusBarColor(0.4, 0.4, 0.4)
								end
								f.Spec:SetText(spec)
								f:Show()
							end
						else
							f:Hide()
						end
					end
				else
					for i = 1, 5 do
						arenaprep[i]:Hide()
					end
				end
			end
		end)
	end
end

local function CreateTargetSound(unit)
	if UnitExists(unit) then
		if UnitIsEnemy(unit, "player") then
			PlaySound(PlaySoundKitID and "Igcreatureaggroselect" or SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
		elseif UnitIsFriend("player", unit) then
			PlaySound(PlaySoundKitID and "Igcharacternpcselect" or SOUNDKIT.IG_CHARACTER_NPC_SELECT)
		else
			PlaySound(PlaySoundKitID and "Igcreatureneutralselect" or SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
		end
	else
		PlaySound(PlaySoundKitID and "igcreatureaggrodeselect" or SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

function Module:PLAYER_FOCUS_CHANGED(event)
	CreateTargetSound("focus")
end

function Module:PLAYER_TARGET_CHANGED(event)
	CreateTargetSound("target")
end

local announcedPVP
function Module:UNIT_FACTION(event, unit)
	if (unit ~= "player") then
		return
	end

	if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
		if not announcedPVP then
			announcedPVP = true
			PlaySound(PlaySoundKitID and "IgPVPUpdate" or SOUNDKIT.IG_PVP_UPDATE)
		end
	else
		announcedPVP = nil
	end
end

function Module:OnEnable()
	if C["Unitframe"].Enable ~= true then
		return
	end

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("UNIT_FACTION")
end