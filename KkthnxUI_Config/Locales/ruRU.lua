local ModuleNewFeature = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t]] -- Used for newly implemented features.

local _G = _G

_G.KkthnxUIConfig["ruRU"] = {
	-- Menu Groups Display Names
	["GroupNames"] = {
		-- Let's Keep This In Alphabetical Order, Shall We?
		["ActionBar"] = "Панели команд",
		["Announcements"] = "Оповещения",
		["Auras"] = "Ауры",
		["Automation"] = "Автоматизация",
		["Chat"] = "Чат",
		["DataBars"] = "Инфо-полосы",
		["DataText"] = "Инфо-текст",
		["Filger"] = "Кулдауны",
		["General"] = "Общее",
		["Inventory"] = "Сумки",
		["Loot"] = "Добыча",
		["Minimap"] = "Миникарта",
		["Misc"] = "Разное",
		["Nameplate"] = "Полосы здоровья",
		["Party"] = "Группа",
		["PulseCooldown"] = "Pulse Cooldown",
		["QuestNotifier"] = "Квесты",
		["Raid"] = "Рейд",
		["Skins"] = "Шкурки",
		["Tooltip"] = "Подсказка",
		["UIFonts"] = "Шрифты",
		["UITextures"] = "Текстуры",
		["Unitframe"] = "Рамки персонажей",
		["WorldMap"] = "Карта мира",
	},

	-- Actionbar Local
	["ActionBar"] = {
		["Cooldowns"] = {
			["Name"] = "Показывать кулдауны",
			["Desc"] = "Display cooldowns on the actionbars and other elements.",
		},

		["Count"] = {
			["Name"] = "Показывать кол-во предметов",
			["Desc"] = "Show how many of the item you have in your bags on the actionbars.",
		},

		["DecimalCD"] = {
			["Name"] = "Округлять кулдауны до целых чисел",
		},

		["DefaultButtonSize"] = {
			["Name"] = "Размер кнопок главной панели",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль Панелей команд",
		},

		["EquipBorder"] = {
			["Name"] = "Индикатор надетой вещи",
			["Desc"] = "Display a green border for items you have equipped and put onto your actionbar. |n|nFor example, on use trinkets you put onto your bars will show a green border.",
		},

		["FadeRightBar"] = {
			["Name"] = "Затенять Правую панель 1",
		},

		["FadeRightBar2"] = {
			["Name"] = "Затенять Правую панель 2",
		},

		["HideHighlight"] = {
			["Name"] = "Скрывать вспышку перезарядки заклинания",
		},

		["Hotkey"] = {
			["Name"] = "Показывать Горячие клавиши",
		},

		["Macro"] = {
			["Name"] = "Показывать имена макросов",
		},

		["MicroBar"] = {
			["Name"] = "Показывать Микропанель",
		},

		["MicroBarMouseover"] = {
			["Name"] = "Микропанель при наведении мыши",
		},

		["OverrideWA"] = {
			["Name"] = "Скрывать кулдауны в WeakAuras",
		},

		["RightButtonSize"] = {
			["Name"] = "Размер кнопок на Правой панели",
		},

		["StancePetSize"] = {
			["Name"] = "Размер кнопок на панелях стоек и пета",
		}
	},

	-- Announcements Local
	["Announcements"] = {
		["PullCountdown"] = {
			["Name"] = "Говорить отсчёт пулла (/pc #)",
		},

		["SaySapped"] = {
			["Name"] = "Сказать если на вас Ошеломление",
		},

		["Interrupt"] = {
			["Name"] = "Сказать о прерывании",
		},

		["RareAlert"] = {
			["Name"] = "Announce Rares, Chests & War Supplies",
		},

		["ItemAlert"] = {
			["Name"] = "Announce Items Being Placed",
		}
	},

	-- Automation Local
	["Automation"] = {
		["AutoCollapse"] = {
			["Name"] = "Скрывать список заданий",
		},

		["AutoDeclineDuels"] = {
			["Name"] = "Отклонять PVP-дуэли",
		},

		["AutoDeclinePetDuels"] = {
			["Name"] = "Отклонять битву питомцев",
		},

		["AutoInvite"] = {
			["Name"] = "Принимать приглашения от друзей и членов гильдии",
		},

		["AutoDisenchant"] = {
			["Name"] = "Автораспыление вещей при нажатии 'ALT'",
		},

		["AutoDungeonThanks"] = {
			["Name"] = "Auto Thank Dungeon Groups",
			["Desc"] = "This will auto thank your dungeon group members on completion of the dungeon",
		},

		["AutoQuest"] = {
			["Name"] = "Автоматически принимать и сдавать задания",
		},

		["AutoRelease"] = {
			["Name"] = "Выходить из тела на полях боя и аренах",
		},

		["AutoResurrect"] = {
			["Name"] = "Автоматически принимать запрос на воскрешение",
		},

		["AutoResurrectThank"] = {
			["Name"] = "Говорить 'Thank You' при воскрешении",
		},

		["AutoScreenshot"] = {
			["Name"] = "Скриншоты Достижений",
			["Desc"] = "Автоматически делать скриншот при получении Достижений."
		},

		["AutoReward"] = {
			["Name"] = "Автоматически выбирать награду за задания",
		},

		["AutoBlockStrangerInvites"] = {
			["Name"] = "Blocks Invites From Strangers",
			["Desc"] = "Declines all invites from anyone who is NOT a guild member or a friend on your friends list."
		},

		["AutoSetRole"] = {
			["Name"] = "Автоматически выбирать роль в группе",
		},

		["AutoTabBinder"] = {
			["Name"] = "По 'Tab' выбирать только враждебных игроков",
		},

		["BuffThanks"] = {
			["Name"] = "Благодарить за баффы (везде кроме инстов/рейдов)",
		},

		["BlockMovies"] = {
			["Name"] = "Блокировать ролики, которые вы уже смотрели",
		},

		["NoBadBuffs"] = {
			["Name"] = "Automatically Remove Annoying Buffs",
			["Desc"] = "This will automatically remove buffs like |cff0070dd[Lucille's Sewing Needle]|r"
		},

		["DeclinePvPDuel"] = {
			["Name"] = "Отклонять запросы на PVP-дуэли",
		},

		["WhisperInvite"] = {
			["Name"] = "Ключевое слово для приглашений",
			["Desc"] = "Если вам в приват напишут это слово, вы автоматически примете этого игрока в группу"
		},
	},

	-- Bags Local
	["Inventory"] = {
		["AutoSell"] = {
			["Name"] = "Автоматически продавать серое",
			["Desc"] = "При посещении торговца, весь серый лут будет автоматически продан.",
		},

		["BagBar"] = {
			["Name"] = "Показывать Панель сумок",
		},

		["BagBarMouseover"] = {
			["Name"] = "Панель сумок при наведении мыши",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль сумок",
			["Desc"] = "Включает/выключает модуль отображения сумок.",
		},

		["FilterJunk"] = {
			["Name"] = "Фильтровать Хлам",
			["Desc"] = "'Фильтрация предметов' должна быть включена",
		},

		["FilterMount"] = {
			["Name"] = "Фильтровать маунтов",
			["Desc"] = "'Фильтрация предметов' должна быть включена",
		},

		["ClassRelatedFilter"] = {
			["Name"] = "Фильтровать классовые предметы",
			["Desc"] = "'Фильтрация предметов' должна быть включена",
		},

		["ScrapIcon"] = {
			["Name"] = "Показывать иконку Хлама",
		},

		["UpgradeIcon"] = {
			["Name"] = "Показывать иконку улучшения предмета",
		},

		["QuestItemFilter"] = {
			["Name"] = "Фильтровать предметы для заданий",
			["Desc"] = "'Фильтрация предметов' должна быть включена",
		},

		["TradeGoodsFilter"] = {
			["Name"] = "Filter Trade/Goods Items",
			["Desc"] = "'Фильтрация предметов' должна быть включена",
		},

		["BagsWidth"] = {
			["Name"] = "Ячеек на строку в сумках",
		},

		["BankWidth"] = {
			["Name"] = "Ячеек на строку в банке",
		},

		["DeleteButton"] = {
			["Name"] = "Кнопка режима удаления",
		},

		["GatherEmpty"] = {
			["Name"] = "Собирать пустые ячейки в одну",
		},

		["IconSize"] = {
			["Name"] = "Размер иконки",
		},

		["ItemFilter"] = {
			["Name"] = "Фильтрация предметов",
		},

		["ItemSetFilter"] = {
			["Name"] = "Включить фильтр Предпочтений",
		},

		["ReverseSort"] = {
			["Name"] = "Обратная сортировка",
		},

		["ShowNewItem"] = {
			["Name"] = "Свечение вокруг новых предметов",
		},

		["BagsiLvl"] = {
			["Name"] = "Показывать уровень предметов",
			["Desc"] = "Показывает уровень на носимых предметах.",
		},

		["AutoRepair"] = {
			["Name"] = "Автоматический ремонт",
		},
	},

	-- Auras Local
	["Auras"] = {
		["BuffSize"] = {
			["Name"] = "Размер иконок баффов",
		},

		["BuffsPerRow"] = {
			["Name"] = "Количество баффов на строку",
		},

		["DebuffSize"] = {
			["Name"] = "Размер иконок дебаффов",
		},

		["DebuffsPerRow"] = {
			["Name"] = "Количество дебаффов на строку",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль аур",
		},

		["Reminder"] = {
			["Name"] = "Напоминания о баффах (Крик/Интеллект/Яды и т.д.)",
		},

		["ReverseBuffs"] = {
			["Name"] = "Рост баффов вправо",
		},

		["ReverseDebuffs"] = {
			["Name"] = "Рост дебаффов вправо",
		},

		["Statue"] = {
			["Name"] = "Показать статую |CFF00FF96Монаха|r",
		},

		["Totems"] = {
			["Name"] = "Показать панель Тотемов",
		},
	},

	-- Chat Local
	["Chat"] = {
		["ChatItemLevel"] = {
			["Name"] = "Показывать уровень предметов в чате",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль чата",
		},

		["EnableFilter"] = {
			["Name"] = "Включить фильтр чата",
		},

		["Fading"] = {
			["Name"] = "Скрывать чат при неактивности",
		},

		["FadingTimeFading"] = {
			["Name"] = "Длительность анимации скрытия",
		},

		["FadingTimeVisible"] = {
			["Name"] = "Время неактивности для скрытия",
		},

		["LootIcons"] = {
			["Name"] = "Show Chat Loot Icons",
			["Desc"] = "Displays a chat icon next to any loot you pick up in your chat window."
		},

		["OldChatNames"] = {
			["Name"] = "Use Default Channel Names",
		},

		["PhasingAlert"] = {
			["Name"] = "Phasing Chat Alerts",
			["Desc"] = "Everytime you phase of any sort. KkthnxUI will notify you of this in your chatframe."
		},

		["WhisperColor"] = {
			["Name"] = "Differ Whipser Colors",
		},

		["BlockStranger"] = {
			["Name"] = "Block Whispers From Strangers",
			["Desc"] = "If checked, only accept whispers from party or raid members, friends and guild members."
		},

		["BlockAddonAlert"] = {
			["Name"] = "Block Addon Alert",
		},

		["TabsMouseover"] = {
			["Name"] = "Имена вкладок при наведении мыши",
		},

		["TimestampFormat"] = {
			["Name"] = "Custom Chat Timestamps",
			["Desc"] = "Pick 4 different timestamps to display in your chat.",
		},

		["WhisperSound"] = {
			["Name"] = "Звук приватного сообщения",
		},

		["Background"] = {
			["Name"] = "Show Chat Background",
		},

		["FilterMatches"] = {
			["Name"] = "Filter Matches Number",
		},

	},

	-- Databars Local
	["DataBars"] = {
		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль инфо-полос",
		},

		["ExperienceColor"] = {
			["Name"] = "Цвет полосы Опыта",
		},

		["Height"] = {
			["Name"] = "Высота полос",
		},

		["HonorColor"] = {
			["Name"] = "Цвет полосы Чести",
		},

		["MouseOver"] = {
			["Name"] = "Полосы при наведении мыши",
		},

		["RestedColor"] = {
			["Name"] = "Цвет Отдыха на полосе опыта",
		},

		["Text"] = {
			["Name"] = "Показывать текст значений",
		},

		["TrackHonor"] = {
			["Name"] = "Показывать Честь",
		},

		["Width"] = {
			["Name"] = "Ширина полос",
		},

	},

	-- DataText Local
	["DataText"] = {
		["Battleground"] = {
			["Name"] = "Информация о полях боя",
		},

		["LocalTime"] = {
			["Name"] = "12-часовой формат времени",
		},

		["System"] = {
			["Name"] = "Показать FPS и задержку",
		},

		["Time"] = {
			["Name"] = "Показывать время на миникарте",
		},

		["Time24Hr"] = {
			["Name"] = "24-часовой формат времени",
		},
	},

	-- Filger Local
	["Filger"] = {
		["BuffSize"] = {
			["Name"] = "Размер иконок баффов",
		},

		["CooldownSize"] = {
			["Name"] = "Размер иконок кулдаунов",
		},

		["DisableCD"] = {
			["Name"] = "Выключить слежение за кулдаунами",
		},

		["DisablePvP"] = {
			["Name"] = "Выключить слежение в режиме PVP",
		},

		["Expiration"] = {
			["Name"] = "Сортировать по истекающему времени",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль кулдаунов",
			["Desc"] = "Filger is a very minimal buff/debuff tracking module that will allow you to track buffs/debuffs on yourself, target, etc, and also can be used to track cooldowns."
		},

		["MaxTestIcon"] = {
			["Name"] = "Максимум иконок в режиме Теста",
		},

		["PvPSize"] = {
			["Name"] = "Размер иконок в PvP",
		},

		["ShowTooltip"] = {
			["Name"] = "Показывать подсказки при наведении",
		},

		["TestMode"] = {
			["Name"] = "Режим Теста",
		},
	},

	-- General Local
	["General"] = {
		["AutoScale"] = {
			["Name"] = "Автоматический масштаб",
		},

		["ColorTextures"] = {
			["Name"] = "Раскрасить границы KkthnxUI",
		},

		["DisableTutorialButtons"] = {
			["Name"] = "Отключить кнопки обучения",
		},

		["FixGarbageCollect"] = { -- Перевести
			["Name"] = "Fix Garbage Collection",
		},

		["FontSize"] = {
			["Name"] = "Размер основного шрифта",
		},

		["HideErrors"] = {
			["Name"] = "Скрыть 'некоторые' ошибки интерфейса",
		},

		["LagTolerance"] = { -- Перевести
			["Name"] = "Auto Lag Tolerance",
		},

		["MoveBlizzardFrames"] = {
			["Name"] = "Двигать окна интерфейса",
		},

		["ReplaceBlizzardFonts"] = {
			["Name"] = "Заменить 'некоторые' шрифты игры",
		},

		["TexturesColor"] = {
			["Name"] = "Цвет текстур",
		},

		["Welcome"] = {
			["Name"] = "Показывать приветственное сообщение",
		},

		["VersionCheck"] = {
			["Name"] = "|cff00cc4c".."Включить проверку версии",
		},

		["NumberPrefixStyle"] = {
			["Name"] = "Стиль сокращений цифровых значений",
		},

		["PortraitStyle"] = {
			["Name"] = "Стиль портретов на рамках",
		},
	},

	-- Loot Local
	["Loot"] = {
		["AutoConfirm"] = {
			["Name"] = "Автоматические подтверждения в окнах диалогов",
		},

		["AutoGreed"] = {
			["Name"] = "Автоматически 'Не откажусь' на зеленые вещи",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль лута",
		},

		["FastLoot"] = {
			["Name"] = "Быстрый автолут",
		},

		["GroupLoot"] = {
			["Name"] = "|cff00cc4c".."Включить групповой лут",
		},
	},

	-- Minimap Local
	["Minimap"] = {
		["Calendar"] = {
			["Name"] = "Показать календарь",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль миникарты",
		},

		["ResetZoom"] = {
			["Name"] = "Сбрасывать увеличение",
		},

		["ResetZoomTime"] = {
			["Name"] = "Таймер сброса увеличения",
		},

		["ShowGarrison"] = {
			["Name"] = "Показать кнопку Гарнизона",
		},

		["ShowRecycleBin"] = {
			["Name"] = "Показать корзину с кнопками",
			["Desc"] = "Gather up all of your addon minimap buttons and put them into a frame at the bottom left corner of the minimap.",
		},

		["Size"] = {
			["Name"] = "Размер миникарты",
		},

		["BlipTexture"] = {
			["Name"] = "Blip Icon Styles",
			["Desc"] = "Change the minimap blip icons for nodes, party and so on.",
		},

		["LocationText"] = {
			["Name"] = "Location Text Style",
			["Desc"] = "Change settings for the display of the location text that is on the minimap.",
		},
	},

	-- Miscellaneous Local
	["Misc"] = {
		["AFKCamera"] = {
			["Name"] = "AFK режим",
		},

		["ColorPicker"] = {
			["Name"] = "Улучшенное окно выбора цвета интерфейса",
		},

		["EnhancedFriends"] = {
			["Name"] = "Улучшенные цвета (в окнах Друзей/Гильдии +)",
		},

		["GemEnchantInfo"] = {
			["Name"] = "Показывать зачарования в окне персонажа",
		},

		["ItemLevel"] = {
			["Name"] = "Показывать уровень предметов в окне персонажа",
		},

		["KillingBlow"] = {
			["Name"] = "Показывать инфо о финальном ударе",
		},

		["PvPEmote"] = {
			["Name"] = "Эмоция при убийстве другого игрока",
		},

		["ShowWowHeadLinks"] = {
			["Name"] = "Показывать ссылку на wowhead в окне заданий",
		},

		["SlotDurability"] = {
			["Name"] = "Показывать прочность вещей в окне персонажа",
		},

		["TradeTabs"] = {
			["Name"] = "Show TradeTabs",
			["Desc"] = "Add spellbook-like tabs to the TradeSkillFrame. It will add one for each of your professions and one for each of the profession 'suppliment' abilities (cooking, disenchant, etc)"
		},

		["EnchantmentScroll"] = {
			["Name"] = "Create Enchantment Scrolls With A Single Click"

		},

		["ImprovedStats"] = {
			["Name"] = "Display Character Frame Full Stats"

		},

		["NoTalkingHead"] = {
			["Name"] = "Remove And Hide The TalkingHead Frame"

		}
	},

	-- Nameplates Local
	["Nameplate"] = {
		["AKSProgress"] = {
			["Name"] = "Show AngryKeystones Progress",
		},

		["AuraSize"] = {
			["Name"] = "Auras Size",
		},

		["Distance"] = {
			["Name"] = "Nameplete MaxDistance",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль полос здоровья",
		},

		["ExplosivesScale"] = {
			["Name"] = "Scale Nameplates for Explosives",
		},

		["ClassIcon"] = {
			["Name"] = "Show Hostile Player ClassIcons",
		},

		["HealerIcon"] = {
			["Name"] = "Show Healer Icons In Arena/Battlegrounds",
		},

		["FullHealth"] = {
			["Name"] = "Show Health Value",
		},

		["HealthTextSize"] = {
			["Name"] = "HealthText FontSize",
		},

		["InsideView"] = {
			["Name"] = "Interacted Nameplate Stay Inside",
		},

		["MaxPowerGlow"] = {
			["Name"] = "Fully Charged Glow",
		},

		["MinAlpha"] = {
			["Name"] = "Non-Target Nameplate Alpha",
		},

		["HostileCC"] = {
			["Name"] = "Show Hostile ClassColor",
		},

		["FriendlyCC"] = {
			["Name"] = "Show Friendly ClassColor",
		},

		["DPSRevertThreat"] = {
			["Name"] = "Revert Threat Color If Not Tank",
		},

		["TankMode"] = {
			["Name"] = "Force TankMode Colored",
		},

		["CustomUnitColor"] = {
			["Name"] = "Colored Custom Units",
		},

		["MinScale"] = {
			["Name"] = "Non-Target Nameplate Scale",
		},

		["NameTextSize"] = {
			["Name"] = "NameText FontSize",
		},

		["NameplateClassPower"] = {
			["Name"] = "Target Nameplate ClassPower",
		},

		["PPHeight"] = {
			["Name"] = "Classpower/Healthbar Height",
		},

		["PPHideOOC"] = {
			["Name"] = "Only Visible in Combat",
		},

		["PPIconSize"] = {
			["Name"] = "PlayerPlate IconSize",
		},

		["PPPHeight"] = {
			["Name"] = "PlayerPlate Powerbar Height",
		},

		["PPPowerText"] = {
			["Name"] = "Show PlayerPlate Power Value",
		},

		["PlateHeight"] = {
			["Name"] = "Nameplate Height",
		},

		["PlateWidth"] = {
			["Name"] = "Nameplate Width",
		},

		["QuestIndicator"] = {
			["Name"] = "Quest Progress Indicator",
		},

		["ShowPlayerPlate"] = {
			["Name"] = "Show Pensonal Resource",
		},

		["VerticalSpacing"] = {
			["Name"] = "Nameplate Vertical Spacing",
		},

		["MaxAuras"] = {
			["Name"] = "Max Auras",
		},

		["TargetIndicator"] = {
			["Name"] = "TargetIndicator Style",
		},
	},

	-- Skins Local
	["Skins"] = {
		["ChatBubbles"] = {
			["Name"] = "Оформить облачка сообщений",
		},

		["DBM"] = {
			["Name"] = "DeadlyBossMods",
		},

		["Details"] = {
			["Name"] = "Details",
		},

		["Hekili"] = {
			["Name"] = "Hekili",
		},

		["Skada"] = {
			["Name"] = "Skada",
		},

		["TalkingHeadBackdrop"] = {
			["Name"] = "Show TalkingHead Backdrop",
		},

		["WeakAuras"] = {
			["Name"] = "WeakAuras",
		},
	},

	-- Unitframe Local
	["Unitframe"] = {
		["PlayerBuffs"] = {
			["Name"] = "Show Player Frame Buffs",
		},

		["PlayerDeBuffs"] = {
			["Name"] = "Show Player Frame Debuffs",
		},

		["TargetBuffs"] = {
			["Name"] = "Show Target Frame Buffs",
		},

		["TargetDebuffs"] = {
			["Name"] = "Show Target Frame Debuffs",
		},

		["AdditionalPower"] = {
			["Name"] = "Показывать дополнительный ресурс класса (|CFFFF7D0AДруид|r, |CFFFFFFFFЖрец|r, |CFF0070DEШаман|r)",
		},

		["CastClassColor"] = {
			["Name"] = "Полосы заклинаний по цвету класса",
		},

		["CastReactionColor"] = {
			["Name"] = "Полосы заклинаний по цвету реакции",
		},

		["CastbarLatency"] = {
			["Name"] = "Показывать задержку на полосе заклинаний",
		},

		["Castbars"] = {
			["Name"] = "|cff00cc4c".."Показывать полосы заклинаний",
		},

		["ClassResources"] = {
			["Name"] = "Показывать ресурс класса",
		},

		["Stagger"] = {
			["Name"] = "Show |CFF00FF96Monk|r Stagger Bar",
		},

		["PlayerPowerPrediction"] = {
			["Name"] = "Show Player Power Prediction",
		},

		["CombatFade"] = {
			["Name"] = "Показывать рамки только во время боя",
		},

		["CombatText"] = {
			["Name"] = "Текст боя по краям экрана",
		},

		["DebuffHighlight"] = {
			["Name"] = "Show Health Debuff Highlight",
		},

		["DebuffsOnTop"] = {
			["Name"] = "Показывать дебаффы цели сверху",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль рамок персонажей",
		},

		["GlobalCooldown"] = {
			["Name"] = "Показывать Глобальный Кулдаун",
		},

		["ResurrectSound"] = {
			["Name"] = "Sound Played When You Are Resurrected",
		},

		["HideTargetofTarget"] = {
			["Name"] = "Скрыть Цель Цели",
		},

		["OnlyShowPlayerDebuff"] = {
			["Name"] = "Показывать только ваши дебаффы",
		},

		["PlayerAuraBars"] = {
			["Name"] = "Показывать ваши баффы в виде полос, а не иконок",
		},

		["PlayerBuffs"] = {
			["Name"] = "Показывать баффы внизу рамки Игрока",
		},

		["PlayerCastbarHeight"] = {
			["Name"] = "Высота полосы заклинаний Игрока",
		},

		["PlayerCastbarWidth"] = {
			["Name"] = "Ширина полосы заклинаний Игрока",
		},

		["PortraitTimers"] = { --Перевести
			["Name"] = "Portrait Spell Timers",
		},

		["PvPIndicator"] = {
			["Name"] = "Показывать иконку PvP на Игроке/Цели",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Show HealPrediction Statusbars",
		},

		["ShowPlayerLevel"] = {
			["Name"] = "Показывать уровень игрока",
		},

		["ShowPlayerName"] = {
			["Name"] = "Показывать имя игрока",
		},

		["Smooth"] = {
			["Name"] = "Плавные полосы",
		},

		["Swingbar"] = {
			["Name"] = "Показывать полосу автоатак",
		},

		["SwingbarTimer"] = {
			["Name"] = "Таймер полосы автоатак",
		},

		["TargetAuraBars"] = {
			["Name"] = "Показывать баффы цели в виде полос, а не иконок",
		},

		["TargetCastbarHeight"] = {
			["Name"] = "Высота полосы заклинаний Цели",
		},

		["TargetCastbarWidth"] = {
			["Name"] = "Ширина полосы заклинаний Цели",
		},

		["TotemBar"] = {
			["Name"] = "Показывать панель тотемов",
		},

		["HealthbarColor"] = {
			["Name"] = "Формат цвета здоровья",
		},

		["PlayerHealthFormat"] = {
			["Name"] = "Формат значения здоровья Игрока",
		},

		["PlayerPowerFormat"] = {
			["Name"] = "Формат значения ресурса Игрока",
		},

		["TargetHealthFormat"] = {
			["Name"] = "Формат значения здоровья Цели",
		},

		["TargetPowerFormat"] = {
			["Name"] = "Формат значения ресурса Цели",
		},

		["TargetLevelFormat"] = {
			["Name"] = "Формат уровня Цели",
		},
	},

	-- Arena Local
	["Arena"] = {
		["Castbars"] = {
			["Name"] = "Показывать полосу заклинаний",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль арены",
		},

		["Smooth"] = {
			["Name"] = "Плавные полосы",
		},
	},

	-- Boss Local
	["Boss"] = {
		["Castbars"] = {
			["Name"] = "Показывать полосу заклинаний",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль боссов",
		},

		["Smooth"] = {
			["Name"] = "Плавные полосы",
		},
	},

	-- Party Local
	["Party"] = {
		["Castbars"] = {
			["Name"] = "Показывать полосу заклинаний",
		},

		["ShowTarget"] = {
			["Name"] = "Показывать цели группы",
		},

		["ShowPet"] = {
			["Name"] = "Показывать питомцев группы",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль группы",
		},

		["HorizonParty"] = {
			["Name"] = "Горизонтальное расположение группы",
		},

		["PortraitTimers"] = {
			["Name"] = "Portrait Spell Timers",
		},

		["ShowBuffs"] = {
			["Name"] = "Показывать баффы группы",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Show HealPrediction Statusbars",
		},

		["ShowPlayer"] = {
			["Name"] = "Показывать вас в группе",
		},

		["Smooth"] = {
			["Name"] = "Плавные полосы",
		},

		["TargetHighlight"] = {
			["Name"] = "Show Highlighted Target",
		},

		["HealthbarColor"] = {
			["Name"] = "Формат цвета здоровья",
		},

		["PartyHealthFormat"] = {
			["Name"] = "Формат значений здоровья",
		},

		["PartyPowerFormat"] = {
			["Name"] = "Формат значений ресурсов",
		},
	},

	["PulseCooldown"] = {
		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable PulseCooldown",
		},

		["HoldTime"] = {
			["Name"] = "How Long To Display",
		},

		["MinTreshold"] = {
			["Name"] = "Minimal Threshold Time",
		},

		["Size"] = {
			["Name"] = "Icon Size",
		},

		["Sound"] = {
			["Name"] = "Play Sound On Pulse",
		},
	},

	-- QuestNotifier Local
	["QuestNotifier"] = {
		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить список заданий",
		},

		["QuestProgress"] = {
			["Name"] = "Прогресс квеста в чат",
			["Desc"] = "Информирует о прогрессе заданий в чат группы. Спаммит, поэтому лучше не использовать в группе с незнакомцами!",
		},

		["OnlyCompleteRing"] = {
			["Name"] = "Only Complete Sound",
			["Desc"] = "Only play the complete sound at the end of completing the quest"
		},
	},

	-- Raidframe Local
	["Raid"] = {
		["SpecRaidPos"] = {
			["Name"] = "Save Raid Posions Based On Specs",
		},

		["ShowTeamIndex"] = {
			["Name"] = "Show Group Number Team Index",
		},

		["ReverseRaid"] = {
			["Name"] = "Reverse Raid Frame Growth",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Show HealPrediction Statusbars",
		},

		["HorizonRaid"] = {
			["Name"] = "Horizontal Raid Frames",
		},

		["NumGroups"] = {
			["Name"] = "Number Of Groups to Show",
		},

		["AuraDebuffIconSize"] = {
			["Name"] = "Размер иконок дебаффов",
		},

		["AuraWatch"] = { --Перевести
			["Name"] = "Show AuraWatch Icons",
		},

		["AuraDebuffs"] = {
			["Name"] = "Show AuraDebuff Icons",
		},

		["AuraWatchIconSize"] = { --Перевести
			["Name"] = "AuraWatch Icon Size",
		},

		["AuraWatchTexture"] = { --Перевести
			["Name"] = "Show Color AuraWatch Texture",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Включить модуль рейда",
		},

		["Height"] = {
			["Name"] = "Высота ячейки рейда",
		},

		["MainTankFrames"] = {
			["Name"] = "Показывать главных танков",
		},

		["ManabarShow"] = {
			["Name"] = "Показывать ману",
		},

		["MaxUnitPerColumn"] = {
			["Name"] = "Максимум ячеек на столбец",
		},

		["RaidUtility"] = {
			["Name"] = "Показывать окно управления рейдом",
		},

		["ShowGroupText"] = {
			["Name"] = "Показывать номер группы #",
		},

		["ShowNotHereTimer"] = {
			["Name"] = "Показывать статус 'отошел'",
		},

		["ShowRolePrefix"] = {
			["Name"] = "Показывать значки танков/лекарей",
		},

		["Smooth"] = {
			["Name"] = "Плавные полосы",
		},

		["TargetHighlight"] = {
			["Name"] = "Show Highlighted Target",
		},

		["Width"] = {
			["Name"] = "Ширина ячейки рейда",
		},

		["HealthbarColor"] = {
			["Name"] = "Формат цвета здоровья",
		},

		["RaidLayout"] = {
			["Name"] = "Раскладка рейда",
		},

		["GroupBy"] = {
			["Name"] = "Сортировка в рейде",
		},

		["HealthFormat"] = {
			["Name"] = "Формат значений здоровья",
		},
	},

	-- Worldmap Local
	["WorldMap"] = {
		["AlphaWhenMoving"] = {
			["Name"] = "Alpha When Moving",
		},

		["Coordinates"] = {
			["Name"] = "Показывать ваши и курсора координаты",
		},

		["FadeWhenMoving"] = {
			["Name"] = "Прозрачность карты при движении",
		},

		["MapScale"] = {
			["Name"] = "Масштаб карты",
		},

		["MapReveal"] = {
			["Name"] = "Убрать туман",
			["Desc"] = "Убирает туман с тех локаций где вы еще не были",
		},

		["PartyIconSize"] = {
			["Name"] = "Размер иконки группы",
			["Desc"] = "Adjust the size of player party icons on the world map",
		},

		["PlayerIconSize"] = {
			["Name"] = "Размер иконки игрока",
			["Desc"] = "Adjust the size of your player icon on the world map",
		},

		["WorldMapIcons"] = {
			["Name"] = "Worldmap Scale",
		},

		["SmallWorldMap"] = {
			["Name"] = "Показывать уменьшенную карту",
		},

		["WorldMapPlus"] = {
			["Name"] = "Показывать дополнительные значки на карте",
		},
	},

	-- Tooltip Local
	["Tooltip"] = {
		["AzeriteArmor"] = {
			["Name"] = "Show Azerite Tooltip Traits",
		},

		["ClassColor"] = {
			["Name"] = "Рамка по цвету качества",
		},

		["CombatHide"] = {
			["Name"] = "Скрывать подсказки в бою",
		},

		["Cursor"] = {
			["Name"] = "Возле курсора",
		},

		["FactionIcon"] = {
			["Name"] = "Показывать иконку фракции",
		},

		["HideJunkGuild"] = {
			["Name"] = "Сокращать имена гильдий",
		},

		["HideRank"] = {
			["Name"] = "Скрыть ранг в гильдии",
		},

		["HideRealm"] = {
			["Name"] = "Показывать имя сервера при зажатом SHIFT",
		},

		["HideTitle"] = {
			["Name"] = "Скрыть титулы",
		},

		["Icons"] = {
			["Name"] = "Показывать иконки предметов",
		},

		["ShowIDs"] = {
			["Name"] = "Показывать ID предметов",
		},

		["LFDRole"] = {
			["Name"] = "Показывать выбранную роль для подземелий",
		},

		["SpecLevelByShift"] = {
			["Name"] = "Показывать спек/уровень предметов при зажатом SHIFT",
		},

		["TargetBy"] = {
			["Name"] = "Показывать выбранную цель",
		},
	},

	-- Fonts Local
	["UIFonts"] = {
		["ActionBarsFonts"] = {
			["Name"] = "Панели команд",
		},

		["AuraFonts"] = {
			["Name"] = "Ауры",
		},

		["ChatFonts"] = {
			["Name"] = "Чат",
		},

		["DataBarsFonts"] = {
			["Name"] = "Инфо-полосы",
		},

		["DataTextFonts"] = {
			["Name"] = "Инфо-текст",
		},

		["FilgerFonts"] = {
			["Name"] = "Шрифт кулдаунов",
		},

		["GeneralFonts"] = {
			["Name"] = "Общее",
		},

		["InventoryFonts"] = {
			["Name"] = "Сумки",
		},

		["MinimapFonts"] = {
			["Name"] = "Миникарта",
		},

		["NameplateFonts"] = {
			["Name"] = "Полосы здоровья",
		},

		["QuestTrackerFonts"] = {
			["Name"] = "Список заданий",
		},

		["SkinFonts"] = {
			["Name"] = "Шкурки",
		},

		["TooltipFonts"] = {
			["Name"] = "Подсказка",
		},

		["UnitframeFonts"] = {
			["Name"] = "Рамки персонажей",
		},
	},

	-- Textures Local
	["UITextures"] = {
		["DataBarsTexture"] = {
			["Name"] = "Инфо-полосы",
		},

		["FilgerTextures"] = {
			["Name"] = "Кулдауны",
		},

		["GeneralTextures"] = {
			["Name"] = "Общее",
		},

		["LootTextures"] = {
			["Name"] = "Добыча",
		},

		["NameplateTextures"] = {
			["Name"] = "Полосы здоровья",
		},

		["QuestTrackerTexture"] = {
			["Name"] = "Список заданий",
		},

		["SkinTextures"] = {
			["Name"] = "Шкурки",
		},

		["TooltipTextures"] = {
			["Name"] = "Подсказка",
		},

		["UnitframeTextures"] = {
			["Name"] = "Рамки персонажей",
		},

		["HealPredictionTextures"] = {
			["Name"] = "Полоса отхила",
		},
	}
}
