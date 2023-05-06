local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Loot")

local pairs, unpack, next = pairs, unpack, next
local wipe, tinsert, format = wipe, tinsert, format

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GameTooltip = GameTooltip
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local RollOnLoot = RollOnLoot

local GameTooltip_Hide = GameTooltip_Hide
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local C_LootHistory_GetItem = C_LootHistory.GetItem
local C_LootHistory_GetPlayerInfo = C_LootHistory.GetPlayerInfo

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GREED, NEED, PASS = GREED, NEED, PASS
local ROLL_DISENCHANT = ROLL_DISENCHANT
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES or 4

local cachedRolls = {}
local completedRolls = {}
Module.RollBars = {}

local function ClickRoll(button)
	RollOnLoot(button.parent.rollID, button.rolltype)
end

local rolltypes = { [1] = "need", [2] = "greed", [3] = "disenchant", [0] = "pass" }
local function SetTip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:AddLine(button.tiptext)

	local lineAdded
	if button:IsEnabled() == 0 then
		GameTooltip:AddLine("|cffff3333" .. "Can't Roll")
	end

	local rolls = button.parent.rolls[button.rolltype]
	if rolls then
		for _, infoTable in next, rolls do
			local playerName, className = unpack(infoTable)
			if not lineAdded then
				GameTooltip:AddLine(" ")
				lineAdded = true
			end

			local classColor = K.ClassColors[K.ClassList[className] or className]
			if not classColor then
				classColor = K.ClassColors["PRIEST"]
			end
			GameTooltip:AddLine(playerName, classColor.r, classColor.g, classColor.b)
		end
	end

	GameTooltip:Show()
end

local function SetItemTip(button, event)
	-- print(button, event)
	if not button.rollID or (event == "MODIFIER_STATE_CHANGED" and not button:IsMouseOver()) then
		return
	end

	GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT")
	GameTooltip:SetLootRollItem(button.rollID)

	if IsShiftKeyDown() then
		GameTooltip_ShowCompareItem()
	end
end

local function LootClick(button)
	if IsModifiedClick() then
		_G.HandleModifiedItemClick(button.link)
	end
end

local function StatusUpdate(button, elapsed)
	local bar = button.parent
	if not bar.rollID then
		bar:Hide()
		return
	end

	if button.elapsed and button.elapsed > 0.1 then
		local timeLeft = GetLootRollTimeLeft(bar.rollID)
		if timeLeft <= 0 then -- workaround for other addons auto-passing loot
			Module.CANCEL_LOOT_ROLL(bar, "OnUpdate", bar.rollID)
		else
			button:SetValue(timeLeft)
			button.elapsed = 0
		end
	else
		button.elapsed = (button.elapsed or 0) + elapsed
	end
end

local iconCoords = {
	[0] = { 1.05, -0.1, 1.05, -0.1 }, -- pass
	[2] = { 0.05, 1.05, -0.025, 0.85 }, -- greed
	[1] = { 0.05, 1.05, -0.05, 0.95 }, -- need
	[3] = { 0.05, 1.05, -0.05, 0.95 }, -- disenchant
}

local function RollTexCoords(button, icon, rolltype, minX, maxX, minY, maxY)
	local offset = icon == button.pushedTex and (rolltype == 0 and -0.05 or 0.05) or 0
	icon:SetTexCoord(minX - offset, maxX, minY - offset, maxY)

	if icon == button.disabledTex then
		icon:SetDesaturated(true)
		icon:SetAlpha(0.25)
	end
end

local function RollButtonTextures(button, texture, rollType)
	-- Set the texture for the button's normal, pushed, disabled, and highlight states
	button:SetNormalTexture(texture)
	button:SetPushedTexture(texture)
	button:SetDisabledTexture(texture)
	button:SetHighlightTexture(texture)

	-- Store references to the textures for later use
	local normalTex = button:GetNormalTexture()
	local disabledTex = button:GetDisabledTexture()
	local pushedTex = button:GetPushedTexture()
	local highlightTex = button:GetHighlightTexture()

	-- Retrieve the texture coordinates for the specified roll type
	local minX, maxX, minY, maxY = unpack(iconCoords[rollType])

	-- Apply the texture coordinates to each of the button textures
	RollTexCoords(button, normalTex, rollType, minX, maxX, minY, maxY)
	RollTexCoords(button, disabledTex, rollType, minX, maxX, minY, maxY)
	RollTexCoords(button, pushedTex, rollType, minX, maxX, minY, maxY)
	RollTexCoords(button, highlightTex, rollType, minX, maxX, minY, maxY)
end

local function RollMouseDown(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(0)
	end
end

local function RollMouseUp(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(1)
	end
end

local function CreateRollButton(parent, texture, rolltype, tiptext)
	local button = CreateFrame("Button", format("$parent_%sButton", tiptext), parent)
	button:SetScript("OnMouseDown", RollMouseDown)
	button:SetScript("OnMouseUp", RollMouseUp)
	button:SetScript("OnClick", ClickRoll)
	button:SetScript("OnEnter", SetTip)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button:SetMotionScriptsWhileDisabled(true)
	button:SetHitRectInsets(3, 3, 3, 3)

	RollButtonTextures(button, texture .. "-Up", rolltype)

	button.parent = parent
	button.rolltype = rolltype
	button.tiptext = tiptext

	button.text = button:CreateFontString(nil, "ARTWORK")
	button.text:SetFontObject(K.UIFontOutline)
	button.text:SetPoint("BOTTOMRIGHT", 2, -2)

	return button
end

function Module:LootRoll_Create(index)
	local bar = CreateFrame("Frame", "KKUI_LootRollFrame" .. index, UIParent)
	bar:SetScript("OnEvent", Module.CANCEL_LOOT_ROLL)
	bar:RegisterEvent("CANCEL_LOOT_ROLL")
	bar:Hide()

	local status = CreateFrame("StatusBar", nil, bar)
	status:SetFrameLevel(bar:GetFrameLevel())
	status:SetFrameStrata(bar:GetFrameStrata())
	status:CreateBorder()
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	status.parent = bar
	bar.status = status

	local spark = status:CreateTexture(nil, "ARTWORK", nil, 1)
	spark:SetBlendMode("BLEND")
	spark:SetPoint("RIGHT", status:GetStatusBarTexture())
	spark:SetPoint("BOTTOM")
	spark:SetPoint("TOP")
	spark:SetWidth(2)
	status.spark = spark

	local button = CreateFrame("Button", nil, bar)
	button:CreateBorder()
	button:SetScript("OnEvent", SetItemTip)
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button:SetScript("OnClick", LootClick)
	button:RegisterEvent("MODIFIER_STATE_CHANGED")
	bar.button = button

	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	button.stack = button:CreateFontString(nil, "OVERLAY")
	button.stack:SetPoint("BOTTOMRIGHT", -1, 1)
	button.stack:SetFontObject(K.UIFontOutline)

	bar.pass = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Pass]], 0, PASS)
	bar.disenchant = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-DE]], 3, ROLL_DISENCHANT) or nil
	bar.greed = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Coin]], 2, GREED)
	bar.need = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Dice]], 1, NEED)

	local name = bar:CreateFontString(nil, "OVERLAY")
	name:SetFontObject(K.UIFontOutline)
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)
	bar.name = name

	local bind = bar:CreateFontString(nil, "OVERLAY")
	bind:SetFontObject(K.UIFontOutline)
	bar.bind = bind

	bar.rolls = {}

	tinsert(Module.RollBars, bar)

	return bar
end

function Module:LootFrame_GetFrame(i)
	if i then
		return Module.RollBars[i] or Module:LootRoll_Create(i)
	else -- check for a bar to reuse
		for _, bar in next, Module.RollBars do
			if not bar.rollID then
				return bar
			end
		end
	end
end

function Module.CANCEL_LOOT_ROLL(self, event, rollID)
	if self.rollID == rollID then
		self.rollID = nil
		self.time = nil
	end
end

function Module.START_LOOT_ROLL(_, rollID, rollTime)
	local bar = Module:LootFrame_GetFrame()
	if not bar then
		return
	end -- need more info on this, how does it happen?

	wipe(bar.rolls)

	local itemLink = GetLootRollItemLink(rollID)
	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)
	local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemLink)
	local color = ITEM_QUALITY_COLORS[quality]

	if not bop then
		bop = bindType == 1
	end -- recheck sometimes, we need this from bindType

	bar.rollID = rollID
	bar.time = rollTime

	bar.button.link = itemLink
	bar.button.rollID = rollID
	bar.button.icon:SetTexture(texture)
	bar.button.stack:SetShown(count > 1)
	bar.button.stack:SetText(count)

	bar.need:SetEnabled(canNeed)
	bar.greed:SetEnabled(canGreed)

	bar.need.text:SetText(0)
	bar.greed.text:SetText(0)
	bar.pass.text:SetText(0)

	if bar.disenchant then
		bar.disenchant.text:SetText(0)
		bar.disenchant:SetEnabled(canDisenchant)
	end

	bar.name:SetText(name)
	bar.name:SetTextColor(color.r, color.g, color.b)

	bar.bind:SetText(bop and L["BoP"] or bindType == 2 and L["BoE"] or bindType == 3 and L["BoU"] or "")
	bar.bind:SetVertexColor(bop and 1 or 0.3, bop and 0.3 or 1, bop and 0.1 or 0.3)

	bar.status:SetStatusBarColor(color.r, color.g, color.b, 0.7)
	bar.status.spark:SetColorTexture(color.r, color.g, color.b, 0.9)

	bar.status.elapsed = 1
	bar.status:SetMinMaxValues(0, rollTime)
	bar.status:SetValue(rollTime)

	bar:Show()

	_G.AlertFrame:UpdateAnchors()

	--Add cached roll info, if any
	for rollid, rollTable in pairs(cachedRolls) do
		if bar.rollID == rollid then --rollid matches cached rollid
			for rollType, rollerInfo in pairs(rollTable) do
				local rollerName, class = rollerInfo[1], rollerInfo[2]
				if not bar.rolls[rollType] then
					bar.rolls[rollType] = {}
				end
				tinsert(bar.rolls[rollType], { rollerName, class })
				bar[rolltypes[rollType]].text:SetText(#bar.rolls[rollType])
			end

			completedRolls[rollid] = true
			break
		end
	end
end

function Module:ClearLootRollCache()
	wipe(cachedRolls)
	wipe(completedRolls)
end

function Module:UpdateLootRollAnchors(POSITION)
	-- Constants
	local spacing = 6
	local frame = _G.AlertFrameHolder
	local lastShown

	-- Iterate over the roll bars
	for i, bar in next, Module.RollBars do
		-- Reset the anchor points of the bar
		bar:ClearAllPoints()

		-- Determine the anchor frame based on the position
		if i ~= 1 then
			frame = lastShown
		end

		-- Set the bar position based on the position parameter
		if POSITION == "TOP" then
			bar:SetPoint("TOP", frame, "BOTTOM", 0, -spacing)
		else
			bar:SetPoint("BOTTOM", frame, "TOP", 0, spacing)
		end

		-- Keep track of the last shown bar
		if bar:IsShown() then
			lastShown = bar
		end
	end

	return lastShown
end

function Module:UpdateLootRollFrames()
	if not C["Loot"].GroupLoot then
		return
	end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local bar = Module:LootFrame_GetFrame(i)
		bar:SetSize(328, 26)

		bar.status:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

		bar.button:ClearAllPoints()
		bar.button:SetPoint("RIGHT", bar, "LEFT", -6, 0)
		bar.button:SetSize(26, 26)

		bar.name:SetFontObject(K.UIFontOutline)
		bar.bind:SetFontObject(K.UIFontOutline)

		for _, button in next, rolltypes do
			local icon = bar[button]
			if icon then
				icon:SetSize(20, 20)
				icon:ClearAllPoints()
			end
		end

		bar.status:ClearAllPoints()
		bar.name:ClearAllPoints()
		bar.bind:ClearAllPoints()

		bar.status:SetAllPoints()
		bar.status:SetSize(328, 26)

		bar.need:SetPoint("LEFT", bar, "LEFT", 3, 0)
		if bar.disenchant then
			bar.disenchant:SetPoint("LEFT", bar.need, "RIGHT", 3, 0)
		end
		bar.greed:SetPoint("LEFT", bar.disenchant or bar.need, "RIGHT", 3, 0)
		bar.pass:SetPoint("LEFT", bar.greed, "RIGHT", 3, 0)

		bar.name:SetPoint("RIGHT", bar, "RIGHT", -3, 0)
		bar.name:SetPoint("LEFT", bar.bind, "RIGHT", 1, 0)
		bar.bind:SetPoint("LEFT", bar.pass, "RIGHT", 1, 0)
	end
end

function Module:CreateGroupLoot()
	if not C["Loot"].GroupLoot then
		return
	end

	Module:UpdateLootRollFrames()

	K:RegisterEvent("START_LOOT_ROLL", self.START_LOOT_ROLL)
	-- K:RegisterEvent("CANCEL_LOOT_ROLL", self.CANCEL_LOOT_ROLL)
	K:RegisterEvent("LOOT_ROLLS_COMPLETE", self.ClearLootRollCache)

	_G.UIParent:UnregisterEvent("START_LOOT_ROLL")
	_G.UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")
end

SlashCmdList.KKUI_TESTROLL = function()
	local bar = Module:LootFrame_GetFrame()
	if not bar then
		return
	end -- need more info on this, how does it happen?

	if bar:IsShown() then
		bar:Hide()
	else
		local itemList = { 32837, 34196, 33820, 9425 }
		local bindStatus = { L["BoP"], L["BoE"], L["BoU"], "" }
		local item = itemList[math.random(1, #itemList)]
		local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(item)
		local r, g, b = GetItemQualityColor(quality or 1)

		bar.button.icon:SetTexture(texture)
		bar.button.KKUI_Border:SetVertexColor(r, g, b)
		bar.button.stack:SetText(4)

		bar.need.text:SetText(0)
		bar.greed.text:SetText(0)
		bar.pass.text:SetText(0)

		bar.name:SetText(GetItemInfo(item))
		bar.name:SetTextColor(r, g, b)

		bar.bind:SetText(bindStatus[math.random(1, #bindStatus)])

		bar.status:SetStatusBarColor(r, g, b, 0.7)
		bar.status.spark:SetColorTexture(r, g, b, 0.9)

		bar.status.elapsed = 1
		bar.status:SetMinMaxValues(0, 1)
		bar.status:SetValue(0.5)

		bar.button.link = "item:" .. item .. ":0:0:0:0:0:0:0"
		bar:Show()

		_G.AlertFrame:UpdateAnchors()
	end
end
SLASH_KKUI_TESTROLL1 = "/kkroll"
