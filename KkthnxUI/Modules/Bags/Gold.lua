--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/Gold.lua
	Purpose:
		Track gold on every character on the account and show the running total in a
		tooltip on the bag and bank money text, alongside the Warband bank balance.
		The bank window also gets a small deposit and withdraw control for moving
		gold in and out of the Warband bank.
-----------------------------------------------------------------------------]]

local K, _, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Bags")
if not Module then
	return
end

local _G = _G
local ipairs = ipairs
local pairs = pairs
local tsort = table.sort
local floor = math.floor
local tonumber = tonumber
local format = string.format
local time = time

local GetMoney = GetMoney
local GetRealmName = GetRealmName
local UnitName = UnitName
local UnitClass = UnitClass
local UnitFactionGroup = UnitFactionGroup
local GetCoinTextureString = GetCoinTextureString
local CreateFrame = CreateFrame
local C_Bank = C_Bank
local Enum = Enum

local ACCOUNT = Enum.BankType and Enum.BankType.Account or 2

-- Account wide store, kept on the saved variable so every character sees the same
-- ledger. { chars = { [key] = { gold, class, faction, updated } }, warband = { gold, updated } }
local function DB()
	local root = _G.KkthnxUIDB
	if not root then
		return nil
	end
	root.goldTracker = root.goldTracker or { chars = {}, warband = nil }
	root.goldTracker.chars = root.goldTracker.chars or {}
	return root.goldTracker
end

local function CharKey()
	return UnitName("player") .. " - " .. GetRealmName()
end

-- Strip the realm off a stored key for a tidy tooltip name.
local function ShortName(key)
	return key:match("^(.-) %- ") or key
end

-- Record this character's gold, and the Warband balance when the API will answer.
function Module:CaptureGold()
	local db = DB()
	if not db then
		return
	end

	local _, class = UnitClass("player")
	db.chars[CharKey()] = {
		gold = GetMoney(),
		class = class,
		faction = UnitFactionGroup("player"),
		updated = time(),
	}

	if C_Bank and C_Bank.FetchDepositedMoney then
		local warband = C_Bank.FetchDepositedMoney(ACCOUNT)
		if warband and warband > 0 then
			db.warband = { gold = warband, updated = time() }
		end
	end
end

-- ---------------------------------------------------------------------------
-- Tooltip
-- ---------------------------------------------------------------------------

local function ClassColorHex(class)
	local color = class and (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)[class]
	if color then
		return format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
	end
	return "ffffffff"
end

local function ShowGoldTooltip(anchor)
	local db = DB()
	if not db then
		return
	end

	GameTooltip:SetOwner(anchor, "ANCHOR_RIGHT")
	GameTooltip:AddLine(L["Gold"], 1, 1, 1)
	GameTooltip:AddLine(" ")

	-- Sort characters by gold, richest first.
	local list, total = {}, 0
	for key, data in pairs(db.chars) do
		list[#list + 1] = { key = key, gold = data.gold or 0, class = data.class }
		total = total + (data.gold or 0)
	end
	tsort(list, function(a, b)
		return a.gold > b.gold
	end)

	for _, entry in ipairs(list) do
		GameTooltip:AddDoubleLine(
			"|c" .. ClassColorHex(entry.class) .. ShortName(entry.key) .. "|r",
			GetCoinTextureString(entry.gold), 1, 1, 1, 1, 1, 1
		)
	end

	if db.warband and db.warband.gold and db.warband.gold > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|cffffcc80" .. (L["Warband"]) .. "|r", GetCoinTextureString(db.warband.gold), 1, 1, 1, 1, 1, 1)
		total = total + db.warband.gold
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Total"], GetCoinTextureString(total), 1, 0.82, 0, 1, 1, 1)
	GameTooltip:Show()
end

-- Put an invisible mouse catcher over a money font string so it can carry the
-- tooltip, since a font string takes no mouse of its own.
function Module:AttachGoldTooltip(f)
	if not f or not f.Money or f.MoneyHover then
		return
	end
	local hover = CreateFrame("Button", nil, f)
	hover:SetPoint("TOPLEFT", f.Money, "TOPLEFT", -2, 2)
	hover:SetPoint("BOTTOMRIGHT", f.Money, "BOTTOMRIGHT", 2, -2)
	hover:SetScript("OnEnter", function(self)
		ShowGoldTooltip(self)
	end)
	hover:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	f.MoneyHover = hover
end

-- ---------------------------------------------------------------------------
-- Warband deposit and withdraw
-- ---------------------------------------------------------------------------

local function TransferSupported()
	return C_Bank and C_Bank.DoesBankTypeSupportMoneyTransfer and C_Bank.DoesBankTypeSupportMoneyTransfer(ACCOUNT)
end

-- Read the whole-gold amount typed into the box and hand back copper.
local function BoxCopper(box)
	local gold = tonumber(box:GetText())
	if not gold or gold <= 0 then
		return 0
	end
	return floor(gold) * 10000
end

function Module:AttachGoldControls(f)
	if not f or f.GoldControls or not TransferSupported() then
		return
	end

	local bar = CreateFrame("Frame", nil, f)
	bar:SetSize(200, 22)
	bar:SetPoint("BOTTOM", f, "BOTTOM", 0, 8)
	f.GoldControls = bar

	local box = CreateFrame("EditBox", nil, bar)
	box:SetSize(70, 20)
	box:SetPoint("LEFT", bar, "LEFT", 0, 0)
	box:SetAutoFocus(false)
	box:SetNumeric(true)
	box:SetMaxLetters(10)
	K.SetFont(box, 12, "")
	box:SetTextInsets(4, 4, 0, 0)
	box:SetScript("OnEscapePressed", box.ClearFocus)
	box:SetScript("OnEnterPressed", box.ClearFocus)
	K.SkinEditBox(box)

	local hint = box:CreateFontString(nil, "OVERLAY")
	K.SetFont(hint, 12, "")
	hint:SetPoint("RIGHT", box, "RIGHT", -4, 0)
	hint:SetTextColor(0.7, 0.6, 0.3)
	hint:SetText(L["Gold"])
	box:SetScript("OnTextChanged", function(self)
		hint:SetShown(self:GetText() == "")
	end)

	local deposit = CreateFrame("Button", nil, bar)
	deposit:SetSize(58, 20)
	deposit:SetPoint("LEFT", box, "RIGHT", 6, 0)
	deposit.Text = deposit:CreateFontString(nil, "OVERLAY")
	K.SetFont(deposit.Text, 12, K.FontOutlineStyle())
	deposit.Text:SetPoint("CENTER")
	deposit.Text:SetText(L["Deposit"])
	K.SkinButton(deposit)
	deposit:SetScript("OnClick", function()
		local copper = BoxCopper(box)
		if copper > 0 and C_Bank.DepositMoney and (not C_Bank.CanDepositMoney or C_Bank.CanDepositMoney(ACCOUNT)) then
			C_Bank.DepositMoney(ACCOUNT, copper)
			box:SetText("")
			box:ClearFocus()
		end
	end)

	local withdraw = CreateFrame("Button", nil, bar)
	withdraw:SetSize(58, 20)
	withdraw:SetPoint("LEFT", deposit, "RIGHT", 6, 0)
	withdraw.Text = withdraw:CreateFontString(nil, "OVERLAY")
	K.SetFont(withdraw.Text, 12, K.FontOutlineStyle())
	withdraw.Text:SetPoint("CENTER")
	withdraw.Text:SetText(L["Withdraw"])
	K.SkinButton(withdraw)
	withdraw:SetScript("OnClick", function()
		local copper = BoxCopper(box)
		if copper > 0 and C_Bank.WithdrawMoney and (not C_Bank.CanWithdrawMoney or C_Bank.CanWithdrawMoney(ACCOUNT)) then
			C_Bank.WithdrawMoney(ACCOUNT, copper)
			box:SetText("")
			box:ClearFocus()
		end
	end)
end
