local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Auras")

local pairs = pairs
local select = select
local string_find = string.find
local table_insert = table.insert
local table_remove = table.remove
-- local table_wipe = table.wipe

local C_Item_GetItemInfo = C_Item.GetItemInfo
local C_Spell_GetSpellCharges = C_Spell.GetSpellCharges
local C_Spell_GetSpellCooldown = C_Spell.GetSpellCooldown
local C_Spell_GetSpellName = C_Spell.GetSpellName
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetInventoryItemLink = GetInventoryItemLink
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetTime = GetTime
local GetTotemInfo = GetTotemInfo
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsPlayerSpell = IsPlayerSpell
local SlashCmdList = SlashCmdList
local UnitGUID = UnitGUID
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitName = UnitName

-- Constants
local maxFrames = 12
local hasCentralize

-- Pre-allocate tables
local auraWatchUpdater = CreateFrame("Frame")
local AuraList = {}
local FrameList = {}
local UnitIDTable = {}
local IntTable = {}
local IntCD = {}
local myTable = {}
local cooldownTable = {}

-- Data conversion
local function DataAnalyze(v)
	local newTable = {}
	if type(v[1]) == "number" then
		newTable.IntID = v[1]
		newTable.Duration = v[2]
		if v[3] == "OnCastSuccess" then
			newTable.OnSuccess = true
		elseif v[3] == "UnitCastSucceed" then
			newTable.CastSucceed = true
		end
		newTable.UnitID = v[4]
		newTable.ItemID = v[5]
	else
		newTable[v[1]] = v[2]
		newTable.UnitID = v[3]
		newTable.Caster = v[4]
		newTable.Stack = v[5]
		newTable.Value = v[6]
		newTable.Timeless = v[7]
		newTable.Combat = v[8]
		newTable.Text = v[9]
		newTable.Flash = v[10]
	end
	return newTable
end

local function RecycleTable(t)
	for k in pairs(t) do
		t[k] = nil
	end

	return t
end

local function InsertData(index, target)
	if KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.Switcher[index] then
		RecycleTable(target)
	end

	for spellID, v in pairs(myTable[index]) do
		local value = target[spellID]
		if value and value.AuraID == v.AuraID then
			value = nil
		end
		target[spellID] = v
	end
end

local function ConvertTable()
	for i = 1, 10 do
		if myTable[i] then
			RecycleTable(myTable[i])
		else
			myTable[i] = {}
		end

		local value = KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[i]
		if value and next(value) then
			for spellID, v in pairs(value) do
				myTable[i][spellID] = DataAnalyze(v)
			end
		end
	end

	local internalCD = KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD
	if next(internalCD) then
		for spellID, v in pairs(internalCD) do
			myTable[10][spellID] = DataAnalyze(v)
		end
	end

	local auraWatchList = C.AuraWatchList[K.Class]
	for _, v in pairs(auraWatchList) do
		if v.Name == "Special Aura" then
			InsertData(1, v.List)
		elseif v.Name == "Focus Aura" then
			InsertData(3, v.List)
		elseif v.Name == "Spell Cooldown" then
			InsertData(4, v.List)
		end
	end

	local allAuras = C.AuraWatchList["ALL"]
	for i, v in pairs(allAuras) do
		if v.Name == "Enchant Aura" then
			InsertData(5, v.List)
		elseif v.Name == "Raid Buff" then
			InsertData(6, v.List)
		elseif v.Name == "Raid Debuff" then
			InsertData(7, v.List)
		elseif v.Name == "Warning" then
			InsertData(2, v.List)
		elseif v.Name == "InternalCD" then
			InsertData(8, v.List)
			IntCD = v
			table_remove(allAuras, i)
		end
	end
end

local function BuildAuraList()
	RecycleTable(AuraList)

	AuraList = C.AuraWatchList["ALL"] or {}
	local classAuras = C.AuraWatchList[K.Class]
	for _, value in pairs(classAuras) do
		table_insert(AuraList, value)
	end

	RecycleTable(C.AuraWatchList)
end

local function BuildUnitIDTable()
	local existingUnits = {}
	for _, v in pairs(UnitIDTable) do
		if v then
			existingUnits[v] = true
		end
	end

	for _, VALUE in pairs(AuraList) do
		if VALUE.List then
			for _, value in pairs(VALUE.List) do
				if value.UnitID and not existingUnits[value.UnitID] then
					existingUnits[value.UnitID] = true
					table_insert(UnitIDTable, value.UnitID)
				end
			end
		end
	end
end

local function BuildCooldownTable()
	RecycleTable(cooldownTable)

	for KEY, VALUE in pairs(AuraList) do
		if VALUE.List then
			for spellID, value in pairs(VALUE.List) do
				if (value.SpellID and IsPlayerSpell(value.SpellID)) or value.ItemID or value.SlotID or value.TotemID then
					if not cooldownTable[KEY] then
						cooldownTable[KEY] = {}
					end

					cooldownTable[KEY][spellID] = true
				end
			end
		end
	end
end

local function MakeMoveHandle(frame, text, value, anchor)
	local mover = K.Mover(frame, text, value, anchor, nil, nil, true)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", mover)
	frame.__width = mover:GetWidth()

	return mover
end

-- Aurawatch style
local function tooltipOnEnter(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)

	if self.type == 1 then
		GameTooltip:SetSpellByID(self.spellID)
	elseif self.type == 2 then
		GameTooltip:SetHyperlink(select(2, C_Item_GetItemInfo(self.spellID)))
	elseif self.type == 3 then
		GameTooltip:SetInventoryItem("player", self.spellID)
	elseif self.type == 4 then
		GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
	elseif self.type == 5 then
		GameTooltip:SetTotem(self.spellID)
	end

	GameTooltip:Show()
end

function Module:RemoveSpellFromAuraList()
	if IsAltKeyDown() and IsControlKeyDown() and self.type == 4 and self.spellID then
		KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells[self.spellID] = true
		K.Print(string.format(L["AddToIgnoreList"], "", self.spellID))
	end
end

local function enableTooltip(self)
	self:EnableMouse(true)

	self.HL = self:CreateTexture(nil, "HIGHLIGHT")
	self.HL:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	self.HL:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -0)
	self.HL:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -0, 0)
	self.HL:SetBlendMode("ADD")

	self:SetScript("OnEnter", tooltipOnEnter)
	self:SetScript("OnLeave", K.HideTooltip)
	self:SetScript("OnMouseDown", Module.RemoveSpellFromAuraList)
end

-- Icon mode
local function BuildICON(iconSize)
	iconSize = iconSize * C["AuraWatch"].IconScale

	local frame = CreateFrame("Frame", nil, K.PetBattleFrameHider)
	frame:SetSize(iconSize, iconSize)

	frame.bg = CreateFrame("Frame", nil, frame)
	frame.bg:SetAllPoints(frame)
	frame.bg:SetFrameLevel(frame:GetFrameLevel())
	frame.bg:CreateBorder()

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints(frame.bg)
	frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	frame.Cooldown:SetAllPoints(frame.bg)
	frame.Cooldown:SetReverse(true)

	local parentFrame = CreateFrame("Frame", nil, frame)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(frame:GetFrameLevel() + 6)

	frame.Spellname = K.CreateFontString(parentFrame, 13, "", "OUTLINE", false, "TOP", 0, 5)
	frame.Count = K.CreateFontString(parentFrame, iconSize * 0.40, "", "OUTLINE", false, "BOTTOMRIGHT", 6, -3)

	frame.glowFrame = CreateFrame("Frame", nil, frame)
	frame.glowFrame:SetPoint("TOPLEFT", frame, -4, 4)
	frame.glowFrame:SetPoint("BOTTOMRIGHT", frame, 4, -4)
	frame.glowFrame:SetSize(iconSize, iconSize)
	frame.glowFrame:SetFrameLevel(frame:GetFrameLevel())

	if not C["AuraWatch"].ClickThrough then
		enableTooltip(frame)
	end

	frame:Hide()

	return frame
end

-- Bar mode
local function BuildBAR(barWidth, iconSize)
	if not barWidth or not iconSize or type(barWidth) ~= "number" or type(iconSize) ~= "number" then
		return nil
	end

	local frame = CreateFrame("Frame", nil, K.PetBattleFrameHider)
	frame:SetSize(iconSize, iconSize)
	frame:CreateBorder()

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	frame.Statusbar = CreateFrame("StatusBar", nil, frame)
	frame.Statusbar:SetSize(barWidth, iconSize / 1.6)
	frame.Statusbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 6, 0)
	frame.Statusbar:SetMinMaxValues(0, 1)
	frame.Statusbar:SetValue(0)
	frame.Statusbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	frame.Statusbar:SetStatusBarColor(K.r, K.g, K.b)
	frame.Statusbar:CreateBorder()

	frame.Statusbar.Spark = frame.Statusbar:CreateTexture(nil, "OVERLAY")
	frame.Statusbar.Spark:SetTexture(C["Media"].Textures.Spark16Texture)
	frame.Statusbar.Spark:SetSize(16, frame.Statusbar:GetHeight())
	frame.Statusbar.Spark:SetBlendMode("ADD")
	frame.Statusbar.Spark:SetPoint("CENTER", frame.Statusbar:GetStatusBarTexture(), "RIGHT", 0, 0)

	frame.Count = K.CreateFontString(frame, 12, "", "", false, "BOTTOMRIGHT", 3, -1)
	frame.Time = K.CreateFontString(frame.Statusbar, 12, "", "", false, "RIGHT", 0, 8)
	frame.Spellname = K.CreateFontString(frame.Statusbar, 12, "", "", false, "LEFT", 2, 8)
	frame.Spellname:SetWidth(frame.Statusbar:GetWidth() * 0.6)
	frame.Spellname:SetJustifyH("LEFT")

	if not C["AuraWatch"].ClickThrough then
		enableTooltip(frame)
	end

	frame:Hide()

	return frame
end

-- List and anchor
local function BuildAura()
	for key, value in pairs(AuraList) do
		local frameTable = {}
		for i = 1, maxFrames do
			if value.Mode == "ICON" then
				local frame = BuildICON(value.IconSize)
				if i == 1 then
					frame.MoveHandle = MakeMoveHandle(frame, L[value.Name], key, value.Pos)
				end
				table_insert(frameTable, frame)
			elseif value.Mode == "BAR" then
				local frame = BuildBAR(value.BarWidth, value.IconSize)
				if i == 1 then
					frame.MoveHandle = MakeMoveHandle(frame, L[value.Name], key, value.Pos)
				end
				table_insert(frameTable, frame)
			end
		end
		frameTable.Index = 1

		table_insert(FrameList, frameTable)
	end
end

local function SetupAnchor()
	for key, VALUE in pairs(FrameList) do
		local value = AuraList[key]
		local direction, interval = value.Direction, value.Interval
		-- check whether using CENTER direction
		if value.Mode == "BAR" and direction == "CENTER" then
			direction = "UP" -- sorry, no "CENTER" for bars mode
		end

		if not hasCentralize then
			hasCentralize = direction == "CENTER"
		end

		local previous
		for i = 1, #VALUE do
			local frame = VALUE[i]
			if i == 1 then
				frame:SetPoint("CENTER", frame.MoveHandle)
				frame.__direction = direction
				frame.__interval = interval
			elseif (value.Name == "Target Aura" or value.Name == "Enchant Aura") and i == 7 and direction ~= "CENTER" then
				frame:SetPoint("BOTTOM", VALUE[1], "TOP", 0, interval)
			else
				if direction == "RIGHT" or direction == "CENTER" then
					frame:SetPoint("LEFT", previous, "RIGHT", interval, 0)
				elseif direction == "LEFT" then
					frame:SetPoint("RIGHT", previous, "LEFT", -interval, 0)
				elseif direction == "UP" then
					frame:SetPoint("BOTTOM", previous, "TOP", 0, interval)
				elseif direction == "DOWN" then
					frame:SetPoint("TOP", previous, "BOTTOM", 0, -interval)
				end
			end

			previous = frame
		end
	end
end

local function InitSetup()
	ConvertTable()
	BuildAuraList()
	BuildUnitIDTable()
	BuildCooldownTable()
	K:RegisterEvent("PLAYER_TALENT_UPDATE", BuildCooldownTable)
	BuildAura()
	SetupAnchor()
end

-- Update timer
function Module:AuraWatch_UpdateTimer()
	if self.expires then
		self.elapsed = self.expires - GetTime()
	else
		self.elapsed = self.start + self.duration - GetTime()
	end

	local timer = self.elapsed
	if timer < 0 then
		if self.Time then
			self.Time:SetText("N/A")
		end

		self.Statusbar:SetMinMaxValues(0, 1)
		self.Statusbar:SetValue(0)
		self.Statusbar.Spark:Hide()
	elseif timer < 60 then
		if self.Time then
			self.Time:SetFormattedText("%.1f", timer)
		end

		self.Statusbar:SetMinMaxValues(0, self.duration)
		self.Statusbar:SetValue(timer)
		self.Statusbar.Spark:Show()
	else
		if self.Time then
			self.Time:SetFormattedText("%d:%.2d", timer / 60, timer % 60)
		end
		self.Statusbar:SetMinMaxValues(0, self.duration)
		self.Statusbar:SetValue(timer)
		self.Statusbar.Spark:Show()
	end
end

function Module:AuraWatch_SetupCD(index, name, icon, start, duration, _, type, id, charges)
	local frames = FrameList[index]
	if not frames then
		return
	end

	local frame = frames[frames.Index]
	if not frame then
		return
	end

	frame:Show()

	if frame.Icon then
		frame.Icon:SetTexture(icon)
	end

	if frame.Cooldown then
		frame.Cooldown:SetReverse(false)
		frame.Cooldown:SetCooldown(start, duration)
		frame.Cooldown:Show()
	end

	if frame.Count then
		frame.Count:SetText(charges)
	end

	if frame.Spellname then
		frame.Spellname:SetText(name)
	end

	if frame.Statusbar then
		frame.duration = duration
		frame.start = start
		frame.elapsed = 0
		frame:SetScript("OnUpdate", Module.AuraWatch_UpdateTimer)
	end

	frame.type = type
	frame.spellID = id

	frames.Index = (frames.Index + 1 > maxFrames) and maxFrames or frames.Index + 1
end

Module.IgnoredItems = {
	[193757] = true,
}

function Module:AuraWatch_UpdateCD()
	for KEY, VALUE in pairs(cooldownTable) do
		for spellID in pairs(VALUE) do
			local group = AuraList[KEY]
			local value = group.List[spellID]
			if value then
				if value.SpellID then
					local name, icon = C_Spell_GetSpellName(value.SpellID), C_Spell_GetSpellTexture(value.SpellID)
					local start = C_Spell_GetSpellCooldown(value.SpellID).startTime
					local duration = C_Spell_GetSpellCooldown(value.SpellID).duration
					local charges, maxCharges, chargeStart, chargeDuration = C_Spell_GetSpellCharges(value.SpellID)

					if group.Mode == "ICON" then
						name = ""
					end

					if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
						Module:AuraWatch_SetupCD(KEY, name, icon, chargeStart, chargeDuration, true, 1, value.SpellID, charges)
					elseif start and duration > 3 then
						Module:AuraWatch_SetupCD(KEY, name, icon, start, duration, true, 1, value.SpellID)
					end
				elseif value.ItemID then
					local start, duration = C_Item.GetItemCooldown(value.ItemID)
					if start and duration > 3 then
						local name, _, _, _, _, _, _, _, _, icon = C_Item_GetItemInfo(value.ItemID)
						if group.Mode == "ICON" then
							name = "" -- Change nil to empty string
						end
						Module:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 2, value.ItemID)
					end
				elseif value.SlotID then
					local link = GetInventoryItemLink("player", value.SlotID)
					if link then
						local itemID = GetItemInfoFromHyperlink(link)
						if not Module.IgnoredItems[itemID] then
							local name, _, _, _, _, _, _, _, _, icon = C_Item_GetItemInfo(link)
							local start, duration = GetInventoryItemCooldown("player", value.SlotID)
							if duration > 1.5 then
								if group.Mode == "ICON" then
									name = "" -- Change nil to empty string
								end
								Module:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 3, value.SlotID)
							end
						end
					end
				elseif value.TotemID then
					local haveTotem, name, start, duration, icon = GetTotemInfo(value.TotemID)
					if haveTotem then
						if group.Mode == "ICON" then
							name = "" -- Change nil to empty string
						end
						Module:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 5, value.TotemID)
					end
				end
			end
		end
	end
end

-- UpdateAura
local replacedTexture = {
	[336892] = 135130, -- Change (Unyielding Vigil) to the Aimed Shot icon
	[378770] = 236174, -- Change (Killing Strike) to the Kill Shot icon
	[389020] = 132330, -- Change (Bullet Storm) to the Multi-Shot icon
	[378747] = 132176, -- Change (Frenzied Pack) to the Kill Command icon
}

function Module:AuraWatch_SetupAura(KEY, unit, index, filter, name, icon, count, duration, expires, spellID, flash)
	if not KEY then
		return
	end

	local frames = FrameList[KEY]
	local frame = frames[frames.Index]
	if frame then
		frame:Show()
	end

	if frame.Icon then
		frame.Icon:SetTexture(replacedTexture[spellID] or icon)
	end

	if frame.Count then
		frame.Count:SetText(count > 1 and count or "")
	end

	if frame.Cooldown then
		frame.Cooldown:SetReverse(true)
		frame.Cooldown:SetCooldown(expires - duration, duration)
	end

	if frame.Spellname then
		frame.Spellname:SetText(name)
	end

	if frame.Statusbar then
		frame.duration = duration
		frame.expires = expires
		frame.elapsed = 0
		frame:SetScript("OnUpdate", Module.AuraWatch_UpdateTimer)
	end

	if frame.glowFrame then
		if flash then
			K.ShowOverlayGlow(frame.glowFrame)
		else
			K.HideOverlayGlow(frame.glowFrame)
		end
	end

	frame.type = 4
	frame.unit = unit
	frame.index = index
	frame.filter = filter
	frame.spellID = spellID

	frames.Index = (frames.Index + 1 > maxFrames) and maxFrames or frames.Index + 1
end

function Module:AuraWatch_UpdateAura(unit, index, filter, name, icon, count, duration, expires, caster, spellID, number, inCombat)
	if KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells[spellID] then -- ignore spells
		return
	end

	for KEY, VALUE in pairs(AuraList) do
		local value = VALUE.List[spellID]
		if value and value.AuraID and value.UnitID == unit then
			if value.Combat and not inCombat then
				return
			end
			if value.Caster and value.Caster ~= caster then
				return
			end
			if value.Stack and count and value.Stack > count then
				return
			end

			if value.Value and number then
				if VALUE.Mode == "ICON" then
					name = K.ShortValue(number)
				elseif VALUE.Mode == "BAR" then
					name = name .. ":" .. K.ShortValue(number)
				end
			else
				if VALUE.Mode == "ICON" then
					name = value.Text or nil
				elseif VALUE.Mode == "BAR" then
					name = name
				end
			end

			if value.Timeless then
				duration, expires = 0, 0
			end

			Module:AuraWatch_SetupAura(KEY, unit, index, filter, name, icon, count, duration, expires, spellID, value.Flash)
			return
		end
	end
end

function Module:UpdateAuraWatchByFilter(unit, filter, inCombat)
	local index = 1

	while true do
		local auraData = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
		if not auraData then
			break
		end
		Module:AuraWatch_UpdateAura(unit, index, filter, auraData.name, auraData.icon, auraData.applications, auraData.duration, auraData.expirationTime, auraData.sourceUnit, auraData.spellId, (auraData.points[1] == 0 and tonumber(auraData.points[2]) or tonumber(auraData.points[1])), inCombat)

		index = index + 1
	end
end

function Module:UpdateAuraWatch(unit, inCombat)
	Module:UpdateAuraWatchByFilter(unit, "HELPFUL", inCombat)
	Module:UpdateAuraWatchByFilter(unit, "HARMFUL", inCombat)
end

-- Update InternalCD
function Module:AuraWatch_SortBars()
	if not IntCD.MoveHandle then
		IntCD.MoveHandle = MakeMoveHandle(IntTable[1], L[IntCD.Name], "InternalCD", IntCD.Pos)
	end

	for i = 1, #IntTable do
		IntTable[i]:ClearAllPoints()
		if i == 1 then
			IntTable[i]:SetPoint("CENTER", IntCD.MoveHandle)
		elseif IntCD.Direction == "RIGHT" then
			IntTable[i]:SetPoint("LEFT", IntTable[i - 1], "RIGHT", IntCD.Interval, 0)
		elseif IntCD.Direction == "LEFT" then
			IntTable[i]:SetPoint("RIGHT", IntTable[i - 1], "LEFT", -IntCD.Interval, 0)
		elseif IntCD.Direction == "UP" then
			IntTable[i]:SetPoint("BOTTOM", IntTable[i - 1], "TOP", 0, IntCD.Interval)
		elseif IntCD.Direction == "DOWN" then
			IntTable[i]:SetPoint("TOP", IntTable[i - 1], "BOTTOM", 0, -IntCD.Interval)
		end

		IntTable[i].ID = i
	end
end

function Module:AuraWatch_IntTimer(elapsed)
	self.elapsed = self.elapsed or 0

	if type(elapsed) ~= "number" then
		return
	end

	self.elapsed = self.elapsed + elapsed
	local timer = self.duration - self.elapsed

	if timer < 0 then
		self:SetScript("OnUpdate", nil)
		self:Hide()
		table_remove(IntTable, self.ID)
		Module:AuraWatch_SortBars()
	elseif timer < 60 then
		if self.Time then
			self.Time:SetFormattedText("%.1f", timer)
		end
		self.Statusbar:SetValue(timer)
		self.Statusbar.Spark:Show()
	else
		if self.Time then
			self.Time:SetFormattedText("%d:%.2d", timer / 60, timer % 60)
		end
		self.Statusbar:SetValue(timer)
		self.Statusbar.Spark:Show()
	end
end

function Module:AuraWatch_SetupInt(intID, itemID, duration, unitID, guid, sourceName)
	if not K.PetBattleFrameHider:IsShown() then
		return
	end

	local frame = BuildBAR(IntCD.BarWidth, IntCD.IconSize)
	if frame then
		frame:Show()
		table_insert(IntTable, frame)
		Module:AuraWatch_SortBars()
	end

	local name, icon, _, class
	if itemID then
		name, _, _, _, _, _, _, _, _, icon = C_Item_GetItemInfo(itemID)
		frame.type = 2
		frame.spellID = itemID
	elseif intID and type(intID) == "number" then
		name, icon = C_Spell_GetSpellName(intID), C_Spell_GetSpellTexture(intID)
		if not name or not icon then
			return
		end
		frame.type = 1
		frame.spellID = intID
	else
		return
	end

	if unitID:lower() == "all" then
		class = select(2, GetPlayerInfoByGUID(guid))
		name = "*" .. sourceName
	else
		class = K.Class
	end

	if frame.Icon then
		frame.Icon:SetTexture(icon)
	end

	if frame.Count then
		frame.Count:SetText("")
	end

	if frame.Cooldown then
		frame.Cooldown:SetReverse(true)
		frame.Cooldown:SetCooldown(GetTime(), duration)
	end

	if frame.Spellname then
		frame.Spellname:SetText(name)
	end

	if frame.Statusbar then
		frame.Statusbar:SetStatusBarColor(K.ColorClass(class))
		frame.Statusbar:SetMinMaxValues(0, duration)
		frame.elapsed = 0
		frame.duration = duration
		frame:SetScript("OnUpdate", Module.AuraWatch_IntTimer)
	end
end

local eventList = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REFRESH"] = true,
}

local function checkPetFlags(sourceFlags, all)
	if K.IsMyPet(sourceFlags) or (all and (sourceFlags == K.PartyPetFlags or sourceFlags == K.RaidPetFlags)) then
		return true
	end
end

function Module:IsUnitWeNeed(value, guid, name, flags)
	if not value.UnitID then
		value.UnitID = "Player"
	end

	if value.UnitID:lower() == "all" then
		if name and (UnitInRaid(name) or UnitInParty(name) or checkPetFlags(flags, true) or not GetPlayerInfoByGUID(guid)) then
			return true
		end
	elseif value.UnitID:lower() == "player" then
		if name and name == K.Name or checkPetFlags(flags) then
			return true
		end
	end
end

function Module:IsAuraTracking(value, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
	if value.OnSuccess and eventType == "SPELL_CAST_SUCCESS" and Module:IsUnitWeNeed(value, sourceGUID, sourceName, sourceFlags) then
		return true
	elseif not value.OnSuccess and eventList[eventType] and Module:IsUnitWeNeed(value, destGUID, destName, destFlags) then
		return true
	end
end

local cache = {}

function Module:AuraWatch_UpdateInt(event, ...)
	if not IntCD.List then
		return
	end

	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spellID = ...
		local value = IntCD.List[spellID]
		if value and value.CastSucceed and unit then
			local unitID = value.UnitID:lower()
			local guid = UnitGUID(unit)
			local isPassed = false

			if unitID == "all" and (unit == "player" or string_find(unit, "pet") or UnitInRaid(unit) or UnitInParty(unit) or not GetPlayerInfoByGUID(guid)) then
				isPassed = true
			elseif unitID == "player" and (unit == "player" or unit == "pet") then
				isPassed = true
			end

			if isPassed then
				Module:AuraWatch_SetupInt(value.IntID, value.ItemID, value.Duration, value.UnitID, guid, UnitName(unit))
			end
		end
	else
		local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID = ...
		local value = IntCD.List[spellID]
		if value and cache[timestamp] ~= spellID and Module:IsAuraTracking(value, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags) then
			local guid, name = destGUID, destName
			if value.OnSuccess then
				guid, name = sourceGUID, sourceName
			end

			Module:AuraWatch_SetupInt(value.IntID, value.ItemID, value.Duration, value.UnitID, guid, name)

			cache[timestamp] = spellID
		end

		if #cache > 666 then
			RecycleTable(cache)
			cache = {}
		end
	end
end

-- CleanUp
function Module:AuraWatch_Cleanup()
	for _, value in pairs(FrameList) do
		for i = 1, maxFrames do
			local frame = value[i]
			if not frame:IsShown() then
				break
			end

			if frame then
				frame:Hide()
				frame:SetScript("OnUpdate", nil)
			end

			if frame.Icon then
				frame.Icon:SetTexture(nil)
			end

			if frame.Count then
				frame.Count:SetText("")
			end

			if frame.Spellname then
				frame.Spellname:SetText("")
			end

			if frame.glowFrame then
				K.HideOverlayGlow(frame.glowFrame)
			end
		end

		value.Index = 1
	end
end

function Module:AuraWatch_PreCleanup()
	for _, value in pairs(FrameList) do
		value.Index = 1
	end
end

function Module:AuraWatch_PostCleanup()
	for _, value in pairs(FrameList) do
		local currentIndex = value.Index == maxFrames and maxFrames + 1 or value.Index
		for i = currentIndex, maxFrames do
			local frame = value[i]
			if not frame:IsShown() then
				break
			end

			if frame then
				frame:Hide()
				frame:SetScript("OnUpdate", nil)
			end

			if frame.Icon then
				frame.Icon:SetTexture(nil)
			end

			if frame.Count then
				frame.Count:SetText("")
			end

			if frame.Spellname then
				frame.Spellname:SetText("")
			end

			if frame.glowFrame then
				K.HideOverlayGlow(frame.glowFrame)
			end
		end
	end
end

-- Event
function Module.AuraWatch_OnEvent(event, ...)
	if not C["AuraWatch"].Enable then
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.AuraWatch_OnEvent)
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.AuraWatch_OnEvent)
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.AuraWatch_OnEvent)
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		InitSetup()
		if not IntCD.MoveHandle then
			Module:AuraWatch_SetupInt(2825, nil, 0, "player")
		end
		K:UnregisterEvent(event, Module.AuraWatch_OnEvent)
	else
		Module:AuraWatch_UpdateInt(event, ...)
	end
end
K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.AuraWatch_OnEvent)
K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.AuraWatch_OnEvent)
K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.AuraWatch_OnEvent)

function Module:AuraWatch_Centralize(force)
	if not hasCentralize then
		return
	end

	for i = 1, #FrameList do
		local frames = FrameList[i]
		local frame1 = frames and frames[1]
		if frame1.__direction == "CENTER" and frame1:IsShown() then
			local numIndex = force and 7 or frames.Index
			local width = frame1.__width
			local interval = frame1.__interval
			frame1:ClearAllPoints()
			frame1:SetPoint("CENTER", frame1.MoveHandle, "CENTER", -(width + interval) / 2 * (numIndex - 2), 0)
		end
	end
end

function Module:AuraWatch_OnUpdate(elapsed)
	if type(elapsed) ~= "number" then
		return
	end

	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		self.elapsed = 0

		Module:AuraWatch_PreCleanup()
		Module:AuraWatch_UpdateCD()

		local inCombat = InCombatLockdown()
		for _, value in pairs(UnitIDTable) do
			Module:UpdateAuraWatch(value, inCombat)
		end

		Module:AuraWatch_PostCleanup()
		Module:AuraWatch_Centralize()
	end
end

-- Ensure the updater script is set correctly
auraWatchUpdater:SetScript("OnUpdate", Module.AuraWatch_OnUpdate)

-- Mover
SlashCmdList.AuraWatch = function(msg)
	if msg:lower() == "move" then
		auraWatchUpdater:SetScript("OnUpdate", nil)
		for _, value in pairs(FrameList) do
			for i = 1, 6 do
				if value[i] then
					value[i]:SetScript("OnUpdate", nil)
					value[i]:Show()
				end

				if value[i].Icon then
					value[i].Icon:SetColorTexture(0, 0, 0, 0.25)
				end

				if value[i].Count then
					value[i].Count:SetText("")
				end

				if value[i].Time then
					value[i].Time:SetText("59")
				end

				if value[i].Statusbar then
					value[i].Statusbar:SetValue(1)
				end

				if value[i].Spellname then
					value[i].Spellname:SetText("")
				end

				if value[i].glowFrame then
					K.HideOverlayGlow(value[i].glowFrame)
				end
			end
			Module:AuraWatch_Centralize(true)
			value[1].MoveHandle:Show()
		end

		if IntCD.MoveHandle then
			IntCD.MoveHandle:Show()
			for i = 1, #IntTable do
				if IntTable[i] then
					IntTable[i]:Hide()
				end
			end
			RecycleTable(IntTable)

			Module:AuraWatch_SetupInt(2825, nil, 0, "player")
			Module:AuraWatch_SetupInt(2825, nil, 0, "player")
			Module:AuraWatch_SetupInt(2825, nil, 0, "player")
			Module:AuraWatch_SetupInt(2825, nil, 0, "player")
			Module:AuraWatch_SetupInt(2825, nil, 0, "player")
			Module:AuraWatch_SetupInt(2825, nil, 0, "player")

			for i = 1, #IntTable do
				IntTable[i]:SetScript("OnUpdate", nil)
				IntTable[i]:Show()
				IntTable[i].Spellname:SetText("")
				IntTable[i].Time:SetText("59")
				IntTable[i].Statusbar:SetMinMaxValues(0, 1)
				IntTable[i].Statusbar:SetValue(1)
				IntTable[i].Icon:SetColorTexture(0, 0, 0, 0.25)
			end
		end
	elseif msg:lower() == "lock" then
		Module:AuraWatch_Cleanup()
		for _, value in pairs(FrameList) do
			value[1].MoveHandle:Hide()
		end
		auraWatchUpdater:SetScript("OnUpdate", Module.AuraWatch_OnUpdate)

		if IntCD.MoveHandle then
			IntCD.MoveHandle:Hide()
			for i = 1, #IntTable do
				if IntTable[i] then
					IntTable[i]:Hide()
				end
			end
			RecycleTable(IntTable)
		end
	end
end
