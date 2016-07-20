local Locale = GetLocale()

if (Locale ~= "ruRU") then
	return
end

-- AddonList Localization
L_ADDON_DISABLE_ALL = "Выключить все"
L_ADDON_ENABLE_ALL = "Включить все"
L_ADDON_LIST = "|cff2eb6ffСписок аддонов|r"
L_ADDON_RELOAD = "Перезагрузить"
-- Announce Localization
L_ANNOUNCE_INTERRUPTED = INTERRUPTED..": %s - \124cff71d5ff\124Hspell:%d\124h[%s]\124h\124r!"
L_ANNOUNCE_PC_ABORTED = "ОСТАНОВИТЬ АТАКУ!"
L_ANNOUNCE_PC_GO = "ВПЕРЕД!"
L_ANNOUNCE_PC_MSG = "Атаковать %s через %s.."
L_ANNOUNCE_FP_CAST = "%s применяет %s."
L_ANNOUNCE_FP_CLICK = "%s устанавливает %s. Кликните!"
L_ANNOUNCE_FP_PRE = "%s применяет %s."
L_ANNOUNCE_FP_PUT = "%s ставит %s."
L_ANNOUNCE_FP_STAT = "%s готовится %s - [%s]."
L_ANNOUNCE_FP_USE = "%s использует %s."
L_ANNOUNCE_SAPPED = "Ощеломление!"
L_ANNOUNCE_SAPPED_BY = "Ошеломлен от "
-- Automation Localization
L_SELL_TRASH = "Продано %d серых вещей за %s."
L_REPAIR_BANK = "Ремонт в счет гильдии за %s."
L_REPAIRED_FOR = "Экипировка отремонтированна за %s."
L_CANT_AFFORD_REPAIR = "Ремонт вам не по карману."
-- Bags Localization
L_BAG_BAGS_BIDS = "Использование сумок: "
L_BAG_BUY_BANKS_SLOT = "Купить банковскую ячейку (нужно чтобы банк был открыт)."
L_BAG_BUY_SLOTS = "Buy new slot with /bags purchase yes"
L_BAG_COSTS = "Стоимость: %.2f золотых."
L_BAG_NOTHING_SORT = "Нечего сортировать."
L_BAG_NO_SLOTS = "Нельзя купить больше ячеек."
L_BAG_OPEN_BANK = "Вам нужно сначала открыть банк."
L_BAG_SHOW_BAGS = "Показать сумки"
L_BAG_SORT = "Сортировать ваши сумки или банк, если они открыты."
L_BAG_SORTING_BAGS = "Сортировка завершена."
L_BAG_SORT_MENU = "Сортировать"
L_BAG_SORT_SPECIAL = "Сортировать Special"
L_BAG_STACK = "Собрать вещи в ваших сумках или банке, если они открыты."
L_BAG_STACK_END = "Сборка завершена."
L_BAG_STACK_MENU = "Собрать"
L_BAG_STACK_SPECIAL = "Собрать Special"
L_BAG_RIGHT_CLICK_SEARCH = "Клик правой клавишей мыши для поиска."
L_BAG_RIGHT_CLICK_CLOSE = "Клик правой клавишей мыши открывает меню."
L_BAG_SHOW_KEYRING = "Показать ключи"
-- Bindings Localization
L_BIND_BINDING = "Назначение"
L_BIND_CLEARED = "Сброшены все назначения для"
L_BIND_DISCARD = "Все новые назначения клавиш были сброшены."
L_BIND_INSTRUCT = "Наведите курсор на кнопку и назначьте клавишу. Нажмите ESC или щелкните правой кнопкой мыши, чтобы очистить назначение."
L_BIND_KEY = "Клавиша"
L_BIND_NO_SET = "Нет назначений"
L_BIND_SAVED = "Все назначения клавиш сохранены."
-- Chat Localization
L_CHAT_AFK = "[АФК]"
L_CHAT_BATTLEGROUND	= "ПБ"
L_CHAT_BATTLEGROUND_LEADER = "Лидер ПБ"
L_CHAT_DND = "[ДНД]"
L_CHAT_GUILD = "Г"
L_CHAT_OFFICER = "Оф."
L_CHAT_PARTY = "Гр"
L_CHAT_PARTY_LEADER = "Лидер гр."
L_CHAT_RAID = "Р"
L_CHAT_RAID_LEADER = "РЛ"
L_CHAT_RAID_WARNING = "Объявление"
L_CHAT_SAYS = "Говорит"
L_CHAT_WHISPER = "Шепчет"
L_CHAT_YELLS = "Кричит"
-- BigChat Localization
L_CHAT_BIGCHAT_OFF = "|cffffe02eУвеличенный чат|r: |cFFFF0000Выключен|r."
L_CHAT_BIGCHAT_ON = "|cffffe02eУвеличенный чат|r: |cFF008000Включен|r."
-- Class Localization
L_CLASS_HUNTER_CONTENT = "Ваш петомец доволен!"
L_CLASS_HUNTER_HAPPY = "Ваш петомец счастлив!"
L_CLASS_HUNTER_UNHAPPY = "Ваш петомец несчастлив!"
-- Datatext Localization
L_DATATEXT_ALTERAC = "Альтеракская долина"
L_DATATEXT_ANCIENTS = "Берег Древних"
L_DATATEXT_ARATHI = "Низина Арати"
L_DATATEXT_BASESASSAULTED = "Штурмы баз:"
L_DATATEXT_BASESDEFENDED = "Оборона баз:"
L_DATATEXT_DEMOLISHERSDESTROYED = "Разрушителей уничтожено:"
L_DATATEXT_EYE = "Око Бури"
L_DATATEXT_FLAGSCAPTURED = "Захваты флага:"
L_DATATEXT_FLAGSRETURNED = "Возвраты флага:"
L_DATATEXT_GATESDESTROYED = "Врат разрушено:"
L_DATATEXT_GRAVEYARDSASSAULTED = "Штурмы кладбищ:"
L_DATATEXT_GRAVEYARDSDEFENDED = "Оборона кладбищ:"
L_DATATEXT_ISLE = "Остров Завоеваний"
L_DATATEXT_MEMORY_CLEANED = "|cffffe02eОчищено:|r "
L_DATATEXT_TOWERSASSAULTED = "Штурмы башен:"
L_DATATEXT_TOWERSDEFENDED = "Оборона башен:"
L_DATATEXT_WARSONG = "Ущелье Песни Войны"
-- Exp/Rep Bar Localization
L_CURRENT_EXPERIENCE = "Текущий:"
L_CURRENT_REPUTATION = "Текущая:"
L_EXPERIENCE_BAR = "Опыт:"
L_REMAINING_EXPERIENCE = "Осталось:"
L_REMAINING_REPUTATION = "Осталось:"
L_REPUTATION_BAR = "Репутация:"
L_RESTED_EXPERIENCE = "Бодрость:"
L_STANDING_REPUTATION = "Отношение:"
-- In Combat Localization
L_ERR_NOT_IN_COMBAT = "Вы не можете сделать это в бою или во время смерти."
-- Autoinvite Localization
L_INVITE_ENABLE = "|cffffe02eАвтоприглашение|r: |cFF008000Включено|r: "
L_INVITE_DISABLE = "|cffffe02eАвтоприглашение|r: |cFFFF0000Выключено|r."
-- Info Localization
L_INFO_DISBAND = "Роспуск группы..."
L_INFO_DUEL = "Отклонен запрос дуэли от "
L_INFO_ERRORS = "Ошибок пока нет."
L_INFO_DUEL_DECLINE = "В данный момент я не принимаю дуэли."
L_INFO_INVITE = "Принято приглашение от "
L_INFO_NOT_INSTALLED = " не установлен."
L_INFO_SETTINGS_ALL = "Введите |cff2eb6ff/settings all|r|cffE8CB3B, чтобы применить настройки для всех поддерживаемых аддонов"
L_INFO_SETTINGS_BIGWIGS = "Введите |cff2eb6ff/settings bigwigs|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffBigwigs|r"
L_INFO_SETTINGS_BT4 = "Введите |cff2eb6ff/settings bartender4|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffBartender4|r"
L_INFO_SETTINGS_BUTTONFACADE = "Введите |cff2eb6ff/settings bfacade|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffButtonFacade|r"
L_INFO_SETTINGS_CHATCONSOLIDATE = "Введите |cff2eb6ff/settings chatfilter|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffChatConsolidate|r"
L_INFO_SETTINGS_CLASSCOLOR = "Введите |cff2eb6ff/settings color|r|cffE8CB3B, чтобы применить настройки |cff2eb6ff!ClassColor|r."
L_INFO_SETTINGS_CLASSTIMER = "Введите |cff2eb6ff/settings classtimer|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffClassTimer|r"
L_INFO_SETTINGS_MAPSTER = "Введите |cff2eb6ff/settings mapster|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffMapster|r"
L_INFO_SETTINGS_MSBT = "Введите |cff2eb6ff/settings msbt|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffMikScrollingBattleText|r"
L_INFO_SETTINGS_PLATES = "Введите |cff2eb6ff/settings nameplates|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffNameplates|r"
L_INFO_SETTINGS_SKADA = "Введите |cff2eb6ff/settings skada|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffSkada|r"
L_INFO_SETTINGS_THREATPLATES = "Необходимо изменить положение элементов |cff2eb6ffTidyPlates_ThreatPlates|r"
L_INFO_SETTINGS_XLOOT = "Введите |cff2eb6ff/settings xloot|r|cffE8CB3B, чтобы применить настройки |cff2eb6ffXLoot|r"
-- Loot Localization
L_LOOT_ANNOUNCE = "Объявить"
L_LOOT_CANNOT = "Cannot roll"
L_LOOT_CHEST = ">> Добыча из сундука"
L_LOOT_FISH = "Добыча с рыбалки"
L_LOOT_MONSTER = ">> Добыча из "
L_LOOT_RANDOM = "Случайный игрок."
L_LOOT_SELF = "Каждый сам за себя."
L_LOOT_TO_GUILD = " Гильдии"
L_LOOT_TO_PARTY = " Группе"
L_LOOT_TO_RAID = " Рейду"
L_LOOT_TO_SAY = " Сказать"
-- Mail Localization
L_MAIL_COMPLETE = "Сбор почты завершен."
L_MAIL_MESSAGES = "Сообщения."
L_MAIL_NEED = "Нужен почтовый ящик."
L_MAIL_STOPPED = "Остановлено. Сумки полны."
L_MAIL_UNIQUE = "Остановлено. Найден дубликат предмета в сумках или банке."
-- Map Localization
L_MAP_FARMMODE = "|cff2eb6ffРежим фарма|r"
-- FarmMode Minimap
L_MINIMAP_FARMMODE_ON = "|cffffe02eРежим фарма|r: |cFF008000Включен|r."
L_MINIMAP_FARMMODE_OFF = "|cffffe02eРежим фарма|r: |cFFFF0000Выключен|r."
-- Misc Localization
L_MISC_UI_OUTDATED = "Ваша версия |cff2eb6ffKkthnxUI|r устарела. Вы можете скачать последнюю версию с www.github.com/Kkthnx"
L_MISC_UNDRESS = "Снять"
-- Popup Localization
L_POPUP_ARMORY = "|cffE8CB3BАрмори|r"
L_POPUP_INSTALLUI = "|cff2eb6ffKkthnxUI|r впервые с этим персонажем. Вы должны перезагрузить пользовательский интерфейс, чтобы настроить его."
L_POPUP_RESETUI = "Вы уверены, что хотите сбросить все настройки |cff2eb6ffKkthnxUI|r?"
L_POPUP_RESTART_GFX = "|cffff0000ВНИМАНИЕ:|r Множественная выборка пользовательского интерфейса работает некорректно, границы могут быть нечеткими.|n|nИсправить это?"
L_POPUP_SETTINGS_ALL = "Применить настройки для всех поддерживаемых аддонов? |n|n|cff2eb6ffРекомендуется!|r"
L_POPUP_SETTINGS_BW = "Необходимо изменить положение элементов |cff2eb6ffBigWigs|r."
L_POPUP_SETTINGS_DBM = "Нам нужно изменить позицию баров |cff2eb6ffDBM|r."
L_POPUP_BOOSTUI = "|cffff0000ВНИМАНИЕ:|r Это позволит оптимизировать производительность за счет снижения уровня графики. Применяйте только если у вас возникли проблемы с |cffff0000FPS|r!|r"
L_POPUP_RELOADUI = "Установка завершена. Пожалуйста, нажмите кнопку 'Принять' для перезагрузки UI. Наслаждайтесь |cff2eb6ffKkthnxUI|r!|n|nПосетите мою страницу: |cff2eb6ffwww.github.com/kkthnx|r!"
-- Reputation Standing Localization
L_REPUTATION_EXALTED = "Превознесение"
L_REPUTATION_FRIENDLY = "Дружелюбие"
L_REPUTATION_HATED = "Ненависть"
L_REPUTATION_HONORED = "Уважение"
L_REPUTATION_HOSTILE = "Враждебность"
L_REPUTATION_NEUTRAL = "Равнодушие"
L_REPUTATION_REVERED = "Почтение"
L_REPUTATION_UNFRIENDLY = "Неприязнь"
-- Stats Localization
L_STATS_GLOBAL = "Глобальная задержка:"
L_STATS_HOME = "Локальная задержка:"
L_STATS_INC = "Входящий:"
L_STATS_OUT = "Исходящий:"
L_STATS_SYSTEMLEFT = "|cff2eb6ffЛКМ: Поиск подземелий|r"
L_STATS_SYSTEMRIGHT = "|cff2eb6ffПКМ: Очистить память|r"
-- Tooltip Localization
L_TOOLTIP_ACH_COMPLETE = "Ваш статус: завершено "
L_TOOLTIP_ACH_INCOMPLETE = "Ваш статус: незавершено"
L_TOOLTIP_ACH_STATUS = "Ваш статус:"
L_TOOLTIP_ITEM_COUNT = "Кол-во предметов:"
L_TOOLTIP_ITEM_ID = "ID предмета:"
L_TOOLTIP_LOADING = "Загрузка..."
L_TOOLTIP_NO_TALENT = "Нет талантов"
L_TOOLTIP_SPELL_ID = "ID заклинания:"
L_TOOLTIP_UNIT_DEAD = "|cffd94545Мертвый|r"
L_TOOLTIP_UNIT_GHOST = "|cff999999Призрак|r"
L_TOOLTIP_WHO_TARGET = "Является целью"
-- Total Memory Localization
L_TOTALMEMORY_USAGE = "Общее использование памяти:"
-- WowHead Link Localization
L_WATCH_WOWHEAD_LINK = "|cffE8CB3BСсылка на Wowhead|r"
-- Welcome Localization
L_WELCOME_LINE_1 = "Добро пожаловать в |cff2eb6ffKkthnxUI|r "
L_WELCOME_LINE_2_1 = ""
L_WELCOME_LINE_2_2 = "Введите |cff2eb6ff/uihelp|r или |cff2eb6ff/cfg|r для настройки интерфейса"
-- Slash Commands Localization
L_SLASHCMD_HELP = {
	"|cff2eb6ffДоступные команды:|r",
	"|cff2eb6ff/cfg|r - |cffE8CB3BОткрыть настройки|r |cff2eb6ffKkthnxUI|r.",
	"|cff2eb6ff/kb|r - |cffE8CB3BНазначение клавиш|r |cff2eb6ffKkthnxUI|r.",
	"|cff2eb6ff/align|r - |cffE8CB3BРазмерная сетка.",
	"|cff2eb6ff/bigchat|r - |cffE8CB3BУвеличение окна чата.",
	"|cff2eb6ff/clc, /clfix|r - |cffE8CB3BСброс журнала боя, при поломках.",
	"|cff2eb6ff/clearchat, /cc|r - |cffE8CB3BОчищает выбранное окно чата.",
	"|cff2eb6ff/clearquests, /clquests|r - |cffE8CB3BПолное удаление всех ваших заданий.",
	"|cff2eb6ff/dbmtest|r - |cffE8CB3BЗапустить проверку Deadly Boss Mods.",
	"|cff2eb6ff/farmmode|r - |cffE8CB3BУвеличение размера миникарты.",
	"|cff2eb6ff/frame|r - |cffE8CB3BПоказывает информацию о фрейме под курсором.",
	"|cff2eb6ff/fs|r - |cffE8CB3BПоказать Framestack. Полезно для разработчиков.",
	"|cff2eb6ff/gm|r - |cffE8CB3BОткрыть окно связи с ГМ'ом.",
	"|cff2eb6ff/moveui|r - |cffE8CB3BПозволяет перемещать элементы интерфейса.",
	"|cff2eb6ff/rc|r - |cffE8CB3BАктивирует проверку готовности.",
	"|cff2eb6ff/rd|r - |cffE8CB3BРаспустить группу или рейд.",
	"|cff2eb6ff/resetconfig|r - |cffE8CB3BСбросить настройки |cff2eb6ffKkthnxUI|r.",
	"|cff2eb6ff/resetui|r - |cffE8CB3BСброс общих настроек по умолчанию.",
	"|cff2eb6ff/rl|r - |cffE8CB3BПерезагрузить интерфейс.",
	"|cff2eb6ff/settings ADDON_NAME|r - |cffE8CB3BПриминение настроек для msbt, dbm, skada, или других аддонов.",
	"|cff2eb6ff/spec, /ss|r - |cffE8CB3BПереключение между ветками талантов.",
	"|cff2eb6ff/teleport|r - |cffE8CB3BТелепортация из случайного подземелья",
	"|cff2eb6ff/testa|r - |cffE8CB3BТест панелей оповещения Blizzard.",
	"|cff2eb6ff/toparty, /toraid, /convert|r - |cffE8CB3BПростой перевод группы в рейд.",
	"|cff2eb6ff/tt|r - |cffE8CB3BСообщение цели.",
	"|cff2eb6ff/pc|r - |cffE8CB3BАктивация обратного отсчета на запуск босса.",
}