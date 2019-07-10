local K, C = unpack(select(2, ...))
if C["Arena"].Enable ~= true then
	return
end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

function Module:PostUpdateArenaHealth(unit)
	if (unit and strfind(unit, "arena%d")) then
		local status = UnitIsDead(unit) and "|cffFFFFFF" .. DEAD .. "|r" or UnitIsGhost(unit) and "|cffFFFFFF" .. GHOST .. "|r" or not UnitIsConnected(unit) and "|cffFFFFFF" .. PLAYER_OFFLINE .. "|r"
		if (status) then
			self.Value:SetText(status)
		else
			self.Value:SetText(K.GetFormattedText("CURRENT_PERCENT", UnitHealth(unit), UnitHealthMax(unit)))
		end
	end
end

function Module:PostUpdateArenaPower(unit)
	if (unit and strfind(unit, "arena%d")) then
		local pType = UnitPowerType(unit)
		local min = UnitPower(unit, pType)

		if min == 0 then
			self.Value:SetText(" ")
		else
			self.Value:SetText(K.GetFormattedText("CURRENT", min, UnitPowerMax(unit, pType)))
		end
	end
end

function Module:CreateArena()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", UnitFrame_OnEnter)
	self:HookScript("OnLeave", UnitFrame_OnLeave)
	self:SetAttribute("type2", "focus")

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:SetSize(130, 26)
	self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
	self.Health:CreateBorder()

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	K:SetSmoothing(self.Health, C["Arena"].Smooth)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.PostUpdate = Module.PostUpdateArenaHealth

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:SetSize(130, 14)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	self.Power:CreateBorder()
	self.Power.UpdateColorArenaPreparation = Module.UpdatePowerColorArenaPreparation
	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	K:SetSmoothing(self.Power, C["Arena"].Smooth)

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self.Power.PostUpdate = Module.PostUpdateArenaPower

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetSize(130, 24)
	self.Name:SetJustifyV("TOP")
	self.Name:SetJustifyH("CENTER")
	self.Name:SetFontObject(UnitframeFont)
	self.Name.frequentUpdates = 0.2
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	self.Name.PostUpdate = Module.PostUpdateArenaName

	Module.CreateArenaCastbar(self)
	Module.CreateArenaAuras(self)
	Module.CreateSpecIcons(self)
	Module.CreateTrinkets(self)
	Module.MouseoverHealth(self, "arena")

	self.Range = Module.CreateRangeIndicator(self)
	self.PostUpdate = Module.PostUpdateArenaPreparationSpec
end