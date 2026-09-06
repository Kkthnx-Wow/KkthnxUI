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
-- Warband money display (deposit and withdraw)
-- ---------------------------------------------------------------------------

-- A clickable Warband balance shown on the bank window while the Warband tab is
-- active. Left-click deposits, right-click withdraws, both through Blizzard's own
-- amount-entry popups (the same ones the stock bank uses), so nothing here does
-- protected money moves itself. It sits in the bottom bar to the left of the
-- character money, which stays a plain readout of your own gold.
local function ShowWarbandHint(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(L["Warband Bank"], 1, 1, 1)
	GameTooltip:AddLine(L["Left-click to deposit"], 0.7, 0.85, 1)
	GameTooltip:AddLine(L["Right-click to withdraw"], 0.7, 0.85, 1)
	GameTooltip:Show()
end

function Module:CreateWarbandMoney(f)
	if not f or f.WarbandMoney or not (C_Bank and C_Bank.FetchDepositedMoney) then
		return
	end

	local button = CreateFrame("Button", nil, f)
	button:SetSize(160, 16)
	button:SetPoint("BOTTOMRIGHT", f.Money, "BOTTOMLEFT", -16, 0)

	local text = button:CreateFontString(nil, "OVERLAY")
	K.SetFont(text, 12, K.FontOutlineStyle())
	text:SetPoint("RIGHT", button, "RIGHT", 0, 0)
	text:SetJustifyH("RIGHT")
	button.Text = text

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", function(_, btn)
		if btn == "RightButton" then
			StaticPopup_Hide("BANK_MONEY_DEPOSIT")
			StaticPopup_Show("BANK_MONEY_WITHDRAW", nil, nil, { bankType = ACCOUNT })
		else
			StaticPopup_Hide("BANK_MONEY_WITHDRAW")
			StaticPopup_Show("BANK_MONEY_DEPOSIT", nil, nil, { bankType = ACCOUNT })
		end
	end)
	button:SetScript("OnEnter", ShowWarbandHint)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	button:Hide()
	f.WarbandMoney = button
end

-- Refresh the Warband balance and only show it while the Warband tab is open.
function Module:UpdateWarbandMoney(f)
	if not f or not f.WarbandMoney then
		return
	end
	if self.bankType == ACCOUNT and C_Bank and C_Bank.FetchDepositedMoney then
		local amount = C_Bank.FetchDepositedMoney(ACCOUNT) or 0
		f.WarbandMoney.Text:SetText("|cffffcc80" .. L["Warband"] .. ":|r " .. GetCoinTextureString(amount))
		f.WarbandMoney:Show()
	else
		f.WarbandMoney:Hide()
	end
end
