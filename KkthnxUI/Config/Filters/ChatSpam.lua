local K, C, L = select(2, ...):unpack()
if C.Chat.Enable ~= true or C.Chat.Spam ~= true then return end

K.ChatSpamList = {
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
	"rocket chicken",
}