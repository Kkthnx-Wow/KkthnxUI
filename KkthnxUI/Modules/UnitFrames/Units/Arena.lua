local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G
local string_find = _G.string.find

local CreateFrame = _G.CreateFrame
local DEAD = _G.DEAD
local GHOST = _G.GetLocale() == "deDE" and "Geist" or _G.GetSpellInfo(8326)
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local IsInInstance = _G.IsInInstance
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local UnitFactionGroup = _G.UnitFactionGroup
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsGhost = _G.UnitIsGhost
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType

local function PostUpdateArenaHealth(self, unit)
	if (unit and string_find(unit, "arena%d")) then
		local status = UnitIsDead(unit) and "|cffFFFFFF" .. DEAD .. "|r" or UnitIsGhost(unit) and "|cffFFFFFF" .. GHOST .. "|r" or not UnitIsConnected(unit) and "|cffFFFFFF" .. PLAYER_OFFLINE .. "|r"
		if (status) then
			self.Value:SetText(status)
		else
			self.Value:SetText(K.GetFormattedText("CURRENT_PERCENT", UnitHealth(unit), UnitHealthMax(unit)))
		end
	end
end

local function PostUpdateArenaPower(self, unit)
	if (unit and string_find(unit, "arena%d")) then
		local pType = UnitPowerType(unit)
		local min = UnitPower(unit, pType)

		if min == 0 then
			self.Value:SetText(" ")
		else
			self.Value:SetText(K.GetFormattedText("CURRENT", min, UnitPowerMax(unit, pType)))
		end
	end
end

local function PostUpdateArenaPreparationSpec(self)
	local specIcon = self.PVPSpecIcon
	local instanceType = select(2, IsInInstance())

	if (instanceType == "arena") then
		local specID = self.id and GetArenaOpponentSpec(tonumber(self.id))

		if specID and specID > 0 then
			local icon = select(4, GetSpecializationInfoByID(specID))

			specIcon.Icon:SetTexture(icon)
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	else
		local faction = UnitFactionGroup(self.unit)

		if faction == "Horde" then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_01]])
		elseif faction == "Alliance" then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_02]])
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	end

	self.forceInRange = true
end

local function UpdatePowerColorArenaPreparation(self, specID)
	-- oUF is unable to get power color on arena preparation, so we add this feature here.
	local power = self
	local playerClass = select(6, GetSpecializationInfoByID(specID))

	if playerClass then
		local powerColor = K.Colors.specpowertypes[playerClass][specID]

		if powerColor then
			local r, g, b = unpack(powerColor)

			power:SetStatusBarColor(r, g, b)
		else
			power:SetStatusBarColor(0, 0, 0)
		end
	end
end

function Module:CreateArena()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	Module.CreateHeader(self)

	self:SetAttribute("type2", "focus")

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(24)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.frequentUpdates = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	K.SmoothBar(self.Health)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.PostUpdate = PostUpdateArenaHealth

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(12)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()
	self.Power.UpdateColorArenaPreparation = UpdatePowerColorArenaPreparation
	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	K.SmoothBar(self.Power)

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self.Power.PostUpdate = PostUpdateArenaPower

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetSize(130, 24)
	self.Name:SetJustifyV("TOP")
	self.Name:SetJustifyH("CENTER")
	self.Name:SetFontObject(UnitframeFont)
	self.Name.frequentUpdates = 0.2
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
	self.Buffs:SetWidth(156)
	self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
	self.Buffs.num = 6 * 1
	self.Buffs.spacing = 6
	self.Buffs.size = ((((self.Buffs:GetWidth() - (self.Buffs.spacing * (self.Buffs.num / 1 - 1))) / self.Buffs.num)) * 1)
	self.Buffs:SetHeight(self.Buffs.size * 1)
	self.Buffs.initialAnchor = "TOPLEFT"
	self.Buffs["growth-y"] = "DOWN"
	self.Buffs["growth-x"] = "RIGHT"
	self.Buffs.PostCreateIcon = Module.PostCreateAura
	self.Buffs.PostUpdateIcon = Module.PostUpdateAura

	self.Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	self.Debuffs:SetHeight(24)
	self.Debuffs:SetWidth(24 * 3 + 6 * 2) -- Size x 3 + Spacing x 2
	self.Debuffs:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
	self.Debuffs.size = 24
	self.Debuffs.num = 8
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "RIGHT"
	self.Debuffs["growth-y"] = "DOWN"
	self.Debuffs["growth-x"] = "LEFT"
	self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	if (C["Arena"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "BossCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("LEFT", 0, 0)
		self.Castbar:SetPoint("RIGHT", -24, 0)
		self.Castbar:SetPoint("TOP", 0, 24)
		self.Castbar:SetHeight(18)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.decimal = "%.1f"

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostChannelStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostChannelStop = Module.PostChannelStop
		self.Castbar.PostCastFailed = Module.PostCastFailed
		self.Castbar.PostCastInterrupted = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		self.Castbar.PostCastNotInterruptible = Module.PostUpdateInterruptible

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
		self.Castbar.Button:SetSize(20, 20)
		self.Castbar.Button:CreateBorder()

		self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
		self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
		self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.Castbar.Icon:SetPoint("LEFT", self.Castbar, "RIGHT", 6, 0)

		self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
	end

	self.PVPSpecIcon = CreateFrame("Frame", nil, self)
	self.PVPSpecIcon:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
	self.PVPSpecIcon:SetPoint("RIGHT", self, "LEFT", -6, 0)
	self.PVPSpecIcon:CreateBorder()
	self.PVPSpecIcon:CreateInnerShadow()

	self.Trinket = CreateFrame("Frame", nil, self)
	self.Trinket:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
	self.Trinket:SetPoint("RIGHT", self, "LEFT", -6, 0)
	self.Trinket:CreateBorder()
	self.Trinket:CreateInnerShadow()

	-- Module.CreateHighlight(self)

	self.Range = Module.CreateRangeIndicator(self)
	self.PostUpdate = PostUpdateArenaPreparationSpec
end