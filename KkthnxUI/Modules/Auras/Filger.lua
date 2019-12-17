local K, C, _ = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true or C["Filger"].Enable ~= true then
	return
end

local LCD = K.LibClassicDurations

local _G = _G
local ipairs = _G.ipairs
local pairs = _G.pairs
local select = _G.select
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetInventoryItemCooldown = _G.GetInventoryItemCooldown
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemInfo = _G.GetItemInfo
local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellInfo = _G.GetSpellInfo
local GetTalentInfoByID = _G.GetTalentInfoByID
local GetTime = _G.GetTime
local UnitAura = _G.UnitAura

local Filger = {}
local MyUnits = {player = true, vehicle = true, pet = true}
local SpellGroups = {}

function Filger:TooltipOnEnter()
	if self.spellID > 20 then
		local str = "spell:%s"
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 3)
		GameTooltip:SetHyperlink(format(str, self.spellID))
		GameTooltip:Show()
	end
end

function Filger:TooltipOnLeave()
	GameTooltip:Hide()
end

function Filger:UnitAura(unitID, inSpellID, spellName, filter, absID)
	for i = 1, 40 do
		local name, icon, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unitID, i, filter)
		if not name then break end
		if (absID and spellID == inSpellID) or (not absID and name == spellName) then
			return name, spellID, icon, count, duration, expirationTime, unitCaster
		end
	end
end

function Filger:UpdateCD()
	local time = self.value.start + self.value.duration - GetTime()

	if self:GetParent().Mode == "BAR" then
		self.statusbar:SetValue(time)
		if time <= 60 then
			self.time:SetFormattedText("%.1f", time)
		else
			self.time:SetFormattedText("%d:%.2d", time / 60, time % 60)
		end
	else
		if time < 0 then
			local frame = self:GetParent()
			frame.actives[self.value.spid] = nil
			self:SetScript("OnUpdate", nil)
			Filger.DisplayActives(frame)
		end
	end
end

function Filger:DisplayActives()
	if not self.actives then return end
	if not self.bars then self.bars = {} end
	local id = self.Id
	local index = 1
	local previous = nil

	local FilgerFont = K.GetFont(C["UIFonts"].FilgerFonts)
	local FilgerTexture = K.GetTexture(C["UITextures"].FilgerTextures)

	for _, _ in pairs(self.actives) do
		local bar = self.bars[index]
		if not bar then
			bar = CreateFrame("Frame", "FilgerAnchor"..id.."Frame"..index, self)
			bar:SetScale(1)
			bar:CreateBorder()
			bar:CreateInnerShadow()

			if index == 1 then
				bar:SetPoint(unpack(self.Position))
			else
				if self.Direction == "UP" then
					bar:SetPoint("BOTTOM", previous, "TOP", 0, self.Interval + 2)
				elseif self.Direction == "RIGHT" then
					bar:SetPoint("LEFT", previous, "RIGHT", self.Mode == "ICON" and self.Interval + 2 or (self.BarWidth + self.Interval + 7), 0)
				elseif self.Direction == "LEFT" then
					bar:SetPoint("RIGHT", previous, "LEFT", self.Mode == "ICON" and -self.Interval - 2 or -(self.BarWidth + self.Interval + 7), 0)
				else
					bar:SetPoint("TOP", previous, "BOTTOM", 0, -self.Interval - 2)
				end
			end

			if bar.icon then
				bar.icon = _G[bar.icon:GetName()]
			else
				bar.icon = bar:CreateTexture("$parentIcon", "BORDER")
				bar.icon:SetAllPoints()
				bar.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			end

			if self.Mode == "ICON" then
				if bar.cooldown then
					bar.cooldown = _G[bar.cooldown:GetName()]
				else
					bar.cooldown = CreateFrame("Cooldown", "$parentCD", bar, "CooldownFrameTemplate")
					bar.cooldown:SetAllPoints(bar.icon)
					bar.cooldown:SetReverse(true)
					bar.cooldown:SetFrameLevel(3)
				end

				if bar.count then
					bar.count = _G[bar.count:GetName()]
				else
					bar.count = bar:CreateFontString("$parentCount", "OVERLAY")
					bar.count:SetFontObject(FilgerFont)
					bar.count:SetPoint("BOTTOMRIGHT", -1, 1)
					bar.count:SetJustifyH("RIGHT")
				end
			else
				if bar.statusbar then
					bar.statusbar = _G[bar.statusbar:GetName()]
				else
					bar.statusbar = CreateFrame("StatusBar", "$parentStatusBar", bar)
					bar.statusbar:SetWidth(self.BarWidth)
					bar.statusbar:SetHeight(self.IconSize - 10)
					bar.statusbar:SetStatusBarTexture(FilgerTexture)
					bar.statusbar:SetStatusBarColor(K.r, K.g, K.b, 1)

					bar.statusbar.spark = bar.statusbar:CreateTexture(nil, "OVERLAY")
					bar.statusbar.spark:SetTexture(C["Media"].Spark_16)
					bar.statusbar.spark:SetBlendMode("ADD")
					bar.statusbar.spark:SetPoint("CENTER", bar.statusbar:GetStatusBarTexture(), "RIGHT", 0, 0)
					bar.statusbar.spark:SetSize(16, bar.statusbar:GetHeight())

					if self.IconSide == "LEFT" then
						bar.statusbar:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", 5, 2)
					elseif self.IconSide == "RIGHT" then
						bar.statusbar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -5, 2)
					end
				end
				bar.statusbar:SetMinMaxValues(0, 1)
				bar.statusbar:SetValue(0)

				if bar.bg then
					bar.bg = _G[bar.bg:GetName()]
				else
					bar.bg = CreateFrame("Frame", "$parentBG", bar.statusbar)
					bar.bg:SetFrameLevel(4)
					bar.bg:SetAllPoints()
					K.CreateBorder(bar.bg)
				end

				if bar.background then
					bar.background = _G[bar.background:GetName()]
				else
					bar.background = bar.statusbar:CreateTexture(nil, "BACKGROUND")
					bar.background:SetAllPoints()
					bar.background:SetTexture(C["Media"].Blank)
					bar.background:SetVertexColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
				end

				if bar.time then
					bar.time = _G[bar.time:GetName()]
				else
					bar.time = bar.statusbar:CreateFontString("$parentTime", "OVERLAY")
					bar.time:FontTemplate(C["Media"].Font, 12, "NONE")
					bar.time:SetPoint("RIGHT", bar.statusbar, -3, 0)
					bar.time:SetJustifyH("RIGHT")
				end

				if bar.count then
					bar.count = _G[bar.count:GetName()]
				else
					bar.count = bar:CreateFontString("$parentCount", "OVERLAY")
					bar.count:FontTemplate(C["Media"].Font, 12, "NONE")
					bar.count:SetPoint("BOTTOMRIGHT", 1, 0)
					bar.count:SetJustifyH("RIGHT")
				end

				if bar.spellname then
					bar.spellname = _G[bar.spellname:GetName()]
				else
					bar.spellname = bar.statusbar:CreateFontString("$parentSpellName", "OVERLAY")
					bar.spellname:FontTemplate(C["Media"].Font, 12, "NONE")
					bar.spellname:SetPoint("LEFT", bar.statusbar, 3, 0)
					bar.spellname:SetPoint("RIGHT", bar.time, "LEFT")
					bar.spellname:SetJustifyH("LEFT")
				end
			end
			bar.spellID = 0
			self.bars[index] = bar
		end
		previous = bar
		index = index + 1
	end

	local temp = {}
	for _, value in pairs(self.actives) do
		table.insert(temp, value)
	end

	local function sortTable(a, b)
		if C["Filger"].Expiration == true and a.data.filter == "CD" then
			return a.start + a.duration < b.start + b.duration
		else
			return a.sort < b.sort
		end
	end
	table.sort(temp, sortTable)

	if not self.sortedIndex then self.sortedIndex = {} end

	for n in pairs(self.sortedIndex) do
		self.sortedIndex[n] = 999
	end

	local activeCount = 1
	local limit = (C["ActionBar"].DefaultButtonSize * 12)/self.IconSize
	for n in pairs(self.actives) do
		self.sortedIndex[activeCount] = n
		activeCount = activeCount + 1
		if activeCount > limit then activeCount = limit end
	end
	table.sort(self.sortedIndex)

	index = 1
	for activeIndex, value in pairs(temp) do
		if activeIndex >= activeCount then
			break
		end
		local bar = self.bars[index]
		bar.spellName = GetSpellInfo(value.spid)
		if self.Mode == "BAR" then
			bar.spellname:SetText(bar.spellName)
		end
		bar.icon:SetTexture(value.icon)
		if value.count and value.count > 1 then
			bar.count:SetText(value.count)
			bar.count:Show()
		else
			bar.count:Hide()
		end
		if value.duration and value.duration > 0 then
			if self.Mode == "ICON" then
				if value.start + value.duration - GetTime() > 0.3 then
					bar.cooldown:SetCooldown(value.start + 0.1, value.duration)
				end
				if value.data.filter == "CD" or value.data.filter == "ICD" then
					bar.value = value
					bar:SetScript("OnUpdate", Filger.UpdateCD)
				else
					bar:SetScript("OnUpdate", nil)
				end
				bar.cooldown:Show()
			else
				bar.statusbar:SetMinMaxValues(0, value.duration)
				bar.value = value
				bar:SetScript("OnUpdate", Filger.UpdateCD)
			end
		else
			if self.Mode == "ICON" then
				bar.cooldown:Hide()
			else
				bar.statusbar:SetMinMaxValues(0, 1)
				bar.statusbar:SetValue(1)
				bar.time:SetText("")
			end
			bar:SetScript("OnUpdate", nil)
		end
		bar.spellID = value.spid
		if C["Filger"].ShowTooltip then
			bar:EnableMouse(true)
			bar:SetScript("OnEnter", Filger.TooltipOnEnter)
			bar:SetScript("OnLeave", Filger.TooltipOnLeave)
		end
		bar:SetWidth(self.IconSize or C["Filger"].BuffSize)
		bar:SetHeight(self.IconSize or C["Filger"].BuffSize)
		bar:SetAlpha(value.data.opacity or 1)
		bar:Show()
		index = index + 1
	end

	for i = index, #self.bars, 1 do
		local bar = self.bars[i]
		bar:Hide()
	end
end

local function FindAuras(self, unit)
	for spid in pairs(self.actives) do
		if self.actives[spid].data.filter ~= "CD" and self.actives[spid].data.filter ~= "ICD" and self.actives[spid].data.unitID == unit then
			self.actives[spid] = nil
		end
	end

	for i = 1, 2 do
		local filter = (i == 1 and "HELPFUL" or "HARMFUL")
		local index = 1
		while true do
			local name, icon, count, _, duration, expirationTime, caster, _, _, spid = UnitAura(unit, index, filter)
			if not name then break end

			local data = SpellGroups[self.Id].spells[name] or SpellGroups[self.Id].spells[spid]
			if data and (data.caster ~= 1 and (caster == data.caster or data.caster == "all") or MyUnits[caster]) and data.unitID == unit then
				if data.absID then
					data = SpellGroups[self.Id].spells[spid]
				end
				local isTalent = data.talentID and select(10, GetTalentInfoByID(data.talentID))
				if ((data.filter == "BUFF" and filter == "HELPFUL") or (data.filter == "DEBUFF" and filter == "HARMFUL")) and (not data.spec or data.spec == K.Spec) and (not data.talentID or isTalent) then
					if not data.count or count >= data.count then
						self.actives[spid] = {data = data, name = name, icon = icon, count = count, start = expirationTime - duration, duration = duration, spid = spid, sort = data.sort}
					end
				elseif data.filter == "ICD" and (data.trigger == "BUFF" or data.trigger == "DEBUFF") and (not data.spec or data.spec == T.Spec) and (not data.talentID or isTalent) then
					if data.slotID then
						local slotLink = GetInventoryItemLink("player", data.slotID)
						_, _, _, _, _, _, _, _, _, icon = GetItemInfo(slotLink)
					end
					self.actives[spid] = {data = data, name = name, icon = icon, count = count, start = GetTime(), duration = data.duration, spid = spid, sort = data.sort}
				end
			end
			index = index + 1
		end
	end
	Filger.DisplayActives(self)
end

function Filger:OnEvent(event, unit, _, castID)
	if C["Filger"].DisableCD == true and self.Name == "COOLDOWN" then return end
	if C["Filger"].DisablePvP == true and (self.Name == "PVE/PVP_DEBUFF" or self.Name == "T_BUFF") then return end
	if event == "UNIT_AURA" and (unit == "player" or unit == "target" or unit == "pet" or unit == "focus") then
		FindAuras(self, unit)
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" then
		local name, _, icon = GetSpellInfo(castID)
		local data = SpellGroups[self.Id].spells[name]
		if data and data.filter == "ICD" and data.trigger == "NONE" and (not data.spec or data.spec == T.Spec) then
			self.actives[castID] = {data = data, name = name, icon = icon, count = nil, start = GetTime(), duration = data.duration, spid = castID, sort = data.sort}
			Filger.DisplayActives(self)
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		FindAuras(self, "target")
	elseif event == "PLAYER_FOCUS_CHANGED" then
		FindAuras(self, "focus")
	elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELL_UPDATE_COOLDOWN" then
		if event ~= "SPELL_UPDATE_COOLDOWN" then
			local _, instanceType = IsInInstance()
			if instanceType == "raid" then
				self:UnregisterEvent("UNIT_AURA")
				self:SetScript("OnUpdate", function(timer, elapsed)
					timer.elapsed = (timer.elapsed or 0) + elapsed
					if timer.elapsed < 0.1 then return end
					timer.elapsed = 0
					FindAuras(self, "player")
					if UnitExists("target") then
						FindAuras(self, "target")
					end
					if UnitExists("pet") then
						FindAuras(self, "pet")
					end
					if UnitExists("focus") then
						FindAuras(self, "focus")
					end
				end)
			else
				self:SetScript("OnUpdate", nil)
				self:RegisterEvent("UNIT_AURA")
			end

			for spid in pairs(self.actives) do
				if self.actives[spid].data.filter ~= "CD" and self.actives[spid].data.filter ~= "ICD" then
					self.actives[spid] = nil
				end
			end
		elseif event == "SPELL_UPDATE_COOLDOWN" then
			for spid in pairs(self.actives) do
				if self.actives[spid].data.filter == "CD" then
					self.actives[spid] = nil
				end
			end
		end

		for i = 1, #C["FilgerSpells"][K.Class][self.Id], 1 do
			local data = C["FilgerSpells"][K.Class][self.Id][i]
			local found = false
			local spellName, name, icon, count, duration, expirationTime, caster, start, spid, filter

			if event == "SPELL_UPDATE_COOLDOWN" or event == "PLAYER_ENTERING_WORLD" then
				if data.filter == "CD" and (not data.spec or data.spec == T.Spec) then
					if data.spellID then
						name, _, icon = GetSpellInfo(data.spellID)
						if name then
							if data.absID then
								start, duration = GetSpellCooldown(data.spellID)
							else
								start, duration = GetSpellCooldown(name)
							end
							spid = data.spellID
						end
					elseif data.slotID then
						spid = data.slotID
						local slotLink = GetInventoryItemLink("player", data.slotID)
						if slotLink then
							name, _, _, _, _, _, _, _, _, icon = GetItemInfo(slotLink)
							start, duration = GetInventoryItemCooldown("player", data.slotID)
						end
					end
					if name and (duration or 0) > 1.5 then
						found = true
					end
				end
			end
			if event ~= "SPELL_UPDATE_COOLDOWN" then
				local isTalent = data.talentID and select(10, GetTalentInfoByID(data.talentID))
				if (data.filter == "BUFF" or data.filter == "DEBUFF") and (not data.spec or data.spec == T.Spec) and (not data.talentID or isTalent) then
					local postfix = data.caster == "player" and "|PLAYER" or ""
					if data.filter == "BUFF" then
						filter = "HELPFUL"..postfix
					else
						filter = "HARMFUL"..postfix
					end
					spellName = GetSpellInfo(data.spellID)
					if spellName then
						name, spid, icon, count, duration, expirationTime, caster = Filger:UnitAura(data.unitID, data.spellID, spellName, filter, data.absID)
						if name and (data.caster ~= 1 and (caster == data.caster or data.caster == "all") or MyUnits[caster]) then
							if not data.count or count >= data.count then
								start = expirationTime - duration
								found = true
							end
						end
					end
				end
			end

			if found then
				if not self.actives[spid] then
					self.actives[spid] = {data = data, name = name, icon = icon, count = count, start = start, duration = duration, spid = spid, sort = data.sort}
					if K.Class == "DEATHKNIGHT" and data.filter == "CD" and self.actives[spid].duration < 10 then -- Hide out of rune cd
						self.actives[spid] = nil
					end
				else
					if data.filter ~= "ICD" and (self.actives[spid].count ~= count or self.actives[spid].start ~= start or self.actives[spid].duration ~= duration) then
						self.actives[spid].count = count
						self.actives[spid].start = start
						self.actives[spid].duration = duration
					end
				end
			end
		end

		if self.actives then
			Filger.DisplayActives(self)
		end
	end
end

if C["FilgerSpells"] and C["FilgerSpells"]["ALL"] then
	if not C["FilgerSpells"][K.Class] then
		C["FilgerSpells"][K.Class] = {}
	end

	for i = 1, #C["FilgerSpells"]["ALL"], 1 do
		local merge = false
		local spellListAll = C["FilgerSpells"]["ALL"][i]
		local spellListClass = nil
		for j = 1, #C["FilgerSpells"][K.Class], 1 do
			spellListClass = C["FilgerSpells"][K.Class][j]
			local mergeAll = spellListAll.Merge or false
			local mergeClass = spellListClass.Merge or false
			if spellListClass.Name == spellListAll.Name and (mergeAll or mergeClass) then
				merge = true
				break
			end
		end
		if not merge or not spellListClass then
			table.insert(C["FilgerSpells"][K.Class], C["FilgerSpells"]["ALL"][i])
		else
			for j = 1, #spellListAll, 1 do
				table.insert(spellListClass, spellListAll[j])
			end
		end
	end
end

if K.CustomFilgerSpell then
	for _, data in pairs(K.CustomFilgerSpell) do
		for class, _ in pairs(C["FilgerSpells"]) do
			if class == K.Class then
				for i = 1, #C["FilgerSpells"][class], 1 do
					if C["FilgerSpells"][class][i]["Name"] == data[1] then
						table.insert(C["FilgerSpells"][class][i], data[2])
					end
				end
			end
		end
	end
end

if C["FilgerSpells"] and C["FilgerSpells"][K.Class] then
	for index in pairs(C["FilgerSpells"]) do
		if index ~= K.Class then
			C["FilgerSpells"][index] = nil
		end
	end

	local idx = {}
	for i = 1, #C["FilgerSpells"][K.Class], 1 do
		local jdx = {}
		local data = C["FilgerSpells"][K.Class][i]
		local group = {spells = {}}

		for j = 1, #data, 1 do
			local name
			if data[j].spellID then
				name = GetSpellInfo(data[j].spellID)
			else
				local slotLink = GetInventoryItemLink("player", data[j].slotID)
				if slotLink then
					name = GetItemInfo(slotLink)
				end
			end
			if name or data[j].slotID then
				local id
				if data[j].absID then
					id = data[j].spellID or data[j].slotID
				else
					id = GetSpellInfo(data[j].spellID) or data[j].slotID
				end
				data[j].sort = j
				group.spells[id] = data[j]
			end
			if not name and not data[j].slotID then
				print("|cffff0000WARNING: spell/slot ID ["..(data[j].spellID or data[j].slotID or "UNKNOWN").."] no longer exists! Report this to Kkthnx.|r")
				table.insert(jdx, j)
			end
		end

		for _, v in ipairs(jdx) do
			table.remove(data, v)
		end

		group.data = data
		table.insert(SpellGroups, i, group)

		if #data == 0 then
			print("|cffff0000WARNING: section ["..data.Name.."] is empty! Report this to Kkthnx.|r")
			table.insert(idx, i)
		end
	end

	for _, v in ipairs(idx) do
		table.remove(C["FilgerSpells"][K.Class], v)
	end

	for i = 1, #SpellGroups, 1 do
		local data = SpellGroups[i].data
		local frame = CreateFrame("Frame", "FilgerFrame"..i.."_"..data.Name, K.PetBattleHider)
		frame.Id = i
		frame.Name = data.Name
		frame.Direction = data.Direction or "DOWN"
		frame.IconSide = data.IconSide or "LEFT"
		frame.Mode = data.Mode or "ICON"
		frame.Interval = data.Interval or 3
		frame:SetAlpha(data.Alpha or 1)
		frame.IconSize = data.IconSize or C["Filger"].BuffSize
		frame.BarWidth = data.BarWidth or 186
		frame.Position = data.Position or "CENTER"
		frame:SetPoint(unpack(data.Position))
		frame.actives = {}

		if C["Filger"].TestMode then
			frame.actives = {}
			for j = 1, math.min(C["Filger"].MaxTestIcon, #C["FilgerSpells"][K.Class][i]), 1 do
				local data = C["FilgerSpells"][K.Class][i][j]
				local name, icon
				if data.spellID then
					name, _, icon = GetSpellInfo(data.spellID)
				elseif data.slotID then
					local slotLink = GetInventoryItemLink("player", data.slotID)
					if slotLink then
						name, _, _, _, _, _, _, _, _, icon = GetItemInfo(slotLink)
					end
				end
				frame.actives[j] = {data = data, name = name, icon = icon, count = 9, start = 0, duration = 0, spid = data.spellID or data.slotID, sort = data.sort}
			end
			Filger.DisplayActives(frame)
		else
			for j = 1, #C["FilgerSpells"][K.Class][i], 1 do
				local data = C["FilgerSpells"][K.Class][i][j]
				if data.filter == "CD" then
					frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
					break
				elseif data.trigger == "NONE" then
					frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
					break
				end
				if data.filter ~= "CD" then
					frame:RegisterEvent("UNIT_AURA")
					break
				end
			end
			frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
			frame:RegisterEvent("PLAYER_TARGET_CHANGED")
			frame:RegisterEvent("PLAYER_ENTERING_WORLD")
			frame:SetScript("OnEvent", Filger.OnEvent)
		end
	end
end