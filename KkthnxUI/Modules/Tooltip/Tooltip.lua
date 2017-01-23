local K, C, L = unpack(select(2, ...))
if C.Tooltip.Enable ~= true then return end

-- Lua API
local _G = _G
local math_abs = math.abs
local math_floor = math.floor
local pairs = pairs
local select = select
local table_remove = table.remove
local unpack = unpack

-- Wow API
local CanInspect = CanInspect
local CHAT_FLAG_AFK = CHAT_FLAG_AFK
local CHAT_FLAG_DND = CHAT_FLAG_DND
local CreateFrame = CreateFrame
local FOREIGN_SERVER_LABEL = FOREIGN_SERVER_LABEL
local GetAverageItemLevel = GetAverageItemLevel
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetGuildInfo = GetGuildInfo
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMouseFocus = GetMouseFocus
local GetTime = GetTime
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local INTERACTIVE_SERVER_LABEL = INTERACTIVE_SERVER_LABEL
local IsAltKeyDown = IsAltKeyDown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local LE_REALM_RELATION_COALESCED = LE_REALM_RELATION_COALESCED
local LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_VIRTUAL
local LEVEL = LEVEL
local RaidColors = RAID_CLASS_COLORS
local UIParent = UIParent
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitIsAFK = UnitIsAFK
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDND = UnitIsDND
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local UnitRace = UnitRace
local UnitReaction = UnitReaction
local UnitRealmRelationship = UnitRealmRelationship

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: DEAD, GameTooltip, GameTooltipTextLeft2, TooltipAnchor, GameTooltipTextLeft1
-- GLOBALS: GameTooltipTextLeft1, GameTooltipTextLeft2, MaxHealth, SPECIALIZATION
-- GLOBALS: Health, InspectFrame, UNKNOWN, NONE, STAT_AVERAGE_ITEM_LEVEL

local Tooltip = CreateFrame("Frame")
local BackdropColor = {0, 0, 0}
local HealthBar = GameTooltipStatusBar
local HealthBarBG = CreateFrame("Frame", "StatusBarBG", HealthBar)
local ILevel, TalentSpec, MAXILevel, PVPILevel, LastUpdate = 0, "", 0, 0, 30
local InspectDelay = 0.2
local InspectFreq = 2
local InspectCache = {}
local LastInspectRequest = 0
local Short = K.ShortValue
local Texture = C.Media.Texture

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
	minus = "-",
}

Tooltip.SlotNames = {
	"Head",
	"Neck",
	"Shoulder",
	"Back",
	"Chest",
	"Wrist",
	"Hands",
	"Waist",
	"Legs",
	"Feet",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"MainHand",
	"SecondaryHand"
}

function Tooltip:CreateAnchor()
	local Movers = K.Movers

	local Anchor = CreateFrame("Frame", "TooltipAnchor", UIParent)
	Anchor:SetSize(200, 36)
	Anchor:SetFrameStrata("TOOLTIP")
	Anchor:SetFrameLevel(20)
	Anchor:SetClampedToScreen(true)
	Anchor:SetPoint(unpack(C.Position.Tooltip))
	Anchor:SetMovable(true)

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
		local Color = RaidColors[Class]

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

		local Hex = K.RGBToHex(unpack(Color))

		return Hex, Color[1], Color[2], Color[3]
	end
end

function Tooltip:GetItemLevel(unit)
	local Total, Item = 0, 0
	local ArtefactEquiped = false
	-- local TotalSlots = 16

	for i = 1, #Tooltip.SlotNames do
		local ItemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(("%sSlot"):format(Tooltip.SlotNames[i])))

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

				if(ItemLevel and ItemLevel > 0) then
					Item = Item + 1
					Total = Total + ItemLevel
				end

				-- -- Total slots depend if one/two handed weapon
				-- if (i == 15) then
				-- 	if (ArtifactEquipped or (EquipLoc and EquipLoc == "INVTYPE_2HWEAPON")) then
				-- 		TotalSlots = 15
				-- 	end
				-- end
			end
		end
	end

	-- if(Total < 1 or Item < TotalSlots)
	if(Total < 1 or Item < 15) then
		return
	end

	return math_floor(Total / Item)
end

function Tooltip:GetTalentSpec(unit, isPlayer)
	local Spec

	if not unit or (isPlayer) then
		Spec = GetSpecialization()
	else
		Spec = GetInspectSpecialization(unit)
	end

	if(Spec ~= nil and Spec > 0) then
		if (unit) and (not isPlayer) then
			local Role = GetSpecializationRoleByID(Spec)

			if (Role ~= nil) then
				local _, Name = GetSpecializationInfoByID(Spec)
				return Name
			end
		else
			local _, Name = GetSpecializationInfo(Spec)

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

	if (self.NextUpdate) <= 0 then
		self:Hide()

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

	local ILVL = self:GetItemLevel("mouseover")
	local TalentSpec = self:GetTalentSpec("mouseover")
	local CurrentTime = GetTime()
	local MatchFound

	for i, Cache in ipairs(InspectCache) do
		if Cache.GUID == GUID then
			Cache.ItemLevel = ILVL
			Cache.TalentSpec = TalentSpec
			Cache.LastUpdate = math_floor(CurrentTime)

			MatchFound = true

			break
		end
	end

	if (not MatchFound) then
		local GUIDInfo = {
			["GUID"] = GUID,
			["ItemLevel"] = ILVL,
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
		if (C.Tooltip.Talents and IsShiftKeyDown()) then

			ILevel = "..."
			TalentSpec = "..."

			if (Unit ~= "player") then
				Tooltip.CurrentGUID = UnitGUID(Unit)
				Tooltip.CurrentUnit = Unit

				for i, _ in pairs(InspectCache) do
					local Cache = InspectCache[i]

					if Cache.GUID == Tooltip.CurrentGUID then
						ILevel = Cache.ItemLevel or "..."
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
				local Best, Current, PVP = GetAverageItemLevel()

				ILevel = math_floor(Current) or UNKNOWN
				MAXILevel = math_floor(Best) or UNKNOWN
				PVPILevel = math_floor(PVP) or UNKNOWN

				TalentSpec = Tooltip:GetTalentSpec() or NONE
			end
		end
		if (UnitIsAFK(Unit)) then
			self:AppendText((" %s"):format("|cffff0000".. CHAT_FLAG_AFK .."|r"))
		elseif UnitIsDND(Unit) then
			self:AppendText((" %s"):format("|cffe7e716".. CHAT_FLAG_DND .."|r"))
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

	if (C.Tooltip.HealthValue and Health and MaxHealth) then
		HealthBar.Text:SetText(Short(Health) .. " / " .. Short(MaxHealth))
	end

	if (C.Tooltip.Talents and UnitIsPlayer(Unit) and IsShiftKeyDown()) then
		if Unit == "player" then
			GameTooltip:AddLine(" ") -- We really need this to keep it clean and not bunched up!
			GameTooltip:AddLine(STAT_AVERAGE_ITEM_LEVEL.." ("..CURRENTLY_EQUIPPED .."): |cff3eea23"..ILevel.."|r")
			GameTooltip:AddLine(STAT_AVERAGE_ITEM_LEVEL.." ("..PVP.."): |cff3eea23"..PVPILevel.."|r")
			GameTooltip:AddLine(STAT_AVERAGE_ITEM_LEVEL.." ("..MAXIMUM.."): |cff3eea23"..MAXILevel.."|r")
		else
			GameTooltip:AddLine(" ") -- We really need this to keep it clean and not bunched up! (Target)
			GameTooltip:AddLine(STAT_AVERAGE_ITEM_LEVEL..": |cff3eea23"..ILevel.."|r")
		end

		GameTooltip:AddLine(SPECIALIZATION..": |cff3eea23"..TalentSpec.."|r")
	end

	self.fadeOut = nil
end

function Tooltip:SetColor()
	local GetMouseFocus = GetMouseFocus()

	local Unit = select(2, self:GetUnit()) or (GetMouseFocus and GetMouseFocus.GetAttribute and GetMouseFocus:GetAttribute("unit"))
	if (not Unit) and (UnitExists("mouseover")) then
		Unit = "mouseover"
	end

	self:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	self:SetBackdropBorderColor(unpack(C.Media.Border_Color))

	local Reaction = Unit and UnitReaction(Unit, "player")
	local Player = Unit and UnitIsPlayer(Unit)
	local Friend = Unit and UnitIsFriend("player", Unit)
	local R, G, B

	if Player and Friend then
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
			local Color = K.Colors

			HealthBar:SetStatusBarColor(unpack(K.Colors.reaction[5]))
			HealthBar:SetBackdropBorderColor(unpack(C.Media.Border_Color))
			self:SetBackdropBorderColor(unpack(C.Media.Border_Color))
		end
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
		self:SetBackdropColor(unpack(C.Media.Backdrop_Color))
		self:SetBackdropBorderColor(unpack(C.Media.Border_Color))
	end
end

function Tooltip:Skin()
	if (not self.IsSkinned) then
		self:SetTemplate()
		self.IsSkinned = true
	end

	Tooltip.SetColor(self)
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
		self.Text:SetText(Short(Value) .. " / " .. Short(Max))
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
		end

		Tooltip:HookScript("OnShow", self.Skin)
		if Tooltip.BackdropFrame then
			Tooltip.BackdropFrame:Kill()
		end
	end

	HealthBar:SetScript("OnValueChanged", self.OnValueChanged)
	HealthBar:SetStatusBarTexture(Texture)
	HealthBar:CreateShadow()
	HealthBar:ClearAllPoints()
	HealthBar:SetPoint("BOTTOMLEFT", HealthBar:GetParent(), "TOPLEFT", 4, 2)
	HealthBar:SetPoint("BOTTOMRIGHT", HealthBar:GetParent(), "TOPRIGHT", -4, 2)

	HealthBarBG:SetFrameLevel(HealthBar:GetFrameLevel() - 1)
	HealthBarBG:SetPoint("TOPLEFT", -1, 1)
	HealthBarBG:SetPoint("BOTTOMRIGHT", 1, -1)
	HealthBarBG:SetBackdrop(K.BorderBackdrop)
	HealthBarBG:SetBackdropColor(unpack(C.Media.Backdrop_Color))

	if C.Tooltip.HealthValue then
		HealthBar.Text = HealthBar:CreateFontString(nil, "OVERLAY")
		HealthBar.Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		HealthBar.Text:SetPoint("CENTER", HealthBar, "CENTER", 0, 6)
		HealthBar.Text:SetTextColor(1, 1, 1)
	end
end

local Loading = CreateFrame("Frame")
function Loading:OnEvent(event, addon)
	if (event == "PLAYER_LOGIN") then
		Tooltip:Enable()
	end
end
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", Loading.OnEvent)