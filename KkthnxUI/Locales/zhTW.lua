local K, C, L = unpack(select(2, ...))
if (GetLocale() ~= "zhTW") then return end

-- Localization for zhTW clients

L.AFKScreen = {
	NoGuild = "無公會",
	Sun = "星期天",
	Mon = "星期壹",
	Tue = "星期二",
	Wed = "星期三",
	Thu = "星期四",
	Fri = "星期五",
	Sat = "星期六",
	Jan = "壹月",
	Feb = "二月",
	Mar = "三月",
	Apr = "四月",
	May = "五月",
	Jun = "六月",
	Jul = "七月",
	Aug = "八月",
	Sep = "九月",
	Oct = "十月",
	Nov = "十壹月",
	Dec = "十二月"
}

L.Announce = {
	FPUse = "%s使用了%s.",
	Interrupted = INTERRUPTED.."%s的\124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!",
	PCAborted = "中止開怪!",
	PCGo = "沖啊!",
	PCMessage = "嘲諷%s倒計時%s..",
	Recieved = "接收自",
	Sapped = "被悶棍",
	SappedBy = "被悶棍:",
	SSThanks = "感謝"
}

L.Auras = {
	MoveBuffs = "移動增益",
	MoveDebuffs = "移動減益",
}

-- Merchant Localization
L.Merchant = {
	NotEnoughMoney = "您沒有足夠的金錢修理裝備!",
	RepairCost = "您的裝備修理完畢，共花費",
	SoldTrash = "您的垃圾已經處理完畢，共獲得"
}

-- Bindings Localization
L.Bind = {
	Binding = "按鍵綁定",
	Cleared = "所有按鍵綁定已被清除",
	Discard = "所有按鍵綁定的新設置已被取消.",
	Instruct = "將您的鼠標箭頭放置在任何需要綁定的動作條空格上，然後按下需要綁定的按鍵。按下空格鍵或單擊鼠標右鍵來清除當前動作條空格的按鍵綁定.",
	Key = "按鍵",
	NoSet = "未設置按鍵綁定",
	Saved = "所有按鍵綁定已被保存.",
	Trigger = "觸發"
}

-- Chat Localization
L.Chat = {
	AFK = "|cffff0000[AFK]|r",
	BigChatOff = "大聊天框已停用",
	BigChatOn = "大聊天框已啟用",
	DND = "|cffe7e716[DND]|r",
	Guild = "公",
	GuildRecruitment = "招募",
	Instance = "隨機",
	InstanceLeader = "隨機隊長",
	LocalDefense = "本地防禦",
	LookingForGroup = "尋求組隊",
	Officer = "官",
	Party = "隊",
	PartyLeader = "隊長",
	Raid = "團",
	RaidLeader = "團長",
	RaidWarning = "團隊警告",
}

-- ToggleButton Localization
L.ToggleButton = {
	Config = "打開KkthnxUI設置",
	Functions = "按鍵功能:",
	LeftClick = "鼠標左鍵:",
	MiddleClick = "鼠標中鍵:",
	MoveUI = "移動框體",
	Recount = "打開/關閉Recount",
	RightClick = "鼠標右鍵:",
	ShiftClick = "Shift+鼠標左鍵:",
	Skada = "打開/關閉Skada",
}

-- Cooldowns
L.Cooldowns = {
	Cooldowns = "冷卻:",
	CombatRes = "戰復",
	CombatResRemainder = "戰復:",
	NextTime = "下次:"
}

-- DataBars Localization
L.DataBars = {
	ArtifactClick = "鼠標左鍵:神器面板",
	ArtifactRemaining = "|cffe6cc80剩余:%s|r",
	HonorLeftClick = "|cffcacaca鼠標左鍵：PVP面板|r",
}

-- DataText Localization
L.DataText = {
	Bandwidth = "帶寬:",
	BaseAssault = "已襲擊基地:",
	BaseDefend = "已保衛基地:",
	CartControl = "控制礦車:",
	Damage = "傷害:",
	DamageDone = "傷害總計:",
	Death = "死亡:",
	DemolisherDestroy = "摧毀工程車:",
	Download = "下載",
	FlagCapture = "已獲得旗幟:",
	FlagReturn = "已歸還旗幟:",
	GateDestroy = "已攻破大門:",
	GraveyardAssault = "已攻陷墓地:",
	GraveyardDefend = "已防禦墓地:",
	Healing = "治療: ",
	HealingDone = "治療總計:",
	HomeLatency = "本地延遲:",
	Honor = "榮譽:",
	HonorableKill = "榮譽擊殺:",
	HonorGained = "獲得榮譽:",
	KillingBlow = "連殺計數:",
	MemoryUsage = "（按住shift）已使用內存",
	OrbPossession = "擁有寶珠:",
	SavedDungeons = "已鎖定地下城",
	SavedRaids = "已鎖定團隊副本",
	StatsFor = "Stats for ",
	TotalCPU = "總CPU：",
	TotalMemory = "總內存:",
	TowerAssault = "已攻陷防禦塔:",
	TowerDefend = "已防守防禦塔:",
	VictoryPts = "勝利點數:"
}

-- headers
L.Install = {
	Header1 = "歡迎使用",
	Header2 = "1. 基本",
	Header3 = "2. 角色框體",
	Header4 = "3. 功能",
	Header5 = "4. 您需要了解以下信息！",
	Header6 = "5. 命令",
	Header7 = "6. 結束",
	Header8 = "1. 基本設置",
	Header9 = "2. 社交",
	Header10 = "3. 框體",
	Header11 = "4. 成功！",
	InitLine1 = "感謝您選擇KkthnxUI！",
	InitLine2 = "接下來您將被引導安裝本UI，只有很少的幾個步驟。在每壹個步驟您可以選擇接受或者跳過我們的壹些插件預設。",
	InitLine3 = "您還可以獲得簡單的教程來了解KkthnxUI的壹些功能。",
	InitLine4 = "點擊“教程”按鈕將會向您介紹本UI，或者直接點擊“安裝”按鈕來略過這壹步。",
	Step1Line1 = "這些步驟會加載適合KkthnxUI的系統設置。",
	Step1Line2 = "第壹步將加載基本設置。",
	Step1Line3 = "這壹步我們|cffff0000強烈建議|r您加載這些基本設置，當然您也可以只加載部分設置。",
	Step1Line4 = "點擊“繼續”來加載設置，或者點擊“忽略”如果您想跳過這壹步。",
	Step2Line0 = "檢測到您已經安裝有另壹個聊天窗口插件。我們將跳過這壹步。請點擊“忽略”繼續進行安裝。",
	Step2Line1 = "第二步將應用合適的聊天窗口設置。",
	Step2Line2 = "如果您是新用戶，我們建議您完成這壹步。如果您是老用戶，您可以跳過這壹步。",
	Step2Line3 = "在應用設置後，您的聊天字體大小可能會很大，這很正常。當您結束安裝後字體大小會恢復正常。 It will revert back to normal when you finish with the installation.",
	Step2Line4 = "點擊“繼續”來加載設置，或者點擊“忽略”如果您想跳過這壹步。",
	Step3Line1 = "第三步和最後壹步將會加載默認的框體位置。",
	Step3Line2 = "我們|cffff0000強烈建議|r新用戶完成這壹步.",
	Step3Line3 = "",
	Step3Line4 = "點擊“繼續”來加載設置，或者點擊“忽略”如果您想跳過這壹步。",
	Step4Line1 = "安裝完成。",
	Step4Line2 = "請點擊“結束”按鈕來重載界面。",
	Step4Line3 = "",
	Step4Line4 = "享受KkthnxUI吧！歡迎與我們在 Discord @ |cff748BD9discord.gg/Kjyebkf|r 上交流",
	ButtonTutorial = "教程",
	ButtonInstall = "安裝",
	ButtonNext = "下壹步",
	ButtonSkip = "忽略",
	ButtonContinue = "繼續",
	ButtonFinish = "結束",
	ButtonClose = "關閉",
	Complete = "安裝完成"
}

-- tutorial 1
L.Tutorial = {
	Step1Line1 = "本簡易教程將向您展示KkthnxUI的壹些功能。",
	Step1Line2 = "在使用本UI前您首先需要了解壹些基本點。",
	Step1Line3 = "KkthnxUI的安裝器是區分角色的。雖然有些設置是全帳號通用的，在每個新角色開始使用前都需要進行壹次安裝操作。安裝界面會在您登錄新角色時自動彈出。此外，壹些給“強力”用戶使用的選項可以在/KkthnxUI/Config/Settings.lua中找到，而普通玩家也可以在在遊戲中輸入/KkthnxUI來調取設置界面。",
	Step1Line4 = "我們所說的“強力”玩家是有壹定高級計算機知識的玩家（比如LUA編輯），普通玩家壹般不具有這壹能力，因此我們建議普通玩家在遊戲中直接使用設置界面（/KkthnxUI）來對自定義KkthnxUI。",
	Step2Line1 = "KkthnxUI包括壹個內置的oUF插件（作者：Haste）。這壹插件是屏幕上所有角色框體，增益和減益以及職業資源條的基礎。",
	Step2Line2 = "您可以訪問wowinterface.com並搜索oUF來獲得更多關於它的信息。",
	Step2Line3 = "您可以通過輸入/moveui來很方便地移動各框體位置。",
	Step2Line4 = "",
	Step3Line1 = "KkthnxUI對魔獸世界原始界面進行了重新設計。不多也不少剛剛好。基本上在原始界面上您能看到的功能在KkthnxUI中也能找到。此外，KkthnxUI還有壹些原始界面中沒有的功能，比如自動賣垃圾及自動整理背包。",
	Step3Line2 = "並不是每個玩家都喜歡使用比如傷害統計、BOSS模塊、仇恨監視等類型的插件，我們深知這壹點。KkthnxUI的設計理念是將其發展為所有職業、所有角色、所有專精、所有遊戲方式、所有玩家品味都適合的UI。 這就是為什麽KkthnxUI是目前最受歡迎的UI之壹。它適合所有人的遊戲方式並有很高的可定制性。它也是壹款很好的啟蒙UI來讓初學者們制作自己的UI。自2012年以來，很多玩家將KkthnxUI作為他們自制UI的基礎。",
	Step3Line3 = "玩家們可以訪問我們的網站或訪問www.wowinterface.com來獲得更多的模塊和功能",
	Step3Line4 = "",
	Step4Line1 = "鼠標指針移至下方動作條上側或右側動作條下側可以更改動作條數量。請點擊聊天框右下角的按鈕復制聊天窗口文字。",
	Step4Line2 = "80%的狀態信息都可以點擊打開相應窗口。右鍵點擊好友和公會信息條也有附加功能。",
	Step4Line3 = "壹些下拉菜單也被實現了。右鍵點擊背包右上角的X可以顯示背包裝備情況，右鍵點擊小地圖可以調取微型菜單。",
	Step4Line4 = "",
	Step5Line1 = "最後，KkthnxUI還有壹些有用的命令可以使用。命令列表如下。",
	Step5Line2 = "/moveui 允許您自由移動很多框體。 /rl 重載界面。",
	Step5Line3 = "/tt 允許您向目標發送密語。 /rc 開始團隊檢查。 /rd 解散隊伍或團隊。 /ainv 自動邀請向您發送密語的玩家。 (/ainv off) 關閉自動邀請功能。",
	Step5Line4 = "/gm 打開幫助界面。 /install or /tutorial 加載安裝界面。 ",
	Step6Line1 = "教程已經結束。您可以通過輸入/tutorial在以後重新調取教程。",
	Step6Line2 = "我建議您查看壹下config/config.lua，或輸入/KkthnxUI來自定義您理想中的UI。",
	Step6Line3 = "如果您想繼續未完成的安裝步驟或重置所有設置，您可以繼續點擊安裝按鈕！",
	Step6Line4 = "",
	Message1 = "技術支持請訪問https://github.com/Kkthnx.",
	Message2 = "您可以右鍵小地圖以打開微型菜單。",
	Message3 = "您可以輸入/kb以快速綁定快捷鍵。",
	Message4 = "您可以輸入/focus將當前目標設置為焦點。我們建議您建立相應的宏來使用這項功能。",
	Message5 = "鼠標移動至聊天窗口右下角後會有按鈕顯示，點擊它可以復制聊天窗口內的文字。",
	Message6 = "如果您在使用過程中遇到問題，請關閉除KkthnxUI外的所有插件。請記住KkthnxUI是壹個全界面替換插件，您不可以同時運行另壹個具有類似功能的插件。",
	Message7 = "您可以右鍵點擊聊天窗口標簽並進入設置界面來設置此標簽下顯示哪些頻道的聊天內容。",
	Message8 = "您可以使用/resetui命令來重置所有框體位置。您還可以使用/moveui命令並右鍵點擊某個框體來重置其位置。",
	Message9 = "您需要按住alt鍵並拖動技能來改變其在動作條中的位置。您可以在動作條設置中更改按鍵。",
	Message10 = "在鼠標提示設置中啟用物品等級功能，之後您將可以在鼠標提示中看到其他玩家的平均裝備等級。"
}

-- AutoInvite Localization
L.Invite = {
	Enable = "啟用自動邀請",
	Disable = "禁用自動邀請"
}

-- Info Localization
L.Info = {
	Disabnd = "解散團隊...",
	Duel = "已拒絕決鬥請求自",
	Errors = "沒有錯誤.",
	Invite = "已接受組隊邀請自",
	NotInstalled = " 未安裝.",
	PetDuel = "已拒絕寵物決鬥請求自",
	SettingsALL = "輸入/settings all來加載全局設置.",
	SettingsDBM = "輸入/settings dbm來加載DBM設置.",
	SettingsMSBT = "輸入/settings msbt來加載MSBT設置.",
	SettingsSKADA = "輸入/settings skada來加載Skada設置.",
	SkinDisabled1 = "插件",
	SkinDisabled2 = "皮膚已禁用."
}

-- Loot Localization
L.Loot = {
	Announce = "通告",
	Cannot = "無法roll點",
	Chest = ">> 拾取自寶箱",
	Fish = "釣魚獲得",
	Monster = ">> 拾取自",
	Random = "隨機玩家",
	Self = "個人拾取",
	ToGuild = " 公會",
	ToInstance = " 隨機隊伍",
	ToParty = " 隊伍",
	ToRaid = " 團隊",
	ToSay = " 說"
}

-- Mail Localization
L.Mail = {
	Complete = "全部結束。",
	Messages = "郵件",
	Need = "需要郵箱.",
	Stopped = "已停止.背包已滿.",
	Unique = "已停止.在背包或銀行中已有拾取唯壹的相同物品."
}

-- World Map Localization
L.Map = {
	Fog = "戰爭迷霧"
}

-- FarmMode Minimap
L.Minimap = {
	FarmModeOn = "采集模式開啟",
	FarmModeOff = "采集模式關閉"
}

-- Misc Localization
L.Misc = {
	BuyStack = "Alt左鍵批量購買",
	Collapse = "The Collapse",
	CopperShort = "|cffeda55fC|r",
	GoldShort = "|cffffd700G|r",
	SilverShort = "|cffc7c7cfS|r",
	TriedToCall = "%s: %s 嘗試調用保護函數 '%s'.",
	UIOutdated = "KkthnxUI版本已過期。您可以從Curse.com上下載最新版本。安裝Curse App可以自動更新！",
	Undress = "壹鍵脫光"
}

L.Popup = {
	Armory = "英雄榜",
	BlizzardAddOns = "您的壹個插件禁用了Blizzard_CompactRaidFrames插件。這可能會引發錯誤或其他情況。這個插件將被重新啟用。",
	BoostUI = "|cffff0000警告|r |n|n這將會通過降低圖像質量來優化性能，請在您有|cffff0000FPS|r issues!|r問題時再點擊接受！",
	DisableUI = "KkthnxUI在這壹分辨率上可能不會正常工作，您想禁用KkthnxUI嗎? （如果您想試試其他分辨率請取消）",
	DisbandRaid = "您確定您想解散隊伍嗎？",
	FixActionbars = "您的動作條有壹些問題。您想重載界面來修復問題嗎？",
	InstallUI = "感謝您選擇|cff3c9bedKkthnxUI|r! |n|n請接受安裝來加載設置。",
	ReloadUI = "安裝已經完成。請點擊“接受”按鈕來重載界面。祝您使用|cff3c9bedKkthnxUI|r愉快。|n|n請訪問我的GitHub主頁|cff3c9bedwww.github.com/kkthnx|r.",
	ResetUI = "您確定您想重置|cff3c9bedKkthnxUI|r的設置嗎?",
	ResolutionChanged = "我們檢測到您的魔獸世界客戶端的分辨率被改變。我們強烈建議您重啟遊戲。您想繼續嗎？",
	SettingsAll = "|cffff0000警告|r |n|n這將替換所有被支持插件的設置為|cff3c9bedKkthnxUI|r默認設置。如果您沒有安裝被支持的插件，這壹功能不會對其他插件產生影響。",
	SettingsBW = "需要改變BigWigs各元素的位置。",
	SettingsDBM = "需要改變|cff3c9bedDBM|r計時條的位置。",
}

-- Raid Utility Localization
L.Raid = {
	UtilityDisband = "解散團隊",
	DisbandRaid = "您確定您想要解散團隊？"
}

-- Tooltip Localization
L.Tooltip = {
	AchievementComplete = "您的狀態:已完成",
	AchievementIncomplete = "您的狀態:未完成",
	AchievementStatus = "您的狀態:",
	ItemCount = "物品數量:",
	ItemID = "物品ID:",
	SpellID = "法術ID:"
}

L.WatchFrame = {
	WowheadLink = "Wowhead鏈接"
}

L.Welcome = {
	Line1 = "歡迎使用|cff3c9bedKkthnxUI|r v",
	Line2 = "",
	Line3 = "輸入/cfg打開設置界面，或訪問www.github.com/kkthnx|r",
	Line4 = "",
	Line5 = "壹些常見問題可以輸入/uihelp來查看。"
}

L.Zone = {
	ArathiBasin = "Arathi Basin",
	Gilneas = "The Battle for Gilneas"
}

L.SlashCommand = {
	Help = {
		"",
		"|cff3c9bed可用命令:|r",
		"--------------------------",
		"/rl - 重載界面。",
		"/rc - 團隊檢查。",
		"/gm - 打開GM窗口。",
		"/rd - 解散隊伍或團隊。",
		"/toraid - 轉換為隊伍或團隊。",
		"/teleport - 傳送至隨機副本。",
		"/spec, /ss - 切換專精。",
		"/frame - 暫無說明。",
		"/farmmode - 小地圖變大。",
		"/moveui - 允許自由移動框體。",
		"/resetui - 加載默認設置。",
		"/resetconfig - 重置KkthnxUI_Config設置。",
		"/settings 插件名稱(msbt, dbm, skada, all) - 加載msbt，dbm，skada，或以上所有插件的默認設置。",
		"/pulsecd - 冷卻模塊測試。",
		"/tt - 密語目標。",
		"/ainv - 啟用自動邀請。",
		"/cfg - 打開設置界面。",
		"/patch - 顯示遊戲版本信息",
		"",
		"|cff3c9bed可用隱藏功能:|r",
		"--------------------------",
		"右鍵點擊小地圖打開系統微型菜單。",
		"中鍵點擊小地圖打開跟蹤菜單。",
		"左鍵點擊經驗條打開聲望面板。",
		"左鍵點擊神器能量條打開神器面板。",
		"按住Alt在鼠標提示上顯示玩家裝備等級和專精。",
		"按住並滾動鼠標滾輪直接顯示聊天窗口最後壹行。",
		"復制按鈕在聊天窗口右下方。",
		"中鍵點擊復制按鈕自動roll點。",
	}
}
