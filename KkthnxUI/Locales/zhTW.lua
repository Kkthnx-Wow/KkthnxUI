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
	Interrupted = INTERRUPTED.."%s的\124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!",
	PCAborted = "中止開怪!",
	PCGo = "沖啊!",
	PCMessage = "嘲諷%s倒計時%s..",
	Sapped = "被悶棍",
	SappedBy = "被悶棍:",
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
	AFK = "|cffff0000[离开]|r",
	BigChatOff = "大聊天框已停用",
	BigChatOn = "大聊天框已啟用",
	DND = "|cffe7e716[忙碌]|r",
	General = "綜合",
	Guild = "公",
	GuildRecruitment = "招募",
	Instance = "隨機",
	InstanceLeader = "隨機隊長",
	InvalidTarget = "无效的目标",
	LocalDefense = "本地防禦",
	LookingForGroup = "尋求組隊",
	Officer = "官",
	Party = "隊",
	PartyLeader = "隊長",
	Raid = "團",
	RaidLeader = "團長",
	RaidWarning = "團隊警告",
	Says = "说",
	Trade = "交易",
	Whispers = "密语",
	Yells = "大喊",
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
	Skada = "打開/關閉Skada",
}

-- DataBars Localization
L.DataBars = {
	ArtifactClick = "Toggle Artifact Frame",
	HonorClick = "Toggle Honor Frame",
	ReputationClick = "Toggle Reputation Frame",
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
	Header8 = "1. 基本設置",
	Header9 = "2. 社交",
	Header10 = "3. 框體",
	Header11 = "4. 成功！",
	InitLine1 = "感謝您選擇KkthnxUI！",
	InitLine2 = "接下來您將被引導安裝本UI，只有很少的幾個步驟。在每壹個步驟您可以選擇接受或者跳過我們的壹些插件預設。",
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
	ButtonInstall = "安裝",
	ButtonNext = "下壹步",
	ButtonSkip = "忽略",
	ButtonContinue = "繼續",
	ButtonFinish = "結束",
	ButtonClose = "關閉",
	Complete = "安裝完成"
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
	SetUIScale = "This will set a near 'Pixel Perfect' Scale to your interface. Do you want to proceed?",
}

-- Raid Utility Localization
L.Raid = {
	UtilityDisband = "解散團隊",
	DisbandRaid = "您確定您想要解散團隊？"
}

-- Tooltip Localization
L.Tooltip = {
	ItemCount = "物品數量:",
	SpellID = "法術ID:",
	ToggleBar = "Unlock and lock the action bars using this button. Once you have unlocked the bars, you can hover over them to see the 'toggle bar' feature to toggle more or fewer action bars.",
}

L.WatchFrame = {
	WowheadLink = "Wowhead鏈接"
}

L.Welcome = {
	Line1 = "Welcome to |cff3c9bedKkthnxUI|r v",
	Line2 = "",
	Line3 = "Type |cff3c9bed/cfg|r to access the in-game configuration menu.",
	Line4 = "",
	Line5 = "If you are in need of support you can visit our Discord |cff3c9bedQ2KhGY2|r"
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
		"/tt - 密語目標。",
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
