local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local mod = _G.mod
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format
local string_split = _G.string.split
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local CONVERT_TO_RAID = _G.CONVERT_TO_RAID
local C_Timer_After = _G.C_Timer.After
local ConvertToParty = _G.ConvertToParty
local ConvertToRaid = _G.ConvertToRaid
local CreateFrame = _G.CreateFrame
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local ERR_NOT_LEADER = _G.ERR_NOT_LEADER
local GameTooltip = _G.GameTooltip
local GetInstanceInfo = _G.GetInstanceInfo
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetRaidRosterInfo = _G.GetRaidRosterInfo
local GetReadyCheckStatus = _G.GetReadyCheckStatus
local GetSpellCharges = _G.GetSpellCharges
local GetSpellInfo = _G.GetSpellInfo
local GetSpellTexture = _G.GetSpellTexture
local GetTime = _G.GetTime
local HasLFGRestrictions = _G.HasLFGRestrictions
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local IsLFGComplete = _G.IsLFGComplete
local IsPartyLFG = _G.IsPartyLFG
local LeaveParty = _G.LeaveParty
local MAX_PARTY_MEMBERS = _G.MAX_PARTY_MEMBERS
local NO = _G.NO
local RAID_BUFF_2 = _G.RAID_BUFF_2
local RAID_BUFF_3 = _G.RAID_BUFF_3
local RAID_CONTROL = _G.RAID_CONTROL
local READY_CHECK = _G.READY_CHECK
local ROLE_POLL = _G.ROLE_POLL
local RUNES = _G.RUNES
local SPELL_STAT4_NAME = _G.SPELL_STAT4_NAME
local SendChatMessage = _G.SendChatMessage
local SlashCmdList = _G.SlashCmdList
local StaticPopupDialogs = _G.StaticPopupDialogs
local TEAM_DISBAND = _G.TEAM_DISBAND
local UIErrorsFrame = _G.UIErrorsFrame
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura
local UnitExists = _G.UnitExists
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitName = _G.UnitName
local YES = _G.YES

function Module:RaidTool_Visibility(frame)
	if IsInGroup() then
		frame:Show()
	else
		frame:Hide()
	end
end

function Module:RaidTool_Header()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:SetSize(126, 28)
	frame:SetFrameLevel(2)
	frame:SkinButton()
	K.Mover(frame, "Raid Tool", "RaidManager", {"TOP", UIParent, "TOP", 0, -4})

	Module:RaidTool_Visibility(frame)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", function()
		Module:RaidTool_Visibility(frame)
	end)

	frame:RegisterForClicks("AnyUp")
	frame:SetScript("OnClick", function(self, btn)
		if btn == "LeftButton" then
			local menu = self.menu
			K.TogglePanel(menu)

			if menu:IsShown() then
				menu:ClearAllPoints()
				if Module:IsFrameOnTop(self) then
					menu:SetPoint("TOP", self, "BOTTOM", 0, -6)
				else
					menu:SetPoint("BOTTOM", self, "TOP", 0, 6)
				end

				self.buttons[2].text:SetText(IsInRaid() and _G.CONVERT_TO_PARTY or _G.CONVERT_TO_RAID)
			end
		end
	end)

	frame:SetScript("OnDoubleClick", function(_, btn)
		if btn == "RightButton" and (IsPartyLFG() and IsLFGComplete() or not IsInInstance()) then
			LeaveParty()
		end
	end)

	frame:SetScript("OnHide", function(self)
		if not self and not self.KKUI_Border then
			return
		end

		self.KKUI_Border:SetVertexColor(1, 1, 1)
	end)

	return frame
end

function Module:IsFrameOnTop(frame)
	local y = select(2, frame:GetCenter())
	local screenHeight = UIParent:GetTop()

	return y > screenHeight / 2
end

function Module:GetRaidMaxGroup()
	local _, instType, difficulty = GetInstanceInfo()
	if (instType == "party" or instType == "scenario") and not IsInRaid() then
		return 1
	elseif instType ~= "raid" then
		return 8
	elseif difficulty == 8 or difficulty == 1 or difficulty == 2 or difficulty == 24 then
		return 1
	elseif difficulty == 14 or difficulty == 15 then
		return 6
	elseif difficulty == 16 then
		return 4
	elseif difficulty == 3 or difficulty == 5 then
		return 2
	elseif difficulty == 9 then
		return 8
	else
		return 5
	end
end

function Module:RaidTool_RoleCount(parent)
	local roleTexCoord = {
		{0.5, 0.75, 0, 1},
		{0.75, 1, 0, 1},
		{0.25, 0.5, 0, 1},
	}

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	local role = {}
	for i = 1, 3 do
		role[i] = frame:CreateTexture(nil, "OVERLAY")
		role[i]:SetPoint("LEFT", 36 * i - 30, 0)
		role[i]:SetSize(15, 15)
		role[i]:SetTexture("Interface\\LFGFrame\\LFGROLE")
		role[i]:SetTexCoord(unpack(roleTexCoord[i]))
		role[i].text = K.CreateFontString(frame, 13, "0", "")
		role[i].text:ClearAllPoints()
		role[i].text:SetPoint("CENTER", role[i], "RIGHT", 12, 0)
	end

	local raidCounts = {
		totalTANK = 0,
		totalHEALER = 0,
		totalDAMAGER = 0
	}

	local function updateRoleCount()
		for k in pairs(raidCounts) do
			raidCounts[k] = 0
		end

		local maxgroup = Module:GetRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead, _, _, assignedRole = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead and assignedRole ~= "NONE" then
				raidCounts["total"..assignedRole] = raidCounts["total"..assignedRole] + 1
			end
		end

		role[1].text:SetText(raidCounts.totalTANK)
		role[2].text:SetText(raidCounts.totalHEALER)
		role[3].text:SetText(raidCounts.totalDAMAGER)
	end

	local eventList = {
		"GROUP_ROSTER_UPDATE",
		"UPDATE_ACTIVE_BATTLEFIELD",
		"UNIT_FLAGS",
		"PLAYER_FLAGS_CHANGED",
		"PLAYER_ENTERING_WORLD",
	}

	for _, event in next, eventList do
		K:RegisterEvent(event, updateRoleCount)
	end

	parent.roleFrame = frame
end

function Module:RaidTool_UpdateRes(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		local charges, _, started, duration = GetSpellCharges(20484)
		if charges then
			local timer = duration - (GetTime() - started)
			if timer < 0 then
				self.Timer:SetText("--:--")
			else
				self.Timer:SetFormattedText("%d:%.2d", timer / 60, timer % 60)
			end

			self.Count:SetText(charges)
			if charges == 0 then
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

		self.elapsed = 0
	end
end

function Module:RaidTool_CombatRes(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	frame:SetAlpha(0)

	local res = CreateFrame("Frame", nil, frame)
	res:SetSize(22, 22)
	res:SetPoint("LEFT", 5, 0)

	res.Icon = res:CreateTexture(nil, "ARTWORK")
	res.Icon:SetTexture(GetSpellTexture(20484))
	res.Icon:SetAllPoints()
	res.Icon:SetTexCoord(unpack(K.TexCoords))

	res.__owner = parent

	res.Count = K.CreateFontString(res, 16, "0", "")
	res.Count:ClearAllPoints()
	res.Count:SetPoint("LEFT", res, "RIGHT", 10, 0)

	res.Timer = K.CreateFontString(frame, 16, "00:00", "", false, "RIGHT", -5, 0)
	res:SetScript("OnUpdate", Module.RaidTool_UpdateRes)

	parent.resFrame = frame
end

function Module:RaidTool_ReadyCheck(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOP", parent, "BOTTOM", 0, -6)
	frame:SetSize(120, 50)
	frame:Hide()
	frame:SetScript("OnMouseUp", function(self)
		self:Hide()
	end)
	frame:CreateBorder()
	K.CreateFontString(frame, 14, READY_CHECK, "", true, "TOP", 0, -8)

	local rc = K.CreateFontString(frame, 14, "", "", false, "TOP", 0, -28)
	local count, total
	local function hideRCFrame()
		frame:Hide()
		rc:SetText("")
		count, total = 0, 0
	end

	local function updateReadyCheck(event)
		if event == "READY_CHECK_FINISHED" then
			if count == total then
				rc:SetTextColor(0, 1, 0)
			else
				rc:SetTextColor(1, 0, 0)
			end
			C_Timer_After(5, hideRCFrame)
		else
			count, total = 0, 0

			frame:ClearAllPoints()
			if Module:IsFrameOnTop(parent) then
				frame:SetPoint("TOP", parent, "BOTTOM", 0, -6)
			else
				frame:SetPoint("BOTTOM", parent, "TOP", 0, 6)
			end
			frame:Show()

			local maxgroup = Module:GetRaidMaxGroup()
			for i = 1, GetNumGroupMembers() do
				local name, _, subgroup, _, _, _, _, online = GetRaidRosterInfo(i)
				if name and online and subgroup <= maxgroup then
					total = total + 1
					local status = GetReadyCheckStatus(name)
					if status and status == "ready" then
						count = count + 1
					end
				end
			end
			rc:SetText(count.." / "..total)
			if count == total then
				rc:SetTextColor(0, 1, 0)
			else
				rc:SetTextColor(1, 1, 0)
			end
		end
	end
	K:RegisterEvent("READY_CHECK", updateReadyCheck)
	K:RegisterEvent("READY_CHECK_CONFIRM", updateReadyCheck)
	K:RegisterEvent("READY_CHECK_FINISHED", updateReadyCheck)
end

function Module:RaidTool_Marker(parent)
	local markerButton = _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
	if not markerButton then
		for _, addon in next, {"Blizzard_CUFProfiles", "Blizzard_CompactRaidFrames"} do
			_G.EnableAddOn(addon)
			_G.LoadAddOn(addon)
		end
	end

	if markerButton then
		markerButton:ClearAllPoints()
		markerButton:SetPoint("RIGHT", parent, "LEFT", -6, 0)
		markerButton:SetParent(parent)
		markerButton:SetSize(28, 28)
		markerButton:SkinButton()
		markerButton:SetNormalTexture("Interface\\RaidFrame\\Raid-WorldPing")
		markerButton:GetNormalTexture():SetVertexColor(K.r, K.g, K.b)
		markerButton:HookScript("OnMouseUp", function()
			if (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				return
			end
			UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
		end)
	end
end

function Module:RaidTool_BuffChecker(parent)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetPoint("LEFT", parent, "RIGHT", 6, 0)
	frame:SetSize(28, 28)
	K.CreateFontString(frame, 16, "!", "", true)
	frame:SkinButton()

	local BuffName = {L["Flask"], L["Food"], SPELL_STAT4_NAME, RAID_BUFF_2, RAID_BUFF_3, RUNES}
	local NoBuff, numGroups, numPlayer = {}, 6, 0
	for i = 1, numGroups do NoBuff[i] = {} end

	local debugMode = false
	local function sendMsg(text)
		if debugMode then
			print(text)
		else
			SendChatMessage(text, IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
		end
	end

	local function sendResult(i)
		local count = #NoBuff[i]
		if count > 0 then
			if count >= numPlayer then
				sendMsg(L["Lack"]..BuffName[i]..": "..ALL..PLAYER)
			elseif count >= 5 and i > 2 then
				sendMsg(L["Lack"]..BuffName[i]..": "..string_format(L["%s players"], count))
			else
				local str = L["Lack"]..BuffName[i]..": "
				for j = 1, count do
					str = str..NoBuff[i][j]..(j < #NoBuff[i] and ", " or "")
					if #str > 230 then
						sendMsg(str)
						str = ""
					end
				end
				sendMsg(str)
			end
		end
	end

	local function scanBuff()
		for i = 1, numGroups do
			table_wipe(NoBuff[i])
		end

		numPlayer = 0
		local maxgroup = Module:GetRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead then
				numPlayer = numPlayer + 1
				for j = 1, numGroups do
					local HasBuff
					local buffTable = K.RaidUtilityBuffCheckList[j]
					for k = 1, #buffTable do
						local buffName = GetSpellInfo(buffTable[k])
						for index = 1, 32 do
							local currentBuff = UnitAura(name, index)
							if currentBuff and currentBuff == buffName then
								HasBuff = true
								break
							end
						end
					end

					if not HasBuff then
						name = string_split("-", name) -- remove realm name
						table_insert(NoBuff[j], name)
					end
				end
			end
		end

		-- if not C["Misc"]["RMRune"] then
		-- 	NoBuff[numGroups] = {}
		-- end

		if #NoBuff[1] == 0 and #NoBuff[2] == 0 and #NoBuff[3] == 0 and #NoBuff[4] == 0 and #NoBuff[5] == 0 and #NoBuff[6] == 0 then
			sendMsg(L["All Buffs Ready"])
		else
			sendMsg(L["Raid Buff Checker"])
			for i = 1, 5 do sendResult(i) end
			-- if C["Misc"]["RMRune"] then
			-- 	sendResult(numGroups)
			-- end
		end
	end

	local potionCheck = IsAddOnLoaded("ExRT")
	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("Raid Tool", 0, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(" |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "..K.InfoColor..READY_CHECK)
		GameTooltip:AddDoubleLine(" |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "..L["Start Stop Countdown"])
		GameTooltip:AddDoubleLine(" |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "..L["Ctrl Key"]..K.InfoColor..L["Check Flask Food"])

		if potionCheck then
			GameTooltip:AddDoubleLine(" |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "..L["Alt Key"]..K.InfoColor..L["ExRT Potion Check"])
		end

		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", K.HideTooltip)

	local reset = true
	K:RegisterEvent("PLAYER_REGEN_ENABLED", function()
		reset = true
	end)

	frame:HookScript("OnMouseDown", function(_, btn)
		if btn == "RightButton" then
			if IsAltKeyDown() and potionCheck then
				SlashCmdList["exrtSlash"]("potionchat")
			elseif IsControlKeyDown() then
				scanBuff()
			end
		elseif btn == "LeftButton" then
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
				return
			end
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				_G.DoReadyCheck()
			else
				UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
			end
		else
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				if C["Announcements"].PullCountdown then
					if reset then
						SlashCmdList["PULLCOUNTDOWN"]("5")
					else
						SlashCmdList["PULLCOUNTDOWN"]("0")
					end
					reset = not reset
				elseif IsAddOnLoaded("DBM-Core") and not C["Announcements"].PullCountdown then
					if reset then
						SlashCmdList["DEADLYBOSSMODS"]("pull ".."10")
					else
						SlashCmdList["DEADLYBOSSMODS"]("pull 0")
					end
					reset = not reset
				elseif IsAddOnLoaded("BigWigs") and not C["Announcements"].PullCountdown then
					if not SlashCmdList["BIGWIGSPULL"] then
						_G.LoadAddOn("BigWigs_Plugins")
					end

					if reset then
						SlashCmdList["BIGWIGSPULL"]("10")
					else
						SlashCmdList["BIGWIGSPULL"]("0")
					end

					reset = not reset
				else
					UIErrorsFrame:AddMessage(K.InfoColor..L["Missing DBM BigWigs"])
				end
			else
				UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
			end
		end
	end)
end

function Module:RaidTool_CreateMenu(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOP", parent, "BOTTOM", 0, -6)
	frame:SetSize(194, 70)
	frame:CreateBorder()
	frame:Hide()

	local function updateDelay(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > 0.1 then
			if not frame:IsMouseOver() then
				self:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.elapsed = 0
		end
	end

	frame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", updateDelay)
	end)

	StaticPopupDialogs["Group_Disband"] = {
		text = "Are you sure to |cffff0000disband|r your group?",
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
				return
			end

			if IsInRaid() then
				SendChatMessage(L["Raid Disbanding"], "RAID")
				for i = 1, GetNumGroupMembers() do
					local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
					if online and name ~= K.MyName then
						_G.UninviteUnit(name)
					end
				end
			else
				for i = MAX_PARTY_MEMBERS, 1, -1 do
					if UnitExists("party"..i) then
						_G.UninviteUnit(UnitName("party"..i))
					end
				end
			end
			LeaveParty()
		end,
		timeout = 0,
		whileDead = 1,
	}

	local buttons = {
		{TEAM_DISBAND, function()
				if UnitIsGroupLeader("player") then
					StaticPopup_Show("Group_Disband")
				else
					UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
				end
		end},
		{CONVERT_TO_RAID, function()
				if UnitIsGroupLeader("player") and not HasLFGRestrictions() and GetNumGroupMembers() <= 5 then
					if IsInRaid() then
						ConvertToParty()
					else
						ConvertToRaid()
					end
					frame:Hide()
					frame:SetScript("OnUpdate", nil)
				else
					UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
				end
		end},
		{ROLE_POLL, function()
				if IsInGroup() and not HasLFGRestrictions() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
					_G.InitiateRolePoll()
				else
					UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
				end
		end},
		{RAID_CONTROL, function()
				_G.ToggleFriendsFrame(3)
		end},
	}

	local bu = {}
	for i, j in pairs(buttons) do
		bu[i] = CreateFrame("Button", nil, frame)
		bu[i]:SetSize(89, 26)
		bu[i]:SkinButton()
		bu[i].text = K.CreateFontString(bu[i], 12, j[1], "", true)
		bu[i]:SetPoint(mod(i, 2) == 0 and "TOPRIGHT" or "TOPLEFT", mod(i, 2) == 0 and -5 or 5, i > 2 and -38 or -6)
		bu[i]:SetScript("OnClick", j[2])
	end

	parent.menu = frame
	parent.buttons = bu
end

function Module:CreateRaidUtility()
	if not C["Raid"].RaidUtility then
		return
	end

	local frame = Module:RaidTool_Header()
	Module:RaidTool_RoleCount(frame)
	Module:RaidTool_CombatRes(frame)
	Module:RaidTool_ReadyCheck(frame)
	Module:RaidTool_Marker(frame)
	Module:RaidTool_BuffChecker(frame)
	Module:RaidTool_CreateMenu(frame)
end