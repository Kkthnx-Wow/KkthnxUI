local K, C, L = unpack(select(2, ...))
if C.Chat.SpamFilter ~= true then return end

-- Spam keywords
K.SpamFilterList = {
	-- real spam
	"%.c0m%f[%A]",
	"%d/%d cm gold",
	"%d%s?eur%f[%A]",
	"%d%s?usd%f[%A]",
	"%S+#%d+", -- BattleTag
	"account",
	"boost",
	"cs[:;]go%f[%A]", -- seems to be the new hype
	"delivery",
	"diablo",
	"elite gear",
	"g0ld",
	"game ?time",
	"name change",
	"paypal",
	"professional",
	"qq", -- Chinese IM network, also catches junk as a bonus!
	"ranking",
	"realm",
	"s%A*k%A*y%A*p%Ae", -- spammers love to obfuscate "skype"
	"self ?play",
	"share",
	"transfer",
	"wow gold",
	-- pvp
	"[235]v[235]",
	"%f[%a]arena", -- arenacap, arenamate, arenapoints
	"%f[%a]cap%f[%A]",
	"%f[%a]carry%f[%A]",
	"%f[%a]cr%f[%A]",
	"%f[%d][235]s%f[%A]", -- 2s, 3s, 5s
	"conqu?e?s?t? cap",
	"conqu?e?s?t? points",
	"for %ds",
	"lf %ds",
	"low mmr",
	"partner",
	"points cap",
	"punktecap", -- DE
	"pvp ?mate",
	"rating",
	"rbg",
	"season",
	"weekly cap",
	-- junk
	"%[dirge%]",
	"%f[%a]ebay",
	"a?m[eu]rican?", -- america, american, murica
	"an[au][ls]e?r?%f[%L]", -- anal, anus, -e/er/es/en
	"argument",
	"aussie",
	"australi",
	"bacon",
	"bewbs",
	"bitch",
	"boobs",
	"christian",
	"chuck ?norris",
	"girl",
	"kiss",
	"mad ?bro",
	"mudda",
	"muslim",
	"nigg[ae]r?",
	"obama",
	"pussy",
	"sexy",
	"shut ?up",
	"tits",
	"twitch%.tv",
	"webcam",
	"wts.+guild",
	"xbox",
	"y?o?ur? m[ao]mm?a",
	"y?o?ur? m[ou]th[ae]r",
	"youtu%.?be",
	"youtube",
	-- TCG codes
	"hippogryph hatchling",
	"mottled drake",
	"rocket chicken",
	-- Taken from Badboy
	"%d+k.*giveaway.*guild.*selling.*karazhan.*mount.*mythic.*dungeon.*nightmare.*raid",
	"^wtskarazhan.*,mythic.*mythicdungeons?boost$",
	"^wtskarazhan[,.]mythic.*mythic+dungeon$",
	"^wtsmythickarazhandungeons[,.]*whispme",
	"dving[%.,]net",
	"dving[%.,]ru.*уcлуги",
	"selling.*professional.*team.*mount.*loot",
	"wtsfast.*smooth.*karazhan.*mount.*valor.*nightmare.*wisp",
	"цeн[ae].*lootkeeper[%.,]com",
}