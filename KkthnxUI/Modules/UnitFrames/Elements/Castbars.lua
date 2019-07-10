local K, C = unpack(select(2, ...))

local Module = K:GetModule("Unitframes")

local _G = _G
local select = _G.select

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
local NameplateTexture = K.GetTexture(C["UITextures"].NameplateTextures)
local NameplateFont = K.GetFont(C["UIFonts"].NameplateFonts)

function Module:CreatePlayerCastbar()
	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "PlayerCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()
		self.Castbar:ClearAllPoints()

		if C["Raid"].RaidLayout.Value == "Healer" then
			self.Position = {"BOTTOM", UIParent, "BOTTOM", 0, 350}
		else
			self.Position = {"BOTTOM", UIParent, "BOTTOM", 0, 320}
		end
		self.Castbar:SetPoint(self.Position[1], self.Position[2], self.Position[3], self.Position[4], self.Position[5])

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		if C["Unitframe"].CastbarLatency then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.SafeZone:SetTexture(UnitframeTexture)
			self.Castbar.SafeZone:SetPoint("RIGHT")
			self.Castbar.SafeZone:SetPoint("TOP")
			self.Castbar.SafeZone:SetPoint("BOTTOM")
			self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
			self.Castbar.SafeZone:SetWidth(0.0001)

			self.Castbar.Lag = self.Castbar:CreateFontString(nil, "OVERLAY")
			self.Castbar.Lag:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", -3.5, -3)
			self.Castbar.Lag:SetFontObject(UnitframeFont)
			self.Castbar.Lag:SetFont(select(1, self.Castbar.Lag:GetFont()), 11, select(3, self.Castbar.Lag:GetFont()))
			self.Castbar.Lag:SetTextColor(0.84, 0.75, 0.65)
			self.Castbar.Lag:SetJustifyH("RIGHT")
			self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent, true)
		end

		self.Castbar.decimal = "%.2f"

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostChannelStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostChannelStop = Module.PostChannelStop
		self.Castbar.PostCastFailed = Module.PostCastFailed
		self.Castbar.PostCastInterrupted = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		self.Castbar.PostCastNotInterruptible = Module.PostUpdateInterruptible

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		if (C["Unitframe"].CastbarIcon) then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(20, 20)
			self.Castbar.Button:CreateBorder()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetPoint("RIGHT", self.Castbar, "LEFT", -6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end

		K.Mover(self.Castbar, "PlayerCastBar", "PlayerCastBar", self.Position)
	end
end

function Module:CreateTargetCastbar()
	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "TargetCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight + 6)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()
		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("BOTTOM", "PlayerCastbar", "TOP", 0, 6)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY", nil, 3)
		self.Castbar.Shield:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CastBorderShield")
		self.Castbar.Shield:SetTexCoord(0, 0.84375, 0, 1)
		self.Castbar.Shield:SetSize(C["Unitframe"].CastbarHeight * 0.84375, C["Unitframe"].CastbarHeight)
		self.Castbar.Shield:SetPoint("LEFT", self.Castbar, -22, 0)
		self.Castbar.Shield:SetVertexColor(0.5, 0.5, 0.7)

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.decimal = "%.2f"

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

		if (C["Unitframe"].CastbarIcon) then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(20, 20)
			self.Castbar.Button:CreateBorder()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetPoint("LEFT", self.Castbar, "RIGHT", 6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end

		K.Mover(self.Castbar, "TargetCastBar", "TargetCastBar", {"BOTTOM", "PlayerCastbar", "TOP", 0, 6})
	end
end

function Module:CreateFocusCastbar()
	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "FocusCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("LEFT", 4, 0)
		self.Castbar:SetPoint("RIGHT", -28, 0)
		self.Castbar:SetPoint("TOP", 0, 20)
		self.Castbar:SetHeight(18)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.decimal = "%.2f"

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

		if (C["Unitframe"].CastbarIcon) then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(20, 20)
			self.Castbar.Button:CreateBorder()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetPoint("LEFT", self.Castbar, "RIGHT", 6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end
	end
end

function Module:CreatePartyCastbar()
	if (C["Party"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "PartyCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("LEFT", C["Party"].CastbarIcon and 26 or 4, 0)
		self.Castbar:SetPoint("RIGHT", -4, 0)
		self.Castbar:SetPoint("TOP", 0, 18)
		self.Castbar:SetHeight(16)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetFont(select(1, self.Castbar.Time:GetFont()), 11, select(3, self.Castbar.Time:GetFont()))
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.decimal = "%.2f"

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
		self.Castbar.Text:SetFont(select(1, self.Castbar.Text:GetFont()), 11, select(3, self.Castbar.Text:GetFont()))
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		if (C["Party"].CastbarIcon) then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(16, 16)

			self.Castbar.Button.Backgrounds = self.Castbar.Button:CreateTexture(nil, "BACKGROUND", -1)
			self.Castbar.Button.Backgrounds:SetAllPoints(self.Castbar.Button)
			self.Castbar.Button.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			self.Castbar.Button.Borders = CreateFrame("Frame", nil, self.Castbar.Button)
			self.Castbar.Button.Borders:SetAllPoints(self.Castbar.Button)
			K.CreateBorder(self.Castbar.Button.Borders)
			self.Castbar.Button.Borders:SetBackdropBorderColor()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetPoint("RIGHT", self.Castbar, "LEFT", -6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end
	end
end

function Module:CreateArenaCastbar()
	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "ArenaCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("LEFT", 4, 0)
		self.Castbar:SetPoint("RIGHT", -28, 0)
		self.Castbar:SetPoint("TOP", 0, 20)
		self.Castbar:SetHeight(18)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
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

		if (C["Unitframe"].CastbarIcon) then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(20, 20)

			self.Castbar.Button.Backgrounds = self.Castbar.Button:CreateTexture(nil, "BACKGROUND", -1)
			self.Castbar.Button.Backgrounds:SetAllPoints(self.Castbar.Button)
			self.Castbar.Button.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			self.Castbar.Button.Borders = CreateFrame("Frame", nil, self.Castbar.Button)
			self.Castbar.Button.Borders:SetAllPoints(self.Castbar.Button)
			K.CreateBorder(self.Castbar.Button.Borders)
			self.Castbar.Button.Borders:SetBackdropBorderColor()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetPoint("LEFT", self.Castbar, "RIGHT", 6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end
	end
end

function Module:CreateBossCastbar()
	if (C["Boss"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "BossCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Boss"].CastbarWidth, C["Boss"].CastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("LEFT", 4, 0)
		self.Castbar:SetPoint("RIGHT", -28, 0)
		self.Castbar:SetPoint("TOP", 0, 20)
		self.Castbar:SetHeight(18)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
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

		if (C["Boss"].CastbarIcon) then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(20, 20)
			self.Castbar.Button:CreateBorder()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetPoint("LEFT", self.Castbar, "RIGHT", 6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end
	end
end

function Module:CreateNameplateCastbar()
	self.Castbar = CreateFrame("StatusBar", "NameplateCastbar", self)
	self.Castbar:SetFrameStrata(self:GetFrameStrata())
	self.Castbar:SetStatusBarTexture(NameplateTexture)
	self.Castbar:SetFrameLevel(6)
	self.Castbar:SetHeight(C["Nameplates"].CastHeight)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)
	self.Castbar:CreateShadow()

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetSize(32, self:GetHeight())
	self.Castbar.Spark:SetTexture(C["Media"].Spark_64)
	self.Castbar.Spark:SetBlendMode("ADD")

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

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
	self.Castbar.Time:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", 0, -2)
	self.Castbar.Time:SetJustifyH("RIGHT")
	self.Castbar.Time:SetFontObject(NameplateFont)
	self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(self:GetHeight() + 2, self:GetHeight() + 3)
	self.Castbar.Button:CreateShadow(true)
	self.Castbar.Button:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

	self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetAllPoints()
	self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "ARTWORK", nil, 3)
	self.Castbar.Shield:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]])
	self.Castbar.Shield:SetTexCoord(0, 0.84375, 0, 1)
	self.Castbar.Shield:SetSize(16 * 0.84375, 16)
	self.Castbar.Shield:SetPoint("LEFT", self.Castbar, -7, 0)
	self.Castbar.Shield:SetVertexColor(0.5, 0.5, 0.7)

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFontObject(NameplateFont)
	self.Castbar.Text:SetPoint("TOPLEFT", self.Castbar, "BOTTOMLEFT", 0, -2)
	self.Castbar.Text:SetPoint("TOPRIGHT", self.Castbar.Time, "TOPLEFT")
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
	self.Castbar.Text:SetWordWrap(false)
end