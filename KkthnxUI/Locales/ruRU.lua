local K, C, L = unpack(select(2, ...))

-- Localization For ruRU Clients
if (GetLocale() ~= "ruRU") then
	return
end

L.AFKScreen = {
	NoGuild = "Нет гильдии"
}

L.Announce = {
	FPUse = "%s использует %s.",
	Interrupted = INTERRUPTED.." %s \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!",
	PCAborted = "ОСТАНОВИТЬ АТАКУ!",
	PCGo = "Вперед!",
	PCMessage = "Атаковать %s через %s..",
	Sapped = "Ошеломление!",
	SappedBy = "Ошеломление от: "
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

L.Bags = {
	RightClickClose = "ПКМ, чтобы открыть меню",
	RightClickSearch = "ПКМ для поиска",
	ShowBags = "Показать сумки",
	StackMenu = "Сложить"
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
	DND = "|cffe7e716[НБ]|r",
	Guild = "Г",
	GuildRecruitment = "Набор Гильдии",
	Instance = "П",
	InstanceLeader = "ЛП",
	LocalDefense = "Оборона",
	LookingForGroup = "Поиск Группы",
	Officer = "О",
	Party = "Г",
	PartyLeader = "Г",
	Raid = "Р",
	RaidLeader = "Р",
	RaidWarning = "ОР",
}

-- Configbutton Localization
L.ConfigButton = {
	Functions = "Buttonfunctions:",
	LeftClick = "Левый клик:",
	RightClick = "Правый клик:",
	MiddleClick = "Клик колесом:",
	ShiftClick = "Shift + клик:",
	MoveUI = "Режим перемещения элементов",
	Recount = "Показать/скрыть окно Recount",
	Skada = "Показать/скрыть окно Skada",
	Config = "Показать окно настроек KkthnxUI",
	Spec = "Показать меню выбора специализаций",
	SpecMenu = "Выбор специализации",
	SpecError = "Эта специализация уже активна!"
}

-- Cooldowns
L.Cooldowns = {
	Cooldowns = "CD: ",
	CombatRes = "BattleRes",
	CombatResRemainder = "Battle Resurrection: ",
	NextTime = "Next time: "
}

-- DataBars Localization
L.DataBars = {
	ArtifactClick = "Клик: Открывает обзор артефактов",
	ArtifactRemaining = "|cffe6cc80Осталось: %s|r",
	HonorLeftClick = "|cffccccccЛевый Клик: Открывает окно чести|r",
	HonorRightClick = "|cffccccccПравый Клик: Открывает окно талантов чести|r"
}

-- DataText Localization
L.DataText = {
	ArmError = "Could not get Call To Arms information.",
	AvoidAnceShort = "Avd: ",
	Bags = "Bags",
	Bandwidth = "Шир.Канала: ",
	BasesAssaulted = "Баз атаковано:",
	BasesDefended = "Баз защищено:",
	CartsControlled = "Carts Controlled:",
	CombatTime = "Combat/Arena Time",
	Coords = "Coords",
	DemolishersDestroyed = "Разрушителей уничтожено:",
	Download = "Загрузка: ",
	FlagsCaptured = "Флагов захвачено:",
	FlagsReturned = "Флагов возвращено:",
	FPS = "ФПС",
	GatesDestroyed = "Ворот уничтожено:",
	GoldDeficit = "Deficit: ",
	GoldEarned = "Earned: ",
	GoldProfit = "Profit: ",
	GoldServer = "Server: ",
	GoldSpent = "Spent: ",
	GoldTotal = "Total: ",
	GraveyardsAssaulted = "Кладбищ атаковано:",
	GraveyardsDefended = "Кладбищ защищено:",
	GuildNoGuild = "No Guild",
	LootSpecChange = "|cffFFFFFFRight Click:|r Change Loot Specialization|r",
	LootSpecShow = "|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI|r",
	LootSpecSpec = "Spec",
	LootSpecTalent = "|cffFFFFFFLeft Click:|r Change Talent Specialization|r",
	Memory = "Memory",
	MicroMenu = "MicroMenu",
	MS = "МС",
	NoDungeonArm = "No dungeons are currently offering a Call To Arms.",
	NoOrderHallUnlock = "You have not unlocked your OrderHall",
	NoOrderHallWO = "Orderhall+",
	OrbPossessions = "Orb Possessions:",
	OrderHall = "OrderHall",
	OrderHallReport = "Click: Open the OrderHall report",
	System = "System Stats: ",
	TotalBagSlots = "Total Bag Slots",
	TotalFreeBagSlots = "Free Bag Slots",
	TotalMemory = "Общее использование памяти:",
	TotalMemoryUsage = "Total Memory Usage",
	TotalUsedBagSlots = "Used Bag Slots",
	TowersAssaulted = "Башен атаковано:",
	TowersDefended = "Башен защищено:",
	VictoryPoints = "Очки победы:",
	Slots = {
		[1] = {1, INVTYPE_HEAD, 1000},
		[2] = {3, INVTYPE_SHOULDER, 1000},
		[3] = {5, INVTYPE_ROBE, 1000},
		[4] = {6, INVTYPE_WAIST, 1000},
		[5] = {9, INVTYPE_WRIST, 1000},
		[6] = {10, INVTYPE_HAND, 1000},
		[7] = {7, INVTYPE_LEGS, 1000},
		[8] = {8, INVTYPE_FEET, 1000},
		[9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
		[10] = {17, INVTYPE_WEAPONOFFHAND, 1000},
		[11] = {18, INVTYPE_RANGED, 1000}
	},
}

-- headers
L.Install = {
	Header1 = "Welcome",
	Header2 = "1. Essentials",
	Header3 = "2. Unitframes",
	Header4 = "3. Features",
	Header5 = "4. Things you should know!",
	Header6 = "5. Commands",
	Header7 = "6. Finished",
	Header8 = "1. Essential Settings",
	Header9 = "2. Social",
	Header10 = "3. Frames",
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
	Message1 = "Для технической поддержки посетите https://github.com/Kkthnx.",
	Message2 = "Вы можете переключать микроменю правой клавишей мыши на миникарте.",
	Message3 = "Вы можете быстро назначить клавиши введя команду /kb.",
	Message4 = "Рамку фокуса можно установить введя команду /focus когда выбрана нужная цель. Рекомендуется использовать макрос ждя этого.",
	Message5 = "Вы можете получить доступ к копии чата, наведя указатель мыши в правый нижний угол чата и нажав на появившуюся там кнопку.",
	Message6 = "Если у вас возникли проблемы с KkthnxUI попробуйте отключить все аддоны, кроме KkthnxUI. Помните, KkthnxUI - аддон заменяющий весь интерфейс, вы не можете использовать одновременно два аддона, которые делают тоже самое.",
	Message7 = "Для установки отображения каналов чата, щелкните правой клавишей мыши по вкладке чата и перейдите в настройки.",
	Message8 = "Вы можете использовать команду /resetui для полного сброса позиций всех элементов. Вы так же можете ввести команду /moveui и сбросить позицию нужного элемента щелчком правой клавиши мыши по нему.",
	Message9 = "Для перемещения способностей на панелях команды удерживайте клавишу Shift. Вы моежете изменить клавишу-модификатор в настройках Панелей команд.",
	Message10 = "Вы можете включить отображение среднего уровня предметов на всплывающих подсказках в меню настроек."
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
	SettingsAbu = "Введите /settings abu, для применения настроек oUF_Abu.",
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
	CopperShort = "|cffeda55fм|r",
	GoldShort = "|cffffd700з|r",
	SilverShort = "|cffc7c7cfс|r",
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
	ResetDataText = "Are you sure you want to reset all datatexts to default?",
	ResetUI = "Вы уверены, что хотите сбросить все настройки |cff3c9bedKkthnxUI|r?",
	ResolutionChanged = "Мы обнаружили изменение разрешения в вашем клиенте World of Warcraft. Мы НАСТОЯТЕЛЬНО РЕКОМЕНДУЕМ перезагрузить игру. Хотите продолжить?",
	SettingsAll = "|cffff0000ВНИМАНИЕ|r |n|nЭто применит настройки ко всем аддонам поддерживаемым |cff3c9bedKkthnxUI|r. Ничего не произойдет, если у вас нет ни одного поддерживаемого аддона.",
	SettingsBW = "Need to change the position of elements BigWigs.",
	SettingsDBM = "Нам нужно изменить позицию баров |cff3c9bedDBM|r.",
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
	InspectOpen = "Открыто окно осмотра",
	ItemCount = "Количество предметов:",
	ItemID = "ID предмета:",
	Loading = "Загрузка...",
	NoTalents = "Нет талантов",
	SpellID = "ID заклинания:"
}

L.WatchFrame = {
	WowheadLink = "Ссылка Wowhead"
}

L.Welcome = {
	Line1 = "Добро пожаловать в |cff3c9bedKkthnxUI|r v",
	Line2 = "",
	Line3 = "Введите /cfg для настройки интерфейса, или посетите www.github.com/kkthnx|r",
	Line4 = "",
	Line5 = "Некоторые ваши вопросы могут быть решены путем ввода команды /uihelp"
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
		"/pulsecd - Тест опции отображения времени перезарядки.",
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