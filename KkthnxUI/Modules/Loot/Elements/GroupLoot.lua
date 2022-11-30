local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Loot")

local _G = _G
local ipairs = _G.ipairs
local next = _G.next
local pairs = _G.pairs
local tonumber = _G.tonumber

local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local C_LootHistoryGetItem = _G.C_LootHistory.GetItem
local C_LootHistoryGetPlayerInfo = _G.C_LootHistory.GetPlayerInfo
local ChatEdit_InsertLink = _G.ChatEdit_InsertLink
local CreateFrame = _G.CreateFrame
local CursorOnUpdate = _G.CursorOnUpdate
local DressUpItemLink = _G.DressUpItemLink
local GREED = _G.GREED
local GameTooltip = _G.GameTooltip
local GameTooltip_ShowCompareItem = _G.GameTooltip_ShowCompareItem
local GetLootRollItemInfo = _G.GetLootRollItemInfo
local GetLootRollItemLink = _G.GetLootRollItemLink
local GetLootRollTimeLeft = _G.GetLootRollTimeLeft
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS
local IsControlKeyDown = _G.IsControlKeyDown
local IsModifiedClick = _G.IsModifiedClick
local IsShiftKeyDown = _G.IsShiftKeyDown
local NEED = _G.NEED
local PASS = _G.PASS
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local ROLL_DISENCHANT = _G.ROLL_DISENCHANT
local ResetCursor = _G.ResetCursor
local RollOnLoot = _G.RollOnLoot
local ShowInspectCursor = _G.ShowInspectCursor

local pos = "TOP"
local cancelled_rolls = {}
local cachedRolls = {}
local completedRolls = {}
local FRAME_WIDTH, FRAME_HEIGHT = 328, 26
local GroupLootTexture = K.GetTexture(C["General"].Texture)

Module.RollBars = {}

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local function HideTip()
	GameTooltip:Hide()
end

local function HideTip2()
	GameTooltip:Hide()
	ResetCursor()
end

local rolltypes = { [1] = "need", [2] = "greed", [3] = "disenchant", [0] = "pass" }
local function SetTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)

	if frame:IsEnabled() == 0 then
		GameTooltip:AddLine("|cffff3333" .. "Can't Roll")
	end

	for name, tbl in pairs(frame.parent.rolls) do
		if rolltypes[tbl[1]] == rolltypes[frame.rolltype] then
			local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[tbl[2]] or RAID_CLASS_COLORS[tbl[2]]
			GameTooltip:AddLine(name, classColor.r, classColor.g, classColor.b)
		end
	end

	GameTooltip:Show()
end

local function SetItemTip(frame)
	if not frame.link then
		return
	end

	GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(frame.link)

	if IsShiftKeyDown() then
		GameTooltip_ShowCompareItem()
	end

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor()
	else
		ResetCursor()
	end
end

local function ItemOnUpdate(self)
	if IsShiftKeyDown() then
		GameTooltip_ShowCompareItem()
	end

	CursorOnUpdate(self)
end

local function LootClick(frame)
	if IsControlKeyDown() then
		DressUpItemLink(frame.link)
	elseif IsShiftKeyDown() then
		ChatEdit_InsertLink(frame.link)
	end
end

local function OnEvent(frame, _, rollID)
	cancelled_rolls[rollID] = true

	if frame.rollID ~= rollID then
		return
	end

	frame.rollID = nil
	frame.time = nil
	frame:Hide()
end

local function StatusUpdate(frame, elapsed)
	if not frame.parent.rollID then
		return
	end

	if frame.elapsed and frame.elapsed > 0.5 then
		frame:SetValue(GetLootRollTimeLeft(frame.parent.rollID))
		frame.elapsed = 0
	else
		frame.elapsed = (frame.elapsed or 0) + elapsed
	end
end

local function CreateRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
	local f = CreateFrame("Button", nil, parent)
	f:SetPoint(...)
	f:SetSize(FRAME_HEIGHT - 4, FRAME_HEIGHT - 4)
	f:SetNormalTexture(ntex)

	if ptex then
		f:SetPushedTexture(ptex)
	end

	f:SetHighlightTexture(htex)
	f.rolltype = rolltype
	f.parent = parent
	f.tiptext = tiptext
	f:SetScript("OnEnter", SetTip)
	f:SetScript("OnLeave", HideTip)
	f:SetScript("OnClick", ClickRoll)
	f:SetMotionScriptsWhileDisabled(true)

	local txt = f:CreateFontString(nil, nil)
	txt:SetFontObject(K.UIFontOutline)
	txt:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)

	return f, txt
end

function Module:CreateRollFrame()
	local frame = CreateFrame("Frame", "KKUI_LootRollFrame", UIParent)
	frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	frame:CreateBorder()
	frame:SetScript("OnEvent", OnEvent)
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(10)
	frame:RegisterEvent("CANCEL_LOOT_ROLL")
	frame:Hide()

	local button = CreateFrame("Button", nil, frame)
	button:SetPoint("RIGHT", frame, "LEFT", -(2 * 3), 0)
	button:SetSize(FRAME_HEIGHT + 2, FRAME_HEIGHT)
	button:CreateBorder()
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", HideTip2)
	button:SetScript("OnUpdate", ItemOnUpdate)
	button:SetScript("OnClick", LootClick)
	frame.button = button

	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	local status = CreateFrame("StatusBar", nil, frame)
	status:SetAllPoints()
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetFrameLevel(status:GetFrameLevel() - 1)
	status:SetStatusBarTexture(GroupLootTexture)
	status:SetStatusBarColor(0.8, 0.8, 0.8, 0.9)
	status.parent = frame
	frame.status = status

	local spark = frame:CreateTexture(nil, "OVERLAY")
	spark:SetSize(128, FRAME_HEIGHT)
	spark:SetTexture(C["Media"].Textures.Spark128Texture)
	spark:SetBlendMode("ADD")
	status.spark = spark

	local need, needtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", "Interface\\Buttons\\UI-GroupLoot-Dice-Down", 1, NEED, "LEFT", frame.button, "RIGHT", 5, -1)
	local greed, greedtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Coin-Up", "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight", "Interface\\Buttons\\UI-GroupLoot-Coin-Down", 2, GREED, "LEFT", need, "RIGHT", 0, -1)
	local de, detext
	de, detext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-DE-Up", "Interface\\Buttons\\UI-GroupLoot-DE-Highlight", "Interface\\Buttons\\UI-GroupLoot-DE-Down", 3, ROLL_DISENCHANT, "LEFT", greed, "RIGHT", 0, -1)
	local pass, passtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", nil, "Interface\\Buttons\\UI-GroupLoot-Pass-Down", 0, PASS, "LEFT", de or greed, "RIGHT", 0, 2)
	frame.needbutt, frame.greedbutt, frame.disenchantbutt = need, greed, de
	frame.need, frame.greed, frame.pass, frame.disenchant = needtext, greedtext, passtext, detext

	local bind = frame:CreateFontString()
	bind:SetPoint("LEFT", pass, "RIGHT", 3, 1)
	bind:SetFontObject(K.UIFontOutline)
	frame.fsbind = bind

	local loot = frame:CreateFontString(nil, "ARTWORK")
	loot:SetFontObject(K.UIFontOutline)
	loot:SetPoint("LEFT", bind, "RIGHT", 0, 0)
	loot:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	loot:SetSize(200, 10)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

	frame.rolls = {}

	return frame
end

local function GetFrame()
	for _, f in ipairs(Module.RollBars) do
		if not f.rollID then
			return f
		end
	end

	local f = Module:CreateRollFrame()
	if pos == "TOP" then
		f:SetPoint("TOP", next(Module.RollBars) and Module.RollBars[#Module.RollBars] or _G.AlertFrameHolder, "BOTTOM", 0, -6)
	else
		f:SetPoint("BOTTOM", next(Module.RollBars) and Module.RollBars[#Module.RollBars] or _G.AlertFrameHolder, "TOP", 0, 6)
	end

	table.insert(Module.RollBars, f)

	return f
end

function Module:CANCEL_LOOT_ROLL(_, rollID)
	cancelled_rolls[rollID] = true

	for _, bar in next, Module.RollBars do
		if bar.rollID == rollID then
			bar.rollID = nil
			bar.time = nil
			bar:Hide()
			bar.button:UnregisterAllEvents()
		end
	end
end

function Module.START_LOOT_ROLL(_, rollID, time)
	if cancelled_rolls[rollID] then
		return
	end

	local f = GetFrame()
	f.rollID = rollID
	f.time = time

	for i in pairs(f.rolls) do
		f.rolls[i] = nil
	end

	f.need:SetText(0)
	f.greed:SetText(0)
	f.pass:SetText(0)
	f.disenchant:SetText(0)

	local texture, name, _, quality, bop, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)

	f.button.icon:SetTexture(texture)
	f.button.link = GetLootRollItemLink(rollID)

	if canNeed then
		f.needbutt:Enable()
	else
		f.needbutt:Disable()
	end

	if canGreed then
		f.greedbutt:Enable()
	else
		f.greedbutt:Disable()
	end

	if canDisenchant then
		f.disenchantbutt:Enable()
	else
		f.disenchantbutt:Disable()
	end

	local needTexture = f.needbutt:GetNormalTexture()
	local greenTexture = f.greedbutt:GetNormalTexture()
	local disenchantTexture = f.disenchantbutt:GetNormalTexture()
	needTexture:SetDesaturation(not canNeed)
	greenTexture:SetDesaturation(not canGreed)
	disenchantTexture:SetDesaturation(not canDisenchant)

	if canNeed then
		f.needbutt:SetAlpha(1)
	else
		f.needbutt:SetAlpha(0.2)
	end

	if canGreed then
		f.greedbutt:SetAlpha(1)
	else
		f.greedbutt:SetAlpha(0.2)
	end

	if canDisenchant then
		f.disenchantbutt:SetAlpha(1)
	else
		f.disenchantbutt:SetAlpha(0.2)
	end

	f.fsbind:SetText(bop and L["BoP"] or L["BoE"])
	f.fsbind:SetVertexColor(bop and 1 or 0.3, bop and 0.3 or 1, bop and 0.1 or 0.3)

	local color = ITEM_QUALITY_COLORS[quality]
	f.fsloot:SetText(name)
	f.status:SetStatusBarColor(color.r, color.g, color.b, 0.7)

	f.status:SetMinMaxValues(0, time)
	f.status:SetValue(time)

	f:SetPoint("CENTER", WorldFrame, "CENTER")
	f:Show()

	AlertFrame:UpdateAnchors()

	-- Add cached roll info, if any
	for rollid, rollTable in pairs(cachedRolls) do
		if f.rollID == rollid then -- rollid matches cached rollid
			for rollerName, rollerInfo in pairs(rollTable) do
				local rollType, class = rollerInfo[1], rollerInfo[2]
				f.rolls[rollerName] = { rollType, class }
				f[rolltypes[rollType]]:SetText(tonumber(f[rolltypes[rollType]]:GetText()) + 1)
			end

			completedRolls[rollid] = true
			break
		end
	end
end

function Module.LOOT_HISTORY_ROLL_CHANGED(_, itemIdx, playerIdx)
	local rollID = C_LootHistoryGetItem(itemIdx)
	local name, class, rollType = C_LootHistoryGetPlayerInfo(itemIdx, playerIdx)

	local rollIsHidden = true
	if name and rollType then
		for _, f in ipairs(Module.RollBars) do
			if f.rollID == rollID then
				f.rolls[name] = { rollType, class }
				f[rolltypes[rollType]]:SetText(tonumber(f[rolltypes[rollType]]:GetText()) + 1)
				rollIsHidden = false
				break
			end
		end

		-- History changed for a loot roll that hasn"t popped up for the player yet, so cache it for later
		if rollIsHidden then
			cachedRolls[rollID] = cachedRolls[rollID] or {}
			if not cachedRolls[rollID][name] then
				cachedRolls[rollID][name] = { rollType, class }
			end
		end
	end
end

function Module.LOOT_HISTORY_ROLL_COMPLETE()
	-- Remove completed rolls from cache
	for rollID in pairs(completedRolls) do
		cachedRolls[rollID] = nil
		completedRolls[rollID] = nil
	end
end
Module.LOOT_ROLLS_COMPLETE = Module.LOOT_HISTORY_ROLL_COMPLETE

function Module:CreateGroupLoot()
	if not C["Loot"].GroupLoot then
		return
	end

	K:RegisterEvent("LOOT_HISTORY_ROLL_CHANGED", self.LOOT_HISTORY_ROLL_CHANGED)
	K:RegisterEvent("LOOT_HISTORY_ROLL_COMPLETE", self.LOOT_HISTORY_ROLL_COMPLETE)
	K:RegisterEvent("CANCEL_LOOT_ROLL", self.CANCEL_LOOT_ROLL)
	K:RegisterEvent("START_LOOT_ROLL", self.START_LOOT_ROLL)
	K:RegisterEvent("LOOT_ROLLS_COMPLETE", self.LOOT_ROLLS_COMPLETE)

	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")
end

SlashCmdList.TESTROLL = function()
	local f = GetFrame()
	local items = { 32837, 34196, 33820 }
	if f:IsShown() then
		f:Hide()
	else
		local item = items[math.random(1, #items)]
		local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(item)
		local r, g, b = GetItemQualityColor(quality or 1)

		f.button.icon:SetTexture(texture)
		f.button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		f.fsloot:SetText(GetItemInfo(item))
		f.fsloot:SetVertexColor(1, 1, 1)

		f.status:SetMinMaxValues(0, 100)
		f.status:SetValue(math.random(50, 90))
		f.status:SetStatusBarColor(r, g, b, 0.7)

		f.KKUI_Border:SetVertexColor(r, g, b)
		f.button.KKUI_Border:SetVertexColor(r, g, b)

		f.need:SetText(0)
		f.greed:SetText(0)
		f.pass:SetText(0)

		f.button.link = "item:" .. item .. ":0:0:0:0:0:0:0"
		f:Show()
	end
end
SLASH_TESTROLL1 = "/kkroll"
