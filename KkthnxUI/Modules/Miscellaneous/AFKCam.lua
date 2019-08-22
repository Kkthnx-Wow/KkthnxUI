local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- Sourced: Tukui (Tukz)

local _G = _G
local date = _G.date
local math_floor = _G.math.floor
local string_format = _G.string.format
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local SendChatMessage = _G.SendChatMessage
local ShowUIPanel = _G.ShowUIPanel
local UIFrameFadeIn = _G.UIFrameFadeIn
local UIFrameFadeOut = _G.UIFrameFadeOut
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitIsAFK = _G.UnitIsAFK

function Module:UpdateTime(Value)
	local Minutes = Module.Minutes
	local Seconds = Module.Seconds

	if (Value >= 60) then
		Minutes = math_floor(Value/60)
		Seconds = Value - Minutes*60
	else
		Minutes = 0
		Seconds = Value
	end

	self.Time:SetText("|cffffffff" .. string_format("%.2d", Minutes) .. ":" .. string_format("%.2d", Seconds) .. "|r")

	Module.Minutes = Minutes
	Module.Seconds = Seconds
end

function Module:OnUpdate(Elapsed)
	self.Update = (self.Update or 0) + Elapsed

	if (self.Update > 1.0) then
		self.Total = (self.Total or 0) + 1

		Module.LocalDate:SetFormattedText("%s", date( "%A |cffffffff%B %d|r"))
		Module.LocalTime:SetFormattedText("%s", date( "|cffffffff%I:%M:%S|r %p"))

		Module:UpdateTime(self.Total)

		self.Update = 0
	end
end

function Module:SetAFK(status)
	if (status) then
		ShowUIPanel(_G.WorldMapFrame) -- Avoid Lua errors on M keypress

		UIParent:Hide()
		UIFrameFadeIn(self.Frame, 1, self.Frame:GetAlpha(), 1)

		self.Frame:SetScript("OnUpdate", Module.OnUpdate)

		self.IsAFK = true
	elseif (self.IsAFK) then
		self.Total = 0

		HideUIPanel(_G.WorldMapFrame) -- Avoid Lua errors on M keypress

		UIFrameFadeOut(self.Frame, 0.5, self.Frame:GetAlpha(), 0)
		UIParent:Show()

		self.Frame:SetScript("OnUpdate", nil)

		self.IsAFK = false
	end
end

function Module:OnEvent(event, ...)
	if (event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS") then
		if (event == "UPDATE_BATTLEFIELD_STATUS") then
			local status = GetBattlefieldStatus(...)
			if (status == "confirm") then
				Module:SetAFK(false)
			end
		else
			Module:SetAFK(false)
		end

		if (event == "PLAYER_REGEN_DISABLED") then
			K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.OnEvent)
		end

		return
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if InCombatLockdown() or _G.CinematicFrame:IsShown() or _G.MovieFrame:IsShown() then return end

	if (UnitIsAFK("player")) then
		Module:SetAFK(true)
	else
		Module:SetAFK(false)
	end
end

function Module:SetupAFKCam()
	local Font = C["Media"].Font

	local Frame = CreateFrame("Frame", nil)
	Frame:SetFrameLevel(5)
	Frame:SetScale(UIParent:GetScale())
	Frame:SetAllPoints(UIParent)
	Frame:SetAlpha(0)

	local TopPanel = CreateFrame("Frame", nil, Frame)
	TopPanel:SetFrameLevel(Frame:GetFrameLevel() - 1)
	TopPanel:SetSize(UIParent:GetWidth() + 8, 42)
	TopPanel:SetPoint("TOP", Frame, 0, 2)
	TopPanel:CreateBorder()

	local BottomPanel = CreateFrame("Frame", nil, Frame)
	BottomPanel:SetFrameLevel(Frame:GetFrameLevel() - 1)
	BottomPanel:SetSize(UIParent:GetWidth() + 12, 84)
	BottomPanel:SetPoint("BOTTOM", Frame, 0, -4)
	BottomPanel:CreateBorder()

	local Class = select(2, UnitClass("player"))
	local CustomClassColor = Class and K.Colors.class[Class]

	local LocalTime = Frame:CreateFontString(nil, "OVERLAY")
	LocalTime:SetPoint("RIGHT", TopPanel, -28, -2)
	LocalTime:FontTemplate(Font, 14)
	LocalTime:SetTextColor(unpack(CustomClassColor))

	local LocalDate = Frame:CreateFontString(nil, "OVERLAY")
	LocalDate:SetPoint("LEFT", TopPanel, 28, -2)
	LocalDate:FontTemplate(Font, 14)
	LocalDate:SetTextColor(unpack(CustomClassColor))

	local Time = Frame:CreateFontString(nil, "OVERLAY")
	Time:SetPoint("CENTER", TopPanel, 0, -2)
	Time:FontTemplate(Font, 16)
	Time:SetTextColor(unpack(CustomClassColor))

	local Name = Frame:CreateTexture(nil, "OVERLAY")
	Name:SetSize(256, 128)
	Name:SetTexture(C["Media"].Logo)
	Name:SetPoint("CENTER", BottomPanel, -8, 48)

	local Version = Frame:CreateFontString(nil, "OVERLAY")
	Version:SetPoint("CENTER", BottomPanel, 0, -18)
	Version:FontTemplate(Font, 24)
	Version:SetText("Version "..K.Version)

	K:RegisterEvent("PLAYER_FLAGS_CHANGED", Module.OnEvent)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.OnEvent)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.OnEvent)

	UIParent:HookScript("OnShow", function()
		if UnitIsAFK("player") then
			SendChatMessage("", "AFK")
			Module:SetAFK(false)
		end
	end)

	self.Frame = Frame
	self.PanelTop = TopPanel
	self.BottomPanel = BottomPanel
	self.LocalTime = LocalTime
	self.LocalDate = LocalDate
	self.Time = Time
	self.Name = Name
	self.Version = Version
end

function Module:CreateAFKCam()
	if not C["Misc"].AFKCamera then
		return
	end

	Module.Minutes = Module.Minutes or 0
	Module.Seconds = Module.Seconds or 0

	if not (self.IsCreated) then
		self:SetupAFKCam()
		self.IsCreated = true
	end
end
