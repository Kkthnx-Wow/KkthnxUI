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
	FPUse = "%s использует %s.",
	Interrupted = INTERRUPTED.." %s \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!",
	PCAborted = "ОСТАНОВИТЬ АТАКУ!",
	PCGo = "Вперед!",
	PCMessage = "Атаковать %s через %s..",
	Recieved = " получено от ",
	Sapped = "Ошеломление!",
	SappedBy = "Ошеломление от: ",
	SSThanks = "Спасибо за "
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
	ShiftClick = "Shift + click:",
	Skada = "Toggle Skada",
}

-- Cooldowns
L.Cooldowns = {
	Cooldowns = "CD: ",
	CombatRes = "Боевое Воскрешение",
	CombatResRemainder = "Боевое Воскрешение: ",
	NextTime = "Следующий раз: "
}

-- DataBars Localization
L.DataBars = {
	ArtifactClick = "Клик: Открывает обзор артефактов",
	ArtifactRemaining = "|cffe6cc80Осталось: %s|r",
	HonorLeftClick = "|cffcacacaЛевый Клик: Открывает окно чести|r",
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
	Header2 = "1. Essentials",
	Header3 = "2. Рамки Юнитов",
	Header4 = "3. Features",
	Header5 = "4. Вам нужно знать!",
	Header6 = "5. Команды",
	Header7 = "6. Finished",
	Header8 = "1. Essential Settings",
	Header9 = "2. Social",
	Header10 = "3. Рамки",
	Header11 = "4. Success!",
	InitLine1 = "Thank you for choosing KkthnxUI!",
	InitLine2 = "You will be guided through the installation process in a few simple steps. At each step, you can decide whether or not you want to apply or skip the presented settings.",
	InitLine3 = "You are also given the possibility to be shown a brief tutorial on some of the features of KkthnxUI.",
	InitLine4 = "Press the 'Tutorial' button to be guided through this small introduction, or press 'Install' to skip this step.",
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
	ButtonTutorial = "Tutorial",
	ButtonInstall = "Install",
	ButtonNext = "Next",
	ButtonSkip = "Skip",
	ButtonContinue = "Continue",
	ButtonFinish = "Finish",
	ButtonClose = "Close",
	Complete = "Установка Завершена"
}

-- tutorial 1
L.Tutorial = {
	Step1Line1 = "This quick tutorial will show you some of the features in KkthnxUI.",
	Step1Line2 = "First, the essentials that you should know before you can play with this UI.",
	Step1Line3 = "This installer is partially character-specific. While some of the settings that will be applied later on are account-wide, you need to run the install script for each new character running KkthnxUI. The script is auto shown on every new character you log in with KkthnxUI installed for the first time. Also, the options can be found in /KkthnxUI/Config/Settings.lua for `Power` users or by typing /KkthnxUI in the game for `Friendly` users.",
	Step1Line4 = "A power user is a user of a personal computer who has the ability to use advanced features (ex: Lua editing) which are beyond the abilities of normal users. A friendly user is a normal user and is not necessarily capable of programming. It's recommended for them to use our in-game configuration tool (/KkthnxUI) for settings they want to be changed in KkthnxUI.",
	Step2Line1 = "KkthnxUI includes an embedded version of oUF (oUFKkthnxUI) created by Haste. This handles all of the unit frames on the screen, the buffs and debuffs, and the class-specific elements.",
	Step2Line2 = "You can visit wowinterface.com and search for oUF for more information about this tool.",
	Step2Line3 = "To easily change the unitframes positions, just type /moveui.",
	Step2Line4 = "",
	Step3Line1 = "KkthnxUI is a redesigned Blizzard UI. Nothing less, nothing more. Approxmently all features you see with Default UI is available though KkthnxUI. The only features not available through default UI are some automated features not really visible on screen, for example, auto selling grays when visiting a vendor or, auto sorting bags.",
	Step3Line2 = "Not everyone enjoys things like DPS meters, Boss mods, Threat meters, etc, we judge that it's the best thing to do. KkthnxUI is made around the idea to work for all classes, roles, specs, type of gameplay, a taste of the users, etc. This why KkthnxUI is one of the most popular UI at the moment. It fits everyone's play style and is extremely editable. It's also designed to be a good start for everyone that want to make their own custom UI without depending on add-ons. Since 2012 a lot of users have started using KkthnxUI as a base for their own UI.",
	Step3Line3 = "Users may want to visit our extra mods section on our website or by visiting www.wowinterface.com to install additional features or mods.",
	Step3Line4 = "",
	Step4Line1 = "To set how many bars you want, mouseover on left or right of bottom action bar background. Do the same on the right, via bottom. To copy text from the chat frame, click the button shown on mouseover in the right bottom corner of chat frames.",
	Step4Line2 = "You can left-click through 80% of data text to show various panels from Blizzard. Friend and Guild Datatext have right-clicked features as well.",
	Step4Line3 = "There are some dropdown menus available. Right-clicking on the [X] (Close) bag button will show bags. right-clicking the Minimap will show the micro menu.",
	Step4Line4 = "",
	Step5Line1 = "Lastly, KkthnxUI includes useful slash commands. Below is a list.",
	Step5Line2 = "/moveui allow you to move lots of the frames anywhere on the screen. /rl reloads the UI.",
	Step5Line3 = "/tt lets you whisper your target. /rc initiates a ready check. /rd disbands a party or raid. /ainv enable auto invite by whisper to you. (/ainv off) to turn it off",
	Step5Line4 = "/gm toggles the Help frame. /install or /tutorial loads this installer. ",
	Step6Line1 = "The tutorial is complete. You can choose to reconsult it at any time by typing /tutorial.",
	Step6Line2 = "I suggest you have a look through config/config.lua or type /KkthnxUI to customize the UI to your needs.",
	Step6Line3 = "You can now continue to install the UI if it's not done yet or if you want to reset to default!",
	Step6Line4 = "",
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

-- Mail Localization
L.Mail = {
	Complete = "Сбор почты завершен.",
	Messages = "сообщения",
	Need = "Нужен почтовый ящик.",
	Stopped = "Остановлено. Сумки полны.",
	Unique = "Остановлено. Найден дубликат предмета в сумках или банке."
}

-- World Map Localization
L.Map = {
	Fog = "Туман Войны"
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
	Armory = "Армори",
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
	AchievementComplete = "Ваш статус: Завершено на ",
	AchievementIncomplete = "Ваш статус: Незавершено",
	AchievementStatus = "Ваш статус:",
	ItemCount = "Количество предметов:",
	ItemID = "ID предмета:",
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
		"/ainv - Активаци автоматического приглашения.",
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