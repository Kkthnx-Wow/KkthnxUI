local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Miscellaneous")

local _G = _G
local pairs = _G.pairs
local string_find = _G.string.find

local C_GossipInfo_GetNumOptions = _G.C_GossipInfo.GetNumOptions
local C_GossipInfo_SelectOption = _G.C_GossipInfo.SelectOption
local C_QuestLog_GetLogIndexForQuestID = _G.C_QuestLog.GetLogIndexForQuestID
local GetActionInfo = _G.GetActionInfo
local GetOverrideBarSkin = _G.GetOverrideBarSkin
local GetSpellInfo = _G.GetSpellInfo
local UnitGUID = _G.UnitGUID

C["Misc"].QuestTool = true

L["SpellTip356464"] = "Mousewheel up on blue circles, mousewheel down on red circles, try harder!"
L["SpellTip333960"] = "Mousewheel up on blue circles, try harder!"
L["SpellTip356151"] = "Mousewhell up when Wilderling speeds up!"
L["NPCisTrue"] = "This is |cffff0000T|cffff7f00R|cffffff00U|cff00ff00E"
L["QuestTool"] = "Quests Tool"
L["QuestToolTip"] = "|nIf enabled, add tips for some quests and world quests."
L["CatchButterfly"] = "Get close to butterflies and mouse scroll up."

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

local fixedStrings = {
	["横扫"] = "低扫",
	["突刺"] = "突袭",
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

local function isActionMatch(msg, text)
	return text and string_find(msg, text)
end

function Module:QuestTool_SetGlow(msg)
	if GetOverrideBarSkin() and (activeQuests[59585] or activeQuests[64271]) then
		for i = 1, 3 do
			local button = _G["ActionButton"..i]
			local _, spellID = GetActionInfo(button.action)
			local name = spellID and GetSpellInfo(spellID)
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
			K.HideOverlayGlow(_G["ActionButton"..i])
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
		self:AddLine(L["NPCisTrue"])
	end
end

function Module:CreateQuestTool()
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
	GameTooltip:HookScript("OnTooltipSetUnit", Module.QuestTool_SetQuestUnit)

	-- Auto gossip
	local firstStep
	K:RegisterEvent("GOSSIP_SHOW", function()
		local guid = UnitGUID("npc")
		local npcID = guid and K.GetNPCID(guid)
		if npcID == 174498 then
			C_GossipInfo_SelectOption(3)
		elseif npcID == 174371 then
			if GetItemCount(183961) == 0 then
				return
			end

			if C_GossipInfo_GetNumOptions() ~= 5 then
				return
			end

			if firstStep then
				C_GossipInfo_SelectOption(5)
			else
				C_GossipInfo_SelectOption(2)
				firstStep = true
			end
		end
	end)
end

Module:RegisterMisc("QuestTool", Module.CreateQuestTool)