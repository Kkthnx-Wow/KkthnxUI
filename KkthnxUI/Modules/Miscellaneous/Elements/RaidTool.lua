local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local next, pairs, mod, select = next, pairs, mod, select
local tinsert, strsplit, format = table.insert, string.split, string.format
local min, ceil = math.min, math.ceil
local wipe = wipe

-- Localize frequently used API calls for performance
local IsInGroup, IsInRaid, IsInInstance = IsInGroup, IsInRaid, IsInInstance
local UnitIsGroupLeader, UnitIsGroupAssistant = UnitIsGroupLeader, UnitIsGroupAssistant
local IsPartyLFG, IsLFGComplete, HasLFGRestrictions = IsPartyLFG, IsLFGComplete, HasLFGRestrictions
local GetInstanceInfo, GetNumGroupMembers, GetRaidRosterInfo, GetRaidTargetIndex, SetRaidTarget = GetInstanceInfo, GetNumGroupMembers, GetRaidRosterInfo, GetRaidTargetIndex, SetRaidTarget
local GetTime, SendChatMessage, C_AddOns_IsAddOnLoaded = GetTime, SendChatMessage, C_AddOns.IsAddOnLoaded
local IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown, InCombatLockdown = IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown, InCombatLockdown
local UnitExists, UninviteUnit, UnitName = UnitExists, UninviteUnit, UnitName
local DoReadyCheck, InitiateRolePoll, GetReadyCheckStatus = DoReadyCheck, InitiateRolePoll, GetReadyCheckStatus
local LeaveParty = C_PartyInfo.LeaveParty
local ConvertToRaid = C_PartyInfo.ConvertToRaid
local ConvertToParty = C_PartyInfo.ConvertToParty
local C_Spell_GetSpellCharges = C_Spell.GetSpellCharges
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local C_Spell_GetSpellName = C_Spell.GetSpellName
local C_UnitAuras_GetAuraDataBySpellName = C_UnitAuras.GetAuraDataBySpellName
local ClearRaidMarker = ClearRaidMarker
local ToggleFriendsFrame = ToggleFriendsFrame
local C_AddOns_LoadAddOn = C_AddOns.LoadAddOn

function Module:RaidTool_Visibility(frame)
	if IsInGroup() then
		frame:Show()
	else
		frame:Hide()
	end
end

function Module:RaidTool_Header()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:SetSize(120, 28)
	frame:SetFrameLevel(2)
	frame:SkinButton()
	K.Mover(frame, "Raid Tool", "RaidManager", { "TOP", UIParent, "TOP", 0, -4 })

	frame:HookScript("OnEnter", function(self)
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
	frame:HookScript("OnLeave", K.HideTooltip)

	Module.RaidTool_Visibility(Module, frame)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", function()
		Module.RaidTool_Visibility(Module, frame)
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

				self.buttons[2].text:SetText(IsInRaid() and CONVERT_TO_PARTY or CONVERT_TO_RAID)
				if menu.UpdateState then
					menu:UpdateState()
				end
			end
		end
	end)
	frame:SetScript("OnDoubleClick", function(_, btn)
		if btn == "RightButton" and (IsPartyLFG() and IsLFGComplete() or not IsInInstance()) then
			LeaveParty()
		end
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
	elseif difficulty == 8 or difficulty == 1 or difficulty == 2 then
		return 1
	elseif difficulty == 14 or difficulty == 15 or (difficulty == 24 and instType == "raid") then
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
	local roleIndex = { "TANK", "HEALER", "DAMAGER" }
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	local role = {}
	for i = 1, 3 do
		role[i] = frame:CreateTexture(nil, "OVERLAY")
		role[i]:SetPoint("LEFT", 36 * i - 27, 0)
		role[i]:SetSize(16, 16)
		K.ReskinSmallRole(role[i], roleIndex[i])
		role[i].text = K.CreateFontString(frame, 13, "0", "")
		role[i].text:ClearAllPoints()
		role[i].text:SetPoint("CENTER", role[i], "RIGHT", 8, 0)
	end

	local raidCounts = {
		totalTANK = 0,
		totalHEALER = 0,
		totalDAMAGER = 0,
	}

	local function updateRoleCount()
		raidCounts.totalTANK = 0
		raidCounts.totalHEALER = 0
		raidCounts.totalDAMAGER = 0

		local maxgroup = Module:GetRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead, _, _, assignedRole = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead and assignedRole ~= "NONE" then
				raidCounts["total" .. assignedRole] = raidCounts["total" .. assignedRole] + 1
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
		local chargeInfo = C_Spell_GetSpellCharges(20484)
		local charges = chargeInfo and chargeInfo.currentCharges
		local started = chargeInfo and chargeInfo.cooldownStartTime
		local duration = chargeInfo and chargeInfo.cooldownDuration

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
	res.Icon:SetTexture(C_Spell_GetSpellTexture(20484))
	res.Icon:SetAllPoints()
	res.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
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
			K.Delay(5, hideRCFrame)
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
			rc:SetText(count .. " / " .. total)
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

function Module:RaidTool_BuffChecker(parent)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetPoint("RIGHT", parent, "LEFT", -6, 0)
	frame:SetSize(28, 28)
	frame:SkinButton()

	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", frame, 4, -4)
	icon:SetPoint("BOTTOMRIGHT", frame, -4, 4)
	icon:SetAtlas("UI-QuestTracker-Tracker-Check")
	icon:SetDesaturated(true)

	local BuffName = { L["Flask"], L["Food"], SPELL_STAT4_NAME, RAID_BUFF_2, RAID_BUFF_3, RUNES }
	local NoBuff, numGroups, numPlayer = {}, 6, 0
	for i = 1, numGroups do
		NoBuff[i] = {}
	end

	-- Cache spell names for buff groups (invalidated on SPELLS_CHANGED/PLAYER_ENTERING_WORLD)
	local spellNameCache = {}
	local groupBuffNameCache = {}
	local function getSpellName(spellID)
		local name = spellNameCache[spellID]
		if not name then
			name = C_Spell_GetSpellName(spellID)
			spellNameCache[spellID] = name
		end
		return name
	end
	local function getGroupBuffNames(index)
		local names = groupBuffNameCache[index]
		if not names then
			names = {}
			local buffTable = C.RaidUtilityBuffCheckList[index]
			for k = 1, #buffTable do
				names[k] = getSpellName(buffTable[k])
			end
			groupBuffNameCache[index] = names
		end
		return names
	end
	local function clearBuffCaches()
		for k in pairs(spellNameCache) do
			spellNameCache[k] = nil
		end
		for k in pairs(groupBuffNameCache) do
			groupBuffNameCache[k] = nil
		end
	end
	K:RegisterEvent("SPELLS_CHANGED", clearBuffCaches)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", clearBuffCaches)

	local debugMode = false
	local function sendMsg(text)
		if debugMode then
			K.Print(text)
		else
			SendChatMessage(text, K.CheckChat())
		end
	end

	local chunkBuffer = {}
	local function sendResult(i)
		local count = #NoBuff[i]
		if count > 0 then
			if count >= numPlayer then
				sendMsg(L["Lack"] .. " " .. BuffName[i] .. ": " .. "Everyone")
			elseif count >= 5 and i > 2 then
				sendMsg(L["Lack"] .. " " .. BuffName[i] .. ": " .. format(L["%s players"], count))
			else
				local prefix = L["Lack"] .. " " .. BuffName[i] .. ": "
				local currentLen = 0
				local n = 0
				for j = 1, count do
					local name = NoBuff[i][j]
					local addLen = #name + 2
					if currentLen + addLen > 220 and n > 0 then
						sendMsg(prefix .. table.concat(chunkBuffer, ", ", 1, n))
						for x = 1, n do
							chunkBuffer[x] = nil
						end
						n = 0
						currentLen = 0
					end
					n = n + 1
					chunkBuffer[n] = name
					currentLen = currentLen + addLen
				end
				if n > 0 then
					sendMsg(prefix .. table.concat(chunkBuffer, ", ", 1, n))
					for x = 1, n do
						chunkBuffer[x] = nil
					end
				end
			end
		end
	end

	local function scanBuff()
		for i = 1, numGroups do
			wipe(NoBuff[i])
		end
		numPlayer = 0

		local maxgroup = Module:GetRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead then
				numPlayer = numPlayer + 1
				for j = 1, numGroups do
					local hasBuff
					local buffNames = getGroupBuffNames(j)
					for k = 1, #buffNames do
						local buffName = buffNames[k]
						if buffName and C_UnitAuras_GetAuraDataBySpellName(name, buffName) then
							hasBuff = true
							break
						end
					end
					if not hasBuff then
						local short = strsplit("-", name)
						tinsert(NoBuff[j], short)
					end
				end
			end
		end
		if not C["Misc"].RMRune then
			NoBuff[numGroups] = {}
		end

		if #NoBuff[1] == 0 and #NoBuff[2] == 0 and #NoBuff[3] == 0 and #NoBuff[4] == 0 and #NoBuff[5] == 0 and #NoBuff[6] == 0 then
			sendMsg(L["All Buffs Ready"])
		else
			sendMsg(L["Raid Buff Checker"])
			for i = 1, 5 do
				sendResult(i)
			end
			if C["Misc"].RMRune then
				sendResult(numGroups)
			end
		end
	end

	local potionCheck = C_AddOns_IsAddOnLoaded("MRT")

	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("Raid Tool", 0, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(K.LeftButton .. K.InfoColor .. "Check raid buffs")
		if potionCheck then
			GameTooltip:AddDoubleLine(K.RightButton .. K.InfoColor .. L["MRT Potion Check"])
		end
		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", K.HideTooltip)

	local reset = true
	K:RegisterEvent("PLAYER_REGEN_ENABLED", function()
		reset = true
	end)

	frame:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" then
			scanBuff()
		elseif potionCheck then
			SlashCmdList["mrtSlash"]("potionchat")
		end
	end)
end

function Module:RaidTool_CountDown(parent)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetPoint("LEFT", parent, "RIGHT", 6, 0)
	frame:SetSize(28, 28)
	frame:SkinButton()

	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", frame, 4, -4)
	icon:SetPoint("BOTTOMRIGHT", frame, -4, 4)
	icon:SetAtlas("Ping_Chat_Assist", true)
	icon:SetDesaturated(true)

	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("Raid Tool", 0, 0.6, 1)
		GameTooltip:AddLine(" ")
		local isLeader = IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid()))
		GameTooltip:AddDoubleLine(K.LeftButton .. K.InfoColor .. READY_CHECK .. (isLeader and "" or " |cffFF3333(" .. "Leader required" .. ")|r"))
		local hasTimer = C_AddOns_IsAddOnLoaded("DBM-Core") or C_AddOns_IsAddOnLoaded("BigWigs")
		GameTooltip:AddDoubleLine(K.RightButton .. K.InfoColor .. "Pull Timer" .. (hasTimer and "" or " |cffFFCC00(" .. "DBM/BigWigs required" .. ")|r"))
		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", K.HideTooltip)

	local reset = true
	K:RegisterEvent("PLAYER_REGEN_ENABLED", function()
		reset = true
	end)

	frame:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" then
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
				return
			end
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				DoReadyCheck()
			else
				UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_LEADER)
			end
		else
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				if C_AddOns_IsAddOnLoaded("DBM-Core") then
					if reset then
						SlashCmdList["DEADLYBOSSMODS"]("pull " .. "5")
					else
						SlashCmdList["DEADLYBOSSMODS"]("pull 0")
					end
					reset = not reset
				elseif C_AddOns_IsAddOnLoaded("BigWigs") then
					if not SlashCmdList["BIGWIGSPULL"] then
						C_AddOns_LoadAddOn("BigWigs_Plugins")
					end
					if reset then
						SlashCmdList["BIGWIGSPULL"]("5")
					else
						SlashCmdList["BIGWIGSPULL"]("0")
					end
					reset = not reset
				else
					UIErrorsFrame:AddMessage(K.InfoColor .. "DBM Required")
				end
			else
				UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_LEADER)
			end
		end
	end)
end

function Module:RaidTool_CreateMenu(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOP", parent, "BOTTOM", 0, -6)
	frame:SetSize(250, 70)
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

	-- Update button enable/disable state dynamically
	function frame:UpdateState()
		if not parent.buttons then
			return
		end
		local isLeader = UnitIsGroupLeader("player")
		local isAssist = UnitIsGroupAssistant("player") and IsInRaid()
		local leaderOrAssist = isLeader or isAssist
		local lfg = HasLFGRestrictions()
		local inRaid = IsInRaid()
		local groupSizeOK = GetNumGroupMembers() <= 5
		-- Disband
		parent.buttons[1]:SetEnabled(isLeader)
		-- Convert
		local canConvert = isLeader and not lfg and (inRaid or groupSizeOK)
		parent.buttons[2]:SetEnabled(canConvert)
		parent.buttons[2].text:SetText(inRaid and CONVERT_TO_PARTY or CONVERT_TO_RAID)
		-- Role poll
		parent.buttons[3]:SetEnabled(leaderOrAssist and not lfg)
	end
	K:RegisterEvent("GROUP_ROSTER_UPDATE", function()
		if frame:IsShown() then
			frame:UpdateState()
		end
	end)
	K:RegisterEvent("PLAYER_FLAGS_CHANGED", function()
		if frame:IsShown() then
			frame:UpdateState()
		end
	end)
	frame:HookScript("OnShow", function(self)
		self:UpdateState()
	end)

	StaticPopupDialogs["Group_Disband"] = {
		text = L["Disband Info"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
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
				for i = MAX_PARTY_MEMBERS, 1, -1 do
					if UnitExists("party" .. i) then
						UninviteUnit(UnitName("party" .. i))
					end
				end
			end
			LeaveParty()
		end,
		timeout = 0,
		whileDead = 1,
	}

	local buttons = {
		{
			TEAM_DISBAND,
			function()
				if UnitIsGroupLeader("player") then
					StaticPopup_Show("Group_Disband")
				else
					UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_LEADER)
				end
			end,
		},
		{
			CONVERT_TO_RAID,
			function()
				if UnitIsGroupLeader("player") and not HasLFGRestrictions() and GetNumGroupMembers() <= 5 then
					if IsInRaid() then
						ConvertToParty()
					else
						ConvertToRaid()
					end
					frame:Hide()
					frame:SetScript("OnUpdate", nil)
				else
					UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_LEADER)
				end
			end,
		},
		{
			ROLE_POLL,
			function()
				if IsInGroup() and not HasLFGRestrictions() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
					InitiateRolePoll()
				else
					UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_LEADER)
				end
			end,
		},
		{
			RAID_CONTROL,
			function()
				ToggleFriendsFrame(3)
			end,
		},
	}

	local bu = {}
	for i, j in pairs(buttons) do
		bu[i] = CreateFrame("Button", nil, frame)
		bu[i]:SetSize(116, 26)
		bu[i]:SkinButton()
		bu[i].text = K.CreateFontString(bu[i], 12, j[1], "", true)
		bu[i]:SetPoint(mod(i, 2) == 0 and "TOPRIGHT" or "TOPLEFT", mod(i, 2) == 0 and -6 or 6, i > 2 and -38 or -6)
		bu[i]:SetScript("OnClick", j[2])
		bu[i]:HookScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:ClearLines()
			GameTooltip:AddLine("Raid Tool", 0, 0.6, 1)
			GameTooltip:AddLine(" ")
			if i == 1 then
				GameTooltip:AddLine("Disband the current group", 1, 0.82, 0)
			elseif i == 2 then
				GameTooltip:AddLine("Convert between party and raid", 1, 0.82, 0)
			elseif i == 3 then
				GameTooltip:AddLine("Start a role poll", 1, 0.82, 0)
			elseif i == 4 then
				GameTooltip:AddLine("Open raid panel", 1, 0.82, 0)
			end
			GameTooltip:Show()
		end)
		bu[i]:HookScript("OnLeave", K.HideTooltip)
	end

	parent.menu = frame
	parent.buttons = bu
end

function Module:RaidTool_EasyMarker()
	if not C["Misc"].EasyMarking then
		return
	end

	local menuList = {}

	local function GetMenuTitle(text, ...)
		return (... and K.RGBToHex(...) or "") .. text
	end

	local function SetRaidTargetByIndex(_, arg1)
		SetRaidTarget("target", arg1)
	end

	local mixins = {
		UnitPopupRaidTarget8ButtonMixin,
		UnitPopupRaidTarget7ButtonMixin,
		UnitPopupRaidTarget6ButtonMixin,
		UnitPopupRaidTarget5ButtonMixin,
		UnitPopupRaidTarget4ButtonMixin,
		UnitPopupRaidTarget3ButtonMixin,
		UnitPopupRaidTarget2ButtonMixin,
		UnitPopupRaidTarget1ButtonMixin,
		UnitPopupRaidTargetNoneButtonMixin,
	}
	for index, mixin in pairs(mixins) do
		local t1, t2, t3, t4 = mixin:GetTextureCoords()
		menuList[index] = {
			text = GetMenuTitle(mixin:GetText(), mixin:GetColor()),
			icon = mixin:GetIcon(),
			tCoordLeft = t1,
			tCoordRight = t2,
			tCoordTop = t3,
			tCoordBottom = t4,
			arg1 = 9 - index,
			func = SetRaidTargetByIndex,
		}
	end

	local function GetModifiedState()
		local index = C["Misc"].EasyMarkKey
		if index == 1 then
			return IsControlKeyDown()
		elseif index == 2 then
			return IsAltKeyDown()
		elseif index == 3 then
			return IsShiftKeyDown()
		elseif index == 4 then
			return false
		end
	end

	WorldFrame:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" and GetModifiedState() and UnitExists("mouseover") then
			if not IsInGroup() or (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				local index = GetRaidTargetIndex("mouseover")
				for i = 1, 8 do
					local menu = menuList[i]
					if menu.arg1 == index then
						menu.checked = true
					else
						menu.checked = false
					end
				end
				K.LibEasyMenu.Create(menuList, K.EasyMenu, "cursor", 0, 0, "MENU", 1)
			end
		end
	end)
end

function Module:RaidTool_WorldMarker()
	local iconTexture = {
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

	local frame = CreateFrame("Frame", "KKUI_WorldMarkers", UIParent)
	frame:SetPoint("RIGHT", -100, 0)
	K.CreateMoverFrame(frame, nil, true)
	K.RestoreMoverFrame(frame)
	frame:CreateBorder()
	frame.buttons = {}

	for i = 1, 9 do
		local button = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
		button:SetSize(24, 24)
		button.Icon = button:CreateTexture(nil, "ARTWORK")
		button.Icon:SetAllPoints()
		button.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		button.Icon:SetTexture(iconTexture[i])
		button:SetHighlightTexture(iconTexture[i])
		button:SetPushedTexture(iconTexture[i])

		if i ~= 9 then
			button:RegisterForClicks("AnyUp", "AnyDown")
			button:SetAttribute("type", "macro")
			button:SetAttribute("macrotext1", format("/wm %d", i))
			button:SetAttribute("macrotext2", format("/cwm %d", i))
			button:HookScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:ClearLines()
				GameTooltip:AddLine("World Marker", 0, 0.6, 1)
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(K.LeftButton .. K.InfoColor .. "Place world marker")
				GameTooltip:AddDoubleLine(K.RightButton .. K.InfoColor .. "Clear this marker")
				GameTooltip:Show()
			end)
			button:HookScript("OnLeave", K.HideTooltip)
		else
			button:SetScript("OnClick", ClearRaidMarker)
			button:HookScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:ClearLines()
				GameTooltip:AddLine("World Marker", 0, 0.6, 1)
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(K.LeftButton .. K.InfoColor .. "Clear all world markers")
				GameTooltip:Show()
			end)
			button:HookScript("OnLeave", K.HideTooltip)
		end
		frame.buttons[i] = button
	end

	Module:RaidTool_UpdateGrid()
end

local markerTypeToRow = {
	[1] = 3,
	[2] = 9,
	[3] = 1,
	[4] = 3,
}
function Module:RaidTool_UpdateGrid()
	local frame = _G["KKUI_WorldMarkers"]
	if not frame then
		return
	end

	local size, margin = C["Misc"].MarkerBarSize, 6
	local showType = C["Misc"].ShowMarkerBar
	local perRow = markerTypeToRow[showType]

	for i = 1, 9 do
		local button = frame.buttons[i]
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", frame, margin, -margin)
		elseif mod(i - 1, perRow) == 0 then
			button:SetPoint("TOP", frame.buttons[i - perRow], "BOTTOM", 0, -margin)
		else
			button:SetPoint("LEFT", frame.buttons[i - 1], "RIGHT", margin, 0)
		end
	end

	local column = min(9, perRow)
	local rows = ceil(9 / perRow)
	frame:SetWidth(column * size + (column - 1) * margin + 2 * margin)
	frame:SetHeight(size * rows + (rows - 1) * margin + 2 * margin)
	frame:SetShown(showType ~= 4)
end

function Module:RaidTool_Misc()
	-- UIWidget reanchor
	if not UIWidgetTopCenterContainerFrame:IsMovable() then -- can be movable for some addons, eg BattleInfo
		UIWidgetTopCenterContainerFrame:ClearAllPoints()
		UIWidgetTopCenterContainerFrame:SetPoint("TOP", 0, -46)
	end
end

function Module:RaidTool_Init()
	if not C["Misc"].RaidTool then
		return
	end

	local frame = Module:RaidTool_Header()
	Module:RaidTool_RoleCount(frame)
	Module:RaidTool_CombatRes(frame)
	Module:RaidTool_ReadyCheck(frame)
	Module:RaidTool_BuffChecker(frame)
	Module:RaidTool_CreateMenu(frame)
	Module:RaidTool_CountDown(frame)

	Module:RaidTool_EasyMarker()
	Module:RaidTool_WorldMarker()
	Module:RaidTool_Misc()
end
Module:RegisterMisc("RaidTool", Module.RaidTool_Init)
