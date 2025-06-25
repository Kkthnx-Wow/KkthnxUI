local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

-- Localize WoW API functions
local string_format = string.format
local C_Spell_GetSpellLink = C_Spell.GetSpellLink
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local IsInGroup = IsInGroup
local SendChatMessage = SendChatMessage
local UnitName = UnitName

-- Define player GUID and group units
local groupUnits = { ["player"] = true, ["pet"] = true }
for i = 1, 4 do
	groupUnits["party" .. i] = true
	groupUnits["partypet" .. i] = true
end

for i = 1, 40 do
	groupUnits["raid" .. i] = true
	groupUnits["raidpet" .. i] = true
end

-- Define important spells with IDs
local importantSpells = {
	[698] = true, -- 拉人
	[29893] = true, -- 糖
	[190336] = true, -- 面包
	[54710] = true, -- 随身邮箱
	[67826] = true, -- 基维斯
	[226241] = true, -- 宁神圣典
	[256230] = true, -- 静心圣典
	[185709] = true, -- 焦糖鱼宴
	[199109] = true, -- 自动铁锤
	[259409] = true, -- 海帆盛宴
	[259410] = true, -- 船长盛宴
	[276972] = true, -- 秘法药锅
	[286050] = true, -- 鲜血大餐
	[265116] = true, -- 8.0工程战复
	[308458] = true, -- 惊异怡人大餐
	[308462] = true, -- 纵情饕餮盛宴
	[345130] = true, -- 9.0工程战复
	[307157] = true, -- 永恒药锅
	[359336] = true, -- 石头汤锅
	[261602] = true, -- 凯蒂的印哨
	[376664] = true, -- 欧胡纳栖枝

	[2825] = true, -- 嗜血
	[32182] = true, -- 英勇
	[80353] = true, -- 时间扭曲
	[90355] = true, -- 远古狂乱，宠物
	[264667] = true, -- 原始暴怒，宠物
	[272678] = true, -- 原始暴怒，宠物掌控
	[178207] = true, -- 狂怒战鼓
	[230935] = true, -- 高山战鼓
	[256740] = true, -- 漩涡战鼓
	[292686] = true, -- 雷皮之槌
	[390386] = true, -- 守护巨龙之怒
	[309658] = true, -- 死亡凶蛮战鼓
	[444257] = true, -- 掣雷之鼓
	[466904] = true, -- 鹞鹰尖啸

	[384893] = true, -- 足以乱真的救急电缆11.0工程战复
	[453949] = true, -- 不可抗拒的红色按钮11.0工程战复工具
	[453942] = true, -- 阿加修理机器人11O
	[432877] = true, -- 阿加合剂大锅
	[433292] = true, -- 阿加药水大锅
	[455960] = true, -- 全味炖煮
	[457285] = true, -- 午夜舞会盛宴
	[457302] = true, -- 特色寿司
	[457487] = true, -- 丰盛的全味炖煮(战团)
	[462211] = true, -- 丰盛的特色寿司(战团)
	[462213] = true, -- 丰盛的午夜舞会盛宴(战团)
}

-- Function to handle spell cast alerts
function Module:UpdateItemAlert(unit, castID, spellID)
	if groupUnits[unit] and importantSpells[spellID] and importantSpells[spellID] ~= castID then
		local spellLink = C_Spell_GetSpellLink(spellID) or C_Spell_GetSpellInfo(spellID)
		if spellLink then
			SendChatMessage(string_format("%s used %s", UnitName(unit), spellLink), K.CheckChat())
			importantSpells[spellID] = castID
		end
	end
end

-- Function to check if the player is in a group and register/unregister events accordingly
function Module:CheckGroupStatus()
	if IsInGroup() then
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	else
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	end
end

-- Main function to handle spell and item alerts
function Module:CreateItemAnnounce()
	Module.factionSpell = (K.Faction == "Alliance" and 32182 or 2825)
	Module.factionSpell = C_Spell_GetSpellLink(Module.factionSpell) or C_Spell_GetSpellInfo(Module.factionSpell)

	if C["Announcements"].ItemAlert then
		Module:CheckGroupStatus()
		K:RegisterEvent("GROUP_LEFT", Module.CheckGroupStatus)
		K:RegisterEvent("GROUP_JOINED", Module.CheckGroupStatus)
	else
		K:UnregisterEvent("GROUP_LEFT", Module.CheckGroupStatus)
		K:UnregisterEvent("GROUP_JOINED", Module.CheckGroupStatus)
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	end
end
