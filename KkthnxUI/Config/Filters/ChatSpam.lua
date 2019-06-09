local K = unpack(select(2, ...))

local _G = _G

local ERR_LEARN_ABILITY_S = _G.ERR_LEARN_ABILITY_S
local ERR_LEARN_PASSIVE_S = _G.ERR_LEARN_PASSIVE_S
local ERR_LEARN_SPELL_S = _G.ERR_LEARN_SPELL_S
local ERR_NOT_IN_INSTANCE_GROUP = _G.ERR_NOT_IN_INSTANCE_GROUP
local ERR_NOT_IN_RAID = _G.ERR_NOT_IN_RAID
local ERR_PET_LEARN_ABILITY_S = _G.ERR_PET_LEARN_ABILITY_S
local ERR_PET_LEARN_SPELL_S = _G.ERR_PET_LEARN_SPELL_S
local ERR_PET_SPELL_UNLEARNED_S = _G.ERR_PET_SPELL_UNLEARNED_S
local ERR_QUEST_ALREADY_ON = _G.ERR_QUEST_ALREADY_ON
local ERR_SPELL_UNLEARNED_S = _G.ERR_SPELL_UNLEARNED_S

K.GeneralChatSpam = {
	"an[au][ls]e?r?%f[%L]",
	"nigg[ae]r?",
	"s%A*k%A*y%A*p%Ae",
}

K.PrivateChatEventSpam = {
	"%-(.*)%|T(.*)|t(.*)|c(.*)%|r",
	"%[(.*)Announce by(.*)%]",
	"%[(.*)ARENA ANNOUNCER(.*)%]",
	"%[(.*)Autobroadcast(.*)%]",
	"%[(.*)BG Queue Announcer(.*)%]",

	ERR_NOT_IN_INSTANCE_GROUP or "You aren't in an instance group.",
	ERR_NOT_IN_RAID or "You are not in a raid group",
	ERR_QUEST_ALREADY_ON or "You are already on that quest",
}

K.PrivateChatNoEventSpam = {

}

K.TalentChatSpam = {
	"^"..ERR_LEARN_ABILITY_S:gsub("%%s","(.*)"),
	"^"..ERR_LEARN_SPELL_S:gsub("%%s","(.*)"),
	"^"..ERR_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
	"^"..ERR_LEARN_PASSIVE_S:gsub("%%s","(.*)"),
	"^"..ERR_PET_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
	"^"..ERR_PET_LEARN_ABILITY_S:gsub("%%s","(.*)"),
	"^"..ERR_PET_LEARN_SPELL_S:gsub("%%s","(.*)"),
}