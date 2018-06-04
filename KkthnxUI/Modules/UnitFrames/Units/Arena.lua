local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Unitframes.lua code!")
	return
end

local _G = _G
local print = print
local unpack = unpack

local CreateFrame = _G.CreateFrame
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

local UnitframeFont = K.GetFont(C["Unitframe"].Font)
local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

function Module:CreateArena()
	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", UnitFrame_OnEnter)
	self:HookScript("OnLeave", UnitFrame_OnLeave)
	
	-- Health bar
	self.Health = CreateFrame("StatusBar", "$parent.Healthbar", self)
	self.Health:SetTemplate("Transparent")
	self.Health:SetFrameStrata("LOW")
	self.Health:SetFrameLevel(1)
	self.Health:SetStatusBarTexture(UnitframeTexture)
	
	self.Health.Smooth = C["Unitframe"].Smooth
	self.Health.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = false
	
	self.Health:SetSize(130, 26)
	self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
	-- Health Value
	self.Health.Value = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
	self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	
	-- Power Bar
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetTemplate("Transparent")
	self.Power:SetFrameStrata("LOW")
	self.Power:SetFrameLevel(1)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	
	self.Power.Smooth = C["Unitframe"].Smooth
	self.Power.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Power.colorPower = true
	self.Power.frequentUpdates = false
	
	-- Power StatusBar
	self.Power:SetSize(130, 14)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	-- Power value
	self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
	self.Power.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	
	-- Name Text
	self.Name = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
	self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
	self.Name:SetPoint("TOP", self.Health, "TOP", 0, 16)
	if C["Unitframe"].NameAbbreviate == true then
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMediumAbbrev]")
	else
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
	end
	
	if C["Unitframe"].Castbars then
		Module.CreateCastBar(self, "arena")
	end
	Module.CreateAuras(self, "arena")
	Module.CreateSpecIcons(self)
	Module.CreateTrinkets(self)
	
	self.Range = Module.CreateRange(self)
end

function Module:CreateArenaPreparationFrames()
	local HealthTexture = K.GetTexture(C["Unitframe"].Texture)
	local Font = K.GetFont(C["Unitframe"].Font)
	local ArenaPreparation = {}
	
	for i = 1, 5 do
		local ArenaX = Module.Arena[i]
		
		ArenaPreparation[i] = CreateFrame("Frame", nil, UIParent)
		ArenaPreparation[i]:SetAllPoints(ArenaX)
		ArenaPreparation[i]:SetBackdrop(Module.Backdrop)
		ArenaPreparation[i]:SetBackdropColor(0,0,0)
		
		ArenaPreparation[i]:CreateShadow()
		
		ArenaPreparation[i].Health = CreateFrame("StatusBar", nil, ArenaPreparation[i])
		ArenaPreparation[i].Health:SetAllPoints()
		ArenaPreparation[i].Health:SetStatusBarTexture(HealthTexture)
		ArenaPreparation[i].Health:SetStatusBarColor(0.2, 0.2, 0.2, 1)
		
		ArenaPreparation[i].SpecClass = ArenaPreparation[i].Health:CreateFontString(nil, "OVERLAY")
		ArenaPreparation[i].SpecClass:SetFontObject(Font)
		ArenaPreparation[i].SpecClass:SetPoint("CENTER")
		ArenaPreparation[i]:Hide()
	end
	
	Module.ArenaPreparation = ArenaPreparation
end