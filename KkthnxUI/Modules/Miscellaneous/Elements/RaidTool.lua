--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Provides a comprehensive tool for raid management, including markers, roll tracking, and buff checks.
-- - Design: Implements a mover-based header with various flyout panels for group-wide utilities.
-- - Events: GROUP_ROSTER_UPDATE, PLAYER_REGEN_ENABLED, READY_CHECK, READY_CHECK_FINISHED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local math_ceil = _G.math.ceil
local math_min = _G.math.min
local mod = _G.mod
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format
local string_split = _G.string.split
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe

local _G = _G
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local C_AddOns_LoadAddOn = _G.C_AddOns.LoadAddOn
local C_PartyInfo_ConvertToParty = _G.C_PartyInfo.ConvertToParty
local C_PartyInfo_ConvertToRaid = _G.C_PartyInfo.ConvertToRaid
local C_PartyInfo_LeaveParty = _G.C_PartyInfo.LeaveParty
local C_Spell_GetSpellCharges = _G.C_Spell.GetSpellCharges
local C_Spell_GetSpellName = _G.C_Spell.GetSpellName
local C_Spell_GetSpellTexture = _G.C_Spell.GetSpellTexture
local C_UnitAuras_GetAuraDataBySpellName = _G.C_UnitAuras.GetAuraDataBySpellName
local ClearRaidMarker = _G.ClearRaidMarker
local CreateFrame = _G.CreateFrame
local DoReadyCheck = _G.DoReadyCheck
local GameTooltip = _G.GameTooltip
local GetInstanceInfo = _G.GetInstanceInfo
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetRaidRosterInfo = _G.GetRaidRosterInfo
local GetReadyCheckStatus = _G.GetReadyCheckStatus
local GetTime = _G.GetTime
local HasLFGRestrictions = _G.HasLFGRestrictions
local InCombatLockdown = _G.InCombatLockdown
local InitiateRolePoll = _G.InitiateRolePoll
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local IsLFGComplete = _G.IsLFGComplete
local IsPartyLFG = _G.IsPartyLFG
local IsShiftKeyDown = _G.IsShiftKeyDown
local SendChatMessage = _G.SendChatMessage
local SetRaidTarget = _G.SetRaidTarget
local ToggleFriendsFrame = _G.ToggleFriendsFrame
local UninviteUnit = _G.UninviteUnit
local UnitExists = _G.UnitExists
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitName = _G.UnitName

function Module:updateRaidToolVisibility(frame)
	if IsInGroup() then
		frame:Show()
	else
		frame:Hide()
	end
end

function Module:createRaidToolHeader()
	local raidHeader = CreateFrame("Button", nil, _G.UIParent)
	raidHeader:SetSize(120, 28)
	raidHeader:SetFrameLevel(2)
	raidHeader:SkinButton()
	K.Mover(raidHeader, "Raid Tool", "RaidManager", { "TOP", _G.UIParent, "TOP", 0, -4 })

	raidHeader:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("Raid Tool", 0, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(K.LeftButton .. K.InfoColor .. "Toggle Menu")
		GameTooltip:AddDoubleLine(K.RightButton .. K.InfoColor .. "Leave Group (double-click)")
		if not (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
			GameTooltip:AddLine("Leader or Assistant required for some actions", 1, 0.2, 0.2)
		end
		GameTooltip:Show()
	end)
	raidHeader:HookScript("OnLeave", K.HideTooltip)

	Module:updateRaidToolVisibility(raidHeader)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", function()
		Module:updateRaidToolVisibility(raidHeader)
	end)

	raidHeader:RegisterForClicks("AnyUp")
	raidHeader:SetScript("OnClick", function(self, mouseButton)
		if mouseButton == "LeftButton" then
			local raidMenu = self.menu
			K.TogglePanel(raidMenu)

			if raidMenu:IsShown() then
				raidMenu:ClearAllPoints()
				if Module:isFrameOnTop(self) then
					raidMenu:SetPoint("TOP", self, "BOTTOM", 0, -6)
				else
					raidMenu:SetPoint("BOTTOM", self, "TOP", 0, 6)
				end

				self.buttons[2].text:SetText(IsInRaid() and _G.CONVERT_TO_PARTY or _G.CONVERT_TO_RAID)
				if raidMenu.UpdateState then
					raidMenu:UpdateState()
				end
			end
		end
	end)
	raidHeader:SetScript("OnDoubleClick", function(_, mouseButton)
		if mouseButton == "RightButton" and (IsPartyLFG() and IsLFGComplete() or not IsInInstance()) then
			C_PartyInfo_LeaveParty()
		end
	end)

	return raidHeader
end

function Module:isFrameOnTop(frame)
	local centerY = select(2, frame:GetCenter())
	local screenHeight = _G.UIParent:GetTop()
	return centerY > screenHeight / 2
end

-- REASON: Determines the maximum allowed subgroup index for role counting based on the current instance difficulty.
function Module:getRaidMaxGroupSize()
	local _, instanceType, difficultyID = GetInstanceInfo()
	if (instanceType == "party" or instanceType == "scenario") and not IsInRaid() then
		return 1
	elseif instanceType ~= "raid" then
		return 8
	elseif difficultyID == 8 or difficultyID == 1 or difficultyID == 2 then
		return 1
	elseif difficultyID == 14 or difficultyID == 15 or (difficultyID == 24 and instanceType == "raid") then
		return 6
	elseif difficultyID == 16 then
		return 4
	elseif difficultyID == 3 or difficultyID == 5 then
		return 2
	elseif difficultyID == 9 then
		return 8
	else
		return 5
	end
end

function Module:createRaidRoleCounter(parentFrame)
	local ROLE_FILE_NAMES = { "TANK", "HEALER", "DAMAGER" }
	local counterFrame = CreateFrame("Frame", nil, parentFrame)
	counterFrame:SetAllPoints()
	local roleIconFrames = {}
	for i = 1, 3 do
		roleIconFrames[i] = counterFrame:CreateTexture(nil, "OVERLAY")
		roleIconFrames[i]:SetPoint("LEFT", 36 * i - 27, 0)
		roleIconFrames[i]:SetSize(16, 16)
		K.ReskinSmallRole(roleIconFrames[i], ROLE_FILE_NAMES[i])
		roleIconFrames[i].text = K.CreateFontString(counterFrame, 13, "0", "")
		roleIconFrames[i].text:ClearAllPoints()
		roleIconFrames[i].text:SetPoint("CENTER", roleIconFrames[i], "RIGHT", 8, 0)
	end

	local groupRoleCounts = {
		totalTANK = 0,
		totalHEALER = 0,
		totalDAMAGER = 0,
	}

	local function onRosterUpdateRoleCount()
		groupRoleCounts.totalTANK = 0
		groupRoleCounts.totalHEALER = 0
		groupRoleCounts.totalDAMAGER = 0

		local maxSubgroup = Module:getRaidMaxGroupSize()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead, _, _, unitRole = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxSubgroup and not isDead and unitRole ~= "NONE" then
				groupRoleCounts["total" .. unitRole] = groupRoleCounts["total" .. unitRole] + 1
			end
		end

		roleIconFrames[1].text:SetText(groupRoleCounts.totalTANK)
		roleIconFrames[2].text:SetText(groupRoleCounts.totalHEALER)
		roleIconFrames[3].text:SetText(groupRoleCounts.totalDAMAGER)
	end

	local counterEventList = {
		"GROUP_ROSTER_UPDATE",
		"UPDATE_ACTIVE_BATTLEFIELD",
		"UNIT_FLAGS",
		"PLAYER_FLAGS_CHANGED",
		"PLAYER_ENTERING_WORLD",
	}
	for _, eventName in next, counterEventList do
		K:RegisterEvent(eventName, onRosterUpdateRoleCount)
	end

	parentFrame.roleFrame = counterFrame
end

-- REASON: Monitors and displays Combat Resurrection charges and cooldown timer in a dedicated raid tool panel.
function Module:updateCombatResTimer(elapsedTime)
	self.elapsedSinceLastUpdate = (self.elapsedSinceLastUpdate or 0) + elapsedTime
	if self.elapsedSinceLastUpdate > 0.1 then
		local spellChargeInfo = C_Spell_GetSpellCharges(20484)
		local currentCharges = spellChargeInfo and spellChargeInfo.currentCharges
		local cooldownStart = spellChargeInfo and spellChargeInfo.cooldownStartTime
		local cooldownDuration = spellChargeInfo and spellChargeInfo.cooldownDuration

		if currentCharges then
			local remainingTime = cooldownDuration - (GetTime() - cooldownStart)
			if remainingTime < 0 then
				self.Timer:SetText("--:--")
			else
				self.Timer:SetFormattedText("%d:%.2d", remainingTime / 60, remainingTime % 60)
			end
			self.Count:SetText(currentCharges)
			if currentCharges == 0 then
				self.Count:SetTextColor(1, 0, 0)
			else
				self.Count:SetTextColor(0, 1, 0)
			end
			self.__owner.resFrame:SetAlpha(1)
			self.__owner.roleFrame:SetAlpha(0)
		else
			self.__owner.resFrame:SetAlpha(0)
			self.__owner.roleFrame:SetAlpha(1)
		end

		self.elapsedSinceLastUpdate = 0
	end
end

function Module:createCombatResMonitor(parentFrame)
	local monitorFrame = CreateFrame("Frame", nil, parentFrame)
	monitorFrame:SetAllPoints()
	monitorFrame:SetAlpha(0)
	local resIconFrame = CreateFrame("Frame", nil, monitorFrame)
	resIconFrame:SetSize(22, 22)
	resIconFrame:SetPoint("LEFT", 5, 0)

	resIconFrame.Icon = resIconFrame:CreateTexture(nil, "ARTWORK")
	resIconFrame.Icon:SetTexture(C_Spell_GetSpellTexture(20484))
	resIconFrame.Icon:SetAllPoints()
	resIconFrame.Icon:SetTexCoord(_G.unpack(K.TexCoords))
	resIconFrame.__owner = parentFrame

	resIconFrame.Count = K.CreateFontString(resIconFrame, 16, "0", "")
	resIconFrame.Count:ClearAllPoints()
	resIconFrame.Count:SetPoint("LEFT", resIconFrame, "RIGHT", 10, 0)
	resIconFrame.Timer = K.CreateFontString(monitorFrame, 16, "00:00", "", false, "RIGHT", -5, 0)
	resIconFrame:SetScript("OnUpdate", Module.updateCombatResTimer)

	parentFrame.resFrame = monitorFrame
end

function Module:createReadyCheckMonitor(parentFrame)
	local readyCheckFrame = CreateFrame("Frame", nil, parentFrame)
	readyCheckFrame:SetPoint("TOP", parentFrame, "BOTTOM", 0, -6)
	readyCheckFrame:SetSize(120, 50)
	readyCheckFrame:Hide()
	readyCheckFrame:SetScript("OnMouseUp", function(self)
		self:Hide()
	end)
	readyCheckFrame:CreateBorder()
	K.CreateFontString(readyCheckFrame, 14, _G.READY_CHECK, "", true, "TOP", 0, -8)
	local readyCheckText = K.CreateFontString(readyCheckFrame, 14, "", "", false, "TOP", 0, -28)

	local readyCount, totalCount
	local function hideReadyCheckFrame()
		readyCheckFrame:Hide()
		readyCheckText:SetText("")
		readyCount, totalCount = 0, 0
	end

	local function onReadyCheckUpdate(eventName)
		if eventName == "READY_CHECK_FINISHED" then
			if readyCount == totalCount then
				readyCheckText:SetTextColor(0, 1, 0)
			else
				readyCheckText:SetTextColor(1, 0, 0)
			end
			K.Delay(5, hideReadyCheckFrame)
		else
			readyCount, totalCount = 0, 0

			readyCheckFrame:ClearAllPoints()
			if Module:isFrameOnTop(parentFrame) then
				readyCheckFrame:SetPoint("TOP", parentFrame, "BOTTOM", 0, -6)
			else
				readyCheckFrame:SetPoint("BOTTOM", parentFrame, "TOP", 0, 6)
			end
			readyCheckFrame:Show()

			local maxSubgroup = Module:getRaidMaxGroupSize()
			for i = 1, GetNumGroupMembers() do
				local name, _, subgroup, _, _, _, _, online = GetRaidRosterInfo(i)
				if name and online and subgroup <= maxSubgroup then
					totalCount = totalCount + 1
					local readyStatus = GetReadyCheckStatus(name)
					if readyStatus and readyStatus == "ready" then
						readyCount = readyCount + 1
					end
				end
			end
			readyCheckText:SetText(readyCount .. " / " .. totalCount)
			if readyCount == totalCount then
				readyCheckText:SetTextColor(0, 1, 0)
			else
				readyCheckText:SetTextColor(1, 1, 0)
			end
		end
	end
	K:RegisterEvent("READY_CHECK", onReadyCheckUpdate)
	K:RegisterEvent("READY_CHECK_CONFIRM", onReadyCheckUpdate)
	K:RegisterEvent("READY_CHECK_FINISHED", onReadyCheckUpdate)
end

function Module:createRaidBuffChecker(parentFrame)
	local buffCheckerButton = CreateFrame("Button", nil, parentFrame)
	buffCheckerButton:SetPoint("RIGHT", parentFrame, "LEFT", -6, 0)
	buffCheckerButton:SetSize(28, 28)
	buffCheckerButton:SkinButton()

	local checkIcon = buffCheckerButton:CreateTexture(nil, "ARTWORK")
	checkIcon:SetPoint("TOPLEFT", buffCheckerButton, 4, -4)
	checkIcon:SetPoint("BOTTOMRIGHT", buffCheckerButton, -4, 4)
	checkIcon:SetAtlas("UI-QuestTracker-Tracker-Check")
	checkIcon:SetDesaturated(true)

	local BUFF_CATEGORY_NAMES = { L["Flask"], L["Food"], _G.SPELL_STAT4_NAME, _G.RAID_BUFF_2, _G.RAID_BUFF_3, _G.RUNES }
	local playersMissingBuffs, BUFF_CHECK_GROUPS, playerCount = {}, 6, 0
	for i = 1, BUFF_CHECK_GROUPS do
		playersMissingBuffs[i] = {}
	end

	-- SG: Cache spell names for buff groups
	local spellNameCache = {}
	local groupBuffNameCache = {}
	local function getSpellNameByID(spellIDValue)
		local spellNameText = spellNameCache[spellIDValue]
		if not spellNameText then
			spellNameText = C_Spell_GetSpellName(spellIDValue)
			spellNameCache[spellIDValue] = spellNameText
		end
		return spellNameText
	end

	local function getGroupBuffNamesByIndex(groupIndex)
		local buffNameList = groupBuffNameCache[groupIndex]
		if not buffNameList then
			buffNameList = {}
			local spellIDTable = C.RaidUtilityBuffCheckList[groupIndex]
			for i = 1, #spellIDTable do
				buffNameList[i] = getSpellNameByID(spellIDTable[i])
			end
			groupBuffNameCache[groupIndex] = buffNameList
		end
		return buffNameList
	end

	local function clearBuffCaches()
		table_wipe(spellNameCache)
		table_wipe(groupBuffNameCache)
	end
	K:RegisterEvent("SPELLS_CHANGED", clearBuffCaches)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", clearBuffCaches)

	local isDebugModeActive = false
	local function sendRaidMessage(messageContent)
		if isDebugModeActive then
			K.Print(messageContent)
		else
			SendChatMessage(messageContent, K.CheckChat())
		end
	end

	local messageBuffer = {}
	local function reportMissingBuffs(categoryIndex)
		local missingCount = #playersMissingBuffs[categoryIndex]
		if missingCount > 0 then
			if missingCount >= playerCount then
				sendRaidMessage(L["Lack"] .. " " .. BUFF_CATEGORY_NAMES[categoryIndex] .. ": " .. "Everyone")
			elseif missingCount >= 5 and categoryIndex > 2 then
				sendRaidMessage(L["Lack"] .. " " .. BUFF_CATEGORY_NAMES[categoryIndex] .. ": " .. string_format(L["%s players"], missingCount))
			else
				local reportPrefix = L["Lack"] .. " " .. BUFF_CATEGORY_NAMES[categoryIndex] .. ": "
				local currentLineLength = 0
				local bufferCountCount = 0
				for i = 1, missingCount do
					local playerName = playersMissingBuffs[categoryIndex][i]
					local nameLength = #playerName + 2
					if currentLineLength + nameLength > 220 and bufferCountCount > 0 then
						sendRaidMessage(reportPrefix .. _G.table.concat(messageBuffer, ", ", 1, bufferCountCount))
						table_wipe(messageBuffer)
						bufferCountCount = 0
						currentLineLength = 0
					end
					bufferCountCount = bufferCountCount + 1
					messageBuffer[bufferCountCount] = playerName
					currentLineLength = currentLineLength + nameLength
				end
				if bufferCountCount > 0 then
					sendRaidMessage(reportPrefix .. _G.table.concat(messageBuffer, ", ", 1, bufferCountCount))
					table_wipe(messageBuffer)
				end
			end
		end
	end

	-- REASON: Scans the raid roster to identify players missing essential buffs (flask, food, priority raid buffs, runes).
	local function scanRaidBuffs()
		for i = 1, BUFF_CHECK_GROUPS do
			table_wipe(playersMissingBuffs[i])
		end
		playerCount = 0

		local maxSubgroupSize = Module:getRaidMaxGroupSize()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxSubgroupSize and not isDead then
				playerCount = playerCount + 1
				for j = 1, BUFF_CHECK_GROUPS do
					local hasActiveBuff = false
					local buffNamesForCategory = getGroupBuffNamesByIndex(j)
					for k = 1, #buffNamesForCategory do
						local buffName = buffNamesForCategory[k]
						if buffName and C_UnitAuras_GetAuraDataBySpellName(name, buffName) then
							hasActiveBuff = true
							break
						end
					end
					if not hasActiveBuff then
						local shortName = string_split("-", name)
						table_insert(playersMissingBuffs[j], shortName)
					end
				end
			end
		end

		if not C["Misc"].RMRune then
			table_wipe(playersMissingBuffs[BUFF_CHECK_GROUPS])
		end

		if #playersMissingBuffs[1] == 0 and #playersMissingBuffs[2] == 0 and #playersMissingBuffs[3] == 0 and #playersMissingBuffs[4] == 0 and #playersMissingBuffs[5] == 0 and #playersMissingBuffs[6] == 0 then
			sendRaidMessage(L["All Buffs Ready"])
		else
			sendRaidMessage(L["Raid Buff Checker"])
			for i = 1, 5 do
				reportMissingBuffs(i)
			end
			if C["Misc"].RMRune then
				reportMissingBuffs(BUFF_CHECK_GROUPS)
			end
		end
	end

	local isMRTLoaded = C_AddOns_IsAddOnLoaded("MRT")

	buffCheckerButton:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("Raid Tool", 0, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(K.LeftButton .. K.InfoColor .. "Check raid buffs")
		if isMRTLoaded then
			GameTooltip:AddDoubleLine(K.RightButton .. K.InfoColor .. L["MRT Potion Check"])
		end
		GameTooltip:Show()
	end)
	buffCheckerButton:HookScript("OnLeave", K.HideTooltip)

	buffCheckerButton:HookScript("OnMouseDown", function(_, mouseButton)
		if mouseButton == "LeftButton" then
			scanRaidBuffs()
		elseif isMRTLoaded then
			_G.SlashCmdList["mrtSlash"]("potionchat")
		end
	end)
end

function Module:createCountdownButton(parentFrame)
	local countdownButton = CreateFrame("Button", nil, parentFrame)
	countdownButton:SetPoint("LEFT", parentFrame, "RIGHT", 6, 0)
	countdownButton:SetSize(28, 28)
	countdownButton:SkinButton()

	local countdownIcon = countdownButton:CreateTexture(nil, "ARTWORK")
	countdownIcon:SetPoint("TOPLEFT", countdownButton, 4, -4)
	countdownIcon:SetPoint("BOTTOMRIGHT", countdownButton, -4, 4)
	countdownIcon:SetAtlas("Ping_Chat_Assist", true)
	countdownIcon:SetDesaturated(true)

	countdownButton:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("Raid Tool", 0, 0.6, 1)
		GameTooltip:AddLine(" ")
		local isLeaderOrAssistant = IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid()))
		GameTooltip:AddDoubleLine(K.LeftButton .. K.InfoColor .. _G.READY_CHECK .. (isLeaderOrAssistant and "" or " |cffFF3333(" .. "Leader required" .. ")|r"))
		local isBossModLoaded = C_AddOns_IsAddOnLoaded("DBM-Core") or C_AddOns_IsAddOnLoaded("BigWigs")
		GameTooltip:AddDoubleLine(K.RightButton .. K.InfoColor .. "Pull Timer" .. (isBossModLoaded and "" or " |cffFFCC00(" .. "DBM/BigWigs required" .. ")|r"))
		GameTooltip:Show()
	end)
	countdownButton:HookScript("OnLeave", K.HideTooltip)

	local isCountdownReset = true
	K:RegisterEvent("PLAYER_REGEN_ENABLED", function()
		isCountdownReset = true
	end)

	countdownButton:HookScript("OnMouseDown", function(_, mouseButton)
		if mouseButton == "LeftButton" then
			if InCombatLockdown() then
				_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
				return
			end
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				DoReadyCheck()
			else
				_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_LEADER)
			end
		else
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				if C_AddOns_IsAddOnLoaded("DBM-Core") then
					if isCountdownReset then
						_G.SlashCmdList["DEADLYBOSSMODS"]("pull " .. "5")
					else
						_G.SlashCmdList["DEADLYBOSSMODS"]("pull 0")
					end
					isCountdownReset = not isCountdownReset
				elseif C_AddOns_IsAddOnLoaded("BigWigs") then
					if not _G.SlashCmdList["BIGWIGSPULL"] then
						C_AddOns_LoadAddOn("BigWigs_Plugins")
					end
					if isCountdownReset then
						_G.SlashCmdList["BIGWIGSPULL"]("5")
					else
						_G.SlashCmdList["BIGWIGSPULL"]("0")
					end
					isCountdownReset = not isCountdownReset
				else
					_G.UIErrorsFrame:AddMessage(K.InfoColor .. "DBM Required")
				end
			else
				_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_LEADER)
			end
		end
	end)
end

function Module:createRaidManagementMenu(parentFrame)
	local menuFrame = CreateFrame("Frame", nil, parentFrame)
	menuFrame:SetPoint("TOP", parentFrame, "BOTTOM", 0, -6)
	menuFrame:SetSize(250, 70)
	menuFrame:CreateBorder()
	menuFrame:Hide()

	local function hideMenuOnMouseLeaveDelay(self, elapsedTime)
		self.elapsedSinceLastMouseCheck = (self.elapsedSinceLastMouseCheck or 0) + elapsedTime
		if self.elapsedSinceLastMouseCheck > 0.1 then
			if not menuFrame:IsMouseOver() then
				self:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.elapsedSinceLastMouseCheck = 0
		end
	end

	menuFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", hideMenuOnMouseLeaveDelay)
	end)

	-- REASON: Dynamically updates the enabled/disabled state of raid control buttons based on the player's current role and group status.
	function menuFrame:UpdateState()
		if not parentFrame.raidControlButtons then
			return
		end
		local isLeader = UnitIsGroupLeader("player")
		local isAssistant = UnitIsGroupAssistant("player") and IsInRaid()
		local isLeaderOrAssistant = isLeader or isAssistant
		local isLFGRestricted = HasLFGRestrictions()
		local isInRaidActive = IsInRaid()
		local isGroupSizeSmall = GetNumGroupMembers() <= 5

		parentFrame.raidControlButtons[1]:SetEnabled(isLeader)

		local canConvertToRaid = isLeader and not isLFGRestricted and (isInRaidActive or isGroupSizeSmall)
		parentFrame.raidControlButtons[2]:SetEnabled(canConvertToRaid)
		parentFrame.raidControlButtons[2].text:SetText(isInRaidActive and _G.CONVERT_TO_PARTY or _G.CONVERT_TO_RAID)
		parentFrame.raidControlButtons[3]:SetEnabled(isLeaderOrAssistant and not isLFGRestricted)
	end

	K:RegisterEvent("GROUP_ROSTER_UPDATE", function()
		if menuFrame:IsShown() then
			menuFrame:UpdateState()
		end
	end)
	K:RegisterEvent("PLAYER_FLAGS_CHANGED", function()
		if menuFrame:IsShown() then
			menuFrame:UpdateState()
		end
	end)
	menuFrame:HookScript("OnShow", function(self)
		self:UpdateState()
	end)

	_G.StaticPopupDialogs["Group_Disband"] = {
		text = L["Disband Info"] or "Are you sure you want to disband the group?",
		button1 = _G.YES,
		button2 = _G.NO,
		OnAccept = function()
			if InCombatLockdown() then
				_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
				return
			end
			if IsInRaid() then
				SendChatMessage(L["Disband Process"], "RAID")
				for i = 1, GetNumGroupMembers() do
					local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
					if online and name ~= K.Name then
						UninviteUnit(name)
					end
				end
			else
				for i = _G.MAX_PARTY_MEMBERS, 1, -1 do
					if UnitExists("party" .. i) then
						UninviteUnit(UnitName("party" .. i))
					end
				end
			end
			C_PartyInfo_LeaveParty()
		end,
		timeout = 0,
		whileDead = 1,
	}

	local raidControlButtonsData = {
		{
			_G.TEAM_DISBAND,
			function()
				if UnitIsGroupLeader("player") then
					_G.StaticPopup_Show("Group_Disband")
				else
					_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_LEADER)
				end
			end,
		},
		{
			_G.CONVERT_TO_RAID,
			function()
				if UnitIsGroupLeader("player") and not HasLFGRestrictions() and GetNumGroupMembers() <= 5 then
					if IsInRaid() then
						C_PartyInfo_ConvertToParty()
					else
						C_PartyInfo_ConvertToRaid()
					end
					menuFrame:Hide()
					menuFrame:SetScript("OnUpdate", nil)
				else
					_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_LEADER)
				end
			end,
		},
		{
			_G.ROLE_POLL,
			function()
				if IsInGroup() and not HasLFGRestrictions() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
					InitiateRolePoll()
				else
					_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_LEADER)
				end
			end,
		},
		{
			_G.RAID_CONTROL,
			function()
				ToggleFriendsFrame(3)
			end,
		},
	}

	local raidControlButtons = {}
	for index, data in pairs(raidControlButtonsData) do
		raidControlButtons[index] = CreateFrame("Button", nil, menuFrame)
		raidControlButtons[index]:SetSize(116, 26)
		raidControlButtons[index]:SkinButton()
		raidControlButtons[index].text = K.CreateFontString(raidControlButtons[index], 12, data[1], "", true)
		raidControlButtons[index]:SetPoint(mod(index, 2) == 0 and "TOPRIGHT" or "TOPLEFT", mod(index, 2) == 0 and -6 or 6, index > 2 and -38 or -6)
		raidControlButtons[index]:SetScript("OnClick", data[2])
		raidControlButtons[index]:HookScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:ClearLines()
			GameTooltip:AddLine("Raid Tool", 0, 0.6, 1)
			GameTooltip:AddLine(" ")
			if index == 1 then
				GameTooltip:AddLine("Disband the current group", 1, 0.82, 0)
			elseif index == 2 then
				GameTooltip:AddLine("Convert between party and raid", 1, 0.82, 0)
			elseif index == 3 then
				GameTooltip:AddLine("Start a role poll", 1, 0.82, 0)
			elseif index == 4 then
				GameTooltip:AddLine("Open raid panel", 1, 0.82, 0)
			end
			GameTooltip:Show()
		end)
		raidControlButtons[index]:HookScript("OnLeave", K.HideTooltip)
	end

	parentFrame.menu = menuFrame
	parentFrame.raidControlButtons = raidControlButtons
end

function Module:setupEasyMarker()
	if not C["Misc"].EasyMarking then
		return
	end

	local easyMarkerMenuList = {}

	local function getEasyMarkerMenuTitle(titleText, ...)
		return (... and K.RGBToHex(...) or "") .. titleText
	end

	local function setRaidTargetByIndex(_, targetIndex)
		SetRaidTarget("target", targetIndex)
	end

	local raidTargetMixins = {
		_G.UnitPopupRaidTarget8ButtonMixin,
		_G.UnitPopupRaidTarget7ButtonMixin,
		_G.UnitPopupRaidTarget6ButtonMixin,
		_G.UnitPopupRaidTarget5ButtonMixin,
		_G.UnitPopupRaidTarget4ButtonMixin,
		_G.UnitPopupRaidTarget3ButtonMixin,
		_G.UnitPopupRaidTarget2ButtonMixin,
		_G.UnitPopupRaidTarget1ButtonMixin,
		_G.UnitPopupRaidTargetNoneButtonMixin,
	}
	for index, targetMixin in pairs(raidTargetMixins) do
		local leftCoord, rightCoord, topCoord, bottomCoord = targetMixin:GetTextureCoords()
		easyMarkerMenuList[index] = {
			text = getEasyMarkerMenuTitle(targetMixin:GetText(), targetMixin:GetColor()),
			icon = targetMixin:GetIcon(),
			tCoordLeft = leftCoord,
			tCoordRight = rightCoord,
			tCoordTop = topCoord,
			tCoordBottom = bottomCoord,
			arg1 = 9 - index,
			func = setRaidTargetByIndex,
		}
	end

	local function getMarkerModifierState()
		local activationKeyIndex = C["Misc"].EasyMarkKey
		if activationKeyIndex == 1 then
			return IsControlKeyDown()
		elseif activationKeyIndex == 2 then
			return IsAltKeyDown()
		elseif activationKeyIndex == 3 then
			return IsShiftKeyDown()
		elseif activationKeyIndex == 4 then
			return false
		end
	end

	-- REASON: Hooks the WorldFrame to trigger a context menu for raid targets when clicking with a modifier key over a unit.
	_G.WorldFrame:HookScript("OnMouseDown", function(_, mouseButton)
		if mouseButton == "LeftButton" and getMarkerModifierState() and UnitExists("mouseover") then
			if not IsInGroup() or (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				local currentMarkerIndex = GetRaidTargetIndex("mouseover")
				for i = 1, 8 do
					local menuItem = easyMarkerMenuList[i]
					menuItem.checked = (menuItem.arg1 == currentMarkerIndex)
				end
				K.LibEasyMenu.Create(easyMarkerMenuList, K.EasyMenu, "cursor", 0, 0, "MENU", 1)
			end
		end
	end)
end

function Module:createWorldMarkerBar()
	local WORLD_MARKER_ICONS = {
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
		"Interface\\Buttons\\UI-GroupLoot-Pass-Up",
	}

	local worldMarkerFrame = CreateFrame("Frame", "KKUI_WorldMarkers", _G.UIParent)
	worldMarkerFrame:SetPoint("RIGHT", -100, 0)
	K.CreateMoverFrame(worldMarkerFrame, nil, true)
	K.RestoreMoverFrame(worldMarkerFrame)
	worldMarkerFrame:CreateBorder()
	worldMarkerFrame.markerButtons = {}

	for i = 1, 9 do
		local markerButton = CreateFrame("Button", nil, worldMarkerFrame, "SecureActionButtonTemplate")
		markerButton:SetSize(24, 24)
		markerButton.Icon = markerButton:CreateTexture(nil, "ARTWORK")
		markerButton.Icon:SetAllPoints()
		markerButton.Icon:SetTexCoord(_G.unpack(K.TexCoords))
		markerButton.Icon:SetTexture(WORLD_MARKER_ICONS[i])
		markerButton:SetHighlightTexture(WORLD_MARKER_ICONS[i])
		markerButton:SetPushedTexture(WORLD_MARKER_ICONS[i])

		if i ~= 9 then
			markerButton:RegisterForClicks("AnyUp", "AnyDown")
			markerButton:SetAttribute("type", "macro")
			markerButton:SetAttribute("macrotext1", string_format("/wm %d", i))
			markerButton:SetAttribute("macrotext2", string_format("/cwm %d", i))
			markerButton:HookScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:ClearLines()
				GameTooltip:AddLine("World Marker", 0, 0.6, 1)
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(K.LeftButton .. K.InfoColor .. "Place world marker")
				GameTooltip:AddDoubleLine(K.RightButton .. K.InfoColor .. "Clear this marker")
				GameTooltip:Show()
			end)
			markerButton:HookScript("OnLeave", K.HideTooltip)
		else
			markerButton:SetScript("OnClick", ClearRaidMarker)
			markerButton:HookScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:ClearLines()
				GameTooltip:AddLine("World Marker", 0, 0.6, 1)
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(K.LeftButton .. K.InfoColor .. "Clear all world markers")
				GameTooltip:Show()
			end)
			markerButton:HookScript("OnLeave", K.HideTooltip)
		end
		worldMarkerFrame.markerButtons[i] = markerButton
	end

	Module:updateWorldMarkerGrid()
end

local MARKER_BAR_LAYOUT_MAP = {
	[1] = 3,
	[2] = 9,
	[3] = 1,
	[4] = 3,
}

function Module:updateWorldMarkerGrid()
	local worldMarkerFrame = _G["KKUI_WorldMarkers"]
	if not worldMarkerFrame then
		return
	end

	local markerSize, markerMargin = C["Misc"].MarkerBarSize, 6
	local displayType = C["Misc"].ShowMarkerBar
	local buttonsPerRow = MARKER_BAR_LAYOUT_MAP[displayType]

	for i = 1, 9 do
		local markerButton = worldMarkerFrame.markerButtons[i]
		markerButton:SetSize(markerSize, markerSize)
		markerButton:ClearAllPoints()
		if i == 1 then
			markerButton:SetPoint("TOPLEFT", worldMarkerFrame, markerMargin, -markerMargin)
		elseif mod(i - 1, buttonsPerRow) == 0 then
			markerButton:SetPoint("TOP", worldMarkerFrame.markerButtons[i - buttonsPerRow], "BOTTOM", 0, -markerMargin)
		else
			markerButton:SetPoint("LEFT", worldMarkerFrame.markerButtons[i - 1], "RIGHT", markerMargin, 0)
		end
	end

	local maxColumns = math_min(9, buttonsPerRow)
	local totalRows = math_ceil(9 / buttonsPerRow)
	worldMarkerFrame:SetWidth(maxColumns * markerSize + (maxColumns - 1) * markerMargin + 2 * markerMargin)
	worldMarkerFrame:SetHeight(markerSize * totalRows + (totalRows - 1) * markerMargin + 2 * markerMargin)
	worldMarkerFrame:SetShown(displayType ~= 4)
end

function Module:reanchorUIWidgets()
	-- SG: Re-anchors common UI widgets to prevent overlaps with other KkthnxUI elements.
	local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
	if not topCenterContainer:IsMovable() then
		topCenterContainer:ClearAllPoints()
		topCenterContainer:SetPoint("TOP", 0, -46)
	end
end

function Module:createImprovedRaidTool()
	if not C["Misc"].RaidTool then
		return
	end

	local raidToolHeader = Module:createRaidToolHeader()
	Module:createRaidRoleCounter(raidToolHeader)
	Module:createCombatResMonitor(raidToolHeader)
	Module:createReadyCheckMonitor(raidToolHeader)
	Module:createRaidBuffChecker(raidToolHeader)
	Module:createRaidManagementMenu(raidToolHeader)
	Module:createCountdownButton(raidToolHeader)

	-- Module:setupEasyMarker() -- Broken 12.0
	Module:createWorldMarkerBar()
	Module:reanchorUIWidgets()
end

Module:RegisterMisc("RaidTool", Module.createImprovedRaidTool)
