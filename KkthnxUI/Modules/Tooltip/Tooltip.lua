local K, C, L, _ = select(2, ...):unpack()
if C.Tooltip.Enable ~= true then return end

local _G = _G
local gsub, find, format = string.gsub, string.find, string.format
local min, max = math.min, math.max
local next = next
local pairs = pairs
local select = select
local unpack = unpack
local CreateFrame = CreateFrame
local GetGuildInfo = GetGuildInfo
local GetItem, GetItemInfo, GetItemQualityColor = GetItem, GetItemInfo, GetItemQualityColor
local GetMouseFocus = GetMouseFocus
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown
local LEVEL = LEVEL
local RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS = RAID_CLASS_COLORS, CUSTOM_CLASS_COLORS
local ShortValue = K.ShortValue
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsAFK, UnitIsDND = UnitIsAFK, UnitIsDND
local UnitIsDead = UnitIsDead
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPVPName = UnitPVPName
local UnitReaction = UnitReaction
local hooksecurefunc = hooksecurefunc

local Tooltip = CreateFrame("Frame", "Tooltip", UIParent)
local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]

local Tooltips = {
	GameTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3,
	ItemRefTooltip,
}

local ItemRefTooltip = ItemRefTooltip
local linkTypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}

local classification = {
	worldboss = "|cffAF5050Boss|r",
	rareelite = "|cffAF5050+ Rare|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050Rare|r",
}

local NeedBackdropBorderRefresh = true

local TipAnchor = CreateFrame("Frame", "TooltipAnchor", UIParent)
TipAnchor:SetSize(200, 40)
TipAnchor:SetPoint(unpack(C.Position.Tooltip))

local function UpdateTooltip(self)
	local owner = self:GetOwner()
	if not owner then return end
	local name = owner:GetName()

	-- mouseover
	if self:GetAnchorType() == "ANCHOR_CURSOR" then
		-- h4x for world object tooltip border showing last border color
		-- or showing background sometime ~blue :x
		if NeedBackdropBorderRefresh then
			self:ClearAllPoints()
			NeedBackdropBorderRefresh = false
			self:SetBackdropColor(unpack(C.Media.Backdrop_Color))
			if not C.Tooltip.Cursor then
				self:SetBackdropBorderColor(unpack(C.Media.Border_Color))
			end
		end
	elseif self:GetAnchorType() == "ANCHOR_NONE" and InCombatLockdown() and C.Tooltip.HideCombat == true then
		self:Hide()
		return
	end

	if self:GetAnchorType() == "ANCHOR_NONE" and TooltipAnchor then
			if C["Bag"].enable == true and StuffingFrameBags:IsShown() then
				self:ClearAllPoints()
				self:SetPoint("BOTTOMRIGHT", StuffingFrameBags, "TOPRIGHT", 0, 4)
			else
				self:ClearAllPoints()
				self:SetPoint("BOTTOMRIGHT", TooltipAnchor, "BOTTOMRIGHT", 0, 0)
			end
		end
	end

local function SetTooltipDefaultAnchor(self, parent)
	if C.Tooltip.Cursor == true then
		if parent ~= UIParent then
			self:SetOwner(parent, "ANCHOR_NONE")
		else
			self:SetOwner(parent, "ANCHOR_CURSOR")
		end
	else
		self:SetOwner(parent, "ANCHOR_NONE")
	end

	self:SetPoint("BOTTOMRIGHT", TooltipAnchor, "BOTTOMRIGHT", 0, 0)
end
hooksecurefunc("GameTooltip_SetDefaultAnchor", SetTooltipDefaultAnchor)

GameTooltip:HookScript("OnUpdate", function(self, ...) UpdateTooltip(self) end)

local function Hex(color)
	return string.format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
end

local function GetColor(unit)
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		local color = RAID_CLASS_COLORS[class]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b
		return Hex(color), r, g, b
	else
		local color = BETTER_FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b
		return Hex(color), r, g, b
	end
end

-- update HP value on status bar
local function StatusBarOnValueChanged(self, value)
	if not value then
		return
	end
	local min, max = self:GetMinMaxValues()

	if (value < min) or (value > max) then
		return
	end
	local _, unit = GameTooltip:GetUnit()

	-- fix target of target returning nil
	if (not unit) then
		local GMF = GetMouseFocus()
		unit = GMF and GMF:GetAttribute("unit")
	end

	if not self.text then
		self.text = self:CreateFontString(nil, "OVERLAY")
		local position = TooltipAnchor:GetPoint()
		if position:match("TOP") then
			self.text:SetPoint("CENTER", GameTooltipStatusBar, 0, -6)
		else
			self.text:SetPoint("CENTER", GameTooltipStatusBar, 0, 6)
		end

		self.text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		self.text:Show()
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			local hp = ShortValue(min).." / "..ShortValue(max)
			if UnitIsGhost(unit) then
				self.text:SetText(L_TOOLTIP_UNIT_GHOST)
			elseif min == 0 or UnitIsDead(unit) or UnitIsGhost(unit) then
				self.text:SetText(L_TOOLTIP_UNIT_DEAD)
			else
				self.text:SetText(hp)
			end
		end
	else
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			self.text:Show()
			local hp = ShortValue(min).." / "..ShortValue(max)
			if UnitIsGhost(unit) then
				self.text:SetText(L_TOOLTIP_UNIT_GHOST)
			elseif min == 0 or UnitIsDead(unit) or UnitIsGhost(unit) then
				self.text:SetText(L_TOOLTIP_UNIT_DEAD)
			else
				self.text:SetText(hp)
			end
		else
			self.text:Hide()
		end
	end
end
GameTooltipStatusBar:SetScript("OnValueChanged", StatusBarOnValueChanged)

local healthBar = GameTooltipStatusBar
healthBar:ClearAllPoints()
healthBar:SetHeight(6)
healthBar:SetPoint("BOTTOMLEFT", healthBar:GetParent(), "TOPLEFT", 4, 1)
healthBar:SetPoint("BOTTOMRIGHT", healthBar:GetParent(), "TOPRIGHT", -4, 1)
healthBar:SetStatusBarTexture(C.Media.Texture)

local healthBarBG = CreateFrame("Frame", "StatusBarBG", healthBar)
healthBarBG:SetFrameLevel(healthBar:GetFrameLevel() - 1)
healthBarBG:SetPoint("TOPLEFT", -1, 1)
healthBarBG:SetPoint("BOTTOMRIGHT", 1, -1)
healthBarBG:CreatePixelShadow(2)
healthBarBG:SetBackdrop(K.BorderBackdrop)
healthBarBG:SetBackdropColor(unpack(C.Media.Backdrop_Color))

-- Raid icon
local ricon = GameTooltip:CreateTexture("GameTooltipRaidIcon", "OVERLAY")
ricon:SetSize(18, 18)
ricon:SetPoint("BOTTOM", GameTooltip, "TOP", 0, 5)

GameTooltip:HookScript("OnHide", function(self) ricon:SetTexture(nil) end)

-- Add "Targeted By" line
local targetedList = {}
local ClassColors = {}
local token
for class, color in next, RAID_CLASS_COLORS do
	ClassColors[class] = ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
end

local function AddTargetedBy()
	local numParty, numRaid = GetNumSubgroupMembers(), GetNumGroupMembers()
	if numParty > 0 or numRaid > 0 then
		for i = 1, (numRaid > 0 and numRaid or numParty) do
			local unit = (numRaid > 0 and "raid"..i or "party"..i)
			if UnitIsUnit(unit.."target", token) and not UnitIsUnit(unit, "player") then
				local _, class = UnitClass(unit)
				targetedList[#targetedList + 1] = ClassColors[class]
				targetedList[#targetedList + 1] = UnitName(unit)
				targetedList[#targetedList + 1] = "|r, "
			end
		end
		if #targetedList > 0 then
			targetedList[#targetedList] = nil
			GameTooltip:AddLine(" ", nil, nil, nil, 1)
			local line = _G["GameTooltipTextLeft"..GameTooltip:NumLines()]
			if not line then return end
			line:SetFormattedText(L_TOOLTIP_WHO_TARGET.." (|cffffffff%d|r): %s", (#targetedList + 1) / 3, table.concat(targetedList))
			wipe(targetedList)
		end
	end
end

local function OnTooltipSetUnit(self)
	local lines = self:NumLines()
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))

	-- A mage's mirror images sometimes doesn't return a unit, this would fix it
	if (not unit) and (UnitExists("mouseover")) then
		unit = "mouseover"
	end

	-- Sometimes when you move your mouse quicky over units in the worldframe, we can get here without a unit
	if not unit then self:Hide() return end

	-- for hiding tooltip on unitframes
	if (self:GetOwner() ~= UIParent and C.Tooltip.HideUnitFrames) then self:Hide() return end

	-- A "mouseover" unit is better to have as we can then safely say the tip should no longer show when it becomes invalid.
	if (UnitIsUnit(unit,"mouseover")) then
		unit = "mouseover"
	end

	local race = UnitRace(unit)
	local class = UnitClass(unit)
	local level = UnitLevel(unit)
	local guild = GetGuildInfo(unit)
	local name, realm = UnitName(unit)
	local crtype = UnitCreatureType(unit)
	local classif = UnitClassification(unit)
	local title = UnitPVPName(unit)
	local r, g, b = GetQuestDifficultyColor(level).r, GetQuestDifficultyColor(level).g, GetQuestDifficultyColor(level).b

	local color = GetColor(unit)
	if not color then color = "|CFFFFFFFF" end
	if not realm then realm = "" end

	--if title or name then
	--	_G["GameTooltipTextLeft1"]:SetFormattedText("%s%s%s", color, title or name, realm and realm ~= "" and " - "..realm.."|r" or "|r")
	--end

	if UnitPVPName(unit) and C.Tooltip.Title then
		name = UnitPVPName(unit)
	end

	_G["GameTooltipTextLeft1"]:SetFormattedText("%s%s%s", color, name, "|r")
	if realm and realm ~= "" and C.Tooltip.Realm then
		self:AddLine(FRIENDS_LIST_REALM.."|cffffffff"..realm.."|r")
	end

	if(UnitIsPlayer(unit)) then
		if UnitIsAFK(unit) then
			self:AppendText((" %s"):format(CHAT_FLAG_AFK))
		elseif UnitIsDND(unit) then
			self:AppendText((" %s"):format(CHAT_FLAG_DND))
		end

		local offset = 2
		if guild then
			_G["GameTooltipTextLeft2"]:SetFormattedText("%s", IsInGuild() and GetGuildInfo("player") == guild and "|cff0090ff"..guild.."|r" or "|cff00ff10"..guild.."|r")
			offset = offset + 1
		end

		for i= offset, lines do
			if(_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", r*255, g*255, b*255, level > 0 and level or "??", race or "", color, class or "".."|r")
				break
			end
		end
	else
		for i = 2, lines do
			if((_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) or (crtype and _G["GameTooltipTextLeft"..i]:GetText():find("^"..crtype))) then
				if level == -1 and classif == "elite" then classif = "worldboss" end
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level ~= 0 and level or "", classification[classif] or "", crtype or "")
				break
			end
		end
	end

	local pvpLine
	for i = 1, lines do
		local text = _G["GameTooltipTextLeft"..i]:GetText()
		if text and text == PVP_ENABLED then
			pvpLine = _G["GameTooltipTextLeft"..i]
			pvpLine:SetText()
			break
		end
	end

	-- ToT line
	if UnitExists(unit.."target") and unit~="player" then
		local hex, r, g, b = GetColor(unit.."target")
		if not r and not g and not b then r, g, b = 1, 1, 1 end
		GameTooltip:AddLine(UnitName(unit.."target"), r, g, b)
	end

	if C.Tooltip.RaidIcon == true then
		local raidIndex = GetRaidTargetIndex(unit)
		if raidIndex then
			ricon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..raidIndex)
		end
	end

	if C.Tooltip.WhoTargetting == true then
		token = unit AddTargetedBy()
	end

	-- Sometimes this wasn't getting reset, the fact a cleanup isn't performed at this point, now that it was moved to "OnTooltipCleared" is very bad, so this is a fix
	self.fadeOut = nil
end
GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

-- Adds guild rank to tooltips(GuildRank by Meurtcriss)
if C.Tooltip.Rank == true then
	GameTooltip:HookScript("OnTooltipSetUnit", function(self, ...)
		-- Get the unit
		local _, unit = self:GetUnit()
		if not unit then
			local mFocus = GetMouseFocus()
			if mFocus and mFocus.unit then
				unit = mFocus.unit
			end
		end
		-- Get and display guild rank
		if UnitIsPlayer(unit) then
			local guildName, guildRank = GetGuildInfo(unit)
			if guildName then
				self:AddLine(RANK..": |cffffffff"..guildRank.."|r")
			end
		end
	end)
end

local BorderColor = function(self)
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))

	local reaction = unit and UnitReaction(unit, "player")
	local player = unit and UnitIsPlayer(unit)
	local connected = unit and UnitIsConnected(unit)
	local dead = unit and UnitIsDead(unit)
	local r, g, b

	if player then
		local class = select(2, UnitClass(unit))
		local c = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
		r, g, b = c.r, c.g, c.b
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	elseif reaction then
		local c = BETTER_FACTION_BAR_COLORS[reaction]
		r, g, b = c.r, c.g, c.b
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	elseif C.Tooltip.QualityBorder == true then
		local _, link = self:GetItem()
		local quality = link and select(3, GetItemInfo(link))
		if quality and quality >= 2 then
			local r, g, b = GetItemQualityColor(quality)
			self:SetBackdropBorderColor(r, g, b)
		else
			self:SetBackdropBorderColor(unpack(C.Media.Border_Color))
			healthBarBG:SetBackdropBorderColor(unpack(C.Media.Border_Color))
			healthBar:SetStatusBarColor(unpack(C.Media.Border_Color))
		end
	end

	-- need this
	NeedBackdropBorderRefresh = true
end

local SetStyle = function(self)
	self:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	self:SetBackdropBorderColor(unpack(C.Media.Border_Color))
	BorderColor(self)
end

Tooltip:RegisterEvent("PLAYER_ENTERING_WORLD")
Tooltip:RegisterEvent("ADDON_LOADED")
Tooltip:SetScript("OnEvent", function(self, event, addon)
	if event == "PLAYER_ENTERING_WORLD" then
		for _, tt in pairs(Tooltips) do
			tt:SetBackdrop(K.Backdrop)
			tt:HookScript("OnShow", SetStyle)
		end

		ItemRefTooltip:HookScript("OnTooltipSetItem", SetStyle)
		ItemRefTooltip:HookScript("OnShow", SetStyle)
		--FriendsTooltip:SetTemplate("Default")

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		-- move health status bar if anchor is found at top
		local position = TooltipAnchor:GetPoint()
		if position:match("TOP") then
			healthBar:ClearAllPoints()
			healthBar:SetPoint("TOPLEFT", healthBar:GetParent(), "BOTTOMLEFT", 2, -5)
			healthBar:SetPoint("TOPRIGHT", healthBar:GetParent(), "BOTTOMRIGHT", -2, -5)
		end

		-- Hide tooltips in combat for actions, pet actions and shapeshift
		if C.Tooltip.HideButtons == true then
			local CombatHideActionButtonsTooltip = function(self)
				if not IsShiftKeyDown() then
					self:Hide()
				end
			end

			hooksecurefunc(GameTooltip, "SetAction", CombatHideActionButtonsTooltip)
			hooksecurefunc(GameTooltip, "SetPetAction", CombatHideActionButtonsTooltip)
			hooksecurefunc(GameTooltip, "SetShapeshift", CombatHideActionButtonsTooltip)
		end
	end
end)