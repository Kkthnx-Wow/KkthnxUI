local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local math_abs = _G.math.abs
local string_format = _G.string.format
local table_wipe = _G.table.wipe

local CURRENCY = _G.CURRENCY
local EXPANSION_NAME7 = _G.EXPANSION_NAME7
local GameTooltip = _G.GameTooltip
local GetCurrencyInfo = _G.GetCurrencyInfo
local GetCurrencyListInfo = _G.GetCurrencyListInfo
local GetCurrencyListSize = _G.GetCurrencyListSize
local GetMoney = _G.GetMoney
local GetProfessions = _G.GetProfessions
local InCombatLockdown = _G.InCombatLockdown
local IsLoggedIn = _G.IsLoggedIn
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local PROFESSIONS_ARCHAEOLOGY = _G.PROFESSIONS_ARCHAEOLOGY
local PROFESSIONS_COOKING = _G.PROFESSIONS_COOKING
local TOTAL = _G.TOTAL
local TRACKING = _G.TRACKING
local UIErrorsFrame = _G.UIErrorsFrame

local conf = {}
local t_icon = 12
local IsSubTitle = 0

local function ADDON_LOADED()
	if not KkthnxUIData then
		KkthnxUIData = {}
	end

	if not KkthnxUIData[K.Realm] then
		KkthnxUIData[K.Realm] = {}
	end

	if not KkthnxUIData[K.Realm][K.Name] then
		KkthnxUIData[K.Realm][K.Name] = {}
	end

	conf = KkthnxUIData[K.Realm][K.Name]
end

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
			GameTooltip:AddDoubleLine(name, string_format("%s |T%s:"..t_icon..":"..t_icon..":0:0:64:64:5:59:5:59:%d|t", REFORGE_CURRENT..": ".. amount.." - "..WEEKLY..": "..week.." / "..weekmax, tex, t_icon), 1, 1, 1, 1, 1, 1)
		end
	elseif capped then
		if discovered then
			GameTooltip:AddDoubleLine(name, string_format("%s |T%s:"..t_icon..":"..t_icon..":0:0:64:64:5:59:5:59:%d|t", amount.." / "..maxed, tex, t_icon), 1, 1, 1, 1, 1, 1)
		end
	else
		if discovered then
			GameTooltip:AddDoubleLine(name, string_format("%s |T%s:"..t_icon..":"..t_icon..":0:0:64:64:5:59:5:59:%d|t", amount, tex, t_icon), 1, 1, 1, 1, 1, 1)
		end
	end
end

local function OnEnter()
	local curgold = GetMoney()
	local _, _, archaeology, _, cooking = GetProfessions()
	conf.Gold = curgold

	GameTooltip:SetOwner(Module.CurrencyFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(Module.CurrencyFrame))
	GameTooltip:ClearLines()

	GameTooltip:AddLine("|cffffffff".."Character Info".."|r".." (C)")
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine(K.InfoColor..CURRENCY)
	GameTooltip:AddLine(" ")

	if Module.started ~= curgold then
		local gained = curgold > Module.started
		local color = gained and "|cff55ff55" or "|cffff5555"
		GameTooltip:AddDoubleLine("Session Gain/Loss", string_format("%s$|r %s %s$|r", color, K.FormatMoney(math_abs(Module.started - curgold)), color), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddLine(" ")
	end

	GameTooltip:AddLine(K.InfoColor.."Server Gold")

	local total = 0
	local goldTable = {}
	local charIndex = 0

	table_wipe(goldTable)

	for char, conf in pairs(KkthnxUIData[K.Realm]) do
		if conf.Gold and conf.Gold > 99 then
			charIndex = charIndex + 1
			goldTable[charIndex] = {
				char,
				K.FormatMoney(conf.Gold),
				conf.Gold
			}
		end
	end

	table.sort(goldTable, function(a, b)
		if (a and b) then
			return a[3] > b[3]
		end
	end)

	for _, v in ipairs(goldTable) do
		GameTooltip:AddDoubleLine(v[1], v[2], 1, 1, 1, 1, 1, 1)
		total = total + v[3]
	end

	GameTooltip:AddDoubleLine(" ", "-----------------", 1, 1, 1, 0.5, 0.5, 0.5)
	GameTooltip:AddDoubleLine(K.InfoColor..TOTAL, K.FormatMoney(total), nil, nil, nil, 1, 1, 1)
	GameTooltip:AddLine("-----------------", 0.5, 0.5, 0.5)

	local currencies = 0
	for i = 1, GetCurrencyListSize() do
		local name, _, _, _, watched, count, icon = GetCurrencyListInfo(i)
		if watched then
			if currencies == 0 then
				GameTooltip:AddLine(K.InfoColor..TRACKING)
			end

			local r, g, b
			if count > 0 then
				r, g, b = 1, 1, 1
			else
				r, g, b = 0.5, 0.5, 0.5
			end

			GameTooltip:AddDoubleLine(name, string_format("%d |T%s:"..t_icon..":"..t_icon..":0:0:64:64:5:59:5:59:%d|t", count, icon, t_icon), r, g, b, r, g, b)
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
		Currency(401)	-- Tol'vir
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
		Currency(81)	-- Epicurean's Award
		Currency(402)	-- Ironpaw Token
	end

	if K.Level == MAX_PLAYER_LEVEL then
		IsSubTitle = 3
		Currency(1580, false, true)	-- Seal of Wartorn Fate
	end

	do
		IsSubTitle = 4
		Currency(1560)	-- War Resources
		Currency(1710)	-- Seafarer's Dubloon
		Currency(1716)	-- Honorbound Service Medal
		Currency(1717)	-- 7th Legion Service Medal
		Currency(1718)	-- Titan Residuum
		Currency(1721)	-- Prismatic Manapearl
		Currency(1719)	-- Corrupted Mementos
		Currency(1755)	-- Coalescing Visions
		Currency(1803)	-- Echoes of Ny'alotha
		Currency(515)	-- Darkmoon Prize Ticket
	end

	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function OnMouseUp(_, button)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
		return
	end

	if button == "LeftButton" then
		ToggleCharacter("PaperDollFrame")
	elseif button == "RightButton" then
		ToggleCharacter("TokenFrame")
	end
end

local function OnEvent()
	if not IsLoggedIn() then
		return
	end

	conf.Gold = GetMoney()
end

function Module:CreateCurrencyDataText()
	if not C["DataText"].Currency then
		return
	end

	if not _G.CharacterMicroButton then
		return
	end

	K:RegisterEvent("ADDON_LOADED", ADDON_LOADED)

	self.started = GetMoney()

	Module.CurrencyFrame = CreateFrame("Button", "KKUI_CurrencyDataText", UIParent)
	Module.CurrencyFrame:SetSize(_G.CharacterMicroButton:GetWidth(), _G.CharacterMicroButton:GetHeight())
	Module.CurrencyFrame:SetFrameLevel(_G.CharacterMicroButton:GetFrameLevel() + 2)
	Module.CurrencyFrame:SetAllPoints(_G.CharacterMicroButton)

	-- Gold
	K:RegisterEvent("PLAYER_ENTERING_WORLD", OnEvent)
	K:RegisterEvent("PLAYER_MONEY", OnEvent)
	K:RegisterEvent("SEND_MAIL_MONEY_CHANGED", OnEvent)
	K:RegisterEvent("SEND_MAIL_COD_CHANGED", OnEvent)
	K:RegisterEvent("PLAYER_TRADE_MONEY", OnEvent)
	K:RegisterEvent("TRADE_MONEY_CHANGED", OnEvent)
	K:RegisterEvent("CHAT_MSG_CURRENCY", OnEvent)
	K:RegisterEvent("CURRENCY_DISPLAY_UPDATE", OnEvent)

	Module.CurrencyFrame:SetScript("OnEvent", OnEvent)
	Module.CurrencyFrame:SetScript("OnMouseUp", OnMouseUp)
	Module.CurrencyFrame:SetScript("OnEnter", OnEnter)
	Module.CurrencyFrame:SetScript("OnLeave", OnLeave)
end