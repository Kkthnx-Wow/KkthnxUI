local K, C, L = unpack(select(2, ...))
if C.Loot.GroupLoot ~= true then return end


-- Based on teksLoot(by Tekkub)
local pos = "TOP"
local frames = {}
local cancelled_rolls = {}
local rolltypes = {"need", "greed", "disenchant", [0] = "pass"}
local Movers = K.Movers

local LootRollAnchor = CreateFrame("Frame", "LootRollAnchor", UIParent)
LootRollAnchor:SetSize(314, 26)

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local function HideTip() GameTooltip:Hide() end
local function HideTip2() GameTooltip:Hide() ResetCursor() end

local function SetTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)
	if frame:IsEnabled() == 0 then GameTooltip:AddLine("|cffff3333"..LOOT_ROLL_INELIGIBLE_REASON1) end
	for name, tbl in pairs(frame.parent.rolls) do
		if rolltypes[tbl[1]] == rolltypes[frame.rolltype] then
			local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[tbl[2]] or RAID_CLASS_COLORS[tbl[2]]
			GameTooltip:AddLine(name, classColor.r, classColor.g, classColor.b)
		end
	end
	GameTooltip:Show()
end

local function SetItemTip(frame)
	if not frame.link then return end
	GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(frame.link)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
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

local function OnEvent(frame, event, rollID)
	cancelled_rolls[rollID] = true
	if frame.rollID ~= rollID then return end

	frame.rollID = nil
	frame.time = nil
	frame:Hide()
end

local function StatusUpdate(frame)
	if not frame.parent.rollID then return end
	local t = GetLootRollTimeLeft(frame.parent.rollID)
	local perc = t / frame.parent.time
	frame.spark:SetPoint("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0)
	frame:SetValue(t)

	if t > 1000000000 then
		frame:GetParent():Hide()
	end
end

local function CreateRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
	local f = CreateFrame("Button", nil, parent)
	f:SetPoint(...)
	f:SetSize(28, 28)
	f:SetNormalTexture(ntex)
	if ptex then f:SetPushedTexture(ptex) end
	f:SetHighlightTexture(htex)
	f.rolltype = rolltype
	f.parent = parent
	f.tiptext = tiptext
	f:SetScript("OnEnter", SetTip)
	f:SetScript("OnLeave", HideTip)
	f:SetScript("OnClick", ClickRoll)
	f:SetMotionScriptsWhileDisabled(true)
	local txt = f:CreateFontString(nil, nil)
	txt:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	txt:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)
	return f, txt
end

local function CreateRollFrame()
	local frame = CreateFrame("Frame", nil, UIParent)
	K.CreateBorder(frame, -1)
	frame:SetBackdrop(K.BorderBackdropTwo)
	frame:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
	frame:SetSize(280, 22)
	frame:SetScript("OnEvent", OnEvent)
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(10)
	frame:RegisterEvent("CANCEL_LOOT_ROLL")
	frame:Hide()

	local button = CreateFrame("Button", nil, frame)
	button:SetPoint("RIGHT", frame, "LEFT", -(2 * 4), 0)
	button:SetSize(28 - (2 * 3), 28 - (2 * 3))
	K.CreateBorder(button, -1)
	button:SetBackdrop(K.BorderBackdropTwo)
	button:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", HideTip2)
	button:SetScript("OnUpdate", ItemOnUpdate)
	button:SetScript("OnClick", LootClick)
	frame.button = button

	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	local status = CreateFrame("StatusBar", nil, frame)
	status:SetSize(326, 20)
	status:SetPoint("TOPLEFT", 0, 0)
	status:SetPoint("BOTTOMRIGHT", 0, 0)
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetFrameLevel(status:GetFrameLevel() - 1)
	status:SetStatusBarTexture(C.Media.Texture)
	status:SetStatusBarColor(0.8, 0.8, 0.8, 0.9)
	status.parent = frame
	frame.status = status

	status.bg = status:CreateTexture(nil, "BACKGROUND")
	status.bg:SetAlpha(0.1)
	status.bg:SetAllPoints()
	status.bg:SetDrawLayer("BACKGROUND", 2)
	local spark = frame:CreateTexture(nil, "OVERLAY")
	spark:SetSize(14, frame:GetHeight() * 1.6)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	status.spark = spark

	local need, needtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", "Interface\\Buttons\\UI-GroupLoot-Dice-Down", 1, NEED, "LEFT", frame.button, "RIGHT", 5, -1)
	local greed, greedtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Coin-Up", "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight", "Interface\\Buttons\\UI-GroupLoot-Coin-Down", 2, GREED, "LEFT", need, "RIGHT", 0, -1)
	local de, detext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-DE-Up", "Interface\\Buttons\\UI-GroupLoot-DE-Highlight", "Interface\\Buttons\\UI-GroupLoot-DE-Down", 3, ROLL_DISENCHANT, "LEFT", greed, "RIGHT", 0, -1)
	local pass, passtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", nil, "Interface\\Buttons\\UI-GroupLoot-Pass-Down", 0, PASS, "LEFT", de or greed, "RIGHT", 0, 2.2)
	frame.needbutt, frame.greedbutt, frame.disenchantbutt = need, greed, de
	frame.need, frame.greed, frame.pass, frame.disenchant = needtext, greedtext, passtext, detext

	local bind = frame:CreateFontString()
	bind:SetPoint("LEFT", pass, "RIGHT", 3, 1)
	bind:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	frame.fsbind = bind

	local loot = frame:CreateFontString(nil, "ARTWORK")
	loot:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	loot:SetPoint("LEFT", bind, "RIGHT", 0, 0)
	loot:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	loot:SetSize(200, 10)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

	frame.rolls = {}

	return frame
end

local function GetFrame()
	for i, f in ipairs(frames) do
		if not f.rollID then return f end
	end

	local f = CreateRollFrame()
	if pos == "TOP" then
		f:SetPoint("TOPRIGHT", next(frames) and frames[#frames] or LootRollAnchor, "BOTTOMRIGHT", next(frames) and 0 or -2, next(frames) and -7 or -5)
	else
		f:SetPoint("BOTTOMRIGHT", next(frames) and frames[#frames] or LootRollAnchor, "TOPRIGHT", next(frames) and 0 or -2, next(frames) and 7 or 5)
	end
	table.insert(frames, f)
	return f
end

local function FindFrame(rollID)
	for _, f in ipairs(frames) do
		if f.rollID == rollID then return f end
	end
end

local typemap = {[0] = "pass", "need", "greed", "disenchant"}
local function UpdateRoll(i, rolltype)
	local num = 0
	local rollID, itemLink, numPlayers, isDone = C_LootHistory.GetItem(i)

	if isDone or not numPlayers then return end

	local f = FindFrame(rollID)
	if not f then return end

	for j = 1, numPlayers do
		local name, class, thisrolltype = C_LootHistory.GetPlayerInfo(i, j)
		f.rolls[name] = typemap[thisrolltype]
		if rolltype == thisrolltype then num = num + 1 end
	end

	f[typemap[rolltype]]:SetText(num)
end

local function START_LOOT_ROLL(rollID, time)
	if cancelled_rolls[rollID] then return end

	local f = GetFrame()
	f.rollID = rollID
	f.time = time
	for i in pairs(f.rolls) do f.rolls[i] = nil end
	f.need:SetText(0)
	f.greed:SetText(0)
	f.pass:SetText(0)
	f.disenchant:SetText(0)

	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired = GetLootRollItemInfo(rollID)
	f.button.icon:SetTexture(texture)
	f.button.link = GetLootRollItemLink(rollID)

	if C.Loot.AutoGreed and K.Level == MAX_PLAYER_LEVEL and quality == 2 and not bop then
		if canDisenchant then
			RollOnLoot(rollID, 3)
		else
			RollOnLoot(rollID, 2)
		end
	end

	if canNeed then f.needbutt:Enable() else f.needbutt:Disable() end
	if canGreed then f.greedbutt:Enable() else f.greedbutt:Disable() end
	if canDisenchant then f.disenchantbutt:Enable() else f.disenchantbutt:Disable() end
	SetDesaturation(f.needbutt:GetNormalTexture(), not canNeed)
	SetDesaturation(f.greedbutt:GetNormalTexture(), not canGreed)
	SetDesaturation(f.disenchantbutt:GetNormalTexture(), not canDisenchant)
	if canNeed then f.needbutt:SetAlpha(1) else f.needbutt:SetAlpha(0.2) end
	if canGreed then f.greedbutt:SetAlpha(1) else f.greedbutt:SetAlpha(0.2) end
	if canDisenchant then f.disenchantbutt:SetAlpha(1) else f.disenchantbutt:SetAlpha(0.2) end

	f.fsbind:SetText(bop and "BoP" or "BoE")
	f.fsbind:SetVertexColor(bop and 1 or 0.3, bop and 0.3 or 1, bop and 0.1 or 0.3)

	local color = ITEM_QUALITY_COLORS[quality]
	f.fsloot:SetText(name)
	f.fsloot:SetVertexColor(color.r, color.g, color.b)

	f.status:SetStatusBarColor(color.r, color.g, color.b, .7)
	f.status.bg:SetColorTexture(color.r, color.g, color.b)

	f:SetBackdropBorderColor(color.r, color.g, color.b)
	f.button:SetBackdropBorderColor(color.r, color.g, color.b)

	f.status:SetMinMaxValues(0, time)
	f.status:SetValue(time)

	f:SetPoint("CENTER", WorldFrame, "CENTER")
	f:Show()
end

local function LOOT_HISTORY_ROLL_CHANGED(rollindex, playerindex)
	local _, _, rolltype = C_LootHistory.GetPlayerInfo(rollindex, playerindex)
	UpdateRoll(rollindex, rolltype)
end

LootRollAnchor:RegisterEvent("ADDON_LOADED")
LootRollAnchor:SetScript("OnEvent", function(frame, event)
	LootRollAnchor:UnregisterEvent("ADDON_LOADED")
	LootRollAnchor:RegisterEvent("LOOT_HISTORY_ROLL_CHANGED")
	LootRollAnchor:RegisterEvent("START_LOOT_ROLL")

	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

	LootRollAnchor:SetScript("OnEvent", function(frame, event, ...)
		if event == "LOOT_HISTORY_ROLL_CHANGED" then
			return LOOT_HISTORY_ROLL_CHANGED(...)
		else
			return START_LOOT_ROLL(...)
		end
	end)

	LootRollAnchor:SetPoint(C.Position.GroupLoot[1], C.Position.GroupLoot[2], C.Position.GroupLoot[3], C.Position.GroupLoot[4], C.Position.GroupLoot[5])

	Movers:RegisterFrame(LootRollAnchor)
end)