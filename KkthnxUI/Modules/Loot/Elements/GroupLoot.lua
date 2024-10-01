local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Loot")

--Lua functions
local _G = _G
local pairs, unpack, next = pairs, unpack, next
local wipe, tinsert, format = wipe, tinsert, format

--WoW API / Variables
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsModifiedClick = IsModifiedClick
local RollOnLoot = RollOnLoot

local GameTooltip_Hide = GameTooltip_Hide

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GREED, NEED, PASS = GREED, NEED, PASS
local ROLL_DISENCHANT = ROLL_DISENCHANT
local TRANSMOGRIFICATION = TRANSMOGRIFICATION

local enableDisenchant = false

-- Constants for roll dimensions and direction
local RollWidth, RollHeight, RollDirection = 328, 28, 2

local cachedRolls = {}
local cachedIndex = {}
Module.RollBars = {}

local parentFrame

local rolltypes = { [1] = "need", [2] = "greed", [3] = "disenchant", [4] = "transmog", [0] = "pass" }

local function ClickRoll(button)
	RollOnLoot(button.parent.rollID, button.rolltype)
end

local function SetTip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:AddLine(button.tiptext)

	local rollID = button.parent.rollID
	local rolls = rollID and cachedRolls[rollID] and cachedRolls[rollID][button.rolltype]
	if rolls then
		for _, rollerInfo in next, rolls do
			local playerName, className = unpack(rollerInfo)
			local r, g, b = K.ClassColors[K.ClassList[className] or className] or K.ClassColors["PRIEST"]
			GameTooltip:AddLine(playerName, r, g, b)
		end
	end

	GameTooltip:Show()
end

local function ItemButton_OnEnter(self)
	if not self.link then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(self.link)

	self:RegisterEvent("MODIFIER_STATE_CHANGED")
end

local function ItemButton_OnLeave(self)
	GameTooltip_Hide()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
end

local function ItemButton_OnClick(self)
	if self.link and IsModifiedClick() then
		_G.HandleModifiedItemClick(self.link)
	end
end

local function ItemButton_OnEvent(self, _, key)
	if (key == "LSHIFT" or key == "RSHIFT") and self:IsMouseOver() and GameTooltip:GetOwner() == self then
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:SetHyperlink(self.link)
	end
end

local function StatusUpdate(button, elapsed)
	local bar = button.parent
	if not bar.rollID then
		if not bar.isTest then
			bar:Hide()
		end

		return
	end

	if button.elapsed and button.elapsed > 0.1 then
		local timeLeft = GetLootRollTimeLeft(bar.rollID)
		if timeLeft <= 0 then -- workaround for other addons auto-passing loot
			Module.LootRoll_Cancel(bar, nil, bar.rollID)
		else
			button:SetValue(timeLeft)
			button.elapsed = 0
		end
	else
		button.elapsed = (button.elapsed or 0) + elapsed
	end
end

local iconCoords = {
	[0] = { -0.05, 1.05, -0.05, 1.05 }, -- pass
	[1] = { 0.025, 1.025, -0.05, 0.95 }, -- need
	[2] = { 0, 1, 0.05, 0.95 }, -- greed
	[3] = { 0, 1, 0, 1 }, -- disenchant
	[4] = { 0, 1, 0, 1 }, -- transmog
}

local function RollTexCoords(button, icon, minX, maxX, minY, maxY)
	local offset = icon == button.pushedTex and 0.05 or 0
	icon:SetTexCoord(minX - offset, maxX, minY - offset, maxY)

	if icon == button.disabledTex then
		icon:SetDesaturated(true)
		icon:SetAlpha(0.25)
	end
end

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

	button.normalTex = button:GetNormalTexture()
	button.disabledTex = button:GetDisabledTexture()
	button.pushedTex = button:GetPushedTexture()
	button.highlightTex = button:GetHighlightTexture()

	local minX, maxX, minY, maxY = unpack(iconCoords[rolltype])
	RollTexCoords(button, button.normalTex, minX, maxX, minY, maxY)
	RollTexCoords(button, button.disabledTex, minX, maxX, minY, maxY)
	RollTexCoords(button, button.pushedTex, minX, maxX, minY, maxY)
	RollTexCoords(button, button.highlightTex, minX, maxX, minY, maxY)
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

	button.text = button:CreateFontString(nil, nil)
	button.text:SetFontObject(K.UIFontOutline)
	button.text:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)

	return button
end

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
	button:SetScript("OnEnter", ItemButton_OnEnter)
	button:SetScript("OnLeave", ItemButton_OnLeave)
	button:SetScript("OnClick", ItemButton_OnClick)
	button:SetScript("OnEvent", ItemButton_OnEvent)
	bar.button = button

	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(K.TexCoords))
	-- button.bg = B.SetBD(button.icon)

	button.stack = button:CreateFontString(nil, "OVERLAY")
	button.stack:SetPoint("BOTTOMRIGHT", -1, 2)
	button.stack:SetFontObject(K.UIFontOutline)

	button.ilvl = button:CreateFontString(nil, "OVERLAY")
	button.ilvl:SetPoint("BOTTOMLEFT", 1, 1)
	button.ilvl:SetFontObject(K.UIFontOutline)

	local status = CreateFrame("StatusBar", nil, bar)
	status:SetAllPoints(bar)
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	status:SetFrameLevel(status:GetFrameLevel() - 1)
	status:CreateBorder()
	status:SetStatusBarColor(0.8, 0.8, 0.8, 0.9)
	status.parent = bar
	bar.status = status

	status.spark = status:CreateTexture(nil, "OVERLAY")
	status.spark:SetTexture(C["Media"].Textures.Spark128Texture)
	status.spark:SetSize(64, bar:GetHeight())
	status.spark:SetBlendMode("ADD")
	status.spark:SetPoint("CENTER", status:GetStatusBarTexture(), "RIGHT", 0, 0)

	bar.need = CreateRollButton(bar, [[lootroll-toast-icon-need]], 1, NEED, { "LEFT", bar.button, "RIGHT", 6, 0 }, true)
	bar.transmog = CreateRollButton(bar, [[lootroll-toast-icon-transmog]], 4, TRANSMOGRIFICATION, { "LEFT", bar.need, "RIGHT", 3, 0 }, true)
	bar.greed = CreateRollButton(bar, [[lootroll-toast-icon-greed]], 2, GREED, { "LEFT", bar.need, "RIGHT", 3, 0 }, true)
	bar.disenchant = enableDisenchant and CreateRollButton(bar, [[lootroll-toast-icon-disenchant]], 3, ROLL_DISENCHANT, { "LEFT", bar.greed, "RIGHT", 3, 0 }, true)
	bar.pass = CreateRollButton(bar, [[lootroll-toast-icon-pass]], 0, PASS, { "LEFT", bar.disenchant or bar.greed, "RIGHT", 3, 0 }, true)

	local bind = bar:CreateFontString()
	bind:SetPoint("LEFT", bar.pass, "RIGHT", 3, 0)
	bind:SetFontObject(K.UIFontOutline)
	bar.fsbind = bind

	local loot = bar:CreateFontString(nil, "ARTWORK")
	loot:SetFontObject(K.UIFontOutline)
	loot:SetPoint("LEFT", bind, "RIGHT", 0, 0)
	loot:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
	loot:SetSize(200, 10)
	loot:SetJustifyH("LEFT")
	bar.fsloot = loot

	return bar
end

local function GetFrame()
	for _, bar in next, LR.RollBars do
		if not bar.rollID then
			return bar
		end
	end

	local bar = Module:CreateRollBar()
	if next(Module.RollBars) then
		if RollDirection == 2 then
			bar:SetPoint("TOP", Module.RollBars[#Module.RollBars], "BOTTOM", 0, -4)
		else
			bar:SetPoint("BOTTOM", Module.RollBars[#Module.RollBars], "TOP", 0, 4)
		end
	else
		bar:SetPoint("TOP", parentFrame, "TOP")
	end

	tinsert(Module.RollBars, bar)
	return bar
end

function Module:LootRoll_Start(rollID, rollTime)
	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired, canTransmog = GetLootRollItemInfo(rollID)

	if not name then
		for _, rollBar in next, Module.RollBars do
			if rollBar.rollID == rollID then
				Module.LootRoll_Cancel(rollBar, nil, rollID)
			end
		end

		return
	end

	if Module.EncounterID and not cachedIndex[Module.EncounterID] then
		cachedIndex[Module.EncounterID] = rollID
	end

	local link = GetLootRollItemLink(rollID)
	local level = K.GetItemLevel(link)
	local color = ITEM_QUALITY_COLORS[quality]

	local bar = GetFrame()
	if not bar then
		return
	end

	bar.rollID = rollID
	bar.time = rollTime

	bar.button.icon:SetTexture(texture)
	bar.button.stack:SetText(count > 1 and count or "")
	bar.button.ilvl:SetText(level or "")
	bar.button.ilvl:SetTextColor(color.r, color.g, color.b)
	bar.button.link = link

	bar.button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)

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

	bar.pass.text:SetText("")

	bar.fsbind:SetText(bop and "BoP" or "BoE")
	bar.fsbind:SetVertexColor(bop and 1 or 0.3, bop and 0.3 or 1, bop and 0.1 or 0.3)
	bar.fsloot:SetText(name)
	bar.status.elapsed = 1
	bar.status:SetStatusBarColor(color.r, color.g, color.b, 0.7)
	bar.status:SetMinMaxValues(0, rollTime)
	bar.status:SetValue(rollTime)

	bar:Show()

	local cachedInfo = cachedRolls[rollID]
	if cachedInfo then
		for rollType in pairs(cachedInfo) do
			bar[rolltypes[rollType]].text:SetText(#cachedInfo[rollType])
		end
	end

	K.Print("RollID: %d %s", rollID, link)
end

local function GetRollBarByID(rollID)
	for _, bar in next, Module.RollBars do
		if bar.rollID == rollID then
			return bar
		end
	end
end

function Module:LootRoll_GetRollID(encounterID, lootListID)
	local index = cachedIndex[encounterID]
	return index and (index + lootListID - 1)
end

local rollStateToType = {
	[Enum.EncounterLootDropRollState.NeedMainSpec] = 1,
	-- [Enum.EncounterLootDropRollState.NeedOffSpec] = 1,
	[Enum.EncounterLootDropRollState.Transmog] = 4,
	[Enum.EncounterLootDropRollState.Greed] = 2,
	[Enum.EncounterLootDropRollState.Pass] = 0,
}

function Module:LootRoll_UpdateDrops(encounterID, lootListID)
	local dropInfo = C_LootHistory.GetSortedInfoForDrop(encounterID, lootListID)
	local rollID = Module:LootRoll_GetRollID(encounterID, lootListID)
	if rollID then
		cachedRolls[rollID] = {}
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
			for rollType in pairs(cachedRolls[rollID]) do
				bar[rolltypes[rollType]].text:SetText(#cachedRolls[rollID][rollType])
			end
		end
	end
end

function Module:LootRoll_EncounterEnd(id, _, _, _, status)
	if status == 1 then
		Module.EncounterID = id
	end
end

function Module:LootRoll_Cancel(_, rollID)
	if self.rollID == rollID then
		self.rollID = nil
		self.time = nil

		if cachedRolls[rollID] then
			wipe(cachedRolls[rollID])
		end
	end
end

function Module:CreateGroupLoot()
	if not C["Loot"].GroupLoot then
		return
	end

	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(RollWidth, RollHeight)
	K.Mover(parentFrame, "GroupLootMover", "GroupLootMover", { "TOP", UIParent, 0, -200 })

	-- K:RegisterEvent("LOOT_HISTORY_UPDATE_DROP", self.LootRoll_UpdateDrops)
	K:RegisterEvent("ENCOUNTER_END", self.LootRoll_EncounterEnd)
	K:RegisterEvent("START_LOOT_ROLL", self.LootRoll_Start)

	_G.UIParent:UnregisterEvent("START_LOOT_ROLL")
	_G.UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")
end

local testFrame
local function OnClick_Hide(self)
	self:GetParent():Hide()
end

function Module:LootRollTest()
	if not parentFrame then
		return
	end

	if testFrame then
		if testFrame:IsShown() then
			testFrame:Hide()
		else
			testFrame:Show()
		end
		return
	end

	testFrame = Module:CreateRollBar("KKUI_LootRoll")
	testFrame.isTest = true
	testFrame:Show()
	testFrame:SetPoint("TOP", parentFrame, "TOP")
	testFrame.need:SetScript("OnClick", OnClick_Hide)
	testFrame.transmog:SetScript("OnClick", OnClick_Hide)
	testFrame.greed:SetScript("OnClick", OnClick_Hide)
	testFrame.greed:Hide()
	if testFrame.disenchant then
		testFrame.disenchant:SetScript("OnClick", OnClick_Hide)
	end
	testFrame.pass:SetScript("OnClick", OnClick_Hide)

	local itemID = 17103
	local bop = 1
	local canTransmog = true
	local item = Item:CreateFromItemID(itemID)
	item:ContinueOnItemLoad(function()
		local name, link, quality, itemLevel, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)
		local color = ITEM_QUALITY_COLORS[quality]
		testFrame.button.icon:SetTexture(icon)
		testFrame.button.link = link
		testFrame.fsloot:SetText(name)
		testFrame.fsbind:SetText(bop and "BoP" or "BoE")
		testFrame.fsbind:SetVertexColor(bop and 1 or 0.3, bop and 0.3 or 1, bop and 0.1 or 0.3)

		testFrame.transmog:SetShown(not not canTransmog)
		testFrame.greed:SetShown(not canTransmog)

		testFrame.status:SetStatusBarColor(color.r, color.g, color.b, 0.7)
		testFrame.status:SetMinMaxValues(0, 100)
		testFrame.status:SetValue(80)

		testFrame.button.itemLevel = itemLevel
		testFrame.button.color = color
		testFrame.button.ilvl:SetText(itemLevel or "")
		testFrame.button.ilvl:SetTextColor(color.r, color.g, color.b)

		testFrame.button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
	end)
end

function Module:UpdateLootRollTest()
	if not parentFrame then
		return
	end

	if not testFrame then
		Module:LootRollTest()
	end

	local width, height = RollWidth, RollHeight
	testFrame:Show()
	testFrame:SetSize(width, height)
	testFrame.button:SetSize(testFrame:GetHeight(), testFrame:GetHeight())
	testFrame.fsbind:SetFontObject(K.UIFontOutline)
	testFrame.fsloot:SetFontObject(K.UIFontOutline)
	testFrame.need:SetSize(height - 4, height - 4)
	testFrame.transmog:SetSize(height - 4, height - 4)
	testFrame.greed:SetSize(height - 4, height - 4)
	if testFrame.disenchant then
		testFrame.disenchant:SetSize(height - 4, height - 4)
	end
	testFrame.pass:SetSize(height - 4, height - 4)
	testFrame.status:SetAllPoints(testFrame)

	local itemLevel = testFrame.button.itemLevel or 29
	local color = testFrame.button.color or K.QualityColors[Enum.ItemQuality.Epic]
	testFrame.button.ilvl:SetText(itemLevel or "")
	testFrame.button.ilvl:SetFontObject(K.UIFontOutline)

	testFrame.button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
end

SlashCmdList["NDUI_TEKS"] = function()
	Module:LootRollTest()
end
SLASH_NDUI_TEKS1 = "/teks"
