local K, C, L = unpack(select(2, ...))
if (GetLocale() ~= "ruRU") then return end

-- Localization For ruRU Clients

L.AFKScreen = {
	NoGuild = "Нет гильдии",
	-- Needs translation
	Sun = "Вскресение",
	Mon = "Понедельник",
	Tue = "Вторник",
	Wed = "Среда",
	Thu = "Четверг",
	Fri = "Пятница",
	Sat = "Суббота",
	Jan = "Январь",
	Feb = "Февраль",
	Mar = "Марта",
	Apr = "Апрель",
	May = "Май",
	Jun = "Июнь",
	Jul = "Июль",
	Aug = "Август",
	Sep = "Сентябрь",
	Oct = "Октябрь",
	Nov = "Ноябрь",
	Dec = "Декабрь"
}

L.Announce = {
	Interrupted = INTERRUPTED.." %s \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!",
	PCAborted = "ОСТАНОВИТЬ АТАКУ!",
	PCGo = "Вперед!",
	PCMessage = "Атаковать %s через %s..",
	Sapped = "Ошеломление!",
	SappedBy = "Ошеломление от: ",
}

L.Auras = {
	MoveBuffs = "Передвинуть Баффы",
	MoveDebuffs = "Передвинуть дебаффы",
}

-- Merchant Localization
L.Merchant = {
	NotEnoughMoney = "У вас недостаточно денег для ремонта!",
	RepairCost = "Ваша экипировка была отремонтирована за ",
	SoldTrash = "Серые вещи были проданы. Вы заработали "
}

-- Bindings Localization
L.Bind = {
	Binding = "Назначение клавиш",
	Cleared = "Все назначения клавиш были очищены.",
	Discard = "Все новые назначения клавиш были сброшены..",
	Instruct = "Наведите указатель мыши на нужную кнопку, чтобы назначить привязку. Нажмите ESC или правую кнопку мыши, что бы очистить текущее назначение.",
	Key = "Клавиша",
	NoSet = "Назначение не установлено",
	Saved = "се назначения клавиш были сохранены.",
	Trigger = "Триггер"
}

-- Chat Localization
L.Chat = {
	AFK = "|cffff0000[АФК]|r",
	BigChatOff = "Большой Чат отключен",
	BigChatOn = "Большой Чат включен",
	DND = "|cffe7e716[НБ]|r",
	General = "Общий",
	Guild = "Г",
	GuildRecruitment = "Набор Гильдии",
	Instance = "П",
	InstanceLeader = "ЛП",
	InvalidTarget = "Неверная цель",
	LocalDefense = "Оборона",
	LookingForGroup = "Поиск Группы",
	Officer = "О",
	Party = "Г",
	PartyLeader = "Г",
	Raid = "Р",
	RaidLeader = "Р",
	RaidWarning = "ОР",
	Says = "говорит",
	Trade = "Торговля",
	Whispers = "шепчет",
	Yells = "кричит",
}

-- ToggleButton Localization
L.ToggleButton = {
	Config = "Toggle KkthnxUI Config",
	Functions = "ToggleButton functions:",
	LeftClick = "Left click:",
	MiddleClick = "Middle click:",
	MoveUI = "Toggle Move UI",
	Recount = "Toggle Recount",
	RightClick = "Right click:",
	Skada = "Toggle Skada",
}

-- DataBars Localization
L.DataBars = {
	ArtifactClick = "Toggle Artifact Frame",
	HonorClick = "Toggle Honor Frame",
	ReputationClick = "Toggle Reputation Frame",
}

-- DataText Localization
L.DataText = {
	Bandwidth = "Bandwidth",
	BaseAssault = "Bases Assaulted:",
	BaseDefend = "Bases Defended:",
	CartControl = "Carts Controlled:",
	Damage = "Урон: ",
	DamageDone = "Урон сделан:",
	Death = "Смерти:",
	DemolisherDestroy = "Demolishers Destroyed:",
	Download = "Загрузка",
	FlagCapture = "Flags Captured:",
	FlagReturn = "Flags Returned:",
	GateDestroy = "Gates Destroyed:",
	GraveyardAssault = "Graveyards Assaulted:",
	GraveyardDefend = "Graveyards Defended:",
	Healing = "Исцеление: ",
	HealingDone = "Исцеление сделано:",
	HomeLatency = "Локальная Задержка:",
	Honor = "Honor: ",
	HonorableKill = "Honorable Kills:",
	HonorGained = "Honor Gained:",
	KillingBlow = "Killing Blows: ",
	MemoryUsage = "(Hold Shift) Memory Usage",
	OrbPossession = "Orb Possessions:",
	SavedDungeons = "Saved Dungeon(s)",
	SavedRaids = "Saved Raid(s)",
	StatsFor = "Stats for ",
	TotalCPU = "Total CPU:",
	TotalMemory = "Total Memory:",
	TowerAssault = "Towers Assaulted:",
	TowerDefend = "Towers Defended:",
	VictoryPts = "Victory Points:"
}

-- headers
L.Install = {
	Header1 = "Welcome",
	Header8 = "1. Essential Settings",
	Header9 = "2. Social",
	Header10 = "3. Рамки",
	Header11 = "4. Success!",
	InitLine1 = "Thank you for choosing KkthnxUI!",
	InitLine2 = "You will be guided through the installation process in a few simple steps. At each step, you can decide whether or not you want to apply or skip the presented settings.",
	Step1Line1 = "These steps will apply the correct CVar settings for KkthnxUI.",
	Step1Line2 = "The first step applies the essential settings.",
	Step1Line3 = "This is |cffff0000recommended|r for any user unless you want to apply only a specific part of the settings.",
	Step1Line4 = "Click 'Continue' to apply the settings, or click 'Skip' if you wish to skip this step.",
	Step2Line0 = "Another chat addon is found. We will ignore this step. Please press skip to continue installation.",
	Step2Line1 = "The second step applies the correct chat setup.",
	Step2Line2 = "If you are a new user, this step is recommended. If you are an existing user, you may want to skip this step.",
	Step2Line3 = "It is normal that your chat font will appear too big upon applying these settings. It will revert back to normal when you finish with the installation.",
	Step2Line4 = "Click 'Continue' to apply the settings, or click 'Skip' if you wish to skip this step.",
	Step3Line1 = "The third and final step applies for the default frame positions.",
	Step3Line2 = "This step is |cffff0000recommended|r for new users.",
	Step3Line3 = "",
	Step3Line4 = "Click 'Continue' to apply the settings, or click 'Skip' if you wish to skip this step.",
	Step4Line1 = "Installation is complete.",
	Step4Line2 = "Please click the 'Finish' button to reload the UI.",
	Step4Line3 = "",
	Step4Line4 = "Enjoy KkthnxUI! Visit us on Discord @ |cff748BD9discord.gg/Kjyebkf|r",
	ButtonInstall = "Install",
	ButtonNext = "Next",
	ButtonSkip = "Skip",
	ButtonContinue = "Continue",
	ButtonFinish = "Finish",
	ButtonClose = "Close",
	Complete = "Установка Завершена"
}

-- AutoInvite Localization
L.Invite = {
	Enable = "Автоприглашение включено: ",
	Disable = "Автоприклашение выключено"
}

-- Info Localization
L.Info = {
	Disabnd = "Роспуск группы...",
	Duel = "DДуэль отклонена от ",
	Errors = "Ошибок не обнаружено.",
	Invite = "Приглашение принято от ",
	NotInstalled = " не установлено.",
	PetDuel = "Дуэль петомцев отклонена от ",
	SettingsAll = "Введите /settings all, для применения настроек ко всем модификациям.",
	SettingsDbm = "Введите /settings dbm, для применения настроек DBM.",
	SettingsMsbt = "Введите /settings msbt, для применения настроек MSBT.",
	SettingsSkada = "Введите /settings skada, для применения настроект Skada.",
	SkinDisabled1 = "Скин для ",
	SkinDisabled2 = " выключен."
}

-- Loot Localization
L.Loot = {
	Announce = "Объявить",
	Cannot = "Cannot roll",
	Chest = ">> Добыча из сундука",
	Fish = "Добыча с рыбалки",
	Monster = ">> Добыча из ",
	Random = "Случайный игрок",
	Self = "Каждый сам за себя",
	ToGuild = " Гильдии",
	ToInstance = " Сценарию",
	ToParty = " Группе",
	ToRaid = " Рейду",
	ToSay = " Сказать"
}

-- FarmMode Minimap
L.Minimap = {
	FarmModeOn = "|cffffe02eРежим фарма|r: |cFF008000Включен|r.",
	FarmModeOff = "|cffffe02eРежим фарма|r: |cFFFF0000Выключен|r."
}

-- Misc Localization
L.Misc = {
	BuyStack = "Зажмите Alt и щелкните мышью, чтобы купить связку",
	Collapse = "Обрушение",
	CopperShort = "|cffeda55fм|r",
	GoldShort = "|cffffd700з|r",
	SilverShort = "|cffc7c7cfс|r",
	TriedToCall = "%s: %s tried to call the protected function '%s'.",
	UIOutdated = "KkthnxUI устарел. Вы можете загрузить последнюю версию с сайта curse.com. Установите приложение Curse и получайте автоматические обновления KkthnxUI.",
	Undress = "Раздеть"
}

L.Popup = {
	BlizzardAddOns = "It appears one of your AddOns have disabled the AddOn Blizzard_CompactRaidFrames. This can cause errors and other issues. The AddOn will now be re-enabled.",
	BoostUI = "|cffff0000ВНИМАНИЕ:|r Это позволит оптимизировать производительность за счет снижения уровня графики. Применяйте только если у вас возникли проблемы с |cffff0000FPS|r!|r",
	DisableUI = "KkthnxUI might not work for this resolution, do you want to disable KkthnxUI? (Cancel if you want to try another resolution)",
	DisbandRaid = "Вы действительно хотите распустить группу?",
	FixActionbars = "Что-то не так с вашими панелями команд. Хотите перезагрузить UI, чтобы исправить это?",
	InstallUI = "Спасибо за выбор |cff3c9bedKkthnxUI|r! |n|nПодтвердите установку для применения настроек.",
	ReloadUI = "Установка завершена. Пожалуйста, нажмите кнопку 'Принять' для перезагрузки UI. Наслаждайтесь |cff2eb6ffKkthnxUI|r!|n|nПосетите мою страницу: |cff2eb6ffwww.github.com/kkthnx|r!",
	ResetUI = "Вы уверены, что хотите сбросить все настройки |cff3c9bedKkthnxUI|r?",
	ResolutionChanged = "Мы обнаружили изменение разрешения в вашем клиенте World of Warcraft. Мы НАСТОЯТЕЛЬНО РЕКОМЕНДУЕМ перезагрузить игру. Хотите продолжить?",
	SettingsAll = "|cffff0000ВНИМАНИЕ|r |n|nЭто применит настройки ко всем аддонам поддерживаемым |cff3c9bedKkthnxUI|r. Ничего не произойдет, если у вас нет ни одного поддерживаемого аддона.",
	SettingsBW = "Need to change the position of elements BigWigs.",
	SettingsDBM = "Нам нужно изменить позицию баров |cff3c9bedDBM|r.",
	SetUIScale = "This will set a near 'Pixel Perfect' Scale to your interface. Do you want to proceed?",
}

-- Raid Utility Localization
L.Raid = {
	UtilityDisband = "Распустить Группу",
	DisbandRaid = "Вы действительно хотите распустить группу?"
}

-- Tooltip Localization
L.Tooltip = {
	ItemCount = "Количество предметов:",
	SpellID = "ID заклинания:"
}

L.WatchFrame = {
	WowheadLink = "Ссылка Wowhead"
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
		"|cff3c9bedДоступные команды:|r",
		"--------------------------",
		"/rl - Перезагрузка интерфейса.",
		"/rc - Активировать проверку готовности.",
		"/gm - Открыть окно ГМ.",
		"/rd - Распустить группу или рейд.",
		"/toraid - Конвертировать в группу или рейд.",
		"/teleport - Телепортация из случайного подземелья.",
		"/spec, /ss - Переключение между наборами талантов.",
		"/frame - Информация об элементе под указателем мыши.",
		"/farmmode - Увеличение размера миникарты.",
		"/moveui - Перемещение всех элементов интерфейса.",
		"/resetui - Сброс общих настроек по умолчанию.",
		"/resetconfig - Сброс настроек KkthnxUI_Config.",
		"/settings ADDON_NAME - Применение настроек для msbt, dbm, skada, или всех аддонов сразу.",
		"/tt - Выбрать в цель приватного собеседника.",
		"/cfg - Открывает настройки интерфейса.",
		"/patch - Выводит информацию о патче WOW.",
		"",
		"|cff3c9bedДоступные скрытые функции:|r",
		"--------------------------",
		"Правый клик по миникарте открывает микроменю.",
		"Средний клик по миникарте открывает меню выбора слежения.",
		"Левый клик по полосе опыта открывает окно репутации.",
		"Левый клик по полосе атифакта открывает окно артифакта.",
		"Зажать Alt для получения среднего уровня вещей во всплывающей подсказке.",
		"Зажать Shift для быстрой прокрутки в начало или конец чата.",
		"Кнопка копии чата находится в правом нижнем углу окна чата.",
		"Средний клик по кнопке копии чата выбрасывает /roll.",
	}
}