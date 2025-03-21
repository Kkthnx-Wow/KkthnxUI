local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local pairs, strfind = pairs, strfind
local UnitGUID, C_Item_GetItemCount = UnitGUID, C_Item.GetItemCount
local GetActionInfo, C_Spell_GetSpellInfo, GetOverrideBarSkin = GetActionInfo, C_Spell.GetSpellInfo, GetOverrideBarSkin
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_GossipInfo_SelectOption, C_GossipInfo_GetNumOptions = C_GossipInfo.SelectOption, C_GossipInfo.GetNumOptions

local watchQuests = {
	-- check npc
	[60739] = true, -- https://www.wowhead.com/quest=60739/tough-crowd
	[62453] = true, -- https://www.wowhead.com/quest=62453/into-the-unknown
	-- glow
	[59585] = true, -- https://www.wowhead.com/quest=59585/well-make-an-aspirant-out-of-you
	[64271] = true, -- https://www.wowhead.com/quest=64271/a-more-civilized-way
}
local activeQuests = {}

local questNPCs = {
	[170080] = true, -- Boggart
	[174498] = true, -- Shimmersod
}

function Module:QuestTool_Init()
	for questID, value in pairs(watchQuests) do
		if C_QuestLog_GetLogIndexForQuestID(questID) then
			activeQuests[questID] = value
		end
	end
end

function Module:QuestTool_Accept(questID)
	if watchQuests[questID] then
		activeQuests[questID] = watchQuests[questID]
	end
end

function Module:QuestTool_Remove(questID)
	if watchQuests[questID] then
		activeQuests[questID] = nil
	end
end

local fixedStrings = {
	["Sweep"] = "Lunge",
	["Assault"] = "Assault",
}
local function isActionMatch(msg, text)
	return text and strfind(msg, text)
end

function Module:QuestTool_SetGlow(msg)
	if GetOverrideBarSkin() and (activeQuests[59585] or activeQuests[64271]) then
		for i = 1, 3 do
			local button = _G["ActionButton" .. i]
			local _, spellID = GetActionInfo(button.action)
			local name = spellID and C_Spell_GetSpellInfo(spellID)
			if fixedStrings[name] and isActionMatch(msg, fixedStrings[name]) or isActionMatch(msg, name) then
				K.ShowOverlayGlow(button)
			else
				K.HideOverlayGlow(button)
			end
		end
		Module.isGlowing = true
	else
		Module:QuestTool_ClearGlow()
	end
end

function Module:QuestTool_ClearGlow()
	if Module.isGlowing then
		Module.isGlowing = nil
		for i = 1, 3 do
			K.HideOverlayGlow(_G["ActionButton" .. i])
		end
	end
end

function Module:QuestTool_SetQuestUnit()
	if not activeQuests[60739] and not activeQuests[62453] then
		return
	end

	local guid = UnitGUID("mouseover")
	local npcID = guid and K.GetNPCID(guid)
	if questNPCs[npcID] then
		self:AddLine(L["QuestTool NPCisTrue"])
	end
end

function Module:QuestTool()
	if not C["Misc"].QuestTool then
		return
	end

	local handler = CreateFrame("Frame", nil, UIParent)
	Module.QuestHandler = handler

	local text = K.CreateFontString(handler, 20)
	text:ClearAllPoints()
	text:SetPoint("TOP", UIParent, 0, -200)
	text:SetWidth(800)
	text:SetWordWrap(true)
	text:Hide()
	Module.QuestTip = text

	-- Check existing quests
	Module:QuestTool_Init()
	K:RegisterEvent("QUEST_ACCEPTED", Module.QuestTool_Accept)
	K:RegisterEvent("QUEST_REMOVED", Module.QuestTool_Remove)

	-- Override button quests
	if C["ActionBar"].Enable then
		K:RegisterEvent("CHAT_MSG_MONSTER_SAY", Module.QuestTool_SetGlow)
		K:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Module.QuestTool_ClearGlow)
	end

	-- Check npc in quests
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, Module.QuestTool_SetQuestUnit)

	-- Auto gossip
	local firstStep
	K:RegisterEvent("GOSSIP_SHOW", function()
		local guid = UnitGUID("npc")
		if guid then
			local npcID = K.GetNPCID(guid)
			if npcID == 174498 then
				C_GossipInfo_SelectOption(3)
			elseif npcID == 174371 then
				if C_Item_GetItemCount(183961) > 0 and C_GossipInfo_GetNumOptions() == 5 then
					C_GossipInfo_SelectOption(firstStep and 2 or 5)
					firstStep = not firstStep
				end
			end
		end
	end)
end

Module:RegisterMisc("QuestTool", Module.QuestTool)
