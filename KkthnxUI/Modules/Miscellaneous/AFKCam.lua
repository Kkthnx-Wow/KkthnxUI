local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- Sourced: ElvUI (Elv)

local _G = _G
local math_floor = _G.math.floor
local string_format = _G.string.format

local C_PetBattles_IsInBattle = _G.C_PetBattles.IsInBattle
local CinematicFrame = _G.CinematicFrame
local CloseAllWindows = _G.CloseAllWindows
local CreateFrame = _G.CreateFrame
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetGuildInfo = _G.GetGuildInfo
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsMacClient = _G.IsMacClient
local MoveViewLeftStart = _G.MoveViewLeftStart
local MoveViewLeftStop = _G.MoveViewLeftStop
local MovieFrame = _G.MovieFrame
local PVEFrame_ToggleFrame = _G.PVEFrame_ToggleFrame
local Screenshot = _G.Screenshot
local SetCVar = _G.SetCVar
local UnitCastingInfo = _G.UnitCastingInfo
local UnitIsAFK = _G.UnitIsAFK

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
	printKeys[_G.KEY_PRINTSCREEN_MAC] = true
end

function Module:UpdateTimer()
	local time = GetTime() - Module.startTime
	Module.AFKMode.bottom.time:SetFormattedText("%02d:%02d", math_floor(time / 60), time % 60)
end

function Module:SetAFK(status)
	if status then
		MoveViewLeftStart(CAMERA_SPEED)
		Module.AFKMode:Show()
		CloseAllWindows()
		_G.UIParent:Hide()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo("player")
			Module.AFKMode.bottom.guild:SetFormattedText("%s-%s", guildName, guildRankName)
		else
			Module.AFKMode.bottom.guild:SetText("No Guild")
		end

		Module.AFKMode.bottom.model.curAnimation = "wave"
		Module.AFKMode.bottom.model.startTime = GetTime()
		Module.AFKMode.bottom.model.duration = 2.3
		Module.AFKMode.bottom.model:SetUnit("player")
		Module.AFKMode.bottom.model.isIdle = nil
		Module.AFKMode.bottom.model:SetAnimation(67)
		Module.AFKMode.bottom.model.idleDuration = 40
		Module.startTime = GetTime()
		Module.timer = K:ScheduleRepeatingTimer(Module.UpdateTimer, 1)

		Module.isAFK = true
	elseif Module.isAFK then
		_G.UIParent:Show()
		Module.AFKMode:Hide()
		MoveViewLeftStop()

		K:CancelTimer(Module.timer)
		K:CancelTimer(Module.animTimer)
		Module.AFKMode.bottom.time:SetText("00:00")

		if _G.PVEFrame:IsShown() then -- odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		Module.isAFK = false
	end
end

function Module:OnEvent(event, ...)
	if event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS" then
		if event ~= "UPDATE_BATTLEFIELD_STATUS" or (GetBattlefieldStatus(...) == "confirm") then
			Module:SetAFK(false)
		end

		if event == "PLAYER_REGEN_DISABLED" then
			Module:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		end

		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.OnEvent)
	end

	if not C["Misc"].AFKCamera or (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then
		return
	end

	if UnitCastingInfo("player") then -- Don't activate afk if player is crafting stuff, check back in 30 seconds
		K:ScheduleTimer(Module.OnEvent, 30)
		return
	end

	Module:SetAFK(UnitIsAFK("player") and not C_PetBattles_IsInBattle())
end

function Module:AFKToggle()
	if (C["Misc"].AFKCamera) then
		K:RegisterEvent("PLAYER_FLAGS_CHANGED", Module.OnEvent)
		K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.OnEvent)
		K:RegisterEvent("LFG_PROPOSAL_SHOW", Module.OnEvent)
		K:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", Module.OnEvent)
		SetCVar("autoClearAFK", "1")
	else
		K:UnregisterEvent("PLAYER_FLAGS_CHANGED", Module.OnEvent)
		K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.OnEvent)
		K:UnregisterEvent("LFG_PROPOSAL_SHOW", Module.OnEvent)
		K:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS", Module.OnEvent)
	end
end

local function OnKeyDown(_, key)
	if ignoreKeys[key] then
		return
	end

	if printKeys[key] then
		Screenshot()
	else
		Module:SetAFK(false)
		K:ScheduleTimer(Module.OnEvent, 60)
	end
end

function Module:LoopAnimations()
	local KKUI_AFKPlayerModel = _G.KKUI_AFKPlayerModel
	if KKUI_AFKPlayerModel.curAnimation == "wave" then
		KKUI_AFKPlayerModel:SetAnimation(69)
		KKUI_AFKPlayerModel.curAnimation = "dance"
		KKUI_AFKPlayerModel.startTime = GetTime()
		KKUI_AFKPlayerModel.duration = 300
		KKUI_AFKPlayerModel.isIdle = false
		KKUI_AFKPlayerModel.idleDuration = 120
	end
end

function Module:CreateAFKCam()
	local classColor = K.MyClassColor

	Module.AFKMode = CreateFrame("Frame", "KKUI_AFKFrame")
	Module.AFKMode:SetFrameLevel(1)
	Module.AFKMode:SetScale(_G.UIParent:GetScale())
	Module.AFKMode:SetAllPoints(_G.UIParent)
	Module.AFKMode:Hide()
	Module.AFKMode:EnableKeyboard(true)
	Module.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	Module.AFKMode.bottom = CreateFrame("Frame", nil, Module.AFKMode)
	Module.AFKMode.bottom:SetFrameLevel(0)
	Module.AFKMode.bottom:CreateBorder()
	Module.AFKMode.bottom:SetPoint("BOTTOM", Module.AFKMode, "BOTTOM", 0, -6)
	Module.AFKMode.bottom:SetWidth(GetScreenWidth() + (6 * 2))
	Module.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 10))

	Module.AFKMode.bottom.logo = Module.AFKMode:CreateTexture(nil, "OVERLAY")
	Module.AFKMode.bottom.logo:SetSize(320, 150)
	Module.AFKMode.bottom.logo:SetPoint("CENTER", Module.AFKMode.bottom, "CENTER", 0, 55)
	Module.AFKMode.bottom.logo:SetTexture(C["Media"].Logo)

	local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = K.Faction, 140, -20, -16, -10, -28
	if factionGroup == "Neutral" then
		factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = "Panda", 90, 15, 10, 20, -5
	end

	Module.AFKMode.bottom.faction = Module.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	Module.AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", Module.AFKMode.bottom, "BOTTOMLEFT", offsetX, offsetY)
	Module.AFKMode.bottom.faction:SetTexture(string_format([[Interface\Timer\%s-Logo]], factionGroup))
	Module.AFKMode.bottom.faction:SetSize(size, size)

	Module.AFKMode.bottom.name = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.name:FontTemplate(nil, 20)
	Module.AFKMode.bottom.name:SetFormattedText(classColor.."%s - %s", K.Name, K.Realm)
	Module.AFKMode.bottom.name:SetPoint("TOPLEFT", Module.AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)

	Module.AFKMode.bottom.playerInfo = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.playerInfo:FontTemplate(nil, 20)
	Module.AFKMode.bottom.playerInfo:SetText("Level".." "..K.Level.." - "..classColor..K.Class)
	Module.AFKMode.bottom.playerInfo:SetPoint("TOPLEFT", Module.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
	Module.AFKMode.bottom.playerInfo:SetTextColor(0.7, 0.7, 0.7)

	Module.AFKMode.bottom.guild = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.guild:FontTemplate(nil, 20)
	Module.AFKMode.bottom.guild:SetText("No Guild")
	Module.AFKMode.bottom.guild:SetPoint("TOPLEFT", Module.AFKMode.bottom.playerInfo, "BOTTOMLEFT", 0, -6)
	Module.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	Module.AFKMode.bottom.time = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.time:FontTemplate(nil, 20)
	Module.AFKMode.bottom.time:SetText("00:00")
	Module.AFKMode.bottom.time:SetPoint("BOTTOM", Module.AFKMode.bottom, "BOTTOM", 0, 20)
	Module.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	-- Use this frame to control position of the model
	Module.AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, Module.AFKMode.bottom)
	Module.AFKMode.bottom.modelHolder:SetSize(150, 150)
	Module.AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", Module.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)

	Module.AFKMode.bottom.model = CreateFrame("PlayerModel", "KKUI_AFKPlayerModel", Module.AFKMode.bottom.modelHolder)
	Module.AFKMode.bottom.model:SetPoint("CENTER", Module.AFKMode.bottom.modelHolder, "CENTER")
	Module.AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2) -- YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame.
	Module.AFKMode.bottom.model:SetCamDistanceScale(4.5) -- Since the model frame is huge, we need to zoom out quite a bit.
	Module.AFKMode.bottom.model:SetFacing(6)
	Module.AFKMode.bottom.model:SetScript("OnUpdate", function(model)
		local timePassed = GetTime() - model.startTime
		if (timePassed > model.duration) and model.isIdle ~= true then
			model:SetAnimation(0)
			model.isIdle = true
			Module.animTimer = K:ScheduleTimer(Module.LoopAnimations, model.idleDuration)
		end
	end)

	Module:AFKToggle()

	Module.isActive = false
end