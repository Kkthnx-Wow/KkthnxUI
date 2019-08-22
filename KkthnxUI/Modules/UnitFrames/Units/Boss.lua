local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame

function Module:CreateBoss()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(24)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = false

	K.SmoothBar(self.Health)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(12)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	K.SmoothBar(self.Power)

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetSize(130, 24)
	self.Name:SetJustifyV("TOP")
	self.Name:SetJustifyH("CENTER")
	self.Name:SetFontObject(UnitframeFont)
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameAbbrev]")

	if C["General"].PortraitStyle.Value == "ThreeDPortraits" then
		self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
		self.Portrait:SetFrameStrata(self:GetFrameStrata())
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.Portrait:CreateBorder()
		self.Portrait:CreateInnerShadow()
	elseif C["General"].PortraitStyle.Value ~= "ThreeDPortraits" then
		self.Portrait = self.Health:CreateTexture("BossPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)

		self.Portrait.Border = CreateFrame("Frame", nil, self)
		self.Portrait.Border:SetAllPoints(self.Portrait)
		self.Portrait.Border:CreateBorder()
		self.Portrait.Border:CreateInnerShadow()

		if (C["General"].PortraitStyle.Value == "ClassPortraits" or C["General"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT", -self.Portrait:GetWidth() - 6, 0)

	self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
	self.Buffs:SetWidth(154)
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
	self.Debuffs:SetWidth(24 * 3 + 6 * 2)
	self.Debuffs:SetPoint("RIGHT", self.Health, "LEFT", -6, 0)
	self.Debuffs.size = 24
	self.Debuffs.num = 8
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "TOPRIGHT"
	self.Debuffs["growth-y"] = "DOWN"
	self.Debuffs["growth-x"] = "LEFT"
	self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	if (C["Boss"].Castbars) then
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

	self.Range = Module.CreateRangeIndicator(self)
end