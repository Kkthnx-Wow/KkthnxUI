local K, C, L = unpack(select(2, ...))
if C.Chat.SpamFilter ~= true then return end

-- Spam keywords
K.SpamFilterWhitelist = {
	"|h", -- links
	"%f[%a]lf[gmw%d%s]", -- lfg, lfm, lfw, lf5, lf ...
	"%f[%a]wt[bst]", -- wtb, wts, wtt
	"%f[%a]sell",
	"blingtron",
	"dps",
	"drov",
	"ffa",
	"free ?roll",
	"gold ?run",
	"he[ai]l",
	"heroic",
	"kaufe", -- de
	"mog ?run",
	"mount",
	"mythic",
	"reserve",
	"rukh", -- rukh, rukhan
	"s[cz]ena?r?i?o?", -- en/de
	"suche", -- de
	"style ?ru[ns]h?", -- en/de
	"tank",
	"tar[il]na", -- tarlna, but people are dumb and also write tarina
	"transmog",
	"trash farm",
	"vk", -- de
	"weltboss", -- de
	"world ?boss"
}

K.SpamFilterBlacklist = {
	-- real spam
	"%.c0m%f[%A]",
	"%S+#%d+", -- BattleTag
	"%d/%d cm gold",
	"%d%s?eur%f[%A]",
	"%d%s?usd%f[%A]",
	"account",
	"boost",
	"cs[:;]go%f[%A]", -- seems to be the new hype
	"delivery",
	"diablo",
	"elite gear",
	"game ?time",
	"g0ld",
	"name change",
	"paypal",
	"professional",
	"qq", -- Chinese IM network, also catches junk as a bonus!
	"ranking",
	"realm",
	"self ?play",
	"server",
	"share",
	"s%A*k%A*y%A*p%Ae", -- spammers love to obfuscate "skype"
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
	"youtu%.?be",
	"y?o?ur? m[ao]mm?a",
	"y?o?ur? m[ou]th[ae]r",
	"youtube",
	-- TCG codes
	"hippogryph hatchling",
	"mottled drake",
	"rocket chicken"
}