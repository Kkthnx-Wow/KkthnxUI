local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Auras")

local maxFrames = 12 -- Max Tracked Auras
local updater = CreateFrame("Frame")
local AuraList, FrameList, UnitIDTable, IntTable, IntCD, myTable, cooldownTable = {}, {}, {}, {}, {}, {}, {}
local pairs, select, tinsert, tremove, wipe = _G.pairs, _G.select, _G.table.insert, _G.table.remove, _G.table.wipe
local InCombatLockdown, UnitBuff, UnitDebuff, GetPlayerInfoByGUID, UnitInRaid, UnitInParty = _G.InCombatLockdown, _G.UnitBuff, _G.UnitDebuff, _G.GetPlayerInfoByGUID, _G.UnitInRaid, _G.UnitInParty
local GetTime, GetSpellInfo, GetSpellCooldown, GetSpellCharges, GetTotemInfo = _G.GetTime, _G.GetSpellInfo, _G.GetSpellCooldown, _G.GetSpellCharges, _G.GetTotemInfo
local GetItemCooldown, GetItemInfo, GetInventoryItemLink, GetInventoryItemCooldown = _G.GetItemCooldown, _G.GetItemInfo, _G.GetInventoryItemLink, _G.GetInventoryItemCooldown

-- DataConvert
local function DataAnalyze(v)
	local newTable = {}
	if type(v[1]) == "number" then
		newTable.IntID = v[1]
		newTable.Duration = v[2]
		if v[3] == "OnCastSuccess" then
			newTable.OnSuccess = true
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

local function InsertData(index, target)
	if KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.Switcher[index] then
		wipe(target)
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
		myTable[i] = {}
		if i < 10 then
			local value = KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[i]
			if value and next(value) then
				for spellID, v in pairs(value) do
					myTable[i][spellID] = DataAnalyze(v)
				end
			end
		else
			if next(KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD) then
				for spellID, v in pairs(KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD) do
					myTable[i][spellID] = DataAnalyze(v)
				end
			end
		end
	end

	for _, v in pairs(C.AuraWatchList[K.Class]) do
		if v.Name == "Player Aura" then
			InsertData(1, v.List)
		elseif v.Name == "Target Aura" then
			InsertData(3, v.List)
		elseif v.Name == "Special Aura" then
			InsertData(2, v.List)
		elseif v.Name == "Focus Aura" then
			InsertData(5, v.List)
		elseif v.Name == "Spell Cooldown" then
			InsertData(6, v.List)
		end
	end

	for i, v in pairs(C.AuraWatchList["ALL"]) do
		if v.Name == "Enchant Aura" then
			InsertData(7, v.List)
		elseif v.Name == "Raid Buff" then
			InsertData(8, v.List)
		elseif v.Name == "Raid Debuff" then
			InsertData(9, v.List)
		elseif v.Name == "Warning" then
			InsertData(4, v.List)
		elseif v.Name == "InternalCD" then
			InsertData(10, v.List)
			IntCD = v
			tremove(C.AuraWatchList["ALL"], i)
		end
	end
end

local function BuildAuraList()
	AuraList = C.AuraWatchList["ALL"] or {}
	for class in pairs(C.AuraWatchList) do
		if class == K.Class then
			for _, value in pairs(C.AuraWatchList[class]) do
				tinsert(AuraList, value)
			end
		end
	end
	wipe(C.AuraWatchList)
end

local function BuildUnitIDTable()
	for _, VALUE in pairs(AuraList) do
		for _, value in pairs(VALUE.List) do
			local flag = true
			for _, v in pairs(UnitIDTable) do
				if value.UnitID == v then
					flag = false
				end
			end

			if flag then
				tinsert(UnitIDTable, value.UnitID)
			end
		end
	end
end

local function BuildCooldownTable()
	wipe(cooldownTable)

	for KEY, VALUE in pairs(AuraList) do
		for spellID, value in pairs(VALUE.List) do
			if value.SpellID and IsPlayerSpell(value.SpellID) or value.ItemID or value.SlotID or value.TotemID then
				if not cooldownTable[KEY] then
					cooldownTable[KEY] = {}
				end
				cooldownTable[KEY][spellID] = true
			end
		end
	end
end

local function MakeMoveHandle(frame, text, value, anchor)
	local mover = K.Mover(frame, text, value, anchor, nil, nil, true)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", mover)

	return mover
end

-- Aurawatch style
local function tooltipOnEnter(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
	if self.type == 1 then
		GameTooltip:SetSpellByID(self.spellID)
	elseif self.type == 2 then
		GameTooltip:SetHyperlink(select(2, GetItemInfo(self.spellID)))
	elseif self.type == 3 then
		GameTooltip:SetInventoryItem("player", self.spellID)
	elseif self.type == 4 then
		GameTooltip:SetUnitAura(self.unitID, self.id, self.filter)
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

	local frame = CreateFrame("Frame", nil, K.PetBattleHider)
	frame:SetSize(iconSize, iconSize)

	frame.bg = CreateFrame("Frame", nil, frame)
	frame.bg:SetAllPoints(frame)
	frame.bg:SetFrameLevel(frame:GetFrameLevel())
	frame.bg:CreateBorder()

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints(frame.bg)
	frame.Icon:SetTexCoord(unpack(K.TexCoords))

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
	local frame = CreateFrame("Frame", nil, K.PetBattleHider)
	frame:SetSize(iconSize, iconSize)
	frame:CreateBorder()

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexCoord(unpack(K.TexCoords))

	frame.Statusbar = CreateFrame("StatusBar", nil, frame)
	frame.Statusbar:SetSize(barWidth, iconSize / 1.6)
	frame.Statusbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 6, 0)
	frame.Statusbar:SetMinMaxValues(0, 1)
	frame.Statusbar:SetValue(0)
	frame.Statusbar:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
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
	frame.Spellname:SetWidth(frame.Statusbar:GetWidth()* 0.6)
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
			if value.Mode:lower() == "icon" then
				local frame = BuildICON(value.IconSize)
				if i == 1 then
					frame.MoveHandle = MakeMoveHandle(frame, L[value.Name], key, value.Pos)
				end
				tinsert(frameTable, frame)
			elseif value.Mode:lower() == "bar" then
				local frame = BuildBAR(value.BarWidth, value.IconSize)
				if i == 1 then
					frame.MoveHandle = MakeMoveHandle(frame, L[value.Name], key, value.Pos)
				end
				tinsert(frameTable, frame)
			end
		end
		frameTable.Index = 1
		tinsert(FrameList, frameTable)
	end
end

local function SetupAnchor()
	for key, VALUE in pairs(FrameList) do
		local value = AuraList[key]
		local previous
		for i = 1, #VALUE do
			local frame = VALUE[i]
			if i == 1 then
				frame:SetPoint("CENTER", frame.MoveHandle)
			elseif (value.Name == "Target Aura" or value.Name == "Enchant Aura") and i == 7 then
				frame:SetPoint("BOTTOM", VALUE[1], "TOP", 0, value.Interval)
			else
				if value.Direction:lower() == "right" then
					frame:SetPoint("LEFT", previous, "RIGHT", value.Interval, 0)
				elseif value.Direction:lower() == "left" then
					frame:SetPoint("RIGHT", previous, "LEFT", -value.Interval, 0)
				elseif value.Direction:lower() == "up" then
					frame:SetPoint("BOTTOM", previous, "TOP", 0, value.Interval)
				elseif value.Direction:lower() == "down" then
					frame:SetPoint("TOP", previous, "BOTTOM", 0, -value.Interval)
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

-- Update cooldown
function Module:AuraWatch_SetupCD(index, name, icon, start, duration, _, type, id, charges)
	local frames = FrameList[index]
	local frame = frames[frames.Index]
	if frame then
		frame:Show()
	end

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

function Module:AuraWatch_UpdateCD()
	for KEY, VALUE in pairs(cooldownTable) do
		for spellID in pairs(VALUE) do
			local group = AuraList[KEY]
			local value = group.List[spellID]
			if value then
				if value.SpellID then
					local name, _, icon = GetSpellInfo(value.SpellID)
					local start, duration = GetSpellCooldown(value.SpellID)
					local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(value.SpellID)
					if group.Mode:lower() == "icon" then
						name = nil
					end

					if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
						Module:AuraWatch_SetupCD(KEY, name, icon, chargeStart, chargeDuration, true, 1, value.SpellID, charges)
					elseif start and duration > 5 then
						Module:AuraWatch_SetupCD(KEY, name, icon, start, duration, true, 1, value.SpellID)
					end
				elseif value.ItemID then
					local start, duration = GetItemCooldown(value.ItemID)
					if start and duration > 5 then
						local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(value.ItemID)
						if group.Mode:lower() == "icon" then
							name = nil
						end
						Module:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 2, value.ItemID)
					end
				elseif value.SlotID then
					local link = GetInventoryItemLink("player", value.SlotID)
					if link then
						local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(link)
						local start, duration = GetInventoryItemCooldown("player", value.SlotID)
						if duration > 1.5 then
							if group.Mode:lower() == "icon" then
								name = nil
							end
							Module:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 3, value.SlotID)
						end
					end
				elseif value.TotemID then
					local haveTotem, name, start, duration, icon = GetTotemInfo(value.TotemID)
					if haveTotem then
						if group.Mode:lower() == "icon" then name = nil end
						Module:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 5, value.TotemID)
					end
				end
			end
		end
	end
end

-- UpdateAura
function Module:AuraWatch_SetupAura(index, UnitID, name, icon, count, duration, expires, id, filter, flash, spellID)
	if not index then
		return
	end

	local frames = FrameList[index]
	local frame = frames[frames.Index]
	if frame then
		frame:Show()
	end

	if frame.Icon then
		frame.Icon:SetTexture(icon)
	end

	if frame.Count then
		frame.Count:SetText(count > 1 and count or nil)
	end

	if frame.Cooldown then
		frame.Cooldown:SetReverse(true)
		frame.Cooldown:SetCooldown(expires-duration, duration)
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
			K.ShowButtonGlow(frame.glowFrame)
		else
			K.HideButtonGlow(frame.glowFrame)
		end
	end

	frame.type = 4
	frame.unitID = UnitID
	frame.id = id
	frame.filter = filter
	frame.spellID = spellID

	frames.Index = (frames.Index + 1 > maxFrames) and maxFrames or frames.Index + 1
end

function Module:AuraWatch_UpdateAura(spellID, UnitID, index, bool)
	if KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells[spellID] then -- ignore spells
		return
	end

	for KEY, VALUE in pairs(AuraList) do
		local value = VALUE.List[spellID]
		if value and value.AuraID and value.UnitID == UnitID then
			local filter = bool and "HELPFUL" or "HARMFUL"
			local name, icon, count, _, duration, expires, caster, _, _, _, _, _, _, _, _, number = UnitAura(value.UnitID, index, filter)
			if value.Combat and not InCombatLockdown() then
				return false
			end

			if value.Caster and value.Caster:lower() ~= caster then
				return false
			end

			if value.Stack and count and value.Stack > count then
				return false
			end

			if value.Value and number then
				if VALUE.Mode:lower() == "icon" then
					name = K.ShortValue(number)
				elseif VALUE.Mode:lower() == "bar" then
					name = name..":"..K.ShortValue(number)
				end
			else
				if VALUE.Mode:lower() == "icon" then
					name = value.Text or nil
				elseif VALUE.Mode:lower() == "bar" then
					name = name
				end
			end

			if value.Timeless then
				duration, expires = 0, 0
			end
			return KEY, value.UnitID, name, icon, count, duration, expires, index, filter, value.Flash, spellID
		end
	end
	return false
end

function Module:UpdateAuraWatch(UnitID)
	local index = 1
	while true do
		local name, _, _, _, _, _, _, _, _, spellID = UnitBuff(UnitID, index)
		if not name then
			break
		end
		Module:AuraWatch_SetupAura(Module:AuraWatch_UpdateAura(spellID, UnitID, index, true))
		index = index + 1
	end

	local index = 1
	while true do
		local name, _, _, _, _, _, _, _, _, spellID = UnitDebuff(UnitID, index)
		if not name then
			break
		end
		Module:AuraWatch_SetupAura(Module:AuraWatch_UpdateAura(spellID, UnitID, index, false))
		index = index + 1
	end
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
		elseif IntCD.Direction:lower() == "right" then
			IntTable[i]:SetPoint("LEFT", IntTable[i-1], "RIGHT", IntCD.Interval, 0)
		elseif IntCD.Direction:lower() == "left" then
			IntTable[i]:SetPoint("RIGHT", IntTable[i-1], "LEFT", -IntCD.Interval, 0)
		elseif IntCD.Direction:lower() == "up" then
			IntTable[i]:SetPoint("BOTTOM", IntTable[i-1], "TOP", 0, IntCD.Interval)
		elseif IntCD.Direction:lower() == "down" then
			IntTable[i]:SetPoint("TOP", IntTable[i-1], "BOTTOM", 0, -IntCD.Interval)
		end
		IntTable[i].ID = i
	end
end

function Module:AuraWatch_IntTimer(elapsed)
	self.elapsed = self.elapsed + elapsed
	local timer = self.duration - self.elapsed
	if timer < 0 then
		self:SetScript("OnUpdate", nil)
		self:Hide()
		tremove(IntTable, self.ID)
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
	if not K.PetBattleHider:IsShown() then
		return
	end

	local frame = BuildBAR(IntCD.BarWidth, IntCD.IconSize)
	if frame then
		frame:Show()
		tinsert(IntTable, frame)
		Module:AuraWatch_SortBars()
	end

	local name, icon, _, class
	if itemID then
		name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
		frame.type = 2
		frame.spellID = itemID
	else
		name, _, icon = GetSpellInfo(intID)
		frame.type = 1
		frame.spellID = intID
	end

	if unitID:lower() == "all" then
		class = select(2, GetPlayerInfoByGUID(guid))
		name = "*"..sourceName
	else
		class = K.Class
	end

	if frame.Icon then
		frame.Icon:SetTexture(icon)
	end

	if frame.Count then
		frame.Count:SetText(nil)
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
local soundKitID = SOUNDKIT.ALARM_CLOCK_WARNING_3
function Module:AuraWatch_UpdateInt(_, ...)
	if not IntCD.List then
		return
	end

	local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID = ...
	local value = IntCD.List[spellID]
	if value and cache[timestamp] ~= spellID and Module:IsAuraTracking(value, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags) then
		local guid, name = destGUID, destName
		if value.OnSuccess then
			guid, name = sourceGUID, sourceName
		end

		Module:AuraWatch_SetupInt(value.IntID, value.ItemID, value.Duration, value.UnitID, guid, name)
		if C["AuraWatch"].QuakeRing and spellID == 240447 then
			PlaySound(soundKitID, "Master") -- 'Ding' on quake
		end

		cache[timestamp] = spellID
	end

	if #cache > 666 then
		wipe(cache)
	end
end

-- CleanUp
function Module:AuraWatch_Cleanup() -- FIXME: there should be a better way to do this
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
				frame.Count:SetText(nil)
			end

			if frame.Spellname then
				frame.Spellname:SetText(nil)
			end
		end
		value.Index = 1
	end
end

-- Event
function Module.AuraWatch_OnEvent(event, ...)
	if not C["AuraWatch"].Enable then
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.AuraWatch_OnEvent)
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
K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.AuraWatch_OnEvent)

function Module:AuraWatch_OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		self.elapsed = 0

		Module:AuraWatch_Cleanup()
		Module:AuraWatch_UpdateCD()

		for _, value in pairs(UnitIDTable) do
			Module:UpdateAuraWatch(value)
		end
	end
end
updater:SetScript("OnUpdate", Module.AuraWatch_OnUpdate)

-- Mover
SlashCmdList.AuraWatch = function(msg)
	if msg:lower() == "move" then
		updater:SetScript("OnUpdate", nil)
		for _, value in pairs(FrameList) do
			for i = 1, 6 do
				if value[i] then
					value[i]:SetScript("OnUpdate", nil)
					value[i]:Show()
				end

				if value[i].Icon then
					value[i].Icon:SetColorTexture(0, 0, 0, .25)
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
					K.HideButtonGlow(value[i].glowFrame)
				end
			end
			value[1].MoveHandle:Show()
		end

		if IntCD.MoveHandle then
			IntCD.MoveHandle:Show()
			for i = 1, #IntTable do
				if IntTable[i] then
					IntTable[i]:Hide()
				end
			end
			wipe(IntTable)

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
				IntTable[i].Icon:SetColorTexture(0, 0, 0, .25)
			end
		end
	elseif msg:lower() == "lock" then
		Module:AuraWatch_Cleanup()
		for _, value in pairs(FrameList) do
			value[1].MoveHandle:Hide()
		end
		updater:SetScript("OnUpdate", Module.AuraWatch_OnUpdate)

		if IntCD.MoveHandle then
			IntCD.MoveHandle:Hide()
			for i = 1, #IntTable do
				if IntTable[i] then
					IntTable[i]:Hide()
				end
			end
			wipe(IntTable)
		end
	end
end

-- Gift of the Titans
local hasTitan
function Module:AuraWatch_OnUnitAura()
	if not IntCD.MoveHandle then
		return
	end

	for i = 1, 40 do
		local name, _, _, _, _, expires, _, _, _, spellID = UnitBuff("player", i)
		if not name then
			break
		end

		if spellID == 313698 then
			if not hasTitan then
				Module:AuraWatch_SetupInt(313698, nil, expires - GetTime() + 60, "player")
			end
			hasTitan = true
			return
		end
	end
	hasTitan = false
end

function Module:AuraWatch_CheckInstance()
	local diffID = select(3, GetInstanceInfo())
	if diffID == 152 then
		K:RegisterEvent("UNIT_AURA", Module.AuraWatch_OnUnitAura, "player")
	else
		K:UnregisterEvent("UNIT_AURA", Module.AuraWatch_OnUnitAura)
	end
end
K:RegisterEvent("UPDATE_INSTANCE_INFO", Module.AuraWatch_CheckInstance)