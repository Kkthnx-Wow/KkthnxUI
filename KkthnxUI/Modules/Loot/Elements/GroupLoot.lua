local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Lua functions
local pairs, unpack, format = pairs, unpack, format

-- WoW API / Variables
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local RollOnLoot = RollOnLoot
local GameTooltip_Hide = GameTooltip_Hide
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GREED, NEED, PASS = GREED, NEED, PASS
local ROLL_DISENCHANT = ROLL_DISENCHANT
local TRANSMOGRIFICATION = TRANSMOGRIFICATION

-- Constants for roll dimensions and direction
local RollWidth, RollHeight, RollDirection = 328, 28, 2

-- Cache for roll data to improve performance
local cachedRolls, cachedIndex = {}, {}
Module.RollBars = {}

-- Parent frame for rolls
local parentFrame

-- Roll type definitions for clarity
local rollTypes = { [1] = "need", [2] = "greed", [3] = "disenchant", [4] = "transmog", [0] = "pass" }

-- Function to handle click on roll button
local function ClickRoll(button)
	RollOnLoot(button.parent.rollID, button.rolltype)
end

-- Function to set tooltip for a button
local function SetTip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:AddLine(button.tiptext)

	local rollID, rolls = button.parent.rollID, cachedRolls[rollID]
	if rolls and rolls[button.rolltype] then
		for _, rollerInfo in pairs(rolls[button.rolltype]) do
			local playerName, className = unpack(rollerInfo)
			local classColor = K.ClassColors[K.ClassList[className] or className] or K.ClassColors["PRIEST"]
			GameTooltip:AddLine(playerName, classColor)
		end
	end

	GameTooltip:Show()
end

-- Function to set item tooltip
local function SetItemTip(button, event)
	if not button.link or (event == "MODIFIER_STATE_CHANGED" and not button:IsMouseOver()) then
		return
	end

	GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(button.link)
	if IsShiftKeyDown() then
		GameTooltip_ShowCompareItem()
	end
end

-- Function to handle loot click
local function LootClick(button)
	if IsModifiedClick() then
		_G.HandleModifiedItemClick(button.link)
	end
end

-- Function to update status of roll bar
local function StatusUpdate(button, elapsed)
	local bar = button.parent
	if not bar.rollID then
		if not bar.isTest then
			bar:Hide()
		end
		return
	end

	button.elapsed = (button.elapsed or 0) + elapsed
	if button.elapsed > 0.1 then
		local timeLeft = GetLootRollTimeLeft(bar.rollID)
		if timeLeft <= 0 then
			Module.LootRoll_Cancel(bar, nil, bar.rollID)
		else
			button:SetValue(timeLeft)
			button.elapsed = 0
		end
	end
end

-- Texture coordinates for roll types
local iconCoords = {
	[0] = { -0.05, 1.05, -0.05, 1.05 }, -- pass
	[1] = { 0.025, 1.025, -0.05, 0.95 }, -- need
	[2] = { 0, 1, 0.05, 0.95 }, -- greed
	[3] = { 0, 1, 0, 1 }, -- disenchant
	[4] = { 0, 1, 0, 1 }, -- transmog
}

-- Function to set texture coordinates for roll buttons
local function RollTexCoords(button, icon, rolltype)
	local minX, maxX, minY, maxY = unpack(iconCoords[rolltype])
	local offset = icon == button.pushedTex and 0.05 or 0
	icon:SetTexCoord(minX - offset, maxX, minY - offset, maxY)
	if icon == button.disabledTex then
		icon:SetDesaturated(true)
		icon:SetAlpha(0.25)
	end
end

-- Function to set textures for roll buttons
local function RollButtonTextures(button, texture, rolltype, atlas)
	if atlas then
		button:SetNormalAtlas(texture)
		button:SetPushedAtlas(texture)
		button:SetDisabledAtlas(texture)
		button:SetHighlightAtlas(texture)
	else
		button:SetNormalTexture(texture)
		button:SetPushedTexture(texture)
		button:SetDisabledTexture(texture)
		button:SetHighlightTexture(texture)
	end

	-- Refactored to reduce redundancy
	local textures = {
		normalTex = button:GetNormalTexture(),
		disabledTex = button:GetDisabledTexture(),
		pushedTex = button:GetPushedTexture(),
		highlightTex = button:GetHighlightTexture(),
	}
	for _, tex in pairs(textures) do
		RollTexCoords(button, tex, rolltype)
	end
end

-- Function to handle mouse down on roll button
local function RollMouseDown(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(0)
	end
end

-- Function to handle mouse up on roll button
local function RollMouseUp(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(1)
	end
end

-- Function to create roll button
local function CreateRollButton(parent, texture, rolltype, tiptext, points, atlas)
	local button = CreateFrame("Button", nil, parent)
	button:SetPoint(unpack(points))
	button:SetSize(RollHeight - 4, RollHeight - 4)
	button:SetScript("OnMouseDown", RollMouseDown)
	button:SetScript("OnMouseUp", RollMouseUp)
	button:SetScript("OnClick", ClickRoll)
	button:SetScript("OnEnter", SetTip)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button:SetMotionScriptsWhileDisabled(true)
	button:SetHitRectInsets(3, 3, 3, 3)

	RollButtonTextures(button, texture .. "-Up", rolltype, atlas)

	button.parent = parent
	button.rolltype = rolltype
	button.tiptext = tiptext

	-- Centering text depending on roll type
	local yOffset = rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0
	button.text = button:CreateFontString(nil, nil)
	button.text:SetFontObject(K.UIFontOutline)
	button.text:SetPoint("CENTER", 0, yOffset)

	return button
end

-- Function to create a roll bar
function Module:CreateRollBar(name)
	local bar = CreateFrame("Frame", name or "KKUI_LootRollFrame", UIParent)
	bar:SetSize(RollWidth, RollHeight)
	bar:SetFrameStrata("MEDIUM")
	bar:SetFrameLevel(10)
	bar:SetScript("OnEvent", Module.LootRoll_Cancel)
	bar:RegisterEvent("CANCEL_LOOT_ROLL")
	bar:Hide()

	local button = CreateFrame("Button", nil, bar)
	button:SetPoint("RIGHT", bar, "LEFT", -6, 0)
	button:SetSize(bar:GetHeight(), bar:GetHeight())
	button:CreateBorder()
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button:SetScript("OnClick", LootClick)
	button:SetScript("OnEvent", SetItemTip)
	button:RegisterEvent("MODIFIER_STATE_CHANGED")
	bar.button = button

	-- Initialization of icon, stack, and item level
	local icon, stack, ilvl = button:CreateTexture(nil, "OVERLAY"), button:CreateFontString(nil, "OVERLAY"), button:CreateFontString(nil, "OVERLAY")
	icon:SetAllPoints()
	icon:SetTexCoord(unpack(K.TexCoords))
	button.icon = icon

	stack:SetPoint("BOTTOMRIGHT", -1, 2)
	stack:SetFontObject(K.UIFontOutline)
	button.stack = stack

	ilvl:SetPoint("BOTTOMLEFT", 1, 1)
	ilvl:SetFontObject(K.UIFontOutline)
	button.ilvl = ilvl

	-- Status bar creation and configuration
	local status = CreateFrame("StatusBar", nil, bar)
	status:SetAllPoints(bar)
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	status:SetFrameLevel(status:GetFrameLevel() - 1)
	status:CreateBorder()
	status:SetStatusBarColor(0.8, 0.8, 0.8, 0.9)
	status.parent = bar
	bar.status = status

	-- Spark for status bar
	local spark = status:CreateTexture(nil, "ARTWORK", nil, 1)
	spark:SetBlendMode("BLEND")
	spark:SetPoint("RIGHT", status:GetStatusBarTexture())
	spark:SetPoint("BOTTOM")
	spark:SetPoint("TOP")
	spark:SetWidth(2)
	status.spark = spark

	-- Roll buttons
	bar.need = CreateRollButton(bar, [[lootroll-toast-icon-need]], 1, NEED, { "LEFT", bar.button, "RIGHT", 6, 0 }, true)
	bar.transmog = CreateRollButton(bar, [[lootroll-toast-icon-transmog]], 4, TRANSMOGRIFICATION, { "LEFT", bar.need, "RIGHT", 3, 0 }, true)
	bar.greed = CreateRollButton(bar, [[lootroll-toast-icon-greed]], 2, GREED, { "LEFT", bar.need, "RIGHT", 3, 0 }, true)
	bar.disenchant = CreateRollButton(bar, [[lootroll-toast-icon-disenchant]], 3, ROLL_DISENCHANT, { "LEFT", bar.greed, "RIGHT", 3, 0 }, true)
	bar.pass = CreateRollButton(bar, [[lootroll-toast-icon-pass]], 0, PASS, { "LEFT", bar.disenchant or bar.greed, "RIGHT", 3, 0 }, true)

	-- Binding and loot text
	local bind, loot = bar:CreateFontString(), bar:CreateFontString(nil, "ARTWORK")
	bind:SetPoint("LEFT", bar.pass, "RIGHT", 3, 0)
	bind:SetFontObject(K.UIFontOutline)
	bar.fsbind = bind

	loot:SetFontObject(K.UIFontOutline)
	loot:SetPoint("LEFT", bind, "RIGHT", 0, 0)
	loot:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
	loot:SetSize(200, 10)
	loot:SetJustifyH("LEFT")
	bar.fsloot = loot

	return bar
end

-- Function to get or create a roll bar
local function GetFrame()
	for _, bar in next, Module.RollBars do
		if not bar.rollID then
			return bar
		end
	end

	local bar = Module:CreateRollBar()
	if next(Module.RollBars) then
		if RollDirection == 2 then
			bar:SetPoint("TOP", Module.RollBars[#Module.RollBars], "BOTTOM", 0, -6)
		else
			bar:SetPoint("BOTTOM", Module.RollBars[#Module.RollBars], "TOP", 0, 6)
		end
	else
		bar:SetPoint("TOP", parentFrame, "TOP")
	end

	tinsert(Module.RollBars, bar)

	return bar
end

-- Function to start a loot roll
function Module:LootRoll_Start(rollID, rollTime)
	local texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired, canTransmog = GetLootRollItemInfo(rollID)
	if not name then
		for _, rollBar in next, Module.RollBars do
			if rollBar.rollID == rollID then
				Module.LootRoll_Cancel(rollBar, nil, rollID)
			end
		end
		return
	end

	cachedIndex[Module.EncounterID] = Module.EncounterID and rollID

	local link = GetLootRollItemLink(rollID)
	local level = K.GetItemLevel(link)
	local color = ITEM_QUALITY_COLORS[quality]

	local bar = GetFrame()
	if not bar then
		return
	end

	bar.rollID = rollID
	bar.time = rollTime

	-- Update button properties
	bar.button.icon:SetTexture(texture)

	bar.button.stack:SetText(count > 1 and count or "")

	bar.button.ilvl:SetText(level or "")
	bar.button.ilvl:SetTextColor(color.r, color.g, color.b)

	bar.button.link = link

	bar.button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)

	-- Update roll buttons
	bar.need.text:SetText("")
	bar.need:SetEnabled(canNeed)
	bar.need.tiptext = canNeed and NEED or _G["LOOT_ROLL_INELIGIBLE_REASON" .. reasonNeed]

	bar.transmog.text:SetText("")
	bar.transmog:SetShown(not not canTransmog)
	bar.transmog:SetEnabled(canTransmog)

	bar.greed.text:SetText("")
	bar.greed:SetShown(not canTransmog)
	bar.greed:SetEnabled(canGreed)
	bar.greed.tiptext = canGreed and GREED or _G["LOOT_ROLL_INELIGIBLE_REASON" .. reasonGreed]

	if bar.disenchant then
		bar.disenchant.text:SetText("")
		bar.disenchant:SetEnabled(canDisenchant)
		bar.disenchant.tiptext = canDisenchant and ROLL_DISENCHANT or format(_G["LOOT_ROLL_INELIGIBLE_REASON" .. reasonDisenchant], deSkillRequired)
	end

	-- Update bind and loot text
	bar.fsbind:SetText(bindOnPickUp and "BoP" or "BoE")
	bar.fsbind:SetVertexColor(bindOnPickUp and 1 or 0.3, bindOnPickUp and 0.3 or 1, bindOnPickUp and 0.1 or 0.3)

	bar.fsloot:SetText(name)

	bar.status.spark:SetColorTexture(color.r, color.g, color.b, 0.5)
	bar.status.elapsed = 1
	bar.status:SetStatusBarColor(color.r, color.g, color.b, 0.7)
	bar.status:SetMinMaxValues(0, rollTime)
	bar.status:SetValue(rollTime)
	bar.status.KKUI_Border:SetVertexColor(color.r, color.g, color.b)

	bar:Show()

	-- Update cached info
	local cachedInfo = cachedRolls[rollID]
	if cachedInfo then
		for rollType in pairs(cachedInfo) do
			bar[rollTypes[rollType]].text:SetText(#cachedInfo[rollType])
		end
	end
end

-- Function to retrieve a roll bar by its ID
local function GetRollBarByID(rollID)
	for _, bar in next, Module.RollBars do
		if bar.rollID == rollID then
			return bar
		end
	end
end

-- Function to compute the roll ID based on encounter and loot list ID
function Module:LootRoll_GetRollID(encounterID, lootListID)
	local index = cachedIndex[encounterID]
	return index and (index + lootListID - 1)
end

-- Mapping of roll states to types for clarity
local rollStateToType = {
	[Enum.EncounterLootDropRollState.NeedMainSpec] = 1,
	--[Enum.EncounterLootDropRollState.NeedOffSpec] = 1, -- Uncomment if needed
	[Enum.EncounterLootDropRollState.Transmog] = 4,
	[Enum.EncounterLootDropRollState.Greed] = 2,
	[Enum.EncounterLootDropRollState.Pass] = 0,
}

-- Function to update loot drops
function Module:LootRoll_UpdateDrops(encounterID, lootListID)
	local dropInfo = C_LootHistory.GetSortedInfoForDrop(encounterID, lootListID)
	local rollID = Module:LootRoll_GetRollID(encounterID, lootListID)
	if rollID then
		cachedRolls[rollID] = cachedRolls[rollID] or {}
		if not dropInfo.allPassed then
			for _, roll in ipairs(dropInfo.rollInfos) do
				local rollType = rollStateToType[roll.state]
				if rollType then
					cachedRolls[rollID][rollType] = cachedRolls[rollID][rollType] or {}
					tinsert(cachedRolls[rollID][rollType], { roll.playerName, roll.playerClass })
				end
			end
		end

		local bar = GetRollBarByID(rollID)
		if bar then
			for rollType, players in pairs(cachedRolls[rollID]) do
				bar[rollTypes[rollType]].text:SetText(#players)
			end
		end
	end
end

-- Function to handle encounter end
function Module:LootRoll_EncounterEnd(id, _, _, _, status)
	if status == 1 then
		Module.EncounterID = id
	end
end

-- Function to cancel a loot roll
function Module:LootRoll_Cancel(_, rollID)
	if self.rollID == rollID then
		self.rollID, self.time = nil, nil
		if cachedRolls[rollID] then
			wipe(cachedRolls[rollID])
		end
	end
end

-- Function to create group loot
function Module:CreateGroupLoot()
	if not C["Loot"].GroupLoot then
		return
	end

	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(RollWidth, RollHeight)
	K.Mover(parentFrame, "GroupLootMover", "GroupLootMover", { "TOP", UIParent, 0, -200 })

	K:RegisterEvent("LOOT_HISTORY_UPDATE_DROP", self.LootRoll_UpdateDrops)
	K:RegisterEvent("ENCOUNTER_END", self.LootRoll_EncounterEnd)
	K:RegisterEvent("START_LOOT_ROLL", self.LootRoll_Start)

	_G.UIParent:UnregisterEvent("START_LOOT_ROLL")
	_G.UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")
end

-- Hide the parent of the clicked button
local function OnClick_Hide(self)
	self:GetParent():Hide()
end

-- Function to test the loot roll
local testFrame
function Module:LootRollTest()
	if not parentFrame then
		return
	end

	if testFrame then
		testFrame:SetShown(not testFrame:IsShown())
		return
	end

	testFrame = Module:CreateRollBar("KKUI_LootRoll")
	testFrame.isTest = true
	testFrame:SetPoint("TOP", parentFrame, "TOP")
	testFrame:Show()

	-- Set hide script for roll buttons
	local buttons = { testFrame.need, testFrame.transmog, testFrame.greed, testFrame.pass }
	for _, button in ipairs(buttons) do
		button:SetScript("OnClick", OnClick_Hide)
	end
	testFrame.greed:Hide()
	if testFrame.disenchant then
		testFrame.disenchant:SetScript("OnClick", OnClick_Hide)
	end

	-- Randomly select a test item
	local itemID, name, quality, itemLevel, icon = 122349, "Bloodied Arcanite Reaper", 7, 79, 132400 -- ??
	local color = ITEM_QUALITY_COLORS[quality]

	-- Set test frame item details
	testFrame.button.icon:SetTexture(icon)
	testFrame.button.link = "|cffa335ee|Hitem:" .. itemID .. "::::::::17:::::::|h[" .. name .. "]|h|r"
	testFrame.fsloot:SetText(name)
	testFrame.fsbind:SetText(bop and "BoP" or "BoE")
	testFrame.fsbind:SetVertexColor(bop and 1 or 0.3, bop and 0.3 or 1, bop and 0.1 or 0.3)

	testFrame.transmog:SetShown(canTransmog)
	testFrame.greed:SetShown(not canTransmog)

	testFrame.status:SetStatusBarColor(color.r, color.g, color.b, 0.7)
	testFrame.status.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
	testFrame.status:SetMinMaxValues(0, 100)
	testFrame.status:SetValue(80)
	testFrame.status.spark:SetColorTexture(color.r, color.g, color.b, 0.5)
	testFrame.button.itemLevel = itemLevel
	testFrame.button.color = color
	testFrame.button.ilvl:SetText(itemLevel or "")
	testFrame.button.ilvl:SetTextColor(color.r, color.g, color.b)
	testFrame.button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
end

-- Function to update loot roll test
function Module:UpdateLootRollTest()
	if not parentFrame or not testFrame then
		Module:LootRollTest()
		return
	end

	-- Update test frame size and font
	testFrame:SetSize(RollWidth, RollHeight)
	testFrame.button:SetSize(RollHeight, RollHeight)
	testFrame.fsbind:SetFontObject(K.UIFontOutline)
	testFrame.fsloot:SetFontObject(K.UIFontOutline)

	-- Update size of roll buttons
	local buttons = { testFrame.need, testFrame.transmog, testFrame.greed, testFrame.pass, testFrame.disenchant }
	for _, button in ipairs(buttons) do
		if button then
			button:SetSize(RollHeight - 4, RollHeight - 4)
		end
	end

	testFrame.status:SetAllPoints()

	-- Update item level and border color
	local itemLevel, color = testFrame.button.itemLevel, testFrame.button.color
	testFrame.button.ilvl:SetText(itemLevel or "")
	testFrame.button.ilvl:SetFontObject(K.UIFontOutline)
	testFrame.button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
end

-- Slash command for testing loot roll
SlashCmdList["KKUI_LOOTROLL_TESTING"] = function()
	Module:LootRollTest()
end
SLASH_KKUI_LOOTROLL_TESTING1 = "/testroll"
SLASH_KKUI_LOOTROLL_TESTING2 = "/rolltest"
