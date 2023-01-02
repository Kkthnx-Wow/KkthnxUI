local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format

local AURA_TYPE_BUFF = _G.AURA_TYPE_BUFF
local GetInstanceInfo = _G.GetInstanceInfo
local GetSpellLink = _G.GetSpellLink
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena
local IsArenaSkirmish = _G.IsArenaSkirmish
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local IsPartyLFG = _G.IsPartyLFG
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid

local infoType = {}

local spellBlackList = {
	[99] = true, -- 夺魂咆哮
	[122] = true, -- 冰霜新星
	[1776] = true, -- 凿击
	[1784] = true, -- 潜行
	[5246] = true, -- 破胆怒吼
	[8122] = true, -- 心灵尖啸
	[31661] = true, -- 龙息术
	[33395] = true, -- 冰冻术
	[64695] = true, -- 陷地
	[82691] = true, -- 冰霜之环
	[91807] = true, -- 蹒跚冲锋
	[102359] = true, -- 群体缠绕
	[105421] = true, -- 盲目之光
	[115191] = true, -- 潜行
	[157997] = true, -- 寒冰新星
	[197214] = true, -- 裂地术
	[198121] = true, -- 冰霜撕咬
	[207167] = true, -- 致盲冰雨
	[207685] = true, -- 悲苦咒符
	[226943] = true, -- 心灵炸弹
	[228600] = true, -- 冰川尖刺
	[331866] = true, -- 混沌代理人
	[354051] = true, -- 轻盈步
	[386770] = true, -- 极寒
}

local function msgChannel()
	local inRaid, inPartyLFG = IsInRaid(), IsPartyLFG()

	local _, instanceType = GetInstanceInfo()
	if instanceType == "arena" then
		local skirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		if skirmish or not isRegistered then
			inPartyLFG = true
		end
		inRaid = false -- IsInRaid() returns true for arenas and they should not be considered a raid
	end

	local Value = C["Announcements"].AlertChannel.Value
	if Value == 1 then
		return inPartyLFG and "INSTANCE_CHAT" or "PARTY"
	elseif Value == 2 then
		return inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY")
	elseif Value == 3 and inRaid then
		return inPartyLFG and "INSTANCE_CHAT" or "RAID"
	elseif Value == 4 and instanceType ~= "none" then
		return "SAY"
	elseif Value == 5 and instanceType ~= "none" then
		return "YELL"
	elseif Value == 6 then
		return "EMOTE"
	end
end

function Module:InterruptAlert_Toggle()
	infoType["SPELL_STOLEN"] = C["Announcements"].DispellAlert and L["Steal"]
	infoType["SPELL_DISPEL"] = C["Announcements"].DispellAlert and L["Dispel"]
	infoType["SPELL_INTERRUPT"] = C["Announcements"].InterruptAlert and L["Interrupt"]
	infoType["SPELL_AURA_BROKEN_SPELL"] = C["Announcements"].BrokenAlert and L["BrokenSpell"]
end

function Module:InterruptAlert_IsEnabled()
	for _, value in pairs(infoType) do
		if value then
			return true
		end
	end
end

function Module:IsAllyPet(sourceFlags)
	if K.IsMyPet(sourceFlags) or sourceFlags == K.PartyPetFlags or sourceFlags == K.RaidPetFlags then
		return true
	end
end

function Module:InterruptAlert_Update(...)
	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraskillID, _, _, auraType = ...
	if not sourceGUID or sourceName == destName then
		return
	end

	if UnitInRaid(sourceName) or UnitInParty(sourceName) or Module:IsAllyPet(sourceFlags) then
		local infoText = infoType[eventType]
		if infoText then
			local sourceSpellID, destSpellID
			if infoText == L["BrokenSpell"] then
				if auraType and auraType == AURA_TYPE_BUFF or spellBlackList[spellID] then
					return
				end
				sourceSpellID, destSpellID = extraskillID, spellID
			elseif infoText == L["Interrupt"] then
				if C["Announcements"].OwnInterrupt and sourceName ~= K.Name and not Module:IsAllyPet(sourceFlags) then
					return
				end
				sourceSpellID, destSpellID = spellID, extraskillID
			else
				if C["Announcements"].OwnDispell and sourceName ~= K.Name and not Module:IsAllyPet(sourceFlags) then
					return
				end
				sourceSpellID, destSpellID = spellID, extraskillID
			end

			if sourceSpellID and destSpellID then
				if infoText == L["BrokenSpell"] then
					SendChatMessage(string_format(infoText, sourceName, GetSpellLink(destSpellID)), msgChannel())
				else
					SendChatMessage(string_format(infoText, GetSpellLink(destSpellID)), msgChannel())
				end
			end
		end
	end
end

function Module:InterruptAlert_CheckGroup()
	if IsInGroup() and (not C["Announcements"].InstAlertOnly or (IsInInstance() and not IsPartyLFG())) then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end

function Module:CreateInterruptAnnounce()
	Module:InterruptAlert_Toggle()

	if Module:InterruptAlert_IsEnabled() then
		self:InterruptAlert_CheckGroup()
		K:RegisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		K:RegisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		K:RegisterEvent("PLAYER_ENTERING_WORLD", self.InterruptAlert_CheckGroup)
	else
		K:UnregisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end
