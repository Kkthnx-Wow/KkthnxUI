--[[-----------------------------------------------------------------------------
-- Quest objective icon and progress on NPC nameplates (Midnight-safe tooltip parse).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")
local NP = Module.NP

local C_QuestLog_UnitIsRelatedToActiveQuest = C_QuestLog.UnitIsRelatedToActiveQuest
local C_TooltipInfo_GetUnit = C_TooltipInfo.GetUnit
local C_Timer_After = C_Timer.After
local Enum = Enum
local IsInInstance = IsInInstance
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local GameTooltip = GameTooltip
local TooltipDataProcessor = TooltipDataProcessor
local UnitTokenFromGUID = UnitTokenFromGUID

local CanAccess = K.CanAccessValue
local NotSecretTable = K.NotSecretTable
local NotSecret = K.NotSecret

local QUEST_TEXTURE = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\NameplateQuest.png"
local LINE_PLAYER = Enum.TooltipDataLineType.QuestPlayer
local LINE_OBJECTIVE = Enum.TooltipDataLineType.QuestObjective

local MODE_ALWAYS, MODE_TARGET, MODE_HOVER, MODE_KEY, MODE_NEVER = 1, 2, 3, 4, 5
local MOD_KEYS = { IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown }

local questFrames = {}
local questModifierDown = false
local lastHoverFrame
local questEventsRegistered = false
local questHoverHooked = false

local function checkInstanceStatus()
	NP.isInInstance = IsInInstance()
end

local function ScheduleQuestRefresh(frame)
	if frame._questRefreshScheduled then
		return
	end
	frame._questRefreshScheduled = true
	C_Timer_After(0.2, function()
		frame._questRefreshScheduled = nil
		if frame.unit and C["Nameplate"].QuestIndicator then
			Module.UpdateQuestUnit(frame, frame.unit)
		end
	end)
end

local function FormatQuestProgressText(text)
	if not (text and CanAccess(text)) then
		return nil
	end

	if C["Nameplate"].QuestProgressFormat == 2 then
		local done, req = text:match("(%d+)/(%d+)")
		done, req = tonumber(done), tonumber(req)
		if done and req and done < req then
			return tostring(req - done)
		end
		local pct = tonumber(text:match("(%d+)%%"))
		if pct and pct < 100 then
			return tostring(100 - pct) .. "%"
		end
		return nil
	end

	return text:match("%d+/%d+") or text:match("%d+%%")
end

function Module:UpdateQuestProgressVisibility(frame)
	if not frame or not frame.questCount then
		return
	end

	if not frame._questHasProgress then
		frame.questCount:Hide()
		return
	end

	local mode = C["Nameplate"].QuestProgressMode or MODE_ALWAYS
	local show
	if mode == MODE_NEVER then
		show = false
	elseif mode == MODE_ALWAYS then
		show = true
	elseif mode == MODE_TARGET then
		show = frame.unit and K.UnitIsUnit("target", frame.unit)
	elseif mode == MODE_HOVER then
		show = frame._questHover
	elseif mode == MODE_KEY then
		show = questModifierDown
	else
		show = true
	end

	frame.questCount:SetShown(show and true or false)
end

function Module:RefreshAllQuestIndicators()
	for frame in pairs(questFrames) do
		if frame.unit and frame:IsShown() then
			Module.UpdateQuestUnit(frame, frame.unit)
		end
		Module:UpdateQuestProgressVisibility(frame)
	end
end

local function OnQuestTargetChanged()
	if (C["Nameplate"].QuestProgressMode or MODE_ALWAYS) ~= MODE_TARGET then
		return
	end
	for frame in pairs(questFrames) do
		if frame:IsShown() then
			Module:UpdateQuestProgressVisibility(frame)
		end
	end
end

local function OnQuestModifierChanged()
	if (C["Nameplate"].QuestProgressMode or MODE_ALWAYS) ~= MODE_KEY then
		return
	end
	local keyIndex = C["Nameplate"].QuestProgressModifier or 1
	local keyDown = MOD_KEYS[keyIndex]
	questModifierDown = keyDown and keyDown() or false
	for frame in pairs(questFrames) do
		if frame:IsShown() then
			Module:UpdateQuestProgressVisibility(frame)
		end
	end
end

local function InstallQuestHoverHook()
	if questHoverHooked or not TooltipDataProcessor then
		return
	end
	questHoverHooked = true

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
		if not C["Nameplate"].QuestIndicator or (C["Nameplate"].QuestProgressMode or MODE_ALWAYS) ~= MODE_HOVER or NP.isInInstance then
			return
		end

		if lastHoverFrame then
			lastHoverFrame._questHover = false
			Module:UpdateQuestProgressVisibility(lastHoverFrame)
			lastHoverFrame = nil
		end

		local data = tooltip.infoList and tooltip.infoList[1] and tooltip.infoList[1].tooltipData
		local guid = data and data.guid
		if not (guid and CanAccess(guid) and UnitTokenFromGUID) then
			return
		end

		local unit = UnitTokenFromGUID(guid)
		for frame in pairs(questFrames) do
			if frame:IsShown() and frame.unit == unit then
				frame._questHover = true
				lastHoverFrame = frame
				Module:UpdateQuestProgressVisibility(frame)
				break
			end
		end
	end)

	GameTooltip:HookScript("OnHide", function()
		if lastHoverFrame then
			lastHoverFrame._questHover = false
			Module:UpdateQuestProgressVisibility(lastHoverFrame)
			lastHoverFrame = nil
		end
	end)
end

local function RegisterQuestModuleEvents()
	if questEventsRegistered then
		return
	end
	questEventsRegistered = true

	K:RegisterEvent("PLAYER_TARGET_CHANGED", OnQuestTargetChanged)
	K:RegisterEvent("MODIFIER_STATE_CHANGED", OnQuestModifierChanged)
end

function Module:QuestIconCheck()
	if not C["Nameplate"].QuestIndicator then
		return
	end

	checkInstanceStatus()
	InstallQuestHoverHook()
	RegisterQuestModuleEvents()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", checkInstanceStatus)
end

function Module:UpdateQuestUnit(_, unit)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	unit = unit or self.unit
	local showParty = C["Nameplate"].QuestShowPartyQuest ~= false

	if NP.isInInstance then
		self._questHasProgress = false
		self.questCount:SetText("")
		self.questCount:Hide()
		local related = C_QuestLog_UnitIsRelatedToActiveQuest(unit)
		if NotSecret(related) and related then
			self.questIcon:SetTexture(QUEST_TEXTURE)
			self.questIcon:SetTexCoord(0, 0.5, 0.25, 0.75)
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
		return
	end

	local questProgress
	local isPartyQuest = false
	local isPlayerQuest = false
	local playerName = K.Name

	local data = C_TooltipInfo_GetUnit(unit)
	if data and NotSecretTable(data) then
		local currentPlayerIsPlayer = true
		for i = 1, #data.lines do
			local lineData = data.lines[i]
			if lineData.type == LINE_PLAYER then
				local linePlayerName = lineData.leftText
				if CanAccess(linePlayerName) then
					currentPlayerIsPlayer = linePlayerName == playerName
				end
			elseif lineData.type == LINE_OBJECTIVE then
				local text = lineData.leftText
				local completed = lineData.completed
				if CanAccess(completed) and completed then
					-- skip completed objectives
				elseif text and CanAccess(text) and (currentPlayerIsPlayer or showParty) then
					local progressText = FormatQuestProgressText(text)
					if progressText then
						if not questProgress or currentPlayerIsPlayer then
							questProgress = progressText
						end
						if currentPlayerIsPlayer then
							isPlayerQuest = true
						else
							isPartyQuest = true
						end
					elseif not questProgress then
						if currentPlayerIsPlayer then
							isPlayerQuest = true
						elseif showParty then
							isPartyQuest = true
						end
					end
				end
			end
		end
	end

	self._questHasProgress = questProgress ~= nil

	if questProgress then
		self.questCount:SetText(questProgress)
		if not isPlayerQuest and isPartyQuest then
			self.questCount:SetTextColor(0.67, 0.67, 0.67)
		else
			self.questCount:SetTextColor(1, 1, 1)
		end
		self.questIcon:Hide()
		Module:UpdateQuestProgressVisibility(self)
	else
		self.questCount:SetText("")
		self.questCount:Hide()
		local related = C_QuestLog_UnitIsRelatedToActiveQuest(unit)
		if (NotSecret(related) and related) or isPlayerQuest then
			self.questIcon:SetTexture(QUEST_TEXTURE)
			self.questIcon:SetTexCoord(0, 0.5, 0.25, 0.75)
			self.questIcon:Show()
		elseif isPartyQuest and showParty then
			self.questIcon:SetTexture(QUEST_TEXTURE)
			self.questIcon:SetTexCoord(0.5, 1, 0, 0.5)
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

function Module:AddQuestIcon(self)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	self.questIcon = self:CreateTexture(nil, "OVERLAY", nil, 2)
	self.questIcon:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
	self.questIcon:SetSize(18, 18)
	self.questIcon:Hide()

	self.questCount = K.CreateFontString(self, 14, "", nil, "LEFT", 0, 0)
	self.questCount:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)

	questFrames[self] = true
	self._questHover = false
	self._questHasProgress = false

	local function OnQuestLogEvent(frame, event, ...)
		if event == "QUEST_LOG_UPDATE" or event == "UNIT_QUEST_LOG_CHANGED" then
			ScheduleQuestRefresh(frame)
			return
		end
		Module.UpdateQuestUnit(frame, ...)
	end

	self:RegisterEvent("QUEST_LOG_UPDATE", OnQuestLogEvent, true)
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED", OnQuestLogEvent, true)
	self:RegisterEvent("UNIT_NAME_UPDATE", Module.UpdateQuestUnit, true)
end
