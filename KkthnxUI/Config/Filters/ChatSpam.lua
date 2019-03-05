local K = unpack(select(2, ...))

local _G = _G

K.GeneralChatSpam = {
	"an[au][ls]e?r?%f[%L]",
	"cs[:;]go%f[%A]",
	"nigg[ae]r?",
	"s%A*k%A*y%A*p%Ae",
	"webcam",
}

K.PrivateChatEventSpam = {
	"%-(.*)%|T(.*)|t(.*)|c(.*)%|r",
	"%[(.*)ARENA ANNOUNCER(.*)%]",
	"%[(.*)Announce by(.*)Shockeru(.*)%]",
	"%[(.*)Autobroadcast(.*)%]",
	"%[(.*)BG Queue Announcer(.*)%]",
	"Above are the latest fixes",
	"In your level range(.*)there are(.*)players(.*)Join Dungeon Finder(.*)to level faster and have fun",
	"VOTE PAGE",
	"You are not allowed to do that in this channel.",
	"Your current language is",
	"wow%-freakz%.com",
	_G.ERR_LEARN_ABILITY_S:gsub("%%s","(.*)"),
	_G.ERR_LEARN_PASSIVE_S:gsub("%%s","(.*)"),
	_G.ERR_LEARN_SPELL_S:gsub("%%s","(.*)"),
	_G.ERR_NOT_IN_INSTANCE_GROUP or "You aren't in an instance group.",
	_G.ERR_NOT_IN_RAID or "You are not in a raid group",
	_G.ERR_PET_LEARN_ABILITY_S:gsub("%%s","(.*)"),
	_G.ERR_PET_LEARN_SPELL_S:gsub("%%s","(.*)"),
	_G.ERR_PET_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
	_G.ERR_QUEST_ALREADY_ON or "You are already on that quest",
	_G.ERR_SPELL_UNLEARNED_S:gsub("%%s","(.*)"),
}

K.PrivateChatNoEventSpam = {
	"(.*)has invited you to join the channel 'global_(.*)'",
	"For(.*)romanian",
	"XP Rate",
	"You have blocked chat channel invites"
}