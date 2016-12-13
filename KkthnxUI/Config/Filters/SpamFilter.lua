local K, C, L = unpack(select(2, ...))
if C.Chat.SpamFilter ~= true then return end

-- Spam keywords
K.SpamFilterWhitelist = {
	"[235]v[235]",
	"%.battle%.net/",
	"%.wix%.com",
	"%d+k[/\\]dungeon",
	"%f[%a]lf[gmw%d%s]", -- lfg, lfm, lfw, lf5, lf ...
	"%f[%a]sell",
	"%f[%a]wt[bst]", -- wtb, wts, wtt
	"|cff",
	"|h", -- links
	"|hspell",
	"appl[iy]", --apply/application
	"arena",
	"blingtron",
	"boost",
	"cardofomen",
	"community",
	"corplaunch%.com",
	"dkp",
	"dps",
	"drov",
	"enjin%.com",
	"etsii", --fi
	"ffa",
	"forgold",
	"fortunecard",
	"free ?roll",
	"gamerlaunch%.com",
	"gametime",
	"gilde", --de
	"gold ?run",
	"goldonly",
	"goldprices",
	"guild",
	"guildhosting.org",
	"guildlaunch%.com",
	"guildomatic%.com",
	"guildportal%.com",
	"guildwork.com",
	"he[ai]l",
	"heroic",
	"house",
	"join",
	"kaufe", -- de
	"kilta", --fi
	"lf[gm]",
	"looking",
	"members",
	"mog ?run",
	"mount",
	"mythic",
	"onlyacceptinggold",
	"own3d%.tv",
	"peйд", --ru, raid
	"peкpуt", --ru, recruit
	"physical",
	"players",
	"portal",
	"progres",
	"raid",
	"recrui?t",
	"rekryt", --se
	"reserve",
	"roleplay",
	"rukh", -- rukh, rukhan
	"s[cz]ena?r?i?o?", -- en/de
	"scam",
	"servertime",
	"shivtr%.com",
	"social",
	"soker", --se
	"sosyal", --tr
	"style ?ru[ns]h?", -- en/de
	"sucht", --de
	"synonym",
	"tank",
	"tar[il]na", -- tarlna, but people are dumb and also write tarina
	"tonight",
	"town",
	"transmog",
	"transmor?g",
	"trash farm",
	"twitch%.tv",
	"ustream%.tv",
	"vialofthe",
	"vk", -- de
	"weltboss", -- de
	"world ?boss",
	"wowlaunch%.com",
	"wowstead%.com",
	"дкп", --ru, dkp
	"лфг", --ru, lfg
	"нoвoбpaн", --ru, recruits
}

K.SpamFilterBlacklist = {
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
	"%d+k.*giveaway.*guild.*selling.*karazhan.*mount.*mythic.*dungeon.*nightmare.*raid", -- 100K weekly giveaway from our guild! By the way we are selling Karazhan with mount, Mythic Dungeons+, Emerald Nightmare raids
	"^wtskarazhan.*,mythic.*mythicdungeons?boost$", -- WTS Karazhan,Mythic+,10/10Mythic dungeon boost
	"^wtskarazhan[,.]mythic.*mythic+dungeon$", -- WTS karazhan. mythic and mythic+ dungeon
	"^wtsmount.*karazhan.*timerun.*quality.*service", --Wts mount from Karazhan (time run) right now! High quality service.
	"^wtsmythickarazhandungeons[,.]*whispme", -- WTS Mythić+ & Kârazhan Dungeøns. Whísp me.
	"^wtsnow.*nightmaremythic.*withmlfastcheap.*readytostartin%d+minute", --WTS Now Emerald Nightmare Mythic(7/7)with ML!Fast & Cheap!Get ready to start in 15 minutes!!!
	"selling.*professional.*team.*mount.*loot", --Selling <<Mythic+>>/<<Karazhan(mount)>>/<<EMERALD NIGHTMARE heroic>> by a professional team! Come get your mount and loot! Going Now pst for detail
	"wts.*heroic.*master.*loot.*mythic.*items.*guarantee.*info", --►►► [WТS] ► Trial of Valor Heroic with Master loot  ► Emerald Nightmare Heroic & Mythic 6 Items Guaranteed! ◄ ask me to get more info!
	"wts.*nightmare.*valor.*le?ve?ling.*best.*info", --►►►WTS: THE EMERALD NIGHTMARE | TRIAL OF VALOR | MYTHIC DUNGEONS |
	"wtsfast.*smooth.*karazhan.*mount.*valor.*nightmare.*wisp", --WTS FAST and SMOOTH Karazhan with mount, Trial of Valor, Emerald Nightmare run. Wisp!
	"цeн[ae].*lootkeeper[%.,]com", --Дракон из Каражана по хорошей цене ☼ Прокачка персонажей и фарм силы артефакта ☼ Фарм хонора и престижа ☼ Маунты ☼ - https://LootKeeper.com
	-- Selling sites
	"boosthive[%.,]eu",
	"dving[%.,]net",
	"farm4gold[%.,]com",
	"leprestore[%.,]com",
	"prestigewow[%.,]com",
	"speedruncharacter[%.,]net",
	--Symbol & space removal
	["[%*%-%(%)\"!%?`'_%+#%%%^&;:~{} ]"]="",
	["¨"]="", ["”"]="", ["“"]="", ["▄"]="", ["▀"]="", ["█"]="", ["▓"]="", ["▲"]="", ["◄"]="", ["►"]="", ["▼"]="",
	["░"]="", ["♥"]="", ["♫"]="", ["●"]="", ["■"]="", ["☼"]="", ["¤"]="", ["☺"]="", ["↑"]="", ["«"]="", ["»"]="",
	["▌"]="", ["√"]="", ["《"]="", ["》"]="",
	--This is the replacement table. It serves to deobfuscate words by replacing letters with their English "equivalents".
	["а"]="a", ["à"]="a", ["á"]="a", ["ä"]="a", ["â"]="a", ["ã"]="a", ["å"]="a", ["Ą"]="a", ["ą"]="a", --First letter is Russian "\208\176". Convert > \97. Note: Ą fail with strlower, include both.
	["с"]="c", ["ç"]="c", ["Ć"]="c", ["ć"]="c", --First letter is Russian "\209\129". Convert > \99. Note: Ć fail with strlower, include both.
	["е"]="e", ["è"]="e", ["é"]="e", ["ë"]="e", ["ё"]="e", ["ę"]="e", ["ė"]="e", ["ê"]="e", ["Ě"]="e", ["ě"]="e", ["Ē"]="e", ["ē"]="e", ["Έ"]="e", ["έ"]="e", ["Ĕ"]="e", ["ĕ"]="e", --First letter is Russian "\208\181". Convert > \101. Note: Ě, Ē, Έ, Ĕ fail with strlower, include both.
	["Ğ"]="g", ["ğ"]="g", ["Ĝ"]="g", ["ĝ"]="g", ["Ģ"]="g", ["ģ"]="g", -- Convert > \103. Note: Ğ, Ĝ, Ģ fail with strlower, include both.
	["ì"]="i", ["í"]="i", ["ï"]="i", ["î"]="i", ["ĭ"]="i", ["İ"]="i", --Convert > \105
	["к"]="k", ["ķ"]="k", -- First letter is Russian "\208\186". Convert > \107
	["Μ"]="m", ["м"]="m", -- First letter is capital Greek μ "\206\156". Convert > \109
	["о"]="o", ["ò"]="o", ["ó"]="o", ["ö"]="o", ["ō"]="o", ["ô"]="o", ["õ"]="o", ["ő"]="o", ["ø"]="o", ["Ǿ"]="o", ["ǿ"]="o", ["Θ"]="o", ["θ"]="o", ["○"]="o", --First letter is Russian "\208\190". Convert > \111. Note: Ǿ, Θ fail with strlower, include both.
	["р"]="p", --First letter is Russian "\209\128". Convert > \112
	["Ř"]="r", ["ř"]="r", ["Ŕ"]="r", ["ŕ"]="r", ["Ŗ"]="r", ["ŗ"]="r", --Convert > \114. -- Note: Ř, Ŕ, Ŗ fail with strlower, include both.
	["Ş"]="s", ["ş"]="s", ["Š"]="s", ["š"]="s", ["Ś"]="s", ["ś"]="s", --Convert > \115. -- Note: Ş, Š, Ś fail with strlower, include both.
	["т"]="t", --Convert > \116
	["ù"]="u", ["ú"]="u", ["ü"]="u", ["û"]="u", --Convert > \117
	["ý"]="y", ["ÿ"]="y", --Convert > \121
}