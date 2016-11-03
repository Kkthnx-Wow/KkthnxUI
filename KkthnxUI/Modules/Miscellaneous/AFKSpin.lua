local K, C, L = select(2, ...):unpack()
if C.Misc.AFKCamera ~= true then return end

local AFKString = _G["AFK"]
local AFK = LibStub("AceAddon-3.0"):NewAddon("AFK", "AceEvent-3.0", "AceTimer-3.0")

-- WoW Lua
local _G = _G
local GetTime = GetTime
local tostring, pcall = tostring, pcall
local floor = floor
local format, strsub, gsub = string.format, string.sub, string.gsub
-- Wow API
local CinematicFrame = CinematicFrame
local CloseAllWindows = CloseAllWindows
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetColoredName = GetColoredName
local GetGuildInfo = GetGuildInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local MovieFrame = MovieFrame
local PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
local RemoveExtraSpaces = RemoveExtraSpaces
local Screenshot = Screenshot
local SetCVar = SetCVar
local UnitFactionGroup = UnitFactionGroup
local UnitIsAFK = UnitIsAFK
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local DND = DND
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local CAMERA_SPEED = 0.035
local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}

local printKeys = {
	["PRINTSCREEN"] = true,
}

if IsMacClient() then
	printKeys[_G["KEY_PRINTSCREEN_MAC"]] = true
end

function AFK:UpdateTimer()
	local time = GetTime() - self.startTime
	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", floor(time/60), time % 60)
end

function AFK:SetAFK(status)
	if(InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then return end
	if(status) then
		MoveViewLeftStart(CAMERA_SPEED)
		self.AFKMode:Show()
		CloseAllWindows()
		UIParent:Hide()
		if(IsInGuild()) then
			local guildName, guildRankName = GetGuildInfo("player")
			self.AFKMode.bottom.guild:SetFormattedText("%s-%s", guildName, guildRankName)
		else
			self.AFKMode.bottom.guild:SetText(L_AFKSCREEN_NOGUILD)
		end
		self.AFKMode.bottom.model.curAnimation = "wave"
		self.AFKMode.bottom.model.startTime = GetTime()
		self.AFKMode.bottom.model.duration = 2.3
		self.AFKMode.bottom.model:SetUnit("player")
		self.AFKMode.bottom.model.isIdle = nil
		self.AFKMode.bottom.model:SetAnimation(67)
		self.AFKMode.bottom.model.idleDuration = 40
		self.startTime = GetTime()
		self.timer = self:ScheduleRepeatingTimer("UpdateTimer", 1)
		self.isAFK = true
	elseif(self.isAFK) then
		UIParent:Show()
		self.AFKMode:Hide()
		MoveViewLeftStop()
		self:CancelTimer(self.timer)
		self:CancelTimer(self.animTimer)
		self.AFKMode.bottom.time:SetText("00:00")
		if(PVEFrame:IsShown()) then --odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end
		self.isAFK = false
	end
end

function AFK:OnEvent(event, ...)
	if(event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS") then
		if(event == "UPDATE_BATTLEFIELD_STATUS") then
			local status = GetBattlefieldStatus(...)
			if (status == "confirm") then
				self:SetAFK(false)
			end
		else
			self:SetAFK(false)
		end
		if(event == "PLAYER_REGEN_DISABLED") then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		end
		return
	end
	if(event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
	if(UnitIsAFK("player")) then
		self:SetAFK(true)
	else
		self:SetAFK(false)
	end
end

function AFK:Toggle()
	if(C.Misc.AFKCamera) then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent")
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
		self:RegisterEvent("LFG_PROPOSAL_SHOW", "OnEvent")
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "OnEvent")
		SetCVar("autoClearAFK", "1")
	else
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("LFG_PROPOSAL_SHOW")
		self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
	end
end

local function OnKeyDown(self, key)
	if(ignoreKeys[key]) then return end
	if printKeys[key] then
		Screenshot()
	else
		AFK:SetAFK(false)
		AFK:ScheduleTimer("OnEvent", 60)
	end
end

function AFK:LoopAnimations()
	if(KkthnxUIAFKPlayerModel.curAnimation == "wave") then
		KkthnxUIAFKPlayerModel:SetAnimation(69)
		KkthnxUIAFKPlayerModel.curAnimation = "dance"
		KkthnxUIAFKPlayerModel.startTime = GetTime()
		KkthnxUIAFKPlayerModel.duration = 300
		KkthnxUIAFKPlayerModel.isIdle = false
		KkthnxUIAFKPlayerModel.idleDuration = 120
	end
end

function AFK:Initialize()
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class]
	self.AFKMode = CreateFrame("Frame", "KkthnxUIAFKFrame")
	self.AFKMode:SetFrameLevel(1)
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)
	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.bottom:SetFrameLevel(0)
	self.AFKMode.bottom:SetTemplate("Transparent")
	self.AFKMode.bottom:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
	self.AFKMode.bottom:SetPoint("BOTTOM", self.AFKMode, "BOTTOM", 0, -4)
	self.AFKMode.bottom:SetWidth(GetScreenWidth() + (4 * 2))
	self.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 9.6))
	self.AFKMode.bottom.logo = self.AFKMode:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.logo:SetSize(512, 256)
	self.AFKMode.bottom.logo:SetPoint("CENTER", self.AFKMode.bottom, "CENTER", 0, 60)
	self.AFKMode.bottom.logo:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Logo")
	local factionGroup = UnitFactionGroup("player")

	--factionGroup = "Alliance"
	local size, offsetX, offsetY = 140, -20, -16
	local nameOffsetX, nameOffsetY = -10, -28
	if factionGroup == "Neutral" then
		factionGroup = "Panda"
		size, offsetX, offsetY = 90, 15, 10
		nameOffsetX, nameOffsetY = 20, -5
	end

	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", self.AFKMode.bottom, "BOTTOMLEFT", offsetX, offsetY)
	self.AFKMode.bottom.faction:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo")
	self.AFKMode.bottom.faction:SetSize(size, size)
	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.name:SetFont(C.Media.Font, 20)
	self.AFKMode.bottom.name:SetFormattedText("%s-%s", K.Name, K.Realm)
	self.AFKMode.bottom.name:SetPoint("TOPLEFT", self.AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)
	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.guild:SetFont(C.Media.Font, 20)
	self.AFKMode.bottom.guild:SetText(L["No Guild"])
	self.AFKMode.bottom.guild:SetPoint("TOPLEFT", self.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)
	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.time:SetFont(C.Media.Font, 20)
	self.AFKMode.bottom.time:SetText("00:00")
	self.AFKMode.bottom.time:SetPoint("TOPLEFT", self.AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)
	--Use this frame to control position of the model
	self.AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, self.AFKMode.bottom)
	self.AFKMode.bottom.modelHolder:SetSize(150, 150)
	self.AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)
	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "KkthnxUIAFKPlayerModel", self.AFKMode.bottom.modelHolder)
	self.AFKMode.bottom.model:SetPoint("CENTER", self.AFKMode.bottom.modelHolder, "CENTER")
	self.AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2) --YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame.
	self.AFKMode.bottom.model:SetCamDistanceScale(4.5) --Since the model frame is huge, we need to zoom out quite a bit.
	self.AFKMode.bottom.model:SetFacing(6)
	self.AFKMode.bottom.model:SetScript("OnUpdateModel", function(self)
		local timePassed = GetTime() - self.startTime
		if(timePassed > self.duration) and self.isIdle ~= true then
			self:SetAnimation(0)
			self.isIdle = true
			AFK.animTimer = AFK:ScheduleTimer("LoopAnimations", self.idleDuration)
		end
	end)
	self:Toggle()
	self.isActive = false
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function(self, event, ...)
	AFK:Initialize()
end)