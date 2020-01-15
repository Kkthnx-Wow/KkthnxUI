local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local mod = _G.mod
local next = _G.next
local pairs = _G.pairs
local string_format = _G.string.format
local string_split = _G.string.split
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local C_Timer_After = _G.C_Timer.After
local ConvertToParty = _G.ConvertToParty
local ConvertToRaid = _G.ConvertToRaid
local CreateFrame = _G.CreateFrame
local GetInstanceInfo = _G.GetInstanceInfo
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetRaidRosterInfo = _G.GetRaidRosterInfo
local GetReadyCheckStatus = _G.GetReadyCheckStatus
local GetSpellCharges = _G.GetSpellCharges
local GetSpellInfo = _G.GetSpellInfo
local GetSpellTexture = _G.GetSpellTexture
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local IsPartyLFG = _G.IsPartyLFG
local LeaveParty = _G.LeaveParty
local SendChatMessage = _G.SendChatMessage
local SlashCmdList = _G.SlashCmdList
local UnitAura = _G.UnitAura
local UnitExists = _G.UnitExists
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitName = _G.UnitName
local IsLFGComplete = _G.IsLFGComplete
local IsInInstance = _G.IsInInstance

-- Raidbuff Checklist
K.RaidBuffCheckList = {
	[1] = {		-- Flasks
		251836,	-- Flask of the Currents
		251837,	-- Flask of Endless Fathoms
		251838,	-- Flask of the Vast Horizon
		251839,	-- Flask of the Undertow
		298836,	-- Greater Flask of the Currents
		298837,	-- Greater Flask of Endless Fathoms
		298839,	-- Greater Flask of the Vast Horizon
		298841,	-- Greater Flask of the Undertow
	},

	[2] = { -- Foods
		104273, -- Well Fed
	},

	[3] = { -- 10% Intellect
		1459, -- Arcane Intellect
		264760, -- War-Scroll of Intellect
	},

	[4] = { -- 10% Stamina
		21562, -- Power Word: Fortitude
		264764, -- War-Scroll of Fortitude
	},

	[5] = { -- 10% Offense
		6673, -- Battle Shout
		264761, -- War-Scroll of Battle
	},

	[6] = { -- Runes
		270058, -- Battle-Scarred
	},
}

function Module:CreateRaidUtility()
	if not C["Raid"].RaidUtility then
		return
	end

	local header = CreateFrame("Button", nil, UIParent)
	header:SetSize(120, 28)
	header:SetFrameLevel(2)
	header:SkinButton()
	K.Mover(header, "Raid Tool", "RaidManager", {"TOP", UIParent, "TOP", 0, -4})
	header:RegisterEvent("GROUP_ROSTER_UPDATE")
	header:RegisterEvent("PLAYER_ENTERING_WORLD")
	header:SetScript("OnEvent", function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		if IsInGroup() then
			self:Show()
		else
			self:Hide()
		end
	end)

	-- Role counts
	local function getRaidMaxGroup()
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

	local roleTexCoord = {
		{0.5, 0.75, 0, 1},
		{0.75, 1, 0, 1},
		{0.25, 0.5, 0, 1},
	}

	local roleFrame = CreateFrame("Frame", nil, header)
	roleFrame:SetAllPoints()

	local role = {}
	for i = 1, 3 do
		role[i] = roleFrame:CreateTexture(nil, "OVERLAY")
		role[i]:SetPoint("LEFT", 36 * i - 30, 0)
		role[i]:SetSize(15, 15)
		role[i]:SetTexture("Interface\\LFGFrame\\LFGROLE")
		role[i]:SetTexCoord(unpack(roleTexCoord[i]))
		role[i].text = K.CreateFontString(roleFrame, 13, "0", "")
		role[i].text:ClearAllPoints()
		role[i].text:SetPoint("CENTER", role[i], "RIGHT", 12, 0)
	end

	local raidCounts = {
		totalTANK = 0,
		totalHEALER = 0,
		totalDAMAGER = 0
	}

	roleFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	roleFrame:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD")
	roleFrame:RegisterEvent("UNIT_FLAGS")
	roleFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	roleFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	roleFrame:SetScript("OnEvent", function()
		for k in pairs(raidCounts) do
			raidCounts[k] = 0
		end

		local maxgroup = getRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead, _, _, assignedRole = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead and assignedRole ~= "NONE" then
				raidCounts["total"..assignedRole] = raidCounts["total"..assignedRole] + 1
			end
		end

		role[1].text:SetText(raidCounts.totalTANK)
		role[2].text:SetText(raidCounts.totalHEALER)
		role[3].text:SetText(raidCounts.totalDAMAGER)
	end)

	-- Battle resurrect
	local resFrame = CreateFrame("Frame", nil, header)
	resFrame:SetAllPoints()
	resFrame:SetAlpha(0)

	local res = CreateFrame("Frame", nil, resFrame)
	res:SetSize(22, 22)
	res:SetPoint("LEFT", 5, 0)

	res.Icon = res:CreateTexture(nil, "ARTWORK")
	res.Icon:SetTexture(GetSpellTexture(20484))
	res.Icon:SetAllPoints()
	res.Icon:SetTexCoord(unpack(K.TexCoords))

	res.Count = K.CreateFontString(res, 16, "0", "")
	res.Count:ClearAllPoints()
	res.Count:SetPoint("LEFT", res, "RIGHT", 10, 0)

	res.Timer = K.CreateFontString(resFrame, 16, "00:00", "", false, "RIGHT", -5, 0)

	res:SetScript("OnUpdate", function(self, elapsed)
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

				resFrame:SetAlpha(1)
				roleFrame:SetAlpha(0)
			else
				resFrame:SetAlpha(0)
				roleFrame:SetAlpha(1)
			end

			self.elapsed = 0
		end
	end)

	-- Ready check indicator
	local rcFrame = CreateFrame("Frame", nil, header)
	rcFrame:SetPoint("TOP", header, "BOTTOM", 0, -6)
	rcFrame:SetSize(120, 50)
	rcFrame:Hide()
	rcFrame:CreateBorder()
	K.CreateFontString(rcFrame, 14, READY_CHECK, "", true, "TOP", 0, -8)
	local rc = K.CreateFontString(rcFrame, 14, "", "", false, "TOP", 0, -28)

	local count, total
	local function hideRCFrame()
		rcFrame:Hide()
		rc:SetText("")
		count, total = 0, 0
	end

	rcFrame:RegisterEvent("READY_CHECK")
	rcFrame:RegisterEvent("READY_CHECK_CONFIRM")
	rcFrame:RegisterEvent("READY_CHECK_FINISHED")
	rcFrame:SetScript("OnEvent", function(self, event)
		if event == "READY_CHECK_FINISHED" then
			if count == total then
				rc:SetTextColor(0, 1, 0)
			else
				rc:SetTextColor(1, 0, 0)
			end
			C_Timer_After(5, hideRCFrame)
		else
			count, total = 0, 0
			self:Show()
			local maxgroup = getRaidMaxGroup()
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
	end)

	rcFrame:SetScript("OnMouseUp", function(self)
		self:Hide()
	end)

	-- World marker
	local marker = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
	if not marker then
		for _, addon in next, {
			"Blizzard_CUFProfiles",
			"Blizzard_CompactRaidFrames"
		} do
			EnableAddOn(addon)
			LoadAddOn(addon)
		end
	end

	if marker then
		marker:ClearAllPoints()
		marker:SetPoint("RIGHT", header, "LEFT", -6, 0)
		marker:SetParent(header)
		marker:SetSize(28, 28)
		marker:StripTextures()
		marker:SkinButton()
		marker:SetNormalTexture("Interface\\RaidFrame\\Raid-WorldPing")
		marker:GetNormalTexture():SetVertexColor(K.r, K.g, K.b)
		marker:HookScript("OnMouseUp", function(_, btn)
			if (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				if btn == "RightButton" then
					ClearRaidMarker()
				end
			else
				UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
			end
		end)
	end

	-- Buff checker
	local checker = CreateFrame("Button", nil, header)
	checker:SetPoint("LEFT", header, "RIGHT", 6, 0)
	checker:SetSize(28, 28)
	K.CreateFontString(checker, 16, "!", "", true)
	checker:SkinButton()

	local BuffName, numPlayer = {
		"Flask",
		"Food",
		SPELL_STAT4_NAME,
		RAID_BUFF_2,
		RAID_BUFF_3,
		RUNES
	}
	local NoBuff, numGroups = {}, 6
	for i = 1, numGroups do
		NoBuff[i] = {}
	end

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
				sendMsg(L["Lack"].." "..BuffName[i]..": "..L["Everyone"])
			elseif count >= 5 and i > 2 then
				sendMsg(L["Lack"].." "..BuffName[i]..": "..string_format(K.ColorClass.."%s players|r", count))
			else
				local str = L["Lack"].." "..BuffName[i]..": "
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

		local maxgroup = getRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead then
				numPlayer = numPlayer + 1
				for j = 1, numGroups do
					local HasBuff
					local buffTable = K.RaidBuffCheckList[j]
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
						name = string_split("-", name)	-- remove realm name
						table_insert(NoBuff[j], name)
					end
				end
			end
		end

		-- if not C["Skins"]["RMRune"] then
		-- 	NoBuff[numGroups] = {}
		-- end

		if #NoBuff[1] == 0 and #NoBuff[2] == 0 and #NoBuff[3] == 0 and #NoBuff[4] == 0 and #NoBuff[5] == 0 and #NoBuff[6] == 0 then
			sendMsg(L["All Buffs Ready"])
		else
			sendMsg(L["Raid Buff Checker"])
			for i = 1, 5 do
				sendResult(i)
			end
			sendResult(numGroups)
		end
	end

	local potionCheck
	if IsAddOnLoaded("ExRT") then
		potionCheck = true
	end

	checker:HookScript("OnEnter", function(self)
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
	checker:HookScript("OnLeave", K.HideTooltip)

	local reset = true
	checker:HookScript("OnMouseDown", function(_, btn)
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
				DoReadyCheck()
			else
				UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
			end
		else
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				if IsAddOnLoaded("DBM-Core") then
					if reset then
						SlashCmdList["DEADLYBOSSMODS"]("pull ".."10")
					else
						SlashCmdList["DEADLYBOSSMODS"]("pull 0")
					end
					reset = not reset
				elseif IsAddOnLoaded("BigWigs") then
					if not SlashCmdList["BIGWIGSPULL"] then
						LoadAddOn("BigWigs_Plugins")
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
	checker:RegisterEvent("PLAYER_REGEN_ENABLED")
	checker:SetScript("OnEvent", function()
		reset = true
	end)

	-- Others
	local menu = CreateFrame("Frame", nil, header)
	menu:SetPoint("TOP", header, "BOTTOM", 0, -6)
	menu:SetSize(188, 70)
	menu:CreateBorder()
	menu:Hide()
	menu:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", function(self, elapsed)
			self.timer = (self.timer or 0) + elapsed
			if self.timer > 0.1 then
				if not menu:IsMouseOver() then
					self:Hide()
					self:SetScript("OnUpdate", nil)
				end

				self.timer = 0
			end
		end)
	end)

	StaticPopupDialogs["Group_Disband"] = {
		text = L["Confirm Disband"],
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
					if online and name ~= K.Name then
						UninviteUnit(name)
					end
				end
			else
				for i = MAX_PARTY_MEMBERS, 1, -1 do
					if UnitExists("party"..i) then
						UninviteUnit(UnitName("party"..i))
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

					menu:Hide()
					menu:SetScript("OnUpdate", nil)
				else
					UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
				end
		end},

		{ROLE_POLL, function()
				if IsInGroup() and not HasLFGRestrictions() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
					InitiateRolePoll()
				else
					UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_LEADER)
				end
		end},

		{RAID_CONTROL, function()
				ToggleFriendsFrame(3)
		end},
	}

	local bu = {}
	for i, j in pairs(buttons) do
		bu[i] = CreateFrame("Button", nil, menu)
		bu[i]:SetSize(86, 26)
		bu[i]:SkinButton()
		bu[i].text = K.CreateFontString(bu[i], 12, j[1], true)
		bu[i]:SetPoint(mod(i, 2) == 0 and "TOPRIGHT" or "TOPLEFT", mod(i, 2) == 0 and -5 or 5, i > 2 and -38 or -6)
		bu[i]:SetScript("OnClick", j[2])
	end

	local function updateText(text)
		if IsInRaid() then
			text:SetText(L["Convert Party"])
		else
			text:SetText(L["Convert Raid"])
		end
	end

	header:RegisterForClicks("AnyUp")
	header:SetScript("OnClick", function(_, btn)
		if btn == "LeftButton" then
			ToggleFrame(menu)
			updateText(bu[2].text)
		end
	end)

	header:SetScript("OnDoubleClick", function(_, btn)
		if btn == "RightButton" and (IsPartyLFG() and IsLFGComplete() or not IsInInstance()) then
			LeaveParty()
		end
	end)

	header:HookScript("OnShow", function(self)
		self:SetBackdropBorderColor()
	end)

	-- Easymarking
	local menuFrame = CreateFrame("Frame", "KKUI_EastMarking", UIParent, "UIDropDownMenuTemplate")
	local menuList = {
		{text = RAID_TARGET_NONE, func = function()
				SetRaidTarget("target", 0)
		end},

		{text = K.RGBToHex(1, .92, 0)..RAID_TARGET_1.." "..ICON_LIST[1].."12|t", func = function()
				SetRaidTarget("target", 1)
		end},

		{text = K.RGBToHex(.98, .57, 0)..RAID_TARGET_2.." "..ICON_LIST[2].."12|t", func = function()
				SetRaidTarget("target", 2)
		end},

		{text = K.RGBToHex(.83, .22, .9)..RAID_TARGET_3.." "..ICON_LIST[3].."12|t", func = function()
				SetRaidTarget("target", 3)
		end},

		{text = K.RGBToHex(.04, .95, 0)..RAID_TARGET_4.." "..ICON_LIST[4].."12|t", func = function()
				SetRaidTarget("target", 4)
		end},

		{text = K.RGBToHex(.7, .82, .875)..RAID_TARGET_5.." "..ICON_LIST[5].."12|t", func = function()
				SetRaidTarget("target", 5)
		end},

		{text = K.RGBToHex(0, .71, 1)..RAID_TARGET_6.." "..ICON_LIST[6].."12|t", func = function()
				SetRaidTarget("target", 6)
		end},

		{text = K.RGBToHex(1, .24, .168)..RAID_TARGET_7.." "..ICON_LIST[7].."12|t", func = function()
				SetRaidTarget("target", 7)
		end},

		{text = K.RGBToHex(.98, .98, .98)..RAID_TARGET_8.." "..ICON_LIST[8].."12|t", func = function()
				SetRaidTarget("target", 8)
		end},
	}

	WorldFrame:HookScript("OnMouseDown", function(_, btn)
		-- if not C["Skins"].EasyMarking then return end
		if btn == "LeftButton" and IsControlKeyDown() and UnitExists("mouseover") then
			if not IsInGroup() or (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				local ricon = GetRaidTargetIndex("mouseover")
				for i = 1, 8 do
					if ricon == i then
						menuList[i + 1].checked = true
					else
						menuList[i + 1].checked = false
					end
				end

				EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 1)
			end
		end
	end)
end