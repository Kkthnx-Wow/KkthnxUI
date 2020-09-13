local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- Sourced: ElvUI (Elv)

local _G = _G
local math_floor = _G.math.floor
local string_format = _G.string.format
local tonumber = _G.tonumber
local math_random = _G.math.random

local C_Calendar_GetDate = _G.C_Calendar.GetDate
local C_Calendar_GetNumPendingInvites =_G.C_Calendar.GetNumPendingInvites
local C_PetBattles_IsInBattle = _G.C_PetBattles.IsInBattle
local CinematicFrame = _G.CinematicFrame
local CloseAllWindows = _G.CloseAllWindows
local CreateFrame = _G.CreateFrame
local GetAchievementInfo = _G.GetAchievementInfo
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetCVarBool =_G.GetCVarBool
local GetGameTime =_G.GetGameTime
local GetGuildInfo = _G.GetGuildInfo
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetStatistic = _G.GetStatistic
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsMacClient = _G.IsMacClient
local MovieFrame = _G.MovieFrame
local NONE = _G.NONE
local PVEFrame_ToggleFrame = _G.PVEFrame_ToggleFrame
local Screenshot = _G.Screenshot
local SetCVar = _G.SetCVar
local TIMEMANAGER_TICKER_12HOUR = _G.TIMEMANAGER_TICKER_12HOUR
local TIMEMANAGER_TICKER_24HOUR = _G.TIMEMANAGER_TICKER_24HOUR
local UnitCastingInfo = _G.UnitCastingInfo
local UnitIsAFK = _G.UnitIsAFK

local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}

local printKeys = {
	["PRINTSCREEN"] = true,
}

local monthAbr = {
	[1] = "Jan",
	[2] = "Feb",
	[3] = "Mar",
	[4] = "Apr",
	[5] = "May",
	[6] = "Jun",
	[7] = "Jul",
	[8] = "Aug",
	[9] = "Sep",
	[10] = "Oct",
	[11] = "Nov",
	[12] = "Dec",
}

local daysAbr = {
	[1] = "Sun",
	[2] = "Mon",
	[3] = "Tue",
	[4] = "Wed",
	[5] = "Thu",
	[6] = "Fri",
	[7] = "Sat",
}

-- Source wowhead.com
local stats = {
	60,		-- Total deaths
	94,		-- Quests abandoned
	97,		-- Daily quests completed
	98,		-- Quests completed
	107,	-- Creatures killed
	112,	-- Deaths from drowning
	114,	-- Deaths from falling
	319,	-- Duels won
	320,	-- Duels lost
	321,	-- Total raid and dungeon deaths
	326,	-- Gold from quest rewards
	328,	-- Total gold acquired
	333,	-- Gold looted
	334,	-- Most gold ever owned
	338,	-- Vanity pets owned
	339,	-- Mounts owned
	342,	-- Epic items acquired
	349,	-- Flight paths taken
	353,	-- Number of times hearthed
	377,	-- Most factions at Exalted
	588,	-- Total Honorable Kills
	837,	-- Arenas won
	838,	-- Arenas played
	839,	-- Battlegrounds played
	840,	-- Battlegrounds won
	919,	-- Gold earned from auctions
	931,	-- Total factions encountered
	932,	-- Total 5-player dungeons entered
	933,	-- Total 10-player raids entered
	934,	-- Total 25-player raids entered
	1042,	-- Number of hugs
	1045,	-- Total cheers
	1047,	-- Total facepalms
	1065,	-- Total waves
	1066,	-- Total times LOL"d
	1149,	-- Talent tree respecs
	1197,	-- Total kills
	1198,	-- Total kills that grant experience or honor
	1339,	-- Mage portal taken most
	1487,	-- Killing Blows
	1491,	-- Battleground Killing Blows
	1518,	-- Fish caught
	1716,	-- Battleground with the most Killing Blows
	2277,	-- Summons accepted
	5692,	-- Rated battlegrounds played
	5694,	-- Rated battlegrounds won
	7399,	-- Challenge mode dungeons completed
	8278,	-- Pet Battles won at max level
	10060,	-- Garrison Followers recruited
	10181,	-- Garrision Missions completed
	10184,	-- Garrision Rare Missions completed
	11234,	-- Class Hall Champions recruited
	11235,	-- Class Hall Troops recruited
	11236,	-- Class Hall Missions completed
	11237,	-- Class Hall Rare Missions completed
}

-- local randomtips = {
-- 	"Nearby questgivers that are awaiting your return are shown as a question mark on your mini-map.",
-- 	"Your spell casting can be cancelled by moving, jumping or hitting the escape key.",
-- 	"Clicking on a player name in the chat window lets you send a private message to them.",
-- 	"If you <Shift>Click on a player name in the chat window it tells you additional information about them.",
-- 	"You can <Control>-Click on an item to see how you would look wearing that item.",
-- 	"An item with its name in gray is a poor quality item and generally can be sold to a vendor.",
-- 	"An item with its name in white is useful to players in some way and can be used or sold at the auction house.",
-- 	"If you are lost trying to complete a quest, the quest log will often tell you what to do next.",
-- 	"You can send mail to other players or even to your other characters from any mailbox in game.",
-- 	"You can <Shift>-Click on an item to place an item link into a chat message.",
-- 	"You can remove a friendly spell enhancement on yourself by right-clicking on the spell effect icon.",
-- 	"When you learn a profession or secondary skill the button that allows you to perform that skill is found in the general tab of your spellbook.",
-- 	"All of your action bars can have their hotkeys remapped in the key bindings interface.",
-- 	"If a profession trainer cannot teach you any more, they will generally tell you where to go to get further training.",
-- 	"On your character sheet is a reputation tab that tells you your status with different groups.",
-- 	"You can use the Tab key to select nearby enemies in front of you.",
-- 	"If you are having trouble finding something in a capital city, try asking a guard for directions.",
-- 	"You can perform many fun actions with the emote system, for instance you can type /dance to dance.",
-- 	"A Blizzard employee will NEVER ask for your password.",
-- 	"You can only know two professions at a time, but you can learn all of the secondary skills (archaeology, fishing, cooking and first-aid).",
-- 	"You can right-click on a beneficial spell that has been cast on you to dismiss it.",
-- 	"The interface options menu <ESC> has lots of ways to customize your game play.",
-- 	"You can turn off the slow scrolling of quest text in the interface options menu.",
-- 	"Spend your talent points carefully as once your talents are chosen, you must spend gold to unlearn them.",
-- 	"A mail icon next to the minimap means you have new mail. Visit a mailbox to retrieve it.",
-- 	"You can add additional action bars to your game interface from the interface options menu.",
-- 	"If you hold down <Shift> while right-clicking on a target to loot, you will automatically loot all items on the target.",
-- 	"Your character can eat and drink at the same time.",
-- 	"If you enjoyed playing with someone, put them on your friends list!",
-- 	"Use the Looking for Group interface ('I' Hotkey) to find a group or add more players to your group.",
-- 	"There are a number of different loot options when in a group. The group leader can right-click their own portrait to change the options.",
-- 	"You can choose not to display your helm and/or cloak with an option from the interface options menu.",
-- 	"You can target members of your party with the function keys. F1 targets you; F2 targets the second party member.",
-- 	"Being polite while in a group with others will get you invited back!",
-- 	"Remember to take all things in moderation (even World of Warcraft!)",
-- 	"You can click on a faction in the reputation pane to get additional information and options about that faction.",
-- 	"A monster with a silver dragon around its portrait is a rare monster with better than average treasure.",
-- 	"If you mouse over a chat pane it will become visible and you can right-click on the chat pane tab for options.",
-- 	"Sharing an account with someone else can compromise its security.",
-- 	"You can display the duration of beneficial spells on you from the interface options menu.",
-- 	"You can lock your action bar so you don't accidentally move spells. This is done using the interface options menu.",
-- 	"You can assign a Hotkey to toggle locking/unlocking your action bar. Just look in the Key Bindings options to set it.",
-- 	"You can cast a spell on yourself without deselecting your current target by holding down <Alt> while pressing your hotkey.",
-- 	"Ensure that all party members are on the same stage of an escort quest before beginning it.",
-- 	"You're much less likely to encounter wandering monsters while following a road.",
-- 	"Killing guards gives no honor.",
-- 	"You can hide your interface with <Alt>-Z and take screenshots with <Print Screen>.",
-- 	"Typing /macro will bring up the interface to create macros.",
-- 	"Enemy players whose names appear in gray are much lower level than you are and will not give honor when killed.",
-- 	"From the Raid UI you can drag a player to the game field to see their status or drag a class icon to see all members of that class.",
-- 	"A blue question mark above a quest giver means the quest is repeatable.",
-- 	"Use the assist button (F key) while targeting another player, and it will target the same target as that player.",
-- 	"<Shift>-Clicking on an item being sold by a vendor will let you select how many of that item you wish to purchase.",
-- 	"Playing in a battleground on its holiday weekend increases your honor gained.",
-- 	"If you are having trouble fishing in an area, try attaching a lure to your fishing pole.",
-- 	"You can view messages you previously sent in chat by pressing <Alt> and the up arrow key.",
-- 	"You can Shift-Click on an item stack to split it into smaller stacks.",
-- 	"Pressing both mouse buttons simultaneously will make your character run.",
-- 	"When replying to a tell from a player (Default 'R'), the <TAB> key cycles through people you have recently replied to.",
-- 	"Clicking an item name that appears bracketed in chat will tell you more about the item.",
-- 	"It's considered polite to talk to someone before inviting them into a group, or opening a trade window.",
-- 	"Pressing 'v' will toggle the display of a health bar over nearby enemies.",
-- 	"Your items do not suffer durability damage when you are killed by an enemy player.",
-- 	"<Shift>-click on a quest in your quest log to toggle quest tracking for that quest.",
-- 	"There is no cow level.",
-- 	"The auction houses in each of your faction's major cities are linked together.",
-- 	"Nearby questgivers that are awaiting your return are shown as a yellow question mark on your mini-map.",
-- 	"Quests completed at maximum level award money instead of experience.",
-- 	"<Shift>-B will open all your bags at once.",
-- 	"When interacting with other players a little kindness goes a long way!",
-- 	"Bring your friends to Azeroth, but don't forget to go outside Azeroth with them as well.",
-- 	"If you keep an empty mailbox, the mail icon will let you know when you have new mail waiting!",
-- 	"Never give another player your account information.",
-- 	"When a player not in your group damages a monster before you do, it will display a gray health bar and you will get no loot or experience from killing it.",
-- 	"You can see the spell that your current target is casting by turning on the 'Show Enemy Cast Bar' options in the basic interface options.",
-- 	"You can see the target of your current target by turning on the 'Show Target of Target' option in the advanced interface options tab.",
-- 	"You can access the map either by clicking the map button in the upper left of the mini-map or by hitting the 'M' key.",
-- 	"Many high level dungeons have a heroic mode setting. Heroic mode dungeons are tuned for level 70 players and have improved loot.",
-- 	"Spend your honor points for powerful rewards at the Champion's Hall (Alliance) or Hall of Legends (Horde).",
-- 	"The honor points you earn each day become available immediately. Check the PvP interface to see how many points you have to spend.",
-- 	"You can turn these tips off in the Interface menu.",
-- 	"Dungeon meeting stones can be used to summon absent party members. It requires two players at the stone to do a summoning.",
-- 	"The Parental Controls section of the Account Management site offers tools to help you manage your play time.",
-- 	"Quest items that are in the bank cannot be used to complete quests.",
-- 	"A quest marked as (Failed) in the quest log can be abandoned and then reacquired from the quest giver.",
-- 	"The number next to the quest name in your log is how many other party members are on that quest.",
-- 	"You cannot advance quests other than (Raid) quests while you are in a raid group.",
-- 	"You cannot cancel your bids in the auction house so bid carefully.",
-- 	"To enter a chat channel, type /join [channel name] and /leave [channel name] to exit.",
-- 	"Mail will be kept for a maximum of 30 days before it disappears.",
-- 	"Once you get a key, they can be found in a special key ring bag that is to the left of your bags.",
-- 	"You can replace a gem that is already socketed into your item by dropping a new gem on top of it in the socketing interface.",
-- 	"City Guards will often give you directions to other locations of note in the city.",
-- 	"You can repurchase items you have recently sold to a vendor from the buyback tab.",
-- 	"A group leader can reset their instances from their portrait right-click menu.",
-- 	"You can always get a new hearthstone from any Innkeeper.",
-- 	"You can open a small map of the current zone either with Shift-M or as an option from the world map.",
-- 	"Players cannot dodge, parry, or block attacks that come from behind them.",
-- 	"If you Right Click on a name in the combat log a list of options will appear.",
-- 	"You can only have one Battle Elixir and one Guardian Elixir on you at a time.",
-- 	"The calendar can tell you when raids reset.",
-- 	"Creatures cannot make critical hits with spells, but players can.",
-- 	"Creatures can dodge attacks from behind, but players cannot. Neither creatures nor players can parry attacks from behind.",
-- 	"Players with the Inscription profession can make glyphs to improve your favorite spells and abilities.",
-- 	"Don't stand in the fire!",
-- 	"The Raid UI can be customized in a number of different ways, such as how it shows debuffs or current health.",
-- 	"Dungeons are more fun when everyone works together as a team. Be patient with players who are still learning the game.",
-- 	"Smile early and often!",
-- 	"Thank you for playing World of Warcraft. You rock!",
-- }

if IsMacClient() then
	printKeys[_G.KEY_PRINTSCREEN_MAC] = true
end

-- Follow Time DataText Formatting
local function setupTime(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color..TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = K.MyClassColor..(hour < 12 and " AM" or " PM")

		if hour >= 12 then
			if hour > 12 then
				hour = hour - 12
			end
		else
			if hour == 0 then
				hour = 12
			end
		end

		return string_format(color..TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

local function createTime()
	local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""
	local hour, minute
	if GetCVarBool("timeMgrUseLocalTime") then
		hour, minute = tonumber(date("%H")), tonumber(date("%M"))
	else
		hour, minute = GetGameTime()
	end

	Module.AFKMode.top.time:SetText(setupTime(color, hour, minute))
end

-- Create Date
local function createDate()
	local date = C_Calendar_GetDate()
	local presentWeekday = date.weekday
	local presentMonth = date.month
	local presentDay = date.monthDay
	local presentYear = date.year

	Module.AFKMode.top.date:SetFormattedText("%s, %s %d, %d", daysAbr[presentWeekday], monthAbr[presentMonth], presentDay, presentYear)
end

-- Create random stats
local function createStats()
	local id = stats[math_random(#stats)]
	local _, name = GetAchievementInfo(id)
	local result = GetStatistic(id)
	if result == "--" then
		result = NONE
	end

	return string_format("%s: |cfff0ff00%s|r", name, result)
end

function Module:UpdateStatMessage()
	K.UIFrameFadeIn(Module.AFKMode.statMsg.info, 1, 1, 0)
	local createdStat = createStats()
	Module.AFKMode.statMsg.info:SetText(createdStat)
	K.UIFrameFadeIn(Module.AFKMode.statMsg.info, 1, 0, 1)
end

function Module:UpdateTimer()
	-- Set time
	createTime()
	-- Set Date
	createDate()

	local time = GetTime() - Module.startTime
	Module.AFKMode.bottom.time:SetFormattedText("%02d:%02d", math_floor(time / 60), time % 60)
end

-- XP string
local function GetXPinfo()
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
	if (K.Level == maxLevel) or IsXPUserDisabled() then
		return
	end

	local cur, max = K:GetModule("DataBars"):GetUnitXP("player")
	return string_format("|cfff0ff00%d%%|r (%s) %s |cfff0ff00%d|r", (max - cur) / max * 100, K.ShortValue(max - cur), "remaining till level", K.Level + 1)
end

function Module:SetAFK(status)
	if status then
		Module.AFKMode:Show()
		CloseAllWindows()
		_G.UIParent:Hide()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo("player")
			Module.AFKMode.bottom.guild:SetFormattedText("%s - %s", guildName, guildRankName)
		else
			Module.AFKMode.bottom.guild:SetText("No Guild")
		end

		if GetXPinfo() then
			Module.AFKMode.top.xp:Show()
			Module.AFKMode.top.xp:SetText(GetXPinfo())
		else
			Module.AFKMode.top.xp:Show()
			Module.AFKMode.top.xp:SetText("")
			-- Module.AFKMode.top.xp:SetText(randomtips[math_random(#randomtips)])
		end

		Module.AFKMode.bottom.modelPlayer.curAnimation = "wave"
		Module.AFKMode.bottom.modelPlayer.startTime = GetTime()
		Module.AFKMode.bottom.modelPlayer.duration = 2.3
		Module.AFKMode.bottom.modelPlayer:SetUnit("player")
		Module.AFKMode.bottom.modelPlayer.isIdle = nil
		Module.AFKMode.bottom.modelPlayer:SetAnimation(67)
		Module.AFKMode.bottom.modelPlayer.idleDuration = 40

		Module.AFKMode.bottom.modelPet:SetUnit("pet")
		Module.AFKMode.bottom.modelPet:SetAnimation(0)

		Module.startTime = GetTime()
		K.ScheduleRepeatingTimer(Module.timer, Module.UpdateTimer, 1)
		K.ScheduleRepeatingTimer(Module.statsTimer, Module.UpdateStatMessage, 6)

		Module.isAFK = true
	elseif Module.isAFK then
		_G.UIParent:Show()
		Module.AFKMode:Hide()

		K.CancelTimer(Module, Module.timer)
		K.CancelTimer(Module, Module.statsTimer)
		K.CancelTimer(Module, Module.animTimer)

		Module.AFKMode.bottom.time:SetText("00:00")
		Module.AFKMode.statMsg.info:SetFormattedText("|cffb3b3b3%s|r", "Random Stats")

		if _G.PVEFrame:IsShown() then -- odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		Module.isAFK = false
	end
end

function Module:OnEvent(event, ...)
	if event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS" then
		if event ~= "UPDATE_BATTLEFIELD_STATUS" or (GetBattlefieldStatus(...) == "confirm") then
			Module:SetAFK(false)
		end

		if event == "PLAYER_REGEN_DISABLED" then
			Module:RegisterEvent("PLAYER_REGEN_ENABLED", Module.OnEvent)
		end

		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.OnEvent)
	end

	if not C["Misc"].AFKCamera or (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then
		return
	end

	if UnitCastingInfo("player") then -- Don"t activate afk if player is crafting stuff, check back in 30 seconds
		K.ScheduleTimer(Module, Module.OnEvent, 30)
		return
	end

	Module:SetAFK(UnitIsAFK("player") and not C_PetBattles_IsInBattle())
end

function Module:AFKToggle()
	if (C["Misc"].AFKCamera) then
		K:RegisterEvent("PLAYER_FLAGS_CHANGED", Module.OnEvent)
		K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.OnEvent)
		K:RegisterEvent("LFG_PROPOSAL_SHOW", Module.OnEvent)
		K:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", Module.OnEvent)
		SetCVar("autoClearAFK", "1")
	else
		K:UnregisterEvent("PLAYER_FLAGS_CHANGED", Module.OnEvent)
		K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.OnEvent)
		K:UnregisterEvent("LFG_PROPOSAL_SHOW", Module.OnEvent)
		K:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS", Module.OnEvent)
	end
end

local function OnKeyDown(_, key)
	if ignoreKeys[key] then
		return
	end

	if printKeys[key] then
		Screenshot()
	else
		Module:SetAFK(false)
		K.ScheduleTimer(Module, Module.OnEvent, 60)
	end
end

function Module:LoopAnimations()
	local KKUI_AFKPlayerModel = _G.KKUI_AFKPlayerModel
	if KKUI_AFKPlayerModel.curAnimation == 'wave' then
		KKUI_AFKPlayerModel:SetAnimation(69)
		KKUI_AFKPlayerModel.curAnimation = 'dance'
		KKUI_AFKPlayerModel.startTime = GetTime()
		KKUI_AFKPlayerModel.duration = 300
		KKUI_AFKPlayerModel.isIdle = false
		KKUI_AFKPlayerModel.idleDuration = 120
	end
end

function Module:CreateAFKCam()
	local classColor = K.MyClassColor
	local playerClass = UnitClass("player")

	Module.AFKMode = CreateFrame("Frame", "KKUI_AFKFrame")
	Module.AFKMode:SetFrameLevel(5)
	Module.AFKMode:SetScale(_G.UIParent:GetScale())
	Module.AFKMode:SetAllPoints(_G.UIParent)
	Module.AFKMode:Hide()
	Module.AFKMode:EnableKeyboard(true)
	Module.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	Module.AFKMode.top = CreateFrame("Frame", nil, Module.AFKMode)
	Module.AFKMode.top:SetFrameLevel(Module.AFKMode:GetFrameLevel() - 1)
	Module.AFKMode.top:SetSize(UIParent:GetWidth() + 8, 54)
	Module.AFKMode.top:SetPoint("TOP", Module.AFKMode, 0, 6)
	Module.AFKMode.top:CreateBorder()

	Module.AFKMode.bottom = CreateFrame("Frame", nil, Module.AFKMode)
	Module.AFKMode.bottom:SetFrameLevel(Module.AFKMode:GetFrameLevel() - 1)
	Module.AFKMode.bottom:CreateBorder()
	Module.AFKMode.bottom:SetPoint("BOTTOM", Module.AFKMode, "BOTTOM", 0, -6)
	Module.AFKMode.bottom:SetSize(UIParent:GetWidth() + 12, 108)

	-- Server/Local Time text
	Module.AFKMode.top.time = Module.AFKMode.top:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.top.time:FontTemplate(nil, 16)
	Module.AFKMode.top.time:SetText("")
	Module.AFKMode.top.time:SetPoint("RIGHT", Module.AFKMode.top, "RIGHT", -20, 0)
	Module.AFKMode.top.time:SetJustifyH("LEFT")
	Module.AFKMode.top.time:SetTextColor(0.7, 0.7, 0.7)

	-- Date text
	Module.AFKMode.top.date = Module.AFKMode.top:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.top.date:FontTemplate(nil, 16)
	Module.AFKMode.top.date:SetText("")
	Module.AFKMode.top.date:SetPoint("LEFT", Module.AFKMode.top, "LEFT", 20, 0)
	Module.AFKMode.top.date:SetJustifyH("RIGHT")
	Module.AFKMode.top.date:SetTextColor(0.7, 0.7, 0.7)

	-- XP info
	Module.AFKMode.top.xp = Module.AFKMode:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.top.xp:FontTemplate(nil, 16)
	Module.AFKMode.top.xp:SetPoint("CENTER", Module.AFKMode.top, "CENTER")
	Module.AFKMode.top.xp:SetJustifyH("CENTER")
	Module.AFKMode.top.xp:SetText(GetXPinfo())
	Module.AFKMode.top.xp:SetTextColor(0.7, 0.7, 0.7)

	Module.AFKMode.bottom.logo = Module.AFKMode:CreateTexture(nil, "OVERLAY")
	Module.AFKMode.bottom.logo:SetSize(320, 150)
	Module.AFKMode.bottom.logo:SetPoint("CENTER", Module.AFKMode.bottom, "CENTER", 0, 55)
	Module.AFKMode.bottom.logo:SetTexture(C["Media"].Logo)

	local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = K.Faction, 140, -20, -16, -10, -32
	if factionGroup == "Neutral" then
		factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = "Panda", 90, 15, 10, 20, -5
	end

	Module.AFKMode.bottom.faction = Module.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	Module.AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", Module.AFKMode.bottom, "BOTTOMLEFT", offsetX, offsetY)
	Module.AFKMode.bottom.faction:SetTexture(string_format([[Interface\Timer\%s-Logo]], factionGroup))
	Module.AFKMode.bottom.faction:SetSize(size, size)

	Module.AFKMode.bottom.name = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.name:FontTemplate(nil, 20)
	Module.AFKMode.bottom.name:SetFormattedText(classColor.."%s - %s", K.Name, K.Realm)
	Module.AFKMode.bottom.name:SetPoint("TOPLEFT", Module.AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)

	Module.AFKMode.bottom.playerInfo = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.playerInfo:FontTemplate(nil, 20)
	Module.AFKMode.bottom.playerInfo:SetText(K.SystemColor..LEVEL.." "..K.Level.."|r "..K.GreyColor..K.Race.."|r "..classColor..playerClass.."|r")
	Module.AFKMode.bottom.playerInfo:SetPoint("TOPLEFT", Module.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)

	Module.AFKMode.bottom.guild = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.guild:FontTemplate(nil, 20)
	Module.AFKMode.bottom.guild:SetText("No Guild")
	Module.AFKMode.bottom.guild:SetPoint("TOPLEFT", Module.AFKMode.bottom.playerInfo, "BOTTOMLEFT", 0, -6)
	Module.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	Module.AFKMode.bottom.time = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.time:FontTemplate(nil, 20)
	Module.AFKMode.bottom.time:SetText("00:00")
	Module.AFKMode.bottom.time:SetPoint("BOTTOM", Module.AFKMode.bottom, "BOTTOM", 0, 20)
	Module.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	-- Random stats decor (taken from install routine)
	Module.AFKMode.statMsg = CreateFrame("Frame", nil, Module.AFKMode)
	Module.AFKMode.statMsg:SetSize(418, 72)
	Module.AFKMode.statMsg:SetPoint("CENTER", 0, 260)

	Module.AFKMode.statMsg.bg = Module.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	Module.AFKMode.statMsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	Module.AFKMode.statMsg.bg:SetPoint("BOTTOM")
	Module.AFKMode.statMsg.bg:SetSize(326, 103)
	Module.AFKMode.statMsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	Module.AFKMode.statMsg.bg:SetVertexColor(1, 1, 1, 0.7)

	Module.AFKMode.statMsg.lineTop = Module.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	Module.AFKMode.statMsg.lineTop:SetDrawLayer("BACKGROUND", 2)
	Module.AFKMode.statMsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	Module.AFKMode.statMsg.lineTop:SetPoint("TOP")
	Module.AFKMode.statMsg.lineTop:SetSize(418, 7)
	Module.AFKMode.statMsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	Module.AFKMode.statMsg.lineBottom = Module.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	Module.AFKMode.statMsg.lineBottom:SetDrawLayer("BACKGROUND", 2)
	Module.AFKMode.statMsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	Module.AFKMode.statMsg.lineBottom:SetPoint("BOTTOM")
	Module.AFKMode.statMsg.lineBottom:SetSize(418, 7)
	Module.AFKMode.statMsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	-- Random stats frame
	Module.AFKMode.statMsg.info = Module.AFKMode.statMsg:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.statMsg.info:FontTemplate(nil, 18)
	Module.AFKMode.statMsg.info:SetPoint("CENTER", Module.AFKMode.statMsg, "CENTER", 0, -2)
	Module.AFKMode.statMsg.info:SetText(string_format("|cffb3b3b3%s|r", "Random Stats"))
	Module.AFKMode.statMsg.info:SetJustifyH("CENTER")
	Module.AFKMode.statMsg.info:SetTextColor(0.7, 0.7, 0.7)

	-- Use this frame to control position of the model
	Module.AFKMode.bottom.modelPlayerHolder = CreateFrame("Frame", nil, Module.AFKMode.bottom)
	Module.AFKMode.bottom.modelPlayerHolder:SetSize(150, 150)
	Module.AFKMode.bottom.modelPlayerHolder:SetPoint("BOTTOMRIGHT", Module.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)

	Module.AFKMode.bottom.modelPlayer = CreateFrame("PlayerModel", "KKUI_AFKPlayerModel", Module.AFKMode.bottom.modelPlayerHolder)
	Module.AFKMode.bottom.modelPlayer:SetPoint("CENTER", Module.AFKMode.bottom.modelPlayerHolder, "CENTER")
	Module.AFKMode.bottom.modelPlayer:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	Module.AFKMode.bottom.modelPlayer:SetCamDistanceScale(4.5)
	Module.AFKMode.bottom.modelPlayer:SetFacing(6)

	Module.AFKMode.bottom.modelPetHolder = CreateFrame("Frame", nil, Module.AFKMode.bottom)
	Module.AFKMode.bottom.modelPetHolder:SetSize(150, 150)
	Module.AFKMode.bottom.modelPetHolder:SetPoint("BOTTOMRIGHT", Module.AFKMode.bottom, "BOTTOMRIGHT", -500, 100)

	Module.AFKMode.bottom.modelPet = CreateFrame("PlayerModel", "KKUI_AFKPetModel", Module.AFKMode.bottom.modelPetHolder)
	Module.AFKMode.bottom.modelPet:SetPoint("CENTER", Module.AFKMode.bottom.modelPetHolder, "CENTER")
	Module.AFKMode.bottom.modelPet:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	Module.AFKMode.bottom.modelPet:SetCamDistanceScale(9)
	Module.AFKMode.bottom.modelPet:SetFacing(6)

	Module.AFKMode.bottom.modelPlayer:SetScript("OnUpdate", function(model)
		local timePassed = GetTime() - model.startTime
		if (timePassed > model.duration) and model.isIdle ~= true then
			model:SetAnimation(0)
			model.isIdle = true
			K.ScheduleTimer(Module.animTimer, Module.LoopAnimations, model.idleDuration)
		end
	end)

	Module:AFKToggle()
	Module.isActive = false
end