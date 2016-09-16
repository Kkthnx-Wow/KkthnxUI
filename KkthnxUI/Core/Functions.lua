local K, C, L, _ = select(2, ...):unpack()

local format, find, gsub = string.format, string.find, string.gsub
local match = string.match
local floor, ceil = math.floor, math.ceil
local print = print
local reverse = string.reverse
local tonumber, type = tonumber, type
local unpack, select = unpack, select
local CreateFrame = CreateFrame
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellInfo = GetSpellInfo
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local UnitStat, UnitAttackPower, UnitBuff = UnitStat, UnitAttackPower, UnitBuff
local tinsert, tremove = tinsert, tremove
local Locale = GetLocale()

K.Backdrop = {bgFile = C.Media.Blank, edgeFile = C.Media.Blizz, edgeSize = 14, insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}}
K.Border = {edgeFile = C.Media.Blizz, edgeSize = 14}
K.BorderBackdrop = {bgFile = C.Media.Blank}
K.PixelBorder = {edgeFile = C.Media.Blank, edgeSize = K.Mult, insets = {left = K.Mult, right = K.Mult, top = K.Mult, bottom = K.Mult}}
K.ShadowBackdrop = {edgeFile = C.Media.Glow, edgeSize = 3, insets = {left = 5, right = 5, top = 5, bottom = 5}}

-- THIS FRAME EVERYTHING IN KKTHNXUI SHOULD BE ANCHORED TO FOR EYEFINITY SUPPORT.
K.UIParent = CreateFrame("Frame", "KkthnxUIParent", UIParent)
K.UIParent:SetFrameLevel(UIParent:GetFrameLevel())
K.UIParent:SetPoint("CENTER", UIParent, "CENTER")
K.UIParent:SetSize(UIParent:GetSize())

K.TexCoords = {5/65, 59/64, 5/64, 59/64}

K.Print = function(...)
	print("|cff2eb6ffKkthnxUI|r:", ...)
end

K.SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(0, -0)

	return fs
end

K.Comma = function(num)
	local Left, Number, Right = match(num, "^([^%d]*%d)(%d*)(.-)$")

	return 	Left .. reverse(gsub(reverse(Number), "(%d%d%d)", "%1,")) .. Right
end

-- SHORTVALUE, WE SHOW A DIFFERENT VALUE FOR THE CHINESE CLIENT.
K.ShortValue = function(value)
	if (Locale == "zhCN") then
		if abs(value) >= 1e8 then
			return format("%.1fY", value / 1e8)
		elseif abs(value) >= 1e4 then
			return format("%.1fW", value / 1e4)
		else
			return format("%d", value)
		end
	else
		if abs(value) >= 1e9 then
			return format("%.1fG", value / 1e9)
		elseif abs(value) >= 1e6 then
			return format("%.1fM", value / 1e6)
		elseif abs(value) >= 1e3 then
			return format("%.1fk", value / 1e3)
		else
			return format("%d", value)
		end
	end
end

-- ROUNDING
K.Round = function(number, decimals)
	if (not decimals) then
		decimals = 0
	end

	return format(format("%%.%df", decimals), number)
end

-- RGBTOHEX COLOR
K.RGBToHex = function(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0

	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- HELPER FUNCTION FOR MOVING A BLIZZARD FRAME THAT HAS A SETMOVEABLE FLAG
K.ModifyFrame = function(frame, anchor, parent, posX, posY, scale)
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:ClearAllPoints()
	if(parent == nil) then frame:SetPoint(anchor, posX, posY) else frame:SetPoint(anchor, parent, posX, posY) end
	if(scale ~= nil) then frame:SetScale(scale) end
	frame:SetUserPlaced(true)
	frame:SetMovable(false)
end

-- HELPER FUNCTION FOR MOVING A BLIZZARD FRAME THAT DOES NOT HAVE A SETMOVEABLE FLAG
K.ModifyBasicFrame = function(frame, anchor, parent, posX, posY, scale)
	frame:ClearAllPoints()
	if(parent == nil) then frame:SetPoint(anchor, posX, posY) else frame:SetPoint(anchor, parent, posX, posY) end
	if(scale ~= nil) then frame:SetScale(scale) end
end

-- CREATE A FAKE BACKDROP FRAME??
K.CreateVirtualFrame = function(parent, point)
	if point == nil then point = parent end

	if point.backdrop then return end
	parent.backdrop = CreateFrame("Frame", nil , parent)
	parent.backdrop:SetAllPoints()
	parent.backdrop:SetBackdrop(K.Backdrop)
	parent.backdrop:SetPoint("TOPLEFT", point, -3 * K.NoScaleMult, 3 * K.NoScaleMult)
	parent.backdrop:SetPoint("BOTTOMRIGHT", point, 3 * K.NoScaleMult, -3 * K.NoScaleMult)
	parent.backdrop:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	parent.backdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))

	if parent:GetFrameLevel() - 1 > 0 then
		parent.backdrop:SetFrameLevel(parent:GetFrameLevel() - 1)
	else
		parent.backdrop:SetFrameLevel(0)
	end
end

-- CHAT CHANNEL CHECK
K.CheckChat = function(warning)
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		if warning and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant()) then
			return "RAID_WARNING"
		else
			return "RAID"
		end
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		return "PARTY"
	end
	return "SAY"
end

-- PLAYER'S ROLE CHECK
local isCaster = {
	DEATHKNIGHT = {nil, nil, nil},
	DEMONHUNTER = {nil, nil},
	DRUID = {true},
	HUNTER = {nil, nil, nil},
	MAGE = {true, true, true},
	MONK = {nil, nil, nil},
	PALADIN = {nil, nil, nil},
	PRIEST = {nil, nil, true},
	ROGUE = {nil, nil, nil},
	SHAMAN = {true},
	WARLOCK = {true, true, true},
	WARRIOR = {nil, nil, nil}
}

local function CheckRole(self, event, unit)
	local Spec = GetSpecialization()
	local Role = Spec and GetSpecializationRole(Spec)

	if Role == "TANK" then
		K.Role = "Tank"
	elseif Role == "HEALER" then
		K.Role = "Healer"
	elseif Role == "DAMAGER" then
		if isCaster[K.Class][Spec] then
			K.Role = "Caster"
		else
			K.Role = "Melee"
		end
	end
end
local RoleUpdater = CreateFrame("Frame")
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)

K.ShortenString = function(string, numChars, dots)
	local bytes = string:len()
	if(bytes <= numChars) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if(c > 0 and c <= 127) then
				pos = pos + 1
			elseif(c >= 192 and c <= 223) then
				pos = pos + 2
			elseif(c >= 224 and c <= 239) then
				pos = pos + 3
			elseif(c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if(len == numChars) then break end
		end

		if(len == numChars and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and "..." or "")
		else
			return string
		end
	end
end

K.FormatMoney = function(value)
	if value >= 1e4 then
		return format("|cffffd700%dg |r|cffc7c7cf%ds |r|cffeda55f%dc|r", value/1e4, strsub(value, -4) / 1e2, strsub(value, -2))
	elseif value >= 1e2 then
		return format("|cffc7c7cf%ds |r|cffeda55f%dc|r", strsub(value, -4) / 1e2, strsub(value, -2))
	else
		return format("|cffeda55f%dc|r", strsub(value, -2))
	end
end

-- ADD TIME BEFORE CALLING A FUNCTION
local waitTable = {}
local waitFrame
K.Delay = function(delay, func, ...)
	if(type(delay) ~= "number" or type(func) ~= "function") then
		return false
	end
	if(waitFrame == nil) then
		waitFrame = CreateFrame("Frame", "WaitFrame", UIParent)
		waitFrame:SetScript("onUpdate", function (self, elapse)
			local count = #waitTable
			local i = 1
			while(i <= count) do
				local waitRecord = tremove(waitTable, i)
				local d = tremove(waitRecord, 1)
				local f = tremove(waitRecord, 1)
				local p = tremove(waitRecord, 1)
				if(d > elapse) then
					tinsert(waitTable, i, {d-elapse, f, p})
					i = i + 1
				else
					count = count - 1
					f(unpack(p))
				end
			end
		end)
	end
	tinsert(waitTable, {delay, func, {...}})
	return true
end

--[[
	GetDetailedItemLevelInfo Polyfill, v 1.0
	by Erorus for The Undermine Journal
	https://theunderminejournal.com/
	Based on these "specs" for a GetDetailedItemLevelInfo function coming in 7.1
	https://www.reddit.com/r/woweconomy/comments/50hp5d/warning_be_careful_flipping/d74olsy
	Pass in an itemstring/link to GetDetailedItemLevelInfo
	Returns effectiveItemLevel, previewItemLevel, baseItemLevel
	This should use the in-game function if it already exists,
	otherwise it'll define a function that does what *I think* the official function would do.
]]

if GetDetailedItemLevelInfo then return end

local bonusLevelBoost = {[1]=20,[15]=20,[44]=6,[171]=10,[448]=6,[449]=13,[450]=26,[451]=-12,[497]=50,[499]=6,[518]=-100,[519]=-80,[520]=-60,[521]=-30,[522]=-15,[526]=15,[527]=30,[545]=10,[546]=6,[547]=6,[552]=0,[553]=35,[554]=40,[555]=70,[556]=65,[557]=70,[558]=15,[559]=30,[560]=6,[561]=6,[562]=6,[566]=15,[567]=30,[571]=6,[573]=-60,[575]=20,[576]=30,[577]=20,[579]=7,[591]=20,[592]=30,[593]=45,[594]=45,[595]=15,[597]=5,[598]=10,[599]=15,[609]=40,[617]=60,[618]=75,[619]=60,[620]=75,[622]=3,[623]=6,[624]=9,[625]=12,[626]=15,[627]=18,[628]=21,[629]=24,[630]=27,[631]=30,[632]=33,[633]=36,[634]=39,[635]=42,[636]=45,[637]=48,[638]=51,[639]=54,[640]=57,[641]=60,[642]=55,[644]=20,[646]=6,[648]=45,[651]=25,[665]=15,[666]=20,[667]=25,[668]=30,[669]=35,[670]=40,[671]=45,[672]=50,[673]=33,[674]=36,[675]=39,[676]=42,[677]=45,[678]=48,[679]=51,[680]=54,[681]=57,[682]=60,[694]=15,[695]=30,[696]=45,[697]=60,[698]=75,[699]=100,[700]=5,[701]=10,[702]=3,[703]=6,[704]=12,[706]=30,[707]=15,[708]=10,[709]=20,[710]=70,[754]=5,[755]=10,[756]=15,[757]=25,[758]=30,[759]=35,[760]=40,[761]=10,[762]=15,[763]=20,[764]=30,[765]=35,[766]=40,[769]=25,[1372]=-100,[1373]=-99,[1374]=-98,[1375]=-97,[1376]=-96,[1377]=-95,[1378]=-94,[1379]=-93,[1380]=-92,[1381]=-91,[1382]=-90,[1383]=-89,[1384]=-88,[1385]=-87,[1386]=-86,[1387]=-85,[1388]=-84,[1389]=-83,[1390]=-82,[1391]=-81,[1392]=-80,[1393]=-79,[1394]=-78,[1395]=-77,[1396]=-76,[1397]=-75,[1398]=-74,[1399]=-73,[1400]=-72,[1401]=-71,[1402]=-70,[1403]=-69,[1404]=-68,[1405]=-67,[1406]=-66,[1407]=-65,[1408]=-64,[1409]=-63,[1410]=-62,[1411]=-61,[1412]=-60,[1413]=-59,[1414]=-58,[1415]=-57,[1416]=-56,[1417]=-55,[1418]=-54,[1419]=-53,[1420]=-52,[1421]=-51,[1422]=-50,[1423]=-49,[1424]=-48,[1425]=-47,[1426]=-46,[1427]=-45,[1428]=-44,[1429]=-43,[1430]=-42,[1431]=-41,[1432]=-40,[1433]=-39,[1434]=-38,[1435]=-37,[1436]=-36,[1437]=-35,[1438]=-34,[1439]=-33,[1440]=-32,[1441]=-31,[1442]=-30,[1443]=-29,[1444]=-28,[1445]=-27,[1446]=-26,[1447]=-25,[1448]=-24,[1449]=-23,[1450]=-22,[1451]=-21,[1452]=-20,[1453]=-19,[1454]=-18,[1455]=-17,[1456]=-16,[1457]=-15,[1458]=-14,[1459]=-13,[1460]=-12,[1461]=-11,[1462]=-10,[1463]=-9,[1464]=-8,[1465]=-7,[1466]=-6,[1467]=-5,[1468]=-4,[1469]=-3,[1470]=-2,[1471]=-1,[1472]=0,[1473]=1,[1474]=2,[1475]=3,[1476]=4,[1477]=5,[1478]=6,[1479]=7,[1480]=8,[1481]=9,[1482]=10,[1483]=11,[1484]=12,[1485]=13,[1486]=14,[1487]=15,[1488]=16,[1489]=17,[1490]=18,[1491]=19,[1492]=20,[1493]=21,[1494]=22,[1495]=23,[1496]=24,[1497]=25,[1498]=26,[1499]=27,[1500]=28,[1501]=29,[1502]=30,[1503]=31,[1504]=32,[1505]=33,[1506]=34,[1507]=35,[1508]=36,[1509]=37,[1510]=38,[1511]=39,[1512]=40,[1513]=41,[1514]=42,[1515]=43,[1516]=44,[1517]=45,[1518]=46,[1519]=47,[1520]=48,[1521]=49,[1522]=50,[1523]=51,[1524]=52,[1525]=53,[1526]=54,[1527]=55,[1528]=56,[1529]=57,[1530]=58,[1531]=59,[1532]=60,[1533]=61,[1534]=62,[1535]=63,[1536]=64,[1537]=65,[1538]=66,[1539]=67,[1540]=68,[1541]=69,[1542]=70,[1543]=71,[1544]=72,[1545]=73,[1546]=74,[1547]=75,[1548]=76,[1549]=77,[1550]=78,[1551]=79,[1552]=80,[1553]=81,[1554]=82,[1555]=83,[1556]=84,[1557]=85,[1558]=86,[1559]=87,[1560]=88,[1561]=89,[1562]=90,[1563]=91,[1564]=92,[1565]=93,[1566]=94,[1567]=95,[1568]=96,[1569]=97,[1570]=98,[1571]=99,[1572]=100,[1573]=101,[1574]=102,[1575]=103,[1576]=104,[1577]=105,[1578]=106,[1579]=107,[1580]=108,[1581]=109,[1582]=110,[1583]=111,[1584]=112,[1585]=113,[1586]=114,[1587]=115,[1588]=116,[1589]=117,[1590]=118,[1591]=119,[1592]=120,[1593]=121,[1594]=122,[1595]=123,[1596]=124,[1597]=125,[1598]=126,[1599]=127,[1600]=128,[1601]=129,[1602]=130,[1603]=131,[1604]=132,[1605]=133,[1606]=134,[1607]=135,[1608]=136,[1609]=137,[1610]=138,[1611]=139,[1612]=140,[1613]=141,[1614]=142,[1615]=143,[1616]=144,[1617]=145,[1618]=146,[1619]=147,[1620]=148,[1621]=149,[1622]=150,[1623]=151,[1624]=152,[1625]=153,[1626]=154,[1627]=155,[1628]=156,[1629]=157,[1630]=158,[1631]=159,[1632]=160,[1633]=161,[1634]=162,[1635]=163,[1636]=164,[1637]=165,[1638]=166,[1639]=167,[1640]=168,[1641]=169,[1642]=170,[1643]=171,[1644]=172,[1645]=173,[1646]=174,[1647]=175,[1648]=176,[1649]=177,[1650]=178,[1651]=179,[1652]=180,[1653]=181,[1654]=182,[1655]=183,[1656]=184,[1657]=185,[1658]=186,[1659]=187,[1660]=188,[1661]=189,[1662]=190,[1663]=191,[1664]=192,[1665]=193,[1666]=194,[1667]=195,[1668]=196,[1669]=197,[1670]=198,[1671]=199,[1672]=200,[1800]=210,[1810]=140,[1817]=10,[1818]=20,[1819]=15,[1820]=25,[2829]=-400,[2830]=-399,[2831]=-398,[2832]=-397,[2833]=-396,[2834]=-395,[2835]=-394,[2836]=-393,[2837]=-392,[2838]=-391,[2839]=-390,[2840]=-389,[2841]=-388,[2842]=-387,[2843]=-386,[2844]=-385,[2845]=-384,[2846]=-383,[2847]=-382,[2848]=-381,[2849]=-380,[2850]=-379,[2851]=-378,[2852]=-377,[2853]=-376,[2854]=-375,[2855]=-374,[2856]=-373,[2857]=-372,[2858]=-371,[2859]=-370,[2860]=-369,[2861]=-368,[2862]=-367,[2863]=-366,[2864]=-365,[2865]=-364,[2866]=-363,[2867]=-362,[2868]=-361,[2869]=-360,[2870]=-359,[2871]=-358,[2872]=-357,[2873]=-356,[2874]=-355,[2875]=-354,[2876]=-353,[2877]=-352,[2878]=-351,[2879]=-350,[2880]=-349,[2881]=-348,[2882]=-347,[2883]=-346,[2884]=-345,[2885]=-344,[2886]=-343,[2887]=-342,[2888]=-341,[2889]=-340,[2890]=-339,[2891]=-338,[2892]=-337,[2893]=-336,[2894]=-335,[2895]=-334,[2896]=-333,[2897]=-332,[2898]=-331,[2899]=-330,[2900]=-329,[2901]=-328,[2902]=-327,[2903]=-326,[2904]=-325,[2905]=-324,[2906]=-323,[2907]=-322,[2908]=-321,[2909]=-320,[2910]=-319,[2911]=-318,[2912]=-317,[2913]=-316,[2914]=-315,[2915]=-314,[2916]=-313,[2917]=-312,[2918]=-311,[2919]=-310,[2920]=-309,[2921]=-308,[2922]=-307,[2923]=-306,[2924]=-305,[2925]=-304,[2926]=-303,[2927]=-302,[2928]=-301,[2929]=-300,[2930]=-299,[2931]=-298,[2932]=-297,[2933]=-296,[2934]=-295,[2935]=-294,[2936]=-293,[2937]=-292,[2938]=-291,[2939]=-290,[2940]=-289,[2941]=-288,[2942]=-287,[2943]=-286,[2944]=-285,[2945]=-284,[2946]=-283,[2947]=-282,[2948]=-281,[2949]=-280,[2950]=-279,[2951]=-278,[2952]=-277,[2953]=-276,[2954]=-275,[2955]=-274,[2956]=-273,[2957]=-272,[2958]=-271,[2959]=-270,[2960]=-269,[2961]=-268,[2962]=-267,[2963]=-266,[2964]=-265,[2965]=-264,[2966]=-263,[2967]=-262,[2968]=-261,[2969]=-260,[2970]=-259,[2971]=-258,[2972]=-257,[2973]=-256,[2974]=-255,[2975]=-254,[2976]=-253,[2977]=-252,[2978]=-251,[2979]=-250,[2980]=-249,[2981]=-248,[2982]=-247,[2983]=-246,[2984]=-245,[2985]=-244,[2986]=-243,[2987]=-242,[2988]=-241,[2989]=-240,[2990]=-239,[2991]=-238,[2992]=-237,[2993]=-236,[2994]=-235,[2995]=-234,[2996]=-233,[2997]=-232,[2998]=-231,[2999]=-230,[3000]=-229,[3001]=-228,[3002]=-227,[3003]=-226,[3004]=-225,[3005]=-224,[3006]=-223,[3007]=-222,[3008]=-221,[3009]=-220,[3010]=-219,[3011]=-218,[3012]=-217,[3013]=-216,[3014]=-215,[3015]=-214,[3016]=-213,[3017]=-212,[3018]=-211,[3019]=-210,[3020]=-209,[3021]=-208,[3022]=-207,[3023]=-206,[3024]=-205,[3025]=-204,[3026]=-203,[3027]=-202,[3028]=-201,[3029]=-200,[3030]=-199,[3031]=-198,[3032]=-197,[3033]=-196,[3034]=-195,[3035]=-194,[3036]=-193,[3037]=-192,[3038]=-191,[3039]=-190,[3040]=-189,[3041]=-188,[3042]=-187,[3043]=-186,[3044]=-185,[3045]=-184,[3046]=-183,[3047]=-182,[3048]=-181,[3049]=-180,[3050]=-179,[3051]=-178,[3052]=-177,[3053]=-176,[3054]=-175,[3055]=-174,[3056]=-173,[3057]=-172,[3058]=-171,[3059]=-170,[3060]=-169,[3061]=-168,[3062]=-167,[3063]=-166,[3064]=-165,[3065]=-164,[3066]=-163,[3067]=-162,[3068]=-161,[3069]=-160,[3070]=-159,[3071]=-158,[3072]=-157,[3073]=-156,[3074]=-155,[3075]=-154,[3076]=-153,[3077]=-152,[3078]=-151,[3079]=-150,[3080]=-149,[3081]=-148,[3082]=-147,[3083]=-146,[3084]=-145,[3085]=-144,[3086]=-143,[3087]=-142,[3088]=-141,[3089]=-140,[3090]=-139,[3091]=-138,[3092]=-137,[3093]=-136,[3094]=-135,[3095]=-134,[3096]=-133,[3097]=-132,[3098]=-131,[3099]=-130,[3100]=-129,[3101]=-128,[3102]=-127,[3103]=-126,[3104]=-125,[3105]=-124,[3106]=-123,[3107]=-122,[3108]=-121,[3109]=-120,[3110]=-119,[3111]=-118,[3112]=-117,[3113]=-116,[3114]=-115,[3115]=-114,[3116]=-113,[3117]=-112,[3118]=-111,[3119]=-110,[3120]=-109,[3121]=-108,[3122]=-107,[3123]=-106,[3124]=-105,[3125]=-104,[3126]=-103,[3127]=-102,[3128]=-101,[3130]=201,[3131]=202,[3132]=203,[3133]=204,[3134]=205,[3135]=206,[3136]=207,[3137]=208,[3138]=209,[3139]=210,[3140]=211,[3141]=212,[3142]=213,[3143]=214,[3144]=215,[3145]=216,[3146]=217,[3147]=218,[3148]=219,[3149]=220,[3150]=221,[3151]=222,[3152]=223,[3153]=224,[3154]=225,[3155]=226,[3156]=227,[3157]=228,[3158]=229,[3159]=230,[3160]=231,[3161]=232,[3162]=233,[3163]=234,[3164]=235,[3165]=236,[3166]=237,[3167]=238,[3168]=239,[3169]=240,[3170]=241,[3171]=242,[3172]=243,[3173]=244,[3174]=245,[3175]=246,[3176]=247,[3177]=248,[3178]=249,[3179]=250,[3180]=251,[3181]=252,[3182]=253,[3183]=254,[3184]=255,[3185]=256,[3186]=257,[3187]=258,[3188]=259,[3189]=260,[3190]=261,[3191]=262,[3192]=263,[3193]=264,[3194]=265,[3195]=266,[3196]=267,[3197]=268,[3198]=269,[3199]=270,[3200]=271,[3201]=272,[3202]=273,[3203]=274,[3204]=275,[3205]=276,[3206]=277,[3207]=278,[3208]=279,[3209]=280,[3210]=281,[3211]=282,[3212]=283,[3213]=284,[3214]=285,[3215]=286,[3216]=287,[3217]=288,[3218]=289,[3219]=290,[3220]=291,[3221]=292,[3222]=293,[3223]=294,[3224]=295,[3225]=296,[3226]=297,[3227]=298,[3228]=299,[3229]=300,[3230]=301,[3231]=302,[3232]=303,[3233]=304,[3234]=305,[3235]=306,[3236]=307,[3237]=308,[3238]=309,[3239]=310,[3240]=311,[3241]=312,[3242]=313,[3243]=314,[3244]=315,[3245]=316,[3246]=317,[3247]=318,[3248]=319,[3249]=320,[3250]=321,[3251]=322,[3252]=323,[3253]=324,[3254]=325,[3255]=326,[3256]=327,[3257]=328,[3258]=329,[3259]=330,[3260]=331,[3261]=332,[3262]=333,[3263]=334,[3264]=335,[3265]=336,[3266]=337,[3267]=338,[3268]=339,[3269]=340,[3270]=341,[3271]=342,[3272]=343,[3273]=344,[3274]=345,[3275]=346,[3276]=347,[3277]=348,[3278]=349,[3279]=350,[3280]=351,[3281]=352,[3282]=353,[3283]=354,[3284]=355,[3285]=356,[3286]=357,[3287]=358,[3288]=359,[3289]=360,[3290]=361,[3291]=362,[3292]=363,[3293]=364,[3294]=365,[3295]=366,[3296]=367,[3297]=368,[3298]=369,[3299]=370,[3300]=371,[3301]=372,[3302]=373,[3303]=374,[3304]=375,[3305]=376,[3306]=377,[3307]=378,[3308]=379,[3309]=380,[3310]=381,[3311]=382,[3312]=383,[3313]=384,[3314]=385,[3315]=386,[3316]=387,[3317]=388,[3318]=389,[3319]=390,[3320]=391,[3321]=392,[3322]=393,[3323]=394,[3324]=395,[3325]=396,[3326]=397,[3327]=398,[3328]=399,[3329]=400,[3330]=15,[3331]=5,[3332]=30,[3333]=35,[3334]=40,[3340]=10,[3341]=40,[3381]=0,[3382]=10,[3383]=20,[3384]=30,[3390]=60,[3391]=80,[3393]=20,[3438]=80,[3439]=95,[3440]=110,}
local bonusPreviewLevel = {[1726]=825,[1727]=840,[1798]=705,[1799]=720,[1801]=690,[1805]=865,[1806]=880,[1807]=850,[1824]=805,[1825]=810,[1826]=805,[3379]=835,[3394]=815,[3395]=820,[3396]=825,[3397]=830,[3399]=840,[3410]=840,[3411]=840,[3412]=840,[3413]=840,[3414]=840,[3415]=840,[3416]=840,[3417]=840,[3418]=840,[3427]=805,[3428]=840,[3432]=835,[3443]=875,[3444]=890,[3445]=905,[3446]=845,}
local bonusLevelCurve = {[664]=1648,[767]=1558,[768]=1688,[1723]=1746,[1724]=1748,[1725]=1749,[1729]=1751,[1730]=1752,[1731]=1753,[1732]=1648,[1733]=1758,[1734]=1759,[1735]=1759,[1736]=1756,[1737]=1757,[1738]=1757,[1739]=1760,[1740]=1761,[1741]=1761,[1788]=1787,[1789]=1788,[1790]=1789,[1791]=1790,[1792]=1756,[1793]=1760,[1794]=1758,[1795]=1832,[1796]=1824,[1812]=2002,[3342]=2202,[3380]=2196,[3387]=2208,[3388]=2209,[3389]=2210,[3398]=2247,}
local curvePoints = {[1558]={{98,660},{99,680},{100,685},{109,775},},[1648]={{98,664},{99,684},{100,689},{109,779},},[1688]={{98,668},{99,688},{100,693},{109,783},},[1746]={{1,10},{5,10},{59,62},{60,79},{69,105},{70,139},{79,187},{80,279},{84,333},{85,384},{89,463},{90,530},{99,605},{100,690},{110,780},},[1748]={{1,10},{5,13},{59,67},{60,84},{69,115},{70,149},{79,197},{80,289},{84,343},{85,394},{89,473},{90,540},{99,615},{100,700},{104,760},{110,820},},[1749]={{1,10},{5,15},{59,72},{60,89},{69,125},{70,159},{79,207},{80,299},{84,353},{85,404},{89,483},{90,550},{99,650},{100,710},{110,800},},[1751]={{650,0},{689,0},{690,1},{691,0},{850,0},},[1752]={{650,0},{809,0},{810,1},{811,0},{850,0},},[1753]={{95,1},{100,12},{109,20},{110,20},{115,30},},[1756]={{98,674},{99,694},{100,699},{109,789},},[1757]={{98,684},{99,704},{100,709},{109,799},},[1758]={{98,670},{99,690},{100,695},{109,785},},[1759]={{98,680},{99,700},{100,705},{109,795},},[1760]={{98,678},{99,698},{100,703},{109,793},},[1761]={{98,688},{99,708},{100,713},{109,803},},[1787]={{1,10},{5,10},{39,41},},[1788]={{1,10},{5,13},{39,44},},[1789]={{1,10},{5,15},{39,48},},[1790]={{1,10},{5,10},{59,62},},[1824]={{98,575},{99,660},{100,680},{101,685},{109,770},},[1832]={{98,675},{99,695},{100,700},{109,790},},[2002]={{98,650},{99,660},{100,670},{109,780},},[2196]={{1,10},{5,10},{57,57},{58,75},{67,95},{68,129},{80,177},{81,269},{85,323},{86,374},{90,453},{91,510},{97,580},{98,588},{99,605},{100,655},},[2202]={{98,660},{99,680},{100,685},{109,745},},[2208]={{1,10},{5,10},{57,62},{58,79},{67,105},{68,139},{80,187},{81,279},{85,333},{86,384},{90,463},{91,530},{97,600},{98,640},{99,670},{100,700},{110,700},},[2209]={{1,10},{5,10},{57,61},{58,79},{67,105},{68,139},{80,187},{81,279},{85,333},{86,384},{90,463},{91,530},{97,600},{98,650},{99,680},{100,710},{110,710},},[2210]={{1,10},{5,20},{57,71},{58,89},{67,115},{68,149},{80,197},{81,289},{85,343},{86,394},{90,473},{91,540},{97,610},{98,660},{99,690},{100,720},{110,720},},[2247]={{98,740},{109,810},},}

local function round(num)
	return floor(num + 0.5)
end

local function GetCurvePoint(curveId, point)
	local curve = curvePoints[curveId]
	if not curve then
		return nil
	end

	local lastKey, lastValue = curve[1][1], curve[1][2]
	if lastKey > point then
		return lastValue
	end

	for x = 1,#curve,1 do
		if point == curve[x][1] then
			return curve[x][2]
		end
		if point < curve[x][1] then
			return round((curve[x][2] - lastValue) / (curve[x][1] - lastKey) * (point - lastKey) + lastValue)
		end
		lastKey = curve[x][1]
		lastValue = curve[x][2]
	end

	return lastValue
end

GetDetailedItemLevelInfo = GetDetailedItemLevelInfo or function(item)
	local _, link, _, origLevel = GetItemInfo(item)
	if not link then
		return nil, nil, nil
	end

	local itemString = string.match(link, "item[%-?%d:]+")
	local itemStringParts = { strsplit(":", itemString) }

	local numBonuses = tonumber(itemStringParts[14],10) or 0

	if numBonuses == 0 then
		return origLevel, nil, origLevel
	end

	local effectiveLevel, previewLevel, curve
	effectiveLevel = origLevel

	for y = 1,numBonuses,1 do
		local bonus = tonumber(itemStringParts[14+y],10) or 0

		origLevel = origLevel - (bonusLevelBoost[bonus] or 0)
		previewLevel = bonusPreviewLevel[bonus] or previewLevel
		curve = bonusLevelCurve[bonus] or curve
	end

	if curve and itemStringParts[12] == "512" then
		effectiveLevel = GetCurvePoint(curve, tonumber(itemStringParts[15+numBonuses],10)) or effectiveLevel
	end

	return effectiveLevel, previewLevel, origLevel
end