local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local string_format = _G.string.format
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe

local C_Timer_NewTicker = _G.C_Timer.NewTicker
local C_WowTokenPublic_GetCurrentMarketPrice = _G.C_WowTokenPublic.GetCurrentMarketPrice
local C_WowTokenPublic_UpdateMarketPrice = _G.C_WowTokenPublic.UpdateMarketPrice
local EXPANSION_NAME7 = _G.EXPANSION_NAME7
local GameTooltip = _G.GameTooltip
local GetCurrencyInfo = _G.GetCurrencyInfo
local GetCurrencyListInfo = _G.GetCurrencyListInfo
local GetCurrencyListSize = _G.GetCurrencyListSize
local GetMoney = _G.GetMoney
local GetProfessions = _G.GetProfessions
local InCombatLockdown = _G.InCombatLockdown
local IsControlKeyDown = _G.IsControlKeyDown
local IsLoggedIn = _G.IsLoggedIn
local IsShiftKeyDown = _G.IsShiftKeyDown
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local PROFESSIONS_ARCHAEOLOGY = _G.PROFESSIONS_ARCHAEOLOGY
local PROFESSIONS_COOKING = _G.PROFESSIONS_COOKING
local TRACKING = _G.TRACKING
local UIErrorsFrame = _G.UIErrorsFrame

local myGold = {}
local Ticker
local IsProfit, IsSpent, IsSubTitle = 0, 0, 0

local function Currency(id, weekly, capped)
	local name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(id)
	if amount == 0 then
		return
	end

	if IsSubTitle == 1 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.InfoColor..PROFESSIONS_ARCHAEOLOGY)
	elseif IsSubTitle == 2 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.InfoColor..PROFESSIONS_COOKING)
	elseif IsSubTitle == 3 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.InfoColor.."Raid Seals")
	elseif IsSubTitle == 4 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.InfoColor..EXPANSION_NAME7)
	end
	IsSubTitle = 0
	if weekly then
		if discovered then
			GameTooltip:AddDoubleLine(name, string_format("%s |T%s:12:12:0:0:64:64:5:59:5:59:%d|t", REFORGE_CURRENT..": ".. amount.." - "..WEEKLY..": "..week.." / "..weekmax, tex, 12), 1, 1, 1, 1, 1, 1)
		end
	elseif capped then
		if discovered then
			GameTooltip:AddDoubleLine(name, string_format("%s |T%s:12:12:0:0:64:64:5:59:5:59:%d|t", amount.." / "..maxed, tex, 12), 1, 1, 1, 1, 1, 1)
		end
	else
		if discovered then
			GameTooltip:AddDoubleLine(name, string_format("%s |T%s:12:12:0:0:64:64:5:59:5:59:%d|t", amount, tex, 12), 1, 1, 1, 1, 1, 1)
		end
	end
end

function Module:CurrencyOnEnter()
	local _, _, archaeology, _, cooking = GetProfessions()

	GameTooltip:SetOwner(Module.CurrencyFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(Module.CurrencyFrame))
	GameTooltip:ClearLines()

	GameTooltip:AddLine("|cffffffff".."Character Info|r ".." (C)")
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(K.SystemColor.."Earned:|r", K.FormatMoney(IsProfit))
	GameTooltip:AddDoubleLine(K.SystemColor.."Spent:|r", K.FormatMoney(IsSpent))
	if IsProfit < IsSpent then
		GameTooltip:AddDoubleLine("Deficit:", K.FormatMoney(IsProfit - IsSpent), 1, 0, 0, 1, 1, 1)
	elseif (IsProfit - IsSpent) > 0 then
		GameTooltip:AddDoubleLine("Profit:", K.FormatMoney(IsProfit - IsSpent), 0, 1, 0, 1, 1, 1)
	end

	GameTooltip:AddLine(" ")

	local totalGold, totalHorde, totalAlliance = 0, 0, 0
	GameTooltip:AddLine(K.SystemColor.."Character")

	table_wipe(myGold)
	for k,_ in pairs(KkthnxUIData.gold[K.Realm]) do
		if KkthnxUIData.gold[K.Realm][k] then
			local class = KkthnxUIData.class[K.Realm][k] or "PRIEST"
			local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class] or RAID_CLASS_COLORS.PRIEST_COLOR
			table_insert(myGold,
			{
				name = k,
				amount = KkthnxUIData.gold[K.Realm][k],
				amountText = K.FormatMoney(KkthnxUIData.gold[K.Realm][k]),
				faction = KkthnxUIData.faction[K.Realm][k] or "",
				r = color.r, g = color.g, b = color.b,
			}
			)
		end

		if KkthnxUIData.faction[K.Realm][k] == "Alliance" then
			totalAlliance = totalAlliance + KkthnxUIData.gold[K.Realm][k]
		elseif KkthnxUIData.faction[K.Realm][k] == "Horde" then
			totalHorde = totalHorde + KkthnxUIData.gold[K.Realm][k]
		end

		totalGold = totalGold + KkthnxUIData.gold[K.Realm][k]
	end

	for _, g in ipairs(myGold) do
		local nameLine = ""
		if g.faction ~= "" and g.faction ~= "Neutral" then
			nameLine = string_format("|TInterface/FriendsFrame/PlusManz-%s:14|t ", g.faction)
		end

		nameLine = g.name == K.Name and nameLine..g.name..K.SystemColor.." <<|r" or nameLine..g.name

		GameTooltip:AddDoubleLine(nameLine, g.amountText, g.r, g.g, g.b, 1, 1, 1)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.SystemColor.."Server")
	if totalAlliance ~= 0 then
		GameTooltip:AddDoubleLine("Alliance: ", K.FormatMoney(totalAlliance), 0, .376, 1, 1, 1, 1)
	end
	if totalHorde ~= 0 then
		GameTooltip:AddDoubleLine("Horde: ", K.FormatMoney(totalHorde), 1, .2, .2, 1, 1, 1)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(K.SystemColor.."Total:|r ", K.FormatMoney(totalGold), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("|TInterface/ICONS/WoW_Token01:12:12:0:0:64:64:5:59:5:59|t WoW Token:", K.FormatMoney(C_WowTokenPublic_GetCurrentMarketPrice() or 0), 0, .8, 1, 1, 1, 1)

	local currencies = 0
	for i = 1, GetCurrencyListSize() do
		local name, _, _, _, watched, count, icon = GetCurrencyListInfo(i)
		if watched then
			if currencies == 0 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(K.InfoColor..TRACKING)
			end

			local r, g, b
			if count > 0 then
				r, g, b = 1, 1, 1
			else
				r, g, b = 0.5, 0.5, 0.5
			end

			GameTooltip:AddDoubleLine(name, string_format("%d |T%s:12:12:0:0:64:64:5:59:5:59:%d|t", count, icon, 12), r, g, b, r, g, b)
			currencies = currencies + 1
		end
	end

	if archaeology then
		IsSubTitle = 1
		Currency(384)	-- Dwarf Archaeology Fragment
		Currency(385)	-- Troll
		Currency(393)	-- Fossil
		Currency(394)	-- Night Elf
		Currency(397)	-- Orc
		Currency(398)	-- Draenei
		Currency(399)	-- Vrykul
		Currency(400)	-- Nerubian
		Currency(401)	-- Tol"vir
		Currency(676)	-- Pandaren
		Currency(677)	-- Mogu
		Currency(754)	-- Mantid
		Currency(821)	-- Draenor Clans
		Currency(828)	-- Ogre
		Currency(829)	-- Arakkoa
		Currency(1172)	-- Highborne
		Currency(1173)	-- Highmountain Tauren
		Currency(1174)	-- Demonic
		Currency(1534)	-- Zandalari
		Currency(1535)	-- Drust
	end

	if cooking then
		IsSubTitle = 2
		Currency(81)	-- Epicurean"s Award
		Currency(402)	-- Ironpaw Token
	end

	if K.Level == MAX_PLAYER_LEVEL then
		IsSubTitle = 3
		Currency(1580, false, true)	-- Seal of Wartorn Fate
	end

	do
		IsSubTitle = 4
		Currency(1560)	-- War Resources
		Currency(1710)	-- Seafarer"s Dubloon
		Currency(1716)	-- Honorbound Service Medal
		Currency(1717)	-- 7th Legion Service Medal
		Currency(1718)	-- Titan Residuum
		Currency(1721)	-- Prismatic Manapearl
		Currency(1719)	-- Corrupted Mementos
		Currency(1755)	-- Coalescing Visions
		Currency(1803)	-- Echoes of Ny"alotha
		Currency(515)	-- Darkmoon Prize Ticket
	end

	GameTooltip:Show()
end

function Module:CurrencyOnLeave()
	GameTooltip:Hide()
end

function Module:CurrencyOnEvent()
	if not IsLoggedIn() then
		return
	end

	if not Ticker then
		C_WowTokenPublic_UpdateMarketPrice()
		Ticker = C_Timer_NewTicker(60, C_WowTokenPublic_UpdateMarketPrice)
	end

	KkthnxUIData = KkthnxUIData or {}

	KkthnxUIData.gold = KkthnxUIData.gold or {}
	KkthnxUIData.gold[K.Realm] = KkthnxUIData.gold[K.Realm] or {}

	KkthnxUIData.class = KkthnxUIData.class or {}
	KkthnxUIData.class[K.Realm] = KkthnxUIData.class[K.Realm] or {}
	KkthnxUIData.class[K.Realm][K.Name] = K.Class

	KkthnxUIData.faction = KkthnxUIData.faction or {}
	KkthnxUIData.faction[K.Realm] = KkthnxUIData.faction[K.Realm] or {}
	KkthnxUIData.faction[K.Realm][K.Name] = K.Faction

	-- prevent an error possibly from really old profiles
	local IsReallyOldMoney = KkthnxUIData.gold[K.Realm][K.Name]
	if IsReallyOldMoney and type(IsReallyOldMoney) ~= "number" then
		KkthnxUIData.gold[K.Realm][K.Name] = nil
		IsReallyOldMoney = nil
	end

	local IsNewMoney = GetMoney()
	KkthnxUIData.gold[K.Realm][K.Name] = IsNewMoney

	local IsOldMoney = IsReallyOldMoney or IsNewMoney
	local IsChange = IsNewMoney - IsOldMoney -- Positive if we gain money
	if IsOldMoney > IsNewMoney then		-- Lost Money
		IsSpent = IsSpent - IsChange
	else							-- Gained Moeny
		IsProfit = IsProfit + IsChange
	end
end

function Module:CurrencyOnMouseUp(btn)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
		return
	end

	if btn == "LeftButton" then
		ToggleCharacter("PaperDollFrame")
	elseif btn == "RightButton" then
		if IsShiftKeyDown() then
			table_wipe(KkthnxUIData.gold)
			Module:CurrencyOnEvent()
			GameTooltip:Hide()
		elseif IsControlKeyDown() then
			IsProfit = 0
			IsSpent = 0
			GameTooltip:Hide()
		end
	end
end

function Module:CreateCurrencyDataText()
	if not C["DataText"].Currency then
		return
	end

	if not _G.CharacterMicroButton then
		return
	end

	Module.CurrencyFrame = CreateFrame("Button", "KKUI_CurrencyDataText", UIParent)
	Module.CurrencyFrame:SetSize(_G.CharacterMicroButton:GetWidth(), _G.CharacterMicroButton:GetHeight())
	Module.CurrencyFrame:SetFrameLevel(_G.CharacterMicroButton:GetFrameLevel() + 2)
	Module.CurrencyFrame:SetAllPoints(_G.CharacterMicroButton)

	-- Gold
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.CurrencyOnEvent)
	K:RegisterEvent("PLAYER_MONEY", Module.CurrencyOnEvent)
	K:RegisterEvent("SEND_MAIL_MONEY_CHANGED", Module.CurrencyOnEvent)
	K:RegisterEvent("SEND_MAIL_COD_CHANGED", Module.CurrencyOnEvent)
	K:RegisterEvent("PLAYER_TRADE_MONEY", Module.CurrencyOnEvent)
	K:RegisterEvent("TRADE_MONEY_CHANGED", Module.CurrencyOnEvent)
	K:RegisterEvent("CHAT_MSG_CURRENCY", Module.CurrencyOnEvent)
	K:RegisterEvent("CURRENCY_DISPLAY_UPDATE", Module.CurrencyOnEvent)

	Module.CurrencyFrame:SetScript("OnEvent", Module.CurrencyOnEvent)
	Module.CurrencyFrame:SetScript("OnMouseUp", Module.CurrencyOnMouseUp)
	Module.CurrencyFrame:SetScript("OnEnter", Module.CurrencyOnEnter)
	Module.CurrencyFrame:SetScript("OnLeave", Module.CurrencyOnLeave)
end