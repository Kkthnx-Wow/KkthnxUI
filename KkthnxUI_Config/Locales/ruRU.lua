-- local MissingDesc = "The description for this module/setting is missing. Someone should really remind Kkthnx to do his job!"
local ModuleNewFeature = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t]] -- Used for newly implemented features.
-- local PerformanceIncrease = "|n|nDisabling this may slightly increase performance|r" -- For semi-high CPU options
-- local RestoreDefault = "|n|nRight-click to restore to default" -- For color pickers

local _G = _G

local REVERSE_NEW_LOOT_TEXT = _G.REVERSE_NEW_LOOT_TEXT

_G.KkthnxUIConfig["ruRU"] = {
	-- Menu Groups Display Names
	["GroupNames"] = {
		-- Let's Keep This In Alphabetical Order, Shall We?
		["ActionBar"] = "Панели команд",
		["Announcements"] = "Оповещения",
		["Arena"] = "Арена",
		["Auras"] = "Ауры",
		["Automation"] = "Автоматизация",
		["Boss"] = "Боссы",
		["Chat"] = "Чат",
		["DataBars"] = "Инфо-полосы",
		["DataText"] = "Инфо-текст",
		["Filger"] = "Кулдауны",
		["General"] = "Общее",
		["Inventory"] = "Сумки",
		["Loot"] = "Добыча",
		["Minimap"] = "Миникарта",
		["Misc"] = "Разное",
		["Nameplates"] = "Полосы здоровья",
		["Party"] = "Группа",
		["QuestNotifier"] = "Квесты",
		["Raid"] = "Рейд",
		["Skins"] = "Шкурки",
		["Tooltip"] = "Подсказка",
		["UIFonts"] = ModuleNewFeature.."Шрифты",
		["UITextures"] = ModuleNewFeature.."Текстуры",
		["Unitframe"] = "Рамки персонажей",
		["WorldMap"] = "Карта мира",
	},

	-- Actionbar Local
	["ActionBar"] = {
		["Cooldowns"] = {
			["Name"] = "Показывать кулдауны",
		},

		["Count"] = {
			["Name"] = "Показывать кол-во предметов",
		},

		["DecimalCD"] = {
			["Name"] = "Округлять кулдауны до целых чисел",
		},

		["DefaultButtonSize"] = {
			["Name"] = "Размер кнопок главной панели",
		},

		["DisableStancePages"] = {
			["Name"] = "Выключить панели стоек (Друид & Разбойник)",
		},

		["Enable"] = {
			["Name"] = "Включить модуль Панелей команд",
		},

		["EquipBorder"] = {
			["Name"] = "Индикатор надетой вещи",
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
		}
	},

	-- Automation Local
	["Automation"] = {
		["AutoBubbles"] = {
			["Name"] = "Выключать облачка сообщений",
			["Desc"] = "Автоматически выключает отображение облачков сообщений, если вы находитесь в подземелье/рейде."
		},

		["AutoCollapse"] = {
			["Name"] = "Скрывать список заданий",
		},

		["AutoInvite"] = {
			["Name"] = "Принимать приглашения от друзей и членов гильдии",
		},

		["AutoDisenchant"] = {
			["Name"] = "Автораспыление вещей при нажатии 'ALT'",
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

		["AutoReward"] = {
			["Name"] = "Автоматически выбирать награду за задания",
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
			["Name"] = "Включить модуль сумок",
			["Desc"] = "Включает/выключает модуль отображения сумок.",
		},

		["ClassRelatedFilter"] = {
			["Name"] = "Фильтровать классовые предметы",
		},

		["QuestItemFilter"] = {
			["Name"] = "Фильтровать предметы для заданий",
		},

		["TradeGoodsFilter"] = { --Перевести
			["Name"] = "Filter Trade/Goods Items",
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
			["Name"] = "Show New Item Glow",
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
			["Name"] = "Включить модуль аур",
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
	},

	-- Chat Local
	["Chat"] = {
		["Background"] = {
			["Name"] = "Показывать фон чата",
		},

		["BackgroundAlpha"] = {
			["Name"] = "Прозрачность фона",
		},

		["BlockAddonAlert"] = {
			["Name"] = "Блокировать ошибки аддонов",
		},

		["ChatItemLevel"] = {
			["Name"] = "Показывать уровень предметов в чате",
		},

		["Enable"] = {
			["Name"] = "Включить модуль чата",
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

		["Height"] = {
			["Name"] = "Высота чата",
		},

		["QuickJoin"] = { -- Перевести
			["Name"] = "Quick Join Messages",
			["Desc"] = "Show clickable Quick Join messages inside of the chat."
		},

		["ScrollByX"] = {
			["Name"] = "Скроллить на '#' строк",
		},

		["ShortenChannelNames"] = {
			["Name"] = "Короткие имена каналов",
		},

		["TabsMouseover"] = {
			["Name"] = "Имена вкладок при наведении мыши",
		},

		["WhisperSound"] = {
			["Name"] = "Звук приватного сообщения",
		},

		["Width"] = {
			["Name"] = "Ширина чата",
		},

	},

	-- Databars Local
	["DataBars"] = {
		["Enable"] = {
			["Name"] = "Включить модуль инфо-полос",
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
			["Name"] = "Показывать FPS/MS на миникарте",
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
			["Name"] = "Включить модуль кулдаунов",
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
			["Name"] = "Включить модуль лута",
		},

		["FastLoot"] = {
			["Name"] = "Быстрый автолут",
		},

		["GroupLoot"] = {
			["Name"] = "Включить групповой лут",
		},
	},

	-- Minimap Local
	["Minimap"] = {
		["Calendar"] = {
			["Name"] = "Показать календарь",
		},

		["Enable"] = {
			["Name"] = "Включить модуль миникарты",
		},

		["ResetZoom"] = {
			["Name"] = "Сбрасывать увеличение",
		},

		["ResetZoomTime"] = {
			["Name"] = "Таймер сброса увеличения",
		},

		["ShowRecycleBin"] = {
			["Name"] = "Показать корзину с кнопками",
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

		["AutoDismountStand"] = {
			["Name"] = "Автоматически встать/спешиться",
			["Desc"] = "Персонаж автоматически встанет или слезет с маунта если вы атакуете или применяете заклинание",
		},

		["ColorPicker"] = {
			["Name"] = "Улучшенное окно выбора цвета интерфейса",
		},

		["EnhancedFriends"] = {
			["Name"] = "Улучшенные цвета (в окнах Друзей/Гильдии +)",
		},

		["EnhancedMenu"] = {
			["Name"] = "Приглашение в гильдию по меню другого игрока",
		},

		["GemEnchantInfo"] = {
			["Name"] = "Показывать зачарования в окне персонажа",
		},

		["ImprovedProfessionWindow"] = {
			["Name"] = "Улучшенное окно Профессий",
		},

		["ImprovedQuestLog"] = {
			["Name"] = "Улучшение журнала заданий",
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

		["ShowHelmCloak"] = {
			["Name"] = "Показать кнопки 'плащ/шлем' в окне персонажа",
		},

		["ShowWowHeadLinks"] = {
			["Name"] = "Показывать ссылку на wowhead в окне заданий",
		},

		["SlotDurability"] = {
			["Name"] = "Показывать прочность вещей в окне персонажа",
		},
	},

	-- Nameplates Local
	["Nameplates"] = {
		["GoodColor"] = {
			["Name"] = "Цвет угрозы 'хорошо'",
		},

		["NearColor"] = {
			["Name"] = "Цвет угрозы 'опасность'",
		},

		["BadColor"] = {
			["Name"] = "Цвет угрозы 'срыв'",
		},

		["OffTankColor"] = {
			["Name"] = "Цвет угрозы для оффтанка",
		},

		["Clamp"] = {
			["Name"] = "Закрепить на экране",
			["Desc"] = "Закрепить полосы у краёв экрана, если цель за его пределами."
		},

		["ClassResource"] = {
			["Name"] = "Показывать классовые ресурсы (мана и т.д.)",
		},

		["Combat"] = {
			["Name"] = "Показывать полосы в бою",
		},

		["Enable"] = {
			["Name"] = "Включить модуль полос здоровья",
		},

		["HealthValue"] = {
			["Name"] = "Показывать количество здоровья",
		},

		["Height"] = {
			["Name"] = "Высота полос",
		},

		["NonTargetAlpha"] = {
			["Name"] = "Прозрачность невыбранных как Цель",
		},

		["OverlapH"] = {
			["Name"] = "Наложение горизонтальное",
		},

		["OverlapV"] = {
			["Name"] = "Наложение вертикальное",
		},

		["QuestInfo"] = {
			["Name"] = "Показывать значок квестовых мобов",
		},

		["SelectedScale"] = {
			["Name"] = "Масштаб Цели",
		},

		["Smooth"] = {
			["Name"] = "Плавные полосы",
		},

		["TankMode"] = {
			["Name"] = "Режим танка",
		},

		["Threat"] = {
			["Name"] = "Угроза на полосах",
		},

		["TrackAuras"] = {
			["Name"] = "Показывать баффы/дебаффы",
		},

		["Width"] = {
			["Name"] = "Высота полос",
		},

		["HealthbarColor"] = {
			["Name"] = "Формат цвета полос здоровья",
		},

		["LevelFormat"] = {
			["Name"] = "Формат уровня моба",
		},

		["TargetArrowMark"] = {
			["Name"] = "Стрелки на полосе Цели",
		},

		["HealthFormat"] = {
			["Name"] = "Формат значения здоровья",
		},

		["ShowEnemyCombat"] = { --Перевести
			["Name"] = "Show Enemy Combat",
		},

		["ShowFriendlyCombat"] = { --Перевести
			["Name"] = "Show Friendly Combat",
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

		["TalkingHeadBackdrop"] = {--Перевести (в Классике такой функции нет в общем-то)
			["Name"] = "Show TalkingHead Backdrop",
		},

		["WeakAuras"] = {
			["Name"] = "WeakAuras",
		},
	},

	-- Unitframe Local
	["Unitframe"] = {
		["AdditionalPower"] = {
			["Name"] = "Показывать ману друидов при смене формы",
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
			["Name"] = "Показывать полосы заклинаний",
		},

		["ClassResource"] = {
			["Name"] = "Показывать ресурсы класса (мана, ярость и т.д.)",
		},

		["CombatFade"] = {
			["Name"] = "Показывать рамки только во время боя",
		},

		["CombatText"] = {
			["Name"] = "Текст боя по краям экрана",
		},

		["DebuffHighlight"] = { --Перевести
			["Name"] = "Show Health Debuff Highlight",
		},

		["DebuffsOnTop"] = {
			["Name"] = "Показывать дебаффы цели сверху",
		},

		["Enable"] = {
			["Name"] = "Включить модуль рамок персонажей",
		},

		["EnergyTick"] = {
			["Name"] = "Показывать тики энергии (Друид / Разбойник)",
		},

		["GlobalCooldown"] = {
			["Name"] = "Показывать Глобальный Кулдаун",
		},

		["HideTargetofTarget"] = {
			["Name"] = "Скрыть Цель Цели",
		},

		["OnlyShowPlayerDebuff"] = {
			["Name"] = "Показывать только ваши дебаффы",
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
			["Name"] = "Show PvP Indicator on Player / Target",
		},

		["ShowHealPrediction"] = { --Перевести
			["Name"] = "Show HealPrediction Statusbars",
		},
		["ShowPetHappinessIcon"] = {
			["Name"] = "Показывать иконку Счастья у пета"..CreateTextureMarkup([[Interface\PetPaperDollFrame\UI-PetHappiness]], 128, 64, 16, 14, 0, 0.1875, 0, 0.359375, 0, 0),
		},

		["ShowPlayerLevel"] = {
			["Name"] = "Показывать ваш уровень",
		},

		["ShowPlayerName"] = {
			["Name"] = "Показывать ваше имя",
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
			["Name"] = "Включить модуль арены",
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
			["Name"] = "Включить модуль боссов",
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

		["Enable"] = {
			["Name"] = "Включить модуль группы",
		},

		["HorizonParty"] = {
			["Name"] = "Horizontal Party Frames",
		},

		["PortraitTimers"] = { --Перевести
			["Name"] = "Portrait Spell Timers",
		},

		["ShowBuffs"] = {
			["Name"] = "Показывать баффы группы",
		},

		["ShowHealPrediction"] = { --Перевести
			["Name"] = "Show HealPrediction Statusbars",
		},

		["ShowPlayer"] = {
			["Name"] = "Показывать вас в группе",
		},

		["Smooth"] = {
			["Name"] = "Плавные полосы",
		},

		["TargetHighlight"] = { --Перевести
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

	-- QuestNotifier Local
	["QuestNotifier"] = {
		["Enable"] = {
			["Name"] = "Включить список заданий",
		},

		["QuestProgress"] = {
			["Name"] = "Прогресс квеста в чат",
			["Desc"] = "Информирует о прогрессе заданий в чат группы. Спаммит, поэтому лучше не использовать в группе с незнакомцами!",
		},

		["OnlyCompleteRing"] = { --Перевести
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

		["AuraWatchIconSize"] = { --Перевести
			["Name"] = "AuraWatch Icon Size",
		},

		["AuraWatchTexture"] = { --Перевести
			["Name"] = "Show Color AuraWatch Texture",
		},

		["Enable"] = {
			["Name"] = "Включить модуль рейда",
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
			["Name"] = "Показывать вашу группу #",
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

		["TargetHighlight"] = { --Перевести
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
		["AlphaWhenMoving"] = { -- Нет применения в данной версии, MapFader ниже не то же самое?
			["Name"] = "Alpha When Moving",
		},

		["Coordinates"] = {
			["Name"] = "Показывать ваши и курсора координаты",
		},

		["MapFader"] = {
			["Name"] = "Прозрачность карты при движении",
		},

		["MapScale"] = {
			["Name"] = "Масштаб карты",
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
