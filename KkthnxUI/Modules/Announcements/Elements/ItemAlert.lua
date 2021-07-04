local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format

local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local GetTime = _G.GetTime
local IsInGroup = _G.IsInGroup
local SendChatMessage = _G.SendChatMessage
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitName = _G.UnitName

local lastTime = 0
local itemList = {
	[185709] = true, -- 焦糖鱼宴
	[226241] = true, -- 宁神圣典
	[256230] = true, -- 静心圣典
	[259409] = true, -- 海帆盛宴
	[259410] = true, -- 船长盛宴
	[265116] = true, -- 8.0工程战复
	[276972] = true, -- 秘法药锅
	[286050] = true, -- 鲜血大餐
	[54710] = true, -- 随身邮箱
	[67826] = true, -- 基维斯

	[307157] = true, -- 永恒药锅
	[308458] = true, -- 惊异怡人大餐
	[308462] = true, -- 纵情饕餮盛宴
	[324029] = true, -- 宁心圣典
	[345130] = true, -- 9.0工程战复
}

function Module:ItemAlert_Update(unit, _, spellID)
	if (UnitInRaid(unit) or UnitInParty(unit)) and spellID and itemList[spellID] and lastTime ~= GetTime() then
		local who = UnitName(unit)
		local link = GetSpellLink(spellID)
		local name = GetSpellInfo(spellID)
		SendChatMessage(string_format(L["Item Placed"], who, link or name), K.CheckChat())

		lastTime = GetTime()
	end
end

function Module:ItemAlert_CheckGroup()
	if IsInGroup() then
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	else
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	end
end

function Module:PlacedItemAlert()
	Module:ItemAlert_CheckGroup()
	K:RegisterEvent("GROUP_LEFT", Module.ItemAlert_CheckGroup)
	K:RegisterEvent("GROUP_JOINED", Module.ItemAlert_CheckGroup)
end

function Module:CreateItemAnnounce()
	if not C["Announcements"].ItemAlert then
		return
	end

	Module:PlacedItemAlert()
end