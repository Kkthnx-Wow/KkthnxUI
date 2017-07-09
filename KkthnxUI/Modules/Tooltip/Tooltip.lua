local K, C, L = unpack(select(2, ...))
if C.Tooltip.Enable ~= true then return end

-- Lua API
local _G = _G
local math_abs = math.abs
local math_floor = math.floor
local table_remove = table.remove
local format = string.format
local string_find = string.find
local string_sub = string.sub

-- Wow API
local CanInspect = _G.CanInspect
local CHAT_FLAG_AFK = _G.CHAT_FLAG_AFK
local CHAT_FLAG_DND = _G.CHAT_FLAG_DND
local ClearInspectPlayer = _G.ClearInspectPlayer
local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local DEAD = _G.DEAD
local FOREIGN_SERVER_LABEL = _G.FOREIGN_SERVER_LABEL
local GetAverageItemLevel = _G.GetAverageItemLevel
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local GetDetailedItemLevelInfo = _G.GetDetailedItemLevelInfo
local GetGuildInfo = _G.GetGuildInfo
local GetInspectSpecialization = _G.GetInspectSpecialization
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventorySlotInfo = _G.GetInventorySlotInfo
local GetItemCount = _G.GetItemCount
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMouseFocus = _G.GetMouseFocus
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetSpecializationRoleByID = _G.GetSpecializationRoleByID
local GetTime = _G.GetTime
local hooksecurefunc = _G.hooksecurefunc
local ID = _G.ID
local InCombatLockdown = _G.InCombatLockdown
local InspectFrame = _G.InspectFrame
local INTERACTIVE_SERVER_LABEL = _G.INTERACTIVE_SERVER_LABEL
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_REALM_RELATION_COALESCED = _G.LE_REALM_RELATION_COALESCED
local LE_REALM_RELATION_VIRTUAL = _G.LE_REALM_RELATION_VIRTUAL
local LEVEL = _G.LEVEL
local MAXIMUM = _G.MAXIMUM
local NONE = _G.NONE
local NotifyInspect = _G.NotifyInspect
local PVP = _G.PVP
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local STAT_AVERAGE_ITEM_LEVEL = _G.STAT_AVERAGE_ITEM_LEVEL
local TALENTS = _G.TALENTS
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitCreatureType = _G.UnitCreatureType
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local UnitIsAFK = _G.UnitIsAFK
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsDND = _G.UnitIsDND
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPVPName = _G.UnitPVPName
local UnitRace = _G.UnitRace
local UnitReaction = _G.UnitReaction
local UnitRealmRelationship = _G.UnitRealmRelationship
local UNKNOWN = _G.UNKNOWN

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, GameTooltipTextLeft2, TooltipAnchor, GameTooltipTextLeft1
-- GLOBALS: GameTooltipTextLeft1, GameTooltipTextLeft2, MaxHealth, ItemRefTooltip
-- GLOBALS: Health, InspectFrame

local Tooltip = CreateFrame("Frame")
local BackdropColor = {0, 0, 0}
local HealthBar = GameTooltipStatusBar
local HealthBarBG = CreateFrame("Frame", "StatusBarBG", HealthBar)

-- ItemLevel, TalentSpec
local ItemLevel, TalentSpec, LastUpdate = 0, "", 30
local InspectCache = {}
local LastInspectRequest = 0
local InspectDelay = 0.2
local InspectFreq = 2

Tooltip.ItemRefTooltip = ItemRefTooltip

Tooltip.Tooltips = {
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

local Classification = {
	worldboss = "|cffAF5050B |r",
	rareelite = "|cffAF5050R+ |r",
	elite = "|cffAF5050+ |r",
	rare = "|cffAF5050R |r",
	minus = "",
	normal = "",
}

Tooltip.SlotName = {
	"Head","Neck","Shoulder","Back","Chest","Wrist",
	"Hands","Waist","Legs","Feet","Finger0","Finger1",
	"Trinket0","Trinket1","MainHand","SecondaryHand"
}

function Tooltip:CreateAnchor()
	local Movers = K.Movers

	local Anchor = CreateFrame("Frame", "TooltipAnchor", UIParent)
	Anchor:SetSize(130, 36)
	Anchor:SetFrameStrata("TOOLTIP")
	Anchor:SetFrameLevel(Anchor:GetFrameLevel() + 400)
	Anchor:SetPoint(C.Position.Tooltip[1], C.Position.Tooltip[2], C.Position.Tooltip[3], C.Position.Tooltip[4], C.Position.Tooltip[5])

	self.Anchor = Anchor

	Movers:RegisterFrame(Anchor)
end

function Tooltip:SetTooltipDefaultAnchor(parent)
	local Anchor = TooltipAnchor

	self:SetOwner(Anchor)
	if C.Tooltip.Cursor then self:SetAnchorType("ANCHOR_CURSOR", 0, 5) else self:SetAnchorType("ANCHOR_TOPRIGHT", 0, -36) end
	if (self:GetOwner() ~= UIParent and InCombatLockdown() and C.Tooltip.HideCombat) then
		self:Hide()
		return
	end
end

function Tooltip:GetColor(unit)
	if (not unit) then
		return
	end

	if (UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local Class = select(2, UnitClass(unit))
		local Color = RAID_CLASS_COLORS[Class]

		if (not Color) then
			return
		end

		return "|c"..Color.colorStr, Color.r, Color.g, Color.b
	else
		local Reaction = UnitReaction(unit, "player")
		local Color = K.Colors.reaction[Reaction]

		if (not Color) then
			return
		end

		local Hex = K.RGBToHex(Color[1], Color[2], Color[3])

		return Hex, Color[1], Color[2], Color[3]
	end
end

function Tooltip:GetItemLevel(unit)
	local Total, Item = 0, 0
	local ArtifactEquipped = false
	local TotalSlots = 16

	for i = 1, #Tooltip.SlotName do
		local ItemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(("%sSlot"):format(Tooltip.SlotName[i])))

		if (ItemLink ~= nil) then
			local _, _, Rarity, _, _, _, _, _, EquipLoc = GetItemInfo(ItemLink)

			-- Check if we have an artifact equipped in main hand
			if (EquipLoc and EquipLoc == "INVTYPE_WEAPONMAINHAND" and Rarity and Rarity == 6) then
				ArtifactEquipped = true
			end

			-- If we have artifact equipped in main hand, then we should not count the offhand as it displays an incorrect item level
			if (not ArtifactEquipped or (ArtifactEquipped and EquipLoc and EquipLoc ~= "INVTYPE_WEAPONOFFHAND")) then
				local ItemLevel

				ItemLevel = GetDetailedItemLevelInfo(ItemLink)

				if (ItemLevel and ItemLevel > 0) then
					Item = Item + 1
					Total = Total + ItemLevel
				end

				-- Total slots depend if one/two handed weapon
				if (i == 15) then
					if (ArtifactEquipped or (EquipLoc and EquipLoc == "INVTYPE_2HWEAPON")) then
						TotalSlots = 15
					end
				end
			end
		end
	end

	if (Total < 1 or Item < TotalSlots) then
		return
	end

	return math_floor(Total / Item)
end

function Tooltip:GetTalentSpec(unit)
	local Spec

	if not unit then
		Spec = GetSpecialization()
	else
		Spec = GetInspectSpecialization(unit)
	end

	if(Spec and Spec > 0) then
		if (unit) then
			local Role = GetSpecializationRoleByID(Spec)

			if (Role) then
				local Name = select(2, GetSpecializationInfoByID(Spec))

				return Name
			end
		else
			local Name = select(2, GetSpecializationInfo(Spec))

			return Name
		end
	end
end

Tooltip:SetScript("OnUpdate", function(self, elapsed)
	if not (C.Tooltip.Talents) then
		self:Hide()
		self:SetScript("OnUpdate", nil)
	end

	self.NextUpdate = (self.NextUpdate or 0) - elapsed

	if (self.NextUpdate > 0) then return end

	if (self.NextUpdate) <= 0 then
		self:Hide()
		ClearInspectPlayer()

		local GUID = UnitGUID("mouseover")

		if not GUID then
			return
		end

		if (GUID == self.CurrentGUID) and (not (InspectFrame and InspectFrame:IsShown())) then
			self.LastGUID = self.CurrentGUID
			LastInspectRequest = GetTime()
			self:RegisterEvent("INSPECT_READY")
			NotifyInspect(self.CurrentUnit)
		end
	end
end)

Tooltip:SetScript("OnEvent", function(self, event, GUID)
	if GUID ~= self.LastGUID or (InspectFrame and InspectFrame:IsShown()) then
		self:UnregisterEvent("INSPECT_READY")

		return
	end

	local ItemLevel = self:GetItemLevel("mouseover")
	local TalentSpec = self:GetTalentSpec("mouseover")
	local CurrentTime = GetTime()
	local MatchFound

	for i, Cache in ipairs(InspectCache) do
		if Cache.GUID == GUID then
			Cache.ItemLevel = ItemLevel
			Cache.TalentSpec = TalentSpec
			Cache.LastUpdate = math_floor(CurrentTime)

			MatchFound = true

			break
		end
	end

	if (not MatchFound) then
		local GUIDInfo = {
			["GUID"] = GUID,
			["ItemLevel"] = ItemLevel,
			["TalentSpec"] = TalentSpec,
			["LastUpdate"] = math_floor(CurrentTime)
		}

		InspectCache[#InspectCache + 1] = GUIDInfo
	end

	if (#InspectCache > 50) then
		table_remove(InspectCache, 1)
	end

	GameTooltip:SetUnit("mouseover")

	ClearInspectPlayer()

	self:UnregisterEvent("INSPECT_READY")
end)

function Tooltip:OnTooltipSetUnit()
	local NumLines = self:NumLines()
	local GetMouseFocus = GetMouseFocus()
	local Unit = (select(2, self:GetUnit())) or (GetMouseFocus and GetMouseFocus.GetAttribute and GetMouseFocus:GetAttribute("unit"))

	if (not Unit) and (UnitExists("mouseover")) then
		Unit = "mouseover"
	end

	if (not Unit) then
		self:Hide()
		return
	end

	if (UnitIsUnit(Unit, "mouseover")) then
		Unit = "mouseover"
	end

	local Line1 = GameTooltipTextLeft1
	local Line2 = GameTooltipTextLeft2
	local Race = UnitRace(Unit)
	local Class = UnitClass(Unit)
	local Level = UnitLevel(Unit)
	local Guild, GuildRankName, _ = GetGuildInfo(Unit)
	local Name, Realm = UnitName(Unit)
	local CreatureType = UnitCreatureType(Unit)
	local CreatureClassification = UnitClassification(Unit)
	local Relationship = UnitRealmRelationship(Unit);
	local Title = UnitPVPName(Unit)
	local Color = Tooltip:GetColor(Unit)
	local R, G, B = GetCreatureDifficultyColor(Level).r, GetCreatureDifficultyColor(Level).g, GetCreatureDifficultyColor(Level).b

	if (not Color) then
		Color = "|cffffffff"
	end

	if (UnitIsPlayer(Unit)) then
		if Title then
			Name = Title
		end

		if(Realm and Realm ~= "") then
			if IsShiftKeyDown() then
				Name = Name.." - "..Realm
			elseif(Relationship == LE_REALM_RELATION_COALESCED) then
				Name = Name..FOREIGN_SERVER_LABEL
			elseif(Relationship == LE_REALM_RELATION_VIRTUAL) then
				Name = Name..INTERACTIVE_SERVER_LABEL
			end
		end
	end

	if Name then
		Line1:SetFormattedText("%s%s%s", Color, Name, "|r")
	end

	if (UnitIsPlayer(Unit)) then
		if (C.Tooltip.Talents and IsShiftKeyDown() and Level > 10) then

			ItemLevel = "..."
			TalentSpec = "..."

			if (Unit ~= "player") then
				Tooltip.CurrentGUID = UnitGUID(Unit)
				Tooltip.CurrentUnit = Unit

				for i, _ in pairs(InspectCache) do
					local Cache = InspectCache[i]

					if Cache.GUID == Tooltip.CurrentGUID then
						ItemLevel = Cache.ItemLevel or "..."
						TalentSpec = Cache.TalentSpec or "..."
						LastUpdate = Cache.LastUpdate and math_abs(Cache.LastUpdate - math_floor(GetTime())) or 30
					end
				end

				if (Unit and (CanInspect(Unit))) and (not (InspectFrame and InspectFrame:IsShown())) then
					local LastInspectTime = GetTime() - LastInspectRequest
					Tooltip.NextUpdate = (LastInspectTime > InspectFreq) and InspectDelay or (InspectFreq - LastInspectTime + InspectDelay)
					Tooltip:Show()
				end
			else
				local Current = GetAverageItemLevel()

				ItemLevel = math_floor(Current) or UNKNOWN

				TalentSpec = Tooltip:GetTalentSpec() or NONE
			end
		end

		if (UnitIsAFK(Unit)) then
			self:AppendText((" %s"):format("|cffff0000"..CHAT_FLAG_AFK.."|r"))
		elseif UnitIsDND(Unit) then
			self:AppendText((" %s"):format("|cffe7e716"..CHAT_FLAG_DND.."|r"))
		end
	end

	local Offset = 2
	if ((UnitIsPlayer(Unit) and Guild)) then
		if(C.Tooltip.Rank and IsShiftKeyDown()) then
			Guild = Guild.." - "..GuildRankName
		end

		Line2:SetFormattedText("%s", IsInGuild() and GetGuildInfo("player") == Guild and "|cff0090ff".. Guild .."|r" or "|cff00ff10".. Guild .."|r")
		Offset = Offset + 1
	end

	for i = Offset, NumLines do
		local Line = _G["GameTooltipTextLeft"..i]
		if (Line:GetText():find("^" .. LEVEL)) then
			if (UnitIsPlayer(Unit) and Race) then
				Line:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", R * 255, G * 255, B * 255, Level > 0 and Level or "??", Race, Color, Class .."|r")
			else
				Line:SetFormattedText("|cff%02x%02x%02x%s|r %s%s", R * 255, G * 255, B * 255, Level > 0 and Level or "??", Classification[CreatureClassification] or "", CreatureType or "" .."|r")
			end

			break
		end
	end

	if (UnitExists(Unit .. "target")) then
		local Hex, R, G, B = Tooltip:GetColor(Unit .. "target")

		if (not R) and (not G) and (not B) then
			R, G, B = 1, 1, 1
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(UnitName(Unit .. "target"), R, G, B)
	end

	if (C.Tooltip.HealthValue and self.Health and self.MaxHealth) then
		HealthBar.Text:SetText(K.ShortValue(Health) .. " / " .. K.ShortValue(MaxHealth))
	end

	if (C.Tooltip.Talents and IsShiftKeyDown() and UnitIsPlayer(Unit) and Level > 10) then

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(TALENTS, TalentSpec, nil, nil, nil, 0/255, 255/255, 16/255)
		GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL, ItemLevel, nil, nil, nil, 0/255, 255/255, 16/255) -- Use string ITEM_LEVEL_ABBR if you want this shorter.
	end

	self.fadeOut = nil
end

function Tooltip:SetColor()
	local GetMouseFocus = GetMouseFocus()

	local Unit = select(2, self:GetUnit()) or (GetMouseFocus and GetMouseFocus.GetAttribute and GetMouseFocus:GetAttribute("unit"))
	if (not Unit) and (UnitExists("mouseover")) then
		Unit = "mouseover"
	end

	self:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
	self:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])

	local Reaction = Unit and UnitReaction(Unit, "player")
	local Player = Unit and UnitIsPlayer(Unit)
	local R, G, B

	if Player then
		local Class = select(2, UnitClass(Unit))
		local Color = K.Colors.class[Class]
		if Color then -- thanks to liquidbase for this fix.
			R, G, B = Color[1], Color[2], Color[3]
			HealthBar:SetStatusBarColor(R, G, B)
			HealthBar:SetBackdropBorderColor(R, G, B)
			self:SetBackdropBorderColor(R, G, B)
		end
	elseif Reaction then
		local Color = K.Colors.reaction[Reaction]

		R, G, B = Color[1], Color[2], Color[3]
		HealthBar:SetStatusBarColor(R, G, B)
		HealthBar:SetBackdropBorderColor(R, G, B)
		self:SetBackdropBorderColor(R, G, B)
	else
		local Link = select(2, self:GetItem())
		local Quality = Link and select(3, GetItemInfo(Link))

		if (Quality and Quality >= 2) and not K.CheckAddOn("Pawn") then
			R, G, B = GetItemQualityColor(Quality)
			self:SetBackdropBorderColor(R, G, B)
		else
			HealthBar:SetStatusBarColor(K.Colors.reaction[5][1], K.Colors.reaction[5][2], K.Colors.reaction[5][3])
			HealthBar:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
			self:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
		end
	end
end

function Tooltip:CheckBackdropColor()
	local r, g, b = GameTooltip:GetBackdropColor()
	r = K.Round(r, 1)
	g = K.Round(g, 1)
	b = K.Round(b, 1)
	local red, green, blue = C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3]
	local alpha = C.Media.Backdrop_Color[4]

	if(r ~= red or g ~= green or b ~= blue) then
		GameTooltip:SetBackdropColor(red, green, blue, alpha)
	end
end

function Tooltip:OnUpdate(elapsed)
	local Owner = self:GetOwner()

	if (not Owner) then
		return
	end

	if (Owner:IsForbidden()) then
		return
	end

	local Owner = self:GetOwner():GetName()
	local Anchor = self:GetAnchorType()

	-- This ensures that default anchored world frame tips have the proper color.
	if (Owner == "UIParent" and Anchor == "ANCHOR_CURSOR") then
		self:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
		self:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
	end
end

function Tooltip:Skin()
	if (not self.IsSkinned) then
		self:SetTemplate()
		self.IsSkinned = true
	end

	if not self:IsForbidden() then
 		Tooltip.SetColor(self)
 	end
end

hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unit, index, filter)
	local _, _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)
	if id and C.Tooltip.SpellID then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
			self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("|c%s%s|r", color.colorStr, name))
		else
			self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		end

		self:Show()
	end
end)

function Tooltip:OnTooltipSetSpell()
	local id = select(3, self:GetSpell())
	if not id or not C.Tooltip.SpellID then return end

	local displayString = ("|cFFCA3C3C%s|r %d"):format(ID, id)
	local lines = self:NumLines()
	local isFound
	for i = 1, lines do
		local line = _G[("GameTooltipTextLeft%d"):format(i)]
		if line and line:GetText() and line:GetText():find(displayString) then
			isFound = true;
			break
		end
	end

	if not isFound then
		self:AddLine(displayString)
		self:Show()
	end
end

hooksecurefunc("SetItemRef", function(link)
	if string_find(link, "^spell:") and C.Tooltip.SpellID then
		local id = string_sub(link, 7)
		ItemRefTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		ItemRefTooltip:Show()
	end
end)

function Tooltip:OnTooltipSetItem()
	local Item, Link = self:GetItem()
	local ItemCount = GetItemCount(Link)
	local Left = " "
	local Right = " "

	if Link ~= nil and C.Tooltip.SpellID and IsShiftKeyDown() then
		Left = (("|cFFCA3C3C%s|r %s"):format(ID, Link)):match(":(%w+)")
	end

	if C.Tooltip.ItemCount and IsShiftKeyDown() then
		Right = ("|cFFCA3C3C%s|r %d"):format("Count", ItemCount)
	end

	if Left ~= " " or Right ~= " " then
		self:AddLine(" ")
		self:AddDoubleLine(Left, Right)
	end
end

function Tooltip:OnValueChanged()
	if (not C.Tooltip.HealthValue) then
		return
	end

	local unit = select(2, self:GetParent():GetUnit())
	if(not unit) then
		local GMF = GetMouseFocus()
		if (GMF and GMF.GetAttribute and GMF:GetAttribute("unit")) then
			unit = GMF:GetAttribute("unit")
		end
	end

	local _, Max = HealthBar:GetMinMaxValues()
	local Value = HealthBar:GetValue()
	if (Max == 1) then
		self.Text:Hide()
	else
		self.Text:Show()
	end

	if (Value == 0 or (unit and UnitIsDeadOrGhost(unit))) then
		self.Text:SetText("|cffd94545"..DEAD.."|r")
	else
		self.Text:SetText(K.ShortValue(Value) .. " / " .. K.ShortValue(Max))
	end
end

function Tooltip:Enable()
	if (not C.Tooltip.Enable) then
		return
	end

	self:CreateAnchor()

	hooksecurefunc("GameTooltip_SetDefaultAnchor", self.SetTooltipDefaultAnchor)

	for _, Tooltip in pairs(Tooltip.Tooltips) do
		if Tooltip == GameTooltip then
			Tooltip:HookScript("OnUpdate", self.OnUpdate)
			Tooltip:HookScript("OnTooltipSetUnit", self.OnTooltipSetUnit)
			Tooltip:HookScript("OnTooltipSetItem", self.OnTooltipSetItem)
			Tooltip:HookScript("OnTooltipSetSpell", self.OnTooltipSetSpell)
			Tooltip:HookScript("OnSizeChanged", self.CheckBackdropColor)
			Tooltip:HookScript("OnUpdate", self.CheckBackdropColor) --There has to be a more elegant way of doing this.
			Tooltip:RegisterEvent("CURSOR_UPDATE", self.CheckBackdropColor)
		end

		Tooltip:HookScript("OnShow", self.Skin)
		if Tooltip.BackdropFrame then
			Tooltip.BackdropFrame:Kill()
		end
	end

	HealthBar:SetScript("OnValueChanged", self.OnValueChanged)
	HealthBar:SetStatusBarTexture(C.Media.Texture)
	HealthBar:CreateShadow()
	HealthBar:ClearAllPoints()
	HealthBar:SetPoint("BOTTOMLEFT", HealthBar:GetParent(), "TOPLEFT", 4, 2)
	HealthBar:SetPoint("BOTTOMRIGHT", HealthBar:GetParent(), "TOPRIGHT", -4, 2)

	HealthBarBG:SetFrameLevel(HealthBar:GetFrameLevel() - 1)
	HealthBarBG:SetPoint("TOPLEFT", -1, 1)
	HealthBarBG:SetPoint("BOTTOMRIGHT", 1, -1)
	HealthBarBG:SetBackdrop(K.BorderBackdrop)
	HealthBarBG:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])

	if C.Tooltip.HealthValue then
		HealthBar.Text = HealthBar:CreateFontString(nil, "OVERLAY")
		HealthBar.Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		HealthBar.Text:SetPoint("CENTER", HealthBar, "CENTER", 0, 6)
		HealthBar.Text:SetTextColor(1, 1, 1)
	end
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function()
	Tooltip:Enable()
end)