local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

-- Lua Wow
local _G = _G
local table_insert = table.insert
local tostring = tostring
local unpack = unpack

-- Wow API
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs
local GetSpecializationInfoByID = GetSpecializationInfoByID
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitIsUnit = UnitIsUnit

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SetPortraitToTexture, ARENA, SetPortraitTexture, CreateFrame

local _, ns = ...
local oUF = ns.oUF or oUF

local textPath = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\"

local function arenaPrep(self, event, ...)
	if event ~= "ArenaPreparation" then return end

	local specID = GetArenaOpponentSpec(self.id)
	local _, spec, _, icon, _, _, class = GetSpecializationInfoByID(specID)

	SetPortraitToTexture(self.Portrait, icon)
	self.Portrait:SetVertexColor(1, 1, 1, 1)

	self.Name:SetText(ARENA .. " " .. tostring(self.id))

	self.Health.Value:SetText(spec)
	self.Health:SetMinMaxValues(0, 1)
	self.Health:SetValue(1)
	self.Health:SetStatusBarColor(unpack(self.colors.class[class]))
end

local function updatePortrait(self, event, unit)
	local specID = GetArenaOpponentSpec(self.id)
	if specID then
		local _, _, _, icon = GetSpecializationInfoByID(specID)
		SetPortraitToTexture(self.Portrait, icon)
	elseif unit and UnitIsUnit(self.unit, unit) then
		SetPortraitTexture(self.Portrait, unit)
	end
end

function ns.createArenaLayout(self, unit)
	local config = ns.config
	local uconfig = config[self.MatchUnit]

	self.Texture = self:CreateTexture(nil, "BORDER")
	self.Texture:SetTexture(textPath.. "Arena")
	self.Texture:SetSize(230, 100)
	self.Texture:SetPoint("TOPLEFT", self, -22, 14)
	self.Texture:SetTexCoord(0, 0.90625, 0, 0.78125)

	if C.Blizzard.ColorTextures == true then
		self.Texture:SetVertexColor(unpack(C.Blizzard.TexturesColor))
	end

	self.Health = K.CreateStatusBar(self, false)
	self.Health:SetFrameLevel(self:GetFrameLevel()-1)
	self.Health:SetSize(117, 18)
	self.Health:SetPoint("TOPRIGHT", self.Texture, -43, -17)

	self.Power = K.CreateStatusBar(self, false)
	self.Power:SetFrameLevel(self:GetFrameLevel()-1)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -3)
	self.Power:SetHeight(self.Health:GetHeight())

	self.Portrait = self.Health:CreateTexture(nil, "BACKGROUND")
	self.Portrait:SetSize(64, 64)
	self.Portrait:SetPoint("TOPLEFT", self.Health, -64, 13)
	self.Portrait.Override = updatePortrait
	self:RegisterEvent("ARENA_OPPONENT_UPDATE", updatePortrait)

	self.Health.Value = K.SetFontString(self.Health, C.Media.Font, 13)
	self.Health.Value:SetPoint("CENTER", self.Health)

	self.Power.Value = K.SetFontString(self.Health, C.Media.Font, 13)
	self.Power.Value:SetPoint("CENTER", self.Power)

	self:SetSize(167, 46)
	self:SetScale(1)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	if C.Unitframe.Smooth then
			self.Health.Smooth = true
	end
	self.Health.PostUpdate = K.PostUpdateHealth
	table_insert(self.mouseovers, self.Health)

	self.Power.colorPower = true

	if C.Unitframe.Smooth then
			self.Power.Smooth = true
	end
	self.Power.PostUpdate = K.PostUpdatePower
	table_insert(self.mouseovers, self.Power)

	-- Name
	self.Name = K.SetFontString(self.Health, C.Media.Font, 14)
	self.Name:SetSize(110, 10)
	self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 6)
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	-- PvP Icon
	self.PvP = self:CreateTexture(nil, "OVERLAY")
	self.PvP:SetSize(32, 32)
	self.PvP:SetPoint("TOPLEFT", self.Texture, -14, -20)

	-- Portrait Timer
	if (C.Unitframe.PortraitTimer == true and self.Portrait) then
		self.PortraitTimer = CreateFrame("Frame", nil, self.Health)

		self.PortraitTimer.Icon = self.PortraitTimer:CreateTexture(nil, "BACKGROUND")
		self.PortraitTimer.Icon:SetAllPoints(self.Portrait)

		self.PortraitTimer.Remaining = K.SetFontString(self.PortraitTimer, C.Media.Font, self.Portrait:GetWidth() / 3, C.Media.Font_Style, "CENTER")
		self.PortraitTimer.Remaining:SetPoint("CENTER", self.PortraitTimer.Icon)
		self.PortraitTimer.Remaining:SetTextColor(1, 1, 1)
	end

	-- Auras
	self.Buffs = K.AddBuffs(self, "TOPLEFT", 28, 5, 6, 1)
	self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -7)
	self.Buffs.CustomFilter = K.CustomAuraFilters.arena

if C.Unitframe.Castbars then
	if self.MatchUnit == "arena" then
		local CastBar = CreateFrame("StatusBar", nil, self)

		CastBar:SetPoint("RIGHT", -138, 0)
		CastBar:SetPoint("LEFT", 0, 10)
		CastBar:SetPoint("LEFT", -138, 8)
		CastBar:SetHeight(20)
		CastBar:SetStatusBarTexture(C.Media.Texture)
		CastBar:SetFrameLevel(6)

		K.CreateBorder(CastBar, -1)

		CastBar.Background = CastBar:CreateTexture(nil, "BORDER")
		CastBar.Background:SetAllPoints(CastBar)
		CastBar.Background:SetTexture(C.Media.Blank)
		CastBar.Background:SetVertexColor(unpack(C.Media.Backdrop_Color))

		CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
		CastBar.Time:SetFont(C.Media.Font, C.Media.Font_Size)
		CastBar.Time:SetShadowOffset(K.Mult, -K.Mult)
		CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
		CastBar.Time:SetTextColor(1, 1, 1)
		CastBar.Time:SetJustifyH("RIGHT")

		CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
		CastBar.Text:SetFont(C.Media.Font, C.Media.Font_Size)
		CastBar.Text:SetShadowOffset(K.Mult, -K.Mult)
		CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 4, 0)
		CastBar.Text:SetTextColor(1, 1, 1)
		CastBar.Text:SetWidth(166)
		CastBar.Text:SetJustifyH("LEFT")

		CastBar.Button = CreateFrame("Frame", nil, CastBar)
		CastBar.Button:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
		CastBar.Button:SetPoint("RIGHT", CastBar, "LEFT", -4, 0)

		K.CreateBorder(CastBar.Button, -1)

		CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
		CastBar.Icon:SetAllPoints()
		CastBar.Icon:SetTexCoord(unpack(K.TexCoords))

		CastBar.CustomDelayText = K.CustomDelayText
		CastBar.CustomTimeText = K.CustomTimeText
		CastBar.PostCastStart = K.PostCastStart
		CastBar.PostChannelStart = K.PostCastStart
		CastBar.PostCastStop = K.PostCastStop
		CastBar.PostChannelStop = K.PostCastStop
		CastBar.PostChannelUpdate = K.PostChannelUpdate
		CastBar.PostCastInterruptible = K.PostCastInterruptible
		CastBar.PostCastNotInterruptible = K.PostCastNotInterruptible

		self.Castbar = CastBar
		self.Castbar.Icon = CastBar.Icon
	end
end

	-- oUF_Trinkets support
	self.Trinket = CreateFrame("Frame", nil, self)
	self.Trinket:SetSize(26, 26)
	self.Trinket:SetFrameLevel(self:GetFrameLevel() + 2)
	self.Trinket:SetPoint("RIGHT", self, "LEFT", -10, 1)
	self.Trinket.trinketUseAnnounce = true
	self.Trinket.trinketUpAnnounce = true

	self.Trinket.Border = CreateFrame("Frame", nil, self.Trinket)
	self.Trinket.Border:SetFrameLevel(self.Trinket:GetFrameLevel() + 1)
	self.Trinket.Border:SetAllPoints()
	self.Trinket.Border.Texture = self.Trinket.Border:CreateTexture(nil, "OVERLAY")
	self.Trinket.Border.Texture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	self.Trinket.Border.Texture:SetPoint("TOPLEFT", -10, 10)
	self.Trinket.Border.Texture:SetSize(76, 76)

	if C.Blizzard.ColorTextures == true then
		self.Trinket.Border.Texture:SetVertexColor(unpack(C.Blizzard.TexturesColor))
	end

	self.PostUpdate = arenaPrep

	return self
end

-- Arena preparation(by Blizzard)(../Blizzard_ArenaUI/Blizzard_ArenaUI.lua)
if C.Unitframe.ShowArena == true then
	local arenaprep = {}
	for i = 1, 5 do
		arenaprep[i] = CreateFrame("Frame", "oUF_ArenaPrep"..i, UIParent)
		arenaprep[i]:SetAllPoints(_G["oUF_KkthnxArenaFrame"..i])
		arenaprep[i]:SetTemplate()
		arenaprep[i]:SetFrameStrata("BACKGROUND")

		arenaprep[i].Health = CreateFrame("StatusBar", nil, arenaprep[i])
		arenaprep[i].Health:SetInside(arenaprep[i], 4, 4)
		arenaprep[i].Health:SetStatusBarTexture(C.Media.Texture)

		arenaprep[i].Spec = K.SetFontString(arenaprep[i].Health, C.Media.Font, C.Media.Font_Size, C.Media.Font_Style, "CENTER")
		arenaprep[i].Spec:SetShadowOffset(0, 0)
		arenaprep[i].Spec:SetPoint("CENTER")

		arenaprep[i]:Hide()
	end

	local arenaprepupdate = CreateFrame("Frame")
	arenaprepupdate:RegisterEvent("PLAYER_LOGIN")
	arenaprepupdate:RegisterEvent("PLAYER_ENTERING_WORLD")
	arenaprepupdate:RegisterEvent("ARENA_OPPONENT_UPDATE")
	arenaprepupdate:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	arenaprepupdate:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_LOGIN" then
			for i = 1, 5 do
				arenaprep[i]:SetAllPoints(_G["oUF_KkthnxArenaFrame"..i])
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
							local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
							if color then
								f.Health:SetStatusBarColor(color.r, color.g, color.b)
							else
								f.Health:SetStatusBarColor(0.29, 0.67, 0.30)
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