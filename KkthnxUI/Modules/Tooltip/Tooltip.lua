local K, C, L = unpack(select(2, ...))
if C.Tooltip.Enable ~= true then return end

-- Lua API
local _G = _G
local abs = math.abs
local floor = math.floor
local gsub, find, format = string.gsub, string.find, string.format
local pairs = pairs
local select = select
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
local STAT_AVERAGE_ITEM_LEVEL = STAT_AVERAGE_ITEM_LEVEL
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
-- GLOBALS: SPECIALIZATION, NONE, UNKNOWN, Health
-- GLOBALS: DEAD, GameTooltip, GameTooltipTextLeft2, TooltipAnchor, GameTooltipTextLeft1
-- GLOBALS: GameTooltipTextLeft1, GameTooltipTextLeft2, InspectFrame, MaxHealth

local BackdropColor = {0, 0, 0}
local HealthBar = GameTooltipStatusBar
local HealthBarBG = CreateFrame("Frame", "StatusBarBG", HealthBar)
local ILevel, TalentSpec, MAXILevel, PVPILevel, LastUpdate = 0, "", 0, 0, 30
local InspectDelay = 0.2
local InspectFreq = 2
local Short = K.ShortValue
local Texture = C.Media.Texture
local Tooltip = CreateFrame("Frame")

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
	local Guild, GuildRankName, _, GuildRealm = GetGuildInfo(Unit)
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
				Name = Name.."-"..Realm
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

	if (UnitIsPlayer(Unit) and UnitIsFriend("player", Unit)) then
		if (C.Tooltip.Talents and IsAltKeyDown()) then
			local Talents = K.Tooltip.Talents

			ILevel = "..."
			TalentSpec = "..."

			if (Unit ~= "player") then
				Talents.CurrentGUID = UnitGUID(Unit)
				Talents.CurrentUnit = Unit

				for i, _ in pairs(Talents.Cache) do
					local Cache = Talents.Cache[i]

					if Cache.GUID == Talents.CurrentGUID then
						ILevel = Cache.ItemLevel or "..."
						TalentSpec = Cache.TalentSpec or "..."
						LastUpdate = Cache.LastUpdate and abs(Cache.LastUpdate - floor(GetTime())) or 30
					end
				end

				if (Unit and (CanInspect(Unit))) and (not (InspectFrame and InspectFrame:IsShown())) then
					local LastInspectTime = GetTime() - Talents.LastInspectRequest

					Talents.NextUpdate = (LastInspectTime > InspectFreq) and InspectDelay or (InspectFreq - LastInspectTime + InspectDelay)

					Talents:Show()
				end
			else
				local Current = GetAverageItemLevel()

				ILevel = floor(Current) or UNKNOWN

				TalentSpec = Talents:GetTalentSpec() or NONE
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
		if(GuildRealm and IsShiftKeyDown()) then
			Guild = Guild.."-"..GuildRealm
		end

		Line2:SetFormattedText("%s", IsInGuild() and GetGuildInfo("player") == Guild and "|cff0090ff".. Guild .."|r" or "|cff00ff10".. Guild .."|r")
		Offset = Offset + 1
	end

	for i = Offset, NumLines do
		local Line = _G["GameTooltipTextLeft"..i]
		if (Line:GetText():find("^" .. LEVEL)) then
			if (UnitIsPlayer(Unit) and Race) then
				Line:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", R * 255, G * 255, B * 255, Level > 0 and Level or "|cffAF5050??|r", Race, Color, Class .."|r")
			else
				Line:SetFormattedText("|cff%02x%02x%02x%s|r %s%s", R * 255, G * 255, B * 255, Level > 0 and Level or "|cffAF5050??|r", Classification[CreatureClassification] or "", CreatureType or "" .."|r")
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

	if (C.Tooltip.Talents and UnitIsPlayer(Unit) and UnitIsFriend("player", Unit) and IsAltKeyDown()) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(STAT_AVERAGE_ITEM_LEVEL..": |cff3eea23"..ILevel.."|r")
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

K.Tooltip = Tooltip

local Loading = CreateFrame("Frame")

function Loading:OnEvent(event, addon)
	if (event == "PLAYER_LOGIN") then
		Tooltip:Enable()
	end
end

Loading:RegisterEvent("PLAYER_LOGIN")
Loading:RegisterEvent("ADDON_LOADED")
Loading:SetScript("OnEvent", Loading.OnEvent)

if event == ("ADDON_LOADED") then
	Loading:UnregisterEvent("ADDON_LOADED")
end