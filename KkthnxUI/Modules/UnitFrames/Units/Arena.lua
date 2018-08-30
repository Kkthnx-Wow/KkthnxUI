local K, C = unpack(select(2, ...))
if C["Arena"].Enable ~= true then
	return
end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Arena.lua code!")
	return
end

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

function Module:CreateArena()
	local UnitframeFont = K.GetFont(C["Arena"].Font)
	local UnitframeTexture = K.GetTexture(C["Arena"].Texture)

	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", UnitFrame_OnEnter)
	self:HookScript("OnLeave", UnitFrame_OnLeave)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:SetSize(130, 26)
	self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
	self.Health:CreateBorder()

	self.Health.Smooth = C["Arena"].Smooth
	self.Health.SmoothSpeed = C["Arena"].SmoothSpeed * 10
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:SetSize(130, 14)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	self.Power:CreateBorder()

	self.Power.Smooth = C["Arena"].Smooth
	self.Power.SmoothSpeed = C["Arena"].SmoothSpeed * 10
	self.Power.colorPower = true
	self.Power.frequentUpdates = true

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
	self.Name:SetFont(select(1, self.Name:GetFont()), 12, select(3, self.Name:GetFont()))
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "$parentCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
		self.Castbar:SetClampedToScreen(true)

		self.Castbar.Background = self.Castbar:CreateTexture(nil, "BACKGROUND", -1)
		self.Castbar.Background:SetAllPoints()
		self.Castbar.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		self.Castbar.Border = CreateFrame("Frame", nil, self.Castbar)
		self.Castbar.Border:SetAllPoints()
		K.CreateBorder(self.Castbar.Border)

		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("LEFT", 4, 0)
		self.Castbar:SetPoint("RIGHT", -28, 0)
		self.Castbar:SetPoint("TOP", 0, 20)
		self.Castbar:SetHeight(18)

		self.Castbar.PostCastStart = Module.CheckCast
		self.Castbar.PostChannelStart = Module.CheckChannel

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.CustomTimeText = Module.CustomCastTimeText
		self.Castbar.CustomDelayText = Module.CustomCastDelayText

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

		K.Movers:RegisterFrame(self.Castbar)
	end

	Module.CreateAuras(self, "arena")
	Module.CreateSpecIcons(self)
	Module.CreateTrinkets(self)
	Module.MouseoverHealth(self, "arena")

	self.Range = Module.CreateRange(self)
end

function Module:CreateArenaPreparation()
	local HealthTexture = K.GetTexture(C["Arena"].Texture)
	local Font = K.GetFont(C["Arena"].Font)
	local ArenaPreparation = {}

	for i = 1, MAX_ARENA_ENEMIES or 5 do
		local ArenaX = Module.Arena[i]

		ArenaPreparation[i] = CreateFrame("Frame", nil, UIParent)
		ArenaPreparation[i]:SetAllPoints(ArenaX)
		ArenaPreparation[i]:SetScript("OnEvent", Module.UpdatePrep)

		ArenaPreparation[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
		ArenaPreparation[i]:RegisterEvent("ARENA_OPPONENT_UPDATE")
		ArenaPreparation[i]:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

		ArenaPreparation[i].Health = CreateFrame("StatusBar", nil, ArenaPreparation[i])
		ArenaPreparation[i].Health:SetAllPoints()
		ArenaPreparation[i].Health:SetStatusBarTexture(HealthTexture)
		ArenaPreparation[i].Health:CreateBorder()

		ArenaPreparation[i].Icon = ArenaPreparation[i]:CreateTexture(nil, "OVERLAY")
		ArenaPreparation[i].Icon.Background = CreateFrame("Frame", nil, ArenaPreparation[i])
		ArenaPreparation[i].Icon.Background:SetSize(52, 52)
		ArenaPreparation[i].Icon.Background:SetPoint("RIGHT", ArenaPreparation[i], "LEFT", -6, 0)
		ArenaPreparation[i].Icon.Background:CreateBorder()
		ArenaPreparation[i].Icon:SetParent(ArenaPreparation[i].Icon.Background)
		ArenaPreparation[i].Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		ArenaPreparation[i].Icon:SetInside(ArenaPreparation[i].Icon.Background)

		ArenaPreparation[i].SpecClass = ArenaPreparation[i].Health:CreateFontString(nil, "OVERLAY")
		ArenaPreparation[i].SpecClass:SetFontObject(Font)
		ArenaPreparation[i].SpecClass:SetPoint("CENTER")

		ArenaPreparation[i]:Hide()
	end

	Module.ArenaPreparation = ArenaPreparation
end