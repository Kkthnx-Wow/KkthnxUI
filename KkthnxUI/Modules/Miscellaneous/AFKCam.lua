local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("AFKCam", "AceEvent-3.0", "AceTimer-3.0")

-- Sourced: ElvUI (Elvz)

local _G = _G
local math_floor = math.floor
local math_random = math.random

local CinematicFrame = _G.CinematicFrame
local CloseAllWindows = _G.CloseAllWindows
local CreateFrame = _G.CreateFrame
local DND = _G.DND
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetColoredName = _G.GetColoredName
local GetGuildInfo = _G.GetGuildInfo
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsMacClient = _G.IsMacClient
local IsShiftKeyDown = _G.IsShiftKeyDown
local MoveViewLeftStart = _G.MoveViewLeftStart
local MoveViewLeftStop = _G.MoveViewLeftStop
local MovieFrame = _G.MovieFrame
local PVEFrame_ToggleFrame = _G.PVEFrame_ToggleFrame
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local RemoveExtraSpaces = _G.RemoveExtraSpaces
local Screenshot = _G.Screenshot
local SetCVar = _G.SetCVar
local UnitCastingInfo = _G.UnitCastingInfo
local UnitFactionGroup = _G.UnitFactionGroup
local UnitIsAFK = _G.UnitIsAFK

-- GLOBALS: UIParent, PVEFrame, AFKPlayerModel, CUSTOM_CLASS_COLORS

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

function Module:UpdateTimer()
	local time = GetTime() - self.startTime
	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", math_floor(time / 60), time % 60)
end

function Module:SetAFK(status)
	if (status) then
		self.AFKMode:Show()
		CloseAllWindows()
		UIParent:Hide()

		if (IsInGuild()) then
			local guildName, guildRankName = GetGuildInfo("player")
			self.AFKMode.bottom.guild:SetFormattedText("%s - %s", guildName, guildRankName)
		else
			self.AFKMode.bottom.guild:SetText("No Guild")
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

		if (PVEFrame:IsShown()) then -- odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		self.isAFK = false
	end
end

function Module:OnEvent(event, ...)
	if (event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS") then
		if (event == "UPDATE_BATTLEFIELD_STATUS") then
			local status = GetBattlefieldStatus(...)
			if (status == "confirm") then
				self:SetAFK(false)
			end
		else
			self:SetAFK(false)
		end

		if (event == "PLAYER_REGEN_DISABLED") then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		end
		return
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if (not C["Misc"].AFKCamera) then return end
	if (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then return end
	if (UnitCastingInfo("player") ~= nil) then
		--Don't activate afk if player is crafting stuff, check back in 30 seconds
		self:ScheduleTimer("OnEvent", 30)
		return
	end

	if (UnitIsAFK("player")) then
		self:SetAFK(true)
	else
		self:SetAFK(false)
	end
end


function Module:Toggle()
	if (C["Misc"].AFKCamera) then
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
	if (ignoreKeys[key]) then return end
	if printKeys[key] then
		Screenshot()
	else
		Module:SetAFK(false)
		Module:ScheduleTimer("OnEvent", 60)
	end
end

function Module:LoopAnimations()
	if (AFKPlayerModel.curAnimation == "wave") then
		AFKPlayerModel:SetAnimation(69)
		AFKPlayerModel.curAnimation = "dance"
		AFKPlayerModel.startTime = GetTime()
		AFKPlayerModel.duration = 300
		AFKPlayerModel.isIdle = false
		AFKPlayerModel.idleDuration = 120
	end
end

function Module:OnInitialize()
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class]

	self.AFKMode = CreateFrame("Frame", "AFKFrame")
	self.AFKMode:SetFrameLevel(1)
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.bottom:SetFrameLevel(0)
	self.AFKMode.bottom:SetTemplate("Transparent")
	self.AFKMode.bottom:SetPoint("BOTTOM", self.AFKMode, "BOTTOM", 0, -2) -- Might be 2
	self.AFKMode.bottom:SetWidth(GetScreenWidth() + (2 * 2)) -- Might be 2
	self.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 10))

	self.AFKMode.bottom.logo = self.AFKMode:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.logo:SetSize(320, 150)
	self.AFKMode.bottom.logo:SetPoint("CENTER", self.AFKMode.bottom, "CENTER", 0, 54)
	self.AFKMode.bottom.logo:SetTexture(C["Media"].Logo)

	self.AFKMode.bottom.version = self.AFKMode:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.version:FontTemplate(nil, 20)
	self.AFKMode.bottom.version:SetText("v"..K.Version)
	self.AFKMode.bottom.version:SetPoint("TOP", self.AFKMode.bottom.logo, "BOTTOM", 0, 4)
	self.AFKMode.bottom.version:SetTextColor(0.7, 0.7, 0.7)

	local factionGroup = UnitFactionGroup("player")
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
	self.AFKMode.bottom.name:FontTemplate(nil, 20)
	self.AFKMode.bottom.name:SetFormattedText("%s - %s", K.Name, K.Realm)
	self.AFKMode.bottom.name:SetPoint("TOPLEFT", self.AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)

	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.guild:FontTemplate(nil, 20)
	self.AFKMode.bottom.guild:SetText("No Guild")
	self.AFKMode.bottom.guild:SetPoint("TOPLEFT", self.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.time:FontTemplate(nil, 20)
	self.AFKMode.bottom.time:SetText("00:00")
	self.AFKMode.bottom.time:SetPoint("TOPLEFT", self.AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, self.AFKMode.bottom)
	self.AFKMode.bottom.modelHolder:SetSize(150, 150)
	self.AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)

	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "AFKPlayerModel", self.AFKMode.bottom.modelHolder)
	self.AFKMode.bottom.model:SetPoint("CENTER", self.AFKMode.bottom.modelHolder, "CENTER")
	self.AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2) -- YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame.
	self.AFKMode.bottom.model:SetCamDistanceScale(4) -- Since the model frame is huge, we need to zoom out quite a bit.
	self.AFKMode.bottom.model:SetFacing(6)
	self.AFKMode.bottom.model:SetScript("OnUpdate", function(self)
		local timePassed = GetTime() - self.startTime
		if (timePassed > self.duration) and self.isIdle ~= true then
			self:SetAnimation(0)
			self.isIdle = true
			Module.animTimer = Module:ScheduleTimer("LoopAnimations", self.idleDuration)
		end
	end)

	self:Toggle()
	self.isActive = false
end