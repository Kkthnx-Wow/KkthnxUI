--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Nameplates/Style.lua
	Purpose:
		The nameplate look: a bordered health bar, a name/level line above it, a
		slim castbar below, personal debuffs, and a border that lights up on the
		current target. Health is coloured by reaction/class with a threat
		override. Kept secret-safe for Midnight by guarding boolean reads.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Nameplates")

local oUF = K.oUF
local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitLevel = UnitLevel
local UnitReaction = UnitReaction
local UnitPowerType = UnitPowerType
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local C_TooltipInfo = C_TooltipInfo
local UnitGUID = UnitGUID
local strsplit = strsplit
local tonumber = tonumber
local wipe = wipe
local select = select
local floor = math.floor
local strmatch = string.match
local AbbreviateNumbers = AbbreviateNumbers
local IsInInstance = IsInInstance
local IsSecret = K.IsSecret

-- Health readout for plates. Enemy health is a secret number in Midnight, which
-- cannot be divided or compared, so those plates fall back to an abbreviated
-- current-health count (AbbreviateNumbers accepts secrets). Readable values show
-- a percent, blanked at full health to keep the bar clean.
oUF.Tags.Methods["kkui:nphealth"] = function(unit)
	local cur = UnitHealth(unit)
	local max = UnitHealthMax(unit)
	if IsSecret(cur) or IsSecret(max) then
		return AbbreviateNumbers(cur)
	end
	if max == 0 or cur == max then
		return ""
	end
	return floor(cur / max * 100) .. "%"
end
oUF.Tags.Events["kkui:nphealth"] = "UNIT_HEALTH UNIT_MAXHEALTH"

-- Name colour for plates: class colour for players, reaction colour otherwise.
-- Always coloured (unlike the unit-frame tag, which defers to a class-coloured
-- health bar) because a name-only plate has no bar to carry the colour.
oUF.Tags.Methods["kkui:npnamecolor"] = function(unit)
	-- Every discriminator here can be a secret value for an enemy player, and a
	-- secret can neither drive an `if` nor index a table while tainted.
	local isPlayer = UnitIsPlayer(unit)
	if IsSecret(isPlayer) then
		return ""
	end
	if isPlayer then
		local _, class = UnitClass(unit)
		-- A secret class token cannot key our colour table, but the client's own
		-- class colour lookup accepts it, so enemy players still get their colour.
		if IsSecret(class) then
			local color = C_ClassColor.GetClassColor(class)
			if color then
				return color:GenerateHexColorMarkup()
			end
		elseif class then
			local color = oUF.colors.class[class]
			if color then
				return color:GenerateHexColorMarkup()
			end
		end
	else
		local reaction = UnitReaction(unit, "player")
		local color = reaction and not IsSecret(reaction) and oUF.colors.reaction[reaction]
		if color then
			return color:GenerateHexColorMarkup()
		end
	end
	return ""
end
oUF.Tags.Events["kkui:npnamecolor"] = "UNIT_NAME_UPDATE UNIT_FACTION"

-- Unit level for the plate name, difficulty-coloured. Blank when secret.
oUF.Tags.Methods["kkui:nplevel"] = function(unit)
	local level = UnitLevel(unit)
	if IsSecret(level) or not level then
		return ""
	end
	if level <= 0 then
		return "|cffff4040??|r "
	end
	return level .. " "
end
oUF.Tags.Events["kkui:nplevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

-- Guild name in angle brackets for players, blank for everyone else.
oUF.Tags.Methods["kkui:npguild"] = function(unit)
	local guild = GetGuildInfo(unit)
	if guild and not IsSecret(guild) then
		return "<" .. guild .. ">"
	end
	return ""
end
oUF.Tags.Events["kkui:npguild"] = "UNIT_NAME_UPDATE"

local GAP = 6
local CAST_COLOR = { 0.85, 0.65, 0.13 } -- normal cast (gold / yellow)
-- Bright accent that marks the current target's border (never black).
local TARGET_ACCENT = { 1, 0.9, 0.2 }

-- Recolour the current target's border to the accent, and put every other
-- plate's border back to the configured colour. Guarded so a secret UnitIsUnit
-- result never errors in Midnight.
-- The shadow carries three cues, in priority order: the accent when this plate
-- is your target, a threat colour when you hold or are pulling aggro, and plain
-- black otherwise. Replaces the old border recolour.
local function UpdateTargetHighlight(self)
	local unit = self.unit
	local isTarget = unit and UnitIsUnit(unit, "target")

	-- Name-only plates carry no shadow to tint, so the name-select glow is the
	-- target cue there.
	if self.__nameOnly then
		if self.NameSelect then
			self.NameSelect:SetShown(C.Nameplate.TargetHighlight and not IsSecret(isTarget) and isTarget and true or false)
		end
		return
	end

	local shadow = self.KKUI_Shadow
	if not shadow then
		return
	end

	if C.Nameplate.TargetHighlight and not IsSecret(isTarget) and isTarget then
		shadow:SetBackdropBorderColor(TARGET_ACCENT[1], TARGET_ACCENT[2], TARGET_ACCENT[3], 1)
		return
	end

	if C.Nameplate.ThreatColor and unit then
		local status = UnitThreatSituation("player", unit)
		if status and not IsSecret(status) and status >= 2 then
			local r, g, b = GetThreatStatusColor(status)
			shadow:SetBackdropBorderColor(r, g, b, 1)
			return
		end
	end

	shadow:SetBackdropBorderColor(0, 0, 0, 1)
end

-- Elite / rare / boss classification icon.
local function UpdateClassification(self)
	local icon = self.Classification
	if not icon then
		return
	end
	local class = self.unit and UnitClassification(self.unit)
	if IsSecret(class) then
		icon:Hide()
		return
	end
	if class == "worldboss" or class == "elite" then
		icon:SetAtlas("nameplates-icon-elite-gold")
		icon:Show()
	elseif class == "rareelite" or class == "rare" then
		icon:SetAtlas("nameplates-icon-elite-silver")
		icon:Show()
	else
		icon:Hide()
	end
end

-- Format an incomplete objective's text per the config: the completed count
-- ("3/7", "40%") or what remains ("4", "60%").
local function FormatProgress(text)
	local remaining = C.Nameplate.QuestProgressFormat == "Remaining"
	local current, goal = strmatch(text, "(%d+)/(%d+)")
	if current and goal then
		current, goal = tonumber(current), tonumber(goal)
		if current < goal then
			return remaining and tostring(goal - current) or (current .. "/" .. goal)
		end
		return nil
	end
	local percent = tonumber(strmatch(text, "(%d+)%%"))
	if percent and percent < 100 then
		return remaining and (100 - percent) .. "%" or percent .. "%"
	end
	return nil
end

-- Quest objective marker. Outside instances we read
-- the structured unit tooltip and return the first INCOMPLETE objective. Inside
-- instances the tooltip is unreliable, so we fall back to the cheap relation
-- check and show the icon with no text. Returns (progress, fromParty): progress
-- is a string ("" means icon only) or nil for no quest, fromParty flags an
-- objective that belongs to a group member. Secret fields are checked first.
local function QuestProgress(unit)
	if not C.Nameplate.ShowQuestIcon then
		return nil
	end

	if IsInInstance() then
		if C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest and C_QuestLog.UnitIsRelatedToActiveQuest(unit) then
			return "", false
		end
		return nil
	end

	if not (C_TooltipInfo and C_TooltipInfo.GetUnit and Enum and Enum.TooltipDataLineType) then
		return nil
	end

	local data = C_TooltipInfo.GetUnit(unit)
	if not data or not data.lines then
		return nil
	end

	local LT = Enum.TooltipDataLineType
	local ownerIsPlayer = true
	for _, line in ipairs(data.lines) do
		local t = line.type
		if t == LT.QuestPlayer then
			-- A "<name>'s quest" divider, everything after belongs to that player.
			if not IsSecret(line.leftText) then
				ownerIsPlayer = line.leftText == K.Name
			end
		elseif t == LT.QuestObjective then
			local text = line.leftText
			if text and not IsSecret(text) and (ownerIsPlayer or C.Nameplate.QuestShowParty) then
				local progress = FormatProgress(text)
				if progress then
					return progress, not ownerIsPlayer
				end
			end
		end
	end
	return nil
end

local function UpdateQuest(self)
	local icon = self.QuestIcon
	if not icon then
		return
	end
	local unit = self.unit
	local progress, fromParty
	if unit then
		progress, fromParty = QuestProgress(unit)
	end
	if not progress then
		if self.QuestCount then
			self.QuestCount:SetText("")
		end
		icon:Hide()
		return
	end

	-- Grey a party member's quest, full colour for your own.
	if fromParty then
		icon:SetDesaturated(true)
		icon:SetVertexColor(0.7, 0.7, 0.7)
	else
		icon:SetDesaturated(false)
		icon:SetVertexColor(1, 1, 1)
	end
	icon:Show()

	-- Progress text: always, or only while this plate is your target.
	if self.QuestCount then
		local show = progress ~= ""
		if show and C.Nameplate.QuestProgressOnTarget then
			local isTarget = UnitIsUnit(unit, "target")
			show = not IsSecret(isTarget) and isTarget
		end
		self.QuestCount:SetText(show and progress or "")
	end
end

-- Friendly units in name-only mode drop the bars and show just the name over a
-- soft shadow. Always sets an explicit state for every piece so a recycled plate
-- (friendly -> hostile) never keeps a leftover shadow or hidden bar.
local function UpdateNameOnly(self)
	local friendly = false
	if C.Nameplate.FriendlyNameOnly then
		local reaction = self.unit and UnitReaction(self.unit, "player")
		friendly = reaction and not IsSecret(reaction) and reaction >= 5 or false
	end
	self.__nameOnly = friendly

	self.Health:SetShown(not friendly)
	if self.KKUI_Shadow then
		self.KKUI_Shadow:SetShown(not friendly)
	end
	-- Only force the castbar off for friendly name-only plates. For everyone else we
	-- must not force it on: the oUF castbar element hides itself when idle and shows
	-- on cast start, so forcing SetShown(true) here left an empty bar sitting on
	-- every enemy plate that was not casting.
	if self.Castbar and friendly then
		self.Castbar:Hide()
	end
	if self.HealthText then
		self.HealthText:SetShown(not friendly)
	end
	if self.NameShadow then
		self.NameShadow:SetShown(friendly)
	end
	-- Guild line only makes sense in name-only mode, on a bar it would overlap.
	if self.GuildName then
		self.GuildName:SetShown(friendly)
	end

	-- Re-anchor the name to the plate centre when the bar is gone.
	self.Name:ClearAllPoints()
	if friendly then
		self.Name:SetPoint("CENTER", self, "CENTER", 0, 0)
	else
		self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 4)
	end
end

local function PostUpdateHealth(health, unit)
	local self = health.__owner
	if not self then
		return
	end
	-- Name-only first: the target highlight reads self.__nameOnly.
	UpdateNameOnly(self)
	UpdateTargetHighlight(self)
	UpdateClassification(self)
	UpdateQuest(self)
end

-- Unitless oUF events, fired on every plate. The target highlight has to react
-- to target changes on its own, otherwise the old plate keeps the accent and the
-- new one never gets it until its health happens to tick (the "stuck" border).
local function OnTargetChanged(self)
	UpdateTargetHighlight(self)
	-- Progress text can be target-only, so refresh it when the target changes.
	UpdateQuest(self)
end

-- Name-only hover glow: lit while the cursor is over this plate's unit.
--
-- UPDATE_MOUSEOVER_UNIT fires when the cursor gains a unit but not reliably
-- when it moves off to empty space, so the event alone would leave the glow
-- stuck on. While the glow is lit we poll on a throttle and drop it the moment
-- the cursor is no longer over this unit. The watcher unhooks itself so an idle
-- plate costs nothing.
local HOVER_THROTTLE = 0.1

local function IsHovered(self)
	local unit = self.unit
	local hovered = self.__nameOnly and unit and UnitIsUnit(unit, "mouseover")
	return not IsSecret(hovered) and hovered and true or false
end

local function HoverWatch(self, elapsed)
	self.__hoverElapsed = (self.__hoverElapsed or 0) + elapsed
	if self.__hoverElapsed < HOVER_THROTTLE then
		return
	end
	self.__hoverElapsed = 0
	if not IsHovered(self) then
		self.NameHover:Hide()
		self:SetScript("OnUpdate", nil)
	end
end

local function OnMouseover(self)
	if not self.NameHover then
		return
	end
	if IsHovered(self) then
		self.NameHover:Show()
		self.__hoverElapsed = 0
		self:SetScript("OnUpdate", HoverWatch)
	else
		self.NameHover:Hide()
		self:SetScript("OnUpdate", nil)
	end
end

local function OnQuestLogUpdate(self)
	UpdateQuest(self)
end

-- ---------------------------------------------------------------------------
-- Custom unit colours (kill-first / focus lists)
-- ---------------------------------------------------------------------------

-- npcID -> { r, g, b }, rebuilt from config so a change applies without a reload.
K.NameplateCustomColors = {}

function K.BuildNameplateColors()
	wipe(K.NameplateCustomColors)
	local list = C.Nameplate and C.Nameplate.CustomColors
	if list then
		for npcID, color in pairs(list) do
			K.NameplateCustomColors[npcID] = color
		end
	end
end

-- The npcID sits in the 6th field of the GUID. It can be a secret value in
-- Midnight, in which case we simply skip the custom colour.
local function GetNPCID(unit)
	local guid = unit and UnitGUID(unit)
	if not guid or IsSecret(guid) then
		return
	end
	return tonumber((select(6, strsplit("-", guid))))
end

-- Health colour override, run after oUF's own colouring:
--   1. an npcID on the custom list always wins,
--   2. players keep the class / reaction colour oUF gave them,
--   3. enemies get a threat colour when that option is on, otherwise their
--      reaction colour, and a solid hostile colour when the reaction is secret,
--      so a mob we are fighting never falls back to the plain green health fill.
-- A hostile unit is treated as a caster when it runs on mana, the one signal the
-- API gives for a nameplate unit. Read live each colour update so a recycled plate
-- never keeps a stale role, and guarded for a secret power type.
local function PlateIsCaster(unit)
	local power = UnitPowerType and UnitPowerType(unit)
	return power ~= nil and not IsSecret(power) and power == 0
end

local function CustomHealthColor(health, unit)
	local npcID = GetNPCID(unit)
	local custom = npcID and K.NameplateCustomColors[npcID]
	if custom then
		health:SetStatusBarColor(custom[1], custom[2], custom[3])
		return
	end

	local isPlayer = UnitIsPlayer(unit)
	if IsSecret(isPlayer) or isPlayer then
		return
	end

	-- Role colours: hostile plates read as caster or melee so casters stand out.
	-- Sits above reaction colour so the split is visible, below the custom and threat
	-- colours which the player set on purpose. When threat colouring is on we let a
	-- live threat situation win, but the threat read can be a secret for an enemy in
	-- Midnight, so guard it the same way the threat fill below does.
	local threatWins = false
	if C.Nameplate.RoleColors and C.Nameplate.ThreatHealthColor then
		local status = UnitThreatSituation("player", unit)
		threatWins = status and not IsSecret(status) and true or false
	end
	if C.Nameplate.RoleColors and not threatWins then
		local reaction = UnitReaction(unit, "player")
		if reaction and not IsSecret(reaction) and reaction <= 4 then
			local c = PlateIsCaster(unit) and C.Nameplate.CasterColor or C.Nameplate.MeleeColor
			if c then
				health:SetStatusBarColor(c[1], c[2], c[3])
				return
			end
		end
	end

	if C.Nameplate.ThreatHealthColor then
		local status = UnitThreatSituation("player", unit)
		if status and not IsSecret(status) then
			local color = K.ThreatFillColor(status, K.PlayerIsTank())
			if color then
				health:SetStatusBarColor(color[1], color[2], color[3])
				return
			end
		end
	end

	local reaction = UnitReaction(unit, "player")
	if reaction and not IsSecret(reaction) then
		local c = oUF.colors.reaction[reaction]
		if c then
			health:SetStatusBarColor(c:GetRGB())
			return
		end
	end

	-- Reaction unknown (secret): fall back to the hostile colour, not stock green.
	local hostile = oUF.colors and oUF.colors.reaction and oUF.colors.reaction[2]
	if hostile then
		health:SetStatusBarColor(hostile:GetRGB())
	end
end

-- ---------------------------------------------------------------------------
-- Element builders
-- ---------------------------------------------------------------------------

local function BuildHealth(self)
	local db = C.Nameplate
	local health = CreateFrame("StatusBar", nil, self)
	health:SetStatusBarTexture(K.GetTexture(C.Unitframe and C.Unitframe.Texture or "KkthnxUI"))
	-- oUF points `self` at the whole nameplate base, so size the health bar
	-- explicitly and centre it rather than filling the oversized parent.
	health:SetSize(db.Width, db.Height)
	health:SetPoint("CENTER", self, "CENTER", 0, 0)
	health.colorReaction = true
	health.colorClass = db.ClassColor
	-- oUF's threat colouring greys the bar at threat status 0 (group DPS with no
	-- aggro), which read as "everything turns grey". We colour threat on the
	-- shadow instead, so the fill keeps its reaction / class colour.
	health.colorThreat = false
	health.colorTapping = true
	health.colorDisconnected = true
	health.PostUpdate = PostUpdateHealth
	health.PostUpdateColor = CustomHealthColor

	local bg = health:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0.12, 0.12, 0.12, 0.9)
	health.bg = bg

	self.Health = health
	-- Soft shadow instead of the hard border. Its colour doubles as the
	-- target highlight and threat cue (see UpdateTargetHighlight).
	K.CreateShadow(health)
	self.KKUI_Shadow = health.KKUI_Shadow

	-- Health percent, right aligned on the bar.
	if db.ShowHealthText then
		local hp = health:CreateFontString(nil, "OVERLAY")
		K.SetFont(hp, db.NameSize - 1, K.FontOutlineStyle())
		hp:SetPoint("RIGHT", health, "RIGHT", -2, 0)
		self:Tag(hp, "[kkui:nphealth]")
		self.HealthText = hp
	end
end

local function BuildName(self)
	local name = self:CreateFontString(nil, "OVERLAY")
	K.SetFont(name, C.Nameplate.NameSize, K.FontOutlineStyle())
	name:SetPoint("BOTTOM", self.Health, "TOP", 0, 4)
	name:SetJustifyH("CENTER")
	-- Colour through the tag system so it updates on name/faction events, not
	-- only when the health bar happens to recolour (which needed a target/click).
	self:Tag(name, "[kkui:nplevel][kkui:npnamecolor][kkui:name]")
	self.Name = name

	-- Name-only highlights: a hover glow and a target-select glow framing the name
	-- text (they only show in name-only mode, driven from the update handlers).
	local hover = self:CreateTexture(nil, "ARTWORK", nil, 1)
	hover:SetPoint("TOPLEFT", name, "TOPLEFT", -8, 4)
	hover:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", 8, -4)
	hover:SetAtlas("search-highlight", false)
	hover:SetBlendMode("ADD")
	hover:Hide()
	self.NameHover = hover

	local selectTex = self:CreateTexture(nil, "ARTWORK", nil, 2)
	selectTex:SetPoint("TOPLEFT", name, "TOPLEFT", -8, 4)
	selectTex:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", 8, -4)
	selectTex:SetAtlas("search-select", false)
	selectTex:SetBlendMode("ADD")
	selectTex:Hide()
	self.NameSelect = selectTex

	-- Guild line under the name (players only, empty tag hides itself).
	if C.Nameplate.ShowGuildName then
		local guild = self:CreateFontString(nil, "OVERLAY")
		K.SetFont(guild, C.Nameplate.NameSize - 2, K.FontOutlineStyle())
		guild:SetPoint("TOP", name, "BOTTOM", 0, -2)
		guild:SetTextColor(0.7, 0.7, 0.7)
		self:Tag(guild, "[kkui:npguild]")
		self.GuildName = guild
	end
end

-- Cast colour while interruptible, red while not (matching the unit frame
-- castbars). notInterruptible is a Midnight
-- secret boolean, so colour through SetVertexColorFromBoolean rather than an if.
local CAST_CLR = CreateColor(CAST_COLOR[1], CAST_COLOR[2], CAST_COLOR[3])
local NOINTERRUPT_CLR = CreateColor(0.6, 0.6, 0.65) -- cannot interrupt (silver)

-- notInterruptible arrives as a PostCastStart argument in the current oUF. It can
-- be a Midnight secret boolean (enemy casts), a plain boolean, or nil. Only the
-- secret path may use SetVertexColorFromBoolean, and a plain value would error
-- there, so branch on it.
-- Cast in progress: gold while interruptible, silver while not. Shared by the
-- start callback and the mid-cast interruptibility change so a spell that flips (a
-- kick immunity dropping, say) recolours instead of staying its start colour. A
-- failed or interrupted cast goes red.
local FAIL_COLOR = { 0.85, 0.25, 0.25 }

local function CastRecolor(cast, notInterruptible)
	local tex = cast:GetStatusBarTexture()
	if IsSecret(notInterruptible) then
		if tex and tex.SetVertexColorFromBoolean then
			tex:SetVertexColorFromBoolean(notInterruptible, NOINTERRUPT_CLR, CAST_CLR)
		end
	elseif notInterruptible then
		cast:SetStatusBarColor(NOINTERRUPT_CLR:GetRGB())
	else
		cast:SetStatusBarColor(CAST_COLOR[1], CAST_COLOR[2], CAST_COLOR[3])
	end
end

local function OnCastStart(cast, _, _, notInterruptible)
	CastRecolor(cast, notInterruptible)
end

local function OnCastInterruptible(cast, _, _, notInterruptible)
	CastRecolor(cast, notInterruptible)
end

-- A failed or interrupted cast goes grey so the outcome reads before the bar
-- fades, matching the unit frame castbars.
local function OnCastFail(cast)
	cast:SetStatusBarColor(FAIL_COLOR[1], FAIL_COLOR[2], FAIL_COLOR[3])
end

local function CastTimeText(cast, duration)
	if cast.Time then
		cast.Time:SetFormattedText("%.1f", duration:GetRemainingDuration())
	end
end

local function BuildCastbar(self)
	if not C.Nameplate.ShowCastbar then
		return
	end
	local height = C.Nameplate.CastbarHeight
	local cast = CreateFrame("StatusBar", nil, self)
	cast:SetStatusBarTexture(K.GetTexture(C.Unitframe and C.Unitframe.Texture or "KkthnxUI"))
	cast:SetStatusBarColor(CAST_COLOR[1], CAST_COLOR[2], CAST_COLOR[3])
	cast:SetHeight(height)
	cast:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -GAP)
	cast:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -GAP)
	K.CreateBackground(cast, 0.08, 0.08, 0.08, 0.9)
	K.CreateShadow(cast)
	cast.PostCastStart = OnCastStart
	cast.PostCastInterruptible = OnCastInterruptible
	cast.PostCastFail = OnCastFail
	cast.PostCastInterrupted = OnCastFail

	-- Square icon box to the left, matched to the castbar height.
	local iconHolder = CreateFrame("Frame", nil, cast)
	iconHolder:SetSize(height, height)
	iconHolder:SetPoint("RIGHT", cast, "LEFT", -GAP, 0)
	K.CreateBackground(iconHolder, 0.05, 0.05, 0.05, 0.9)
	K.CreateShadow(iconHolder)
	local icon = iconHolder:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", -1, 1)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	cast.Icon = icon

	-- Padlock over the bar while the cast cannot be interrupted, oUF drives its
	-- alpha from notInterruptible.
	local shield = cast:CreateTexture(nil, "OVERLAY")
	shield:SetAtlas("UI-CharacterCreate-PadLock", false)
	shield:SetSize(height * 0.9 * (63 / 76), height * 0.9)
	shield:SetPoint("CENTER", cast, "CENTER", 0, 0)
	shield:SetAlpha(0)
	cast.Shield = shield

	-- Spell name (left) and remaining time (right).
	local name = self:CreateFontString(nil, "OVERLAY")
	K.SetFont(name, C.Nameplate.NameSize - 1, K.FontOutlineStyle())
	name:SetParent(cast)
	name:SetPoint("LEFT", cast, "LEFT", 3, 0)
	name:SetJustifyH("LEFT")
	cast.Text = name

	local time = self:CreateFontString(nil, "OVERLAY")
	K.SetFont(time, C.Nameplate.NameSize - 1, K.FontOutlineStyle())
	time:SetParent(cast)
	time:SetPoint("RIGHT", cast, "RIGHT", -3, 0)
	time:SetJustifyH("RIGHT")
	cast.Time = time
	cast.CustomTimeText = CastTimeText
	name:SetPoint("RIGHT", time, "LEFT", -4, 0)

	self.Castbar = cast
end

local function BuildDebuffs(self)
	if not C.Nameplate.ShowDebuffs then
		return
	end
	local db = C.Nameplate
	local filter = db.OnlyMyDebuffs and "HARMFUL|PLAYER" or "HARMFUL"
	-- Built on the CustomAuraContainer intrinsic (12.1 blocks reading enemy auras
	-- from tainted code). Sits clear above the name and class-resource bar.
	local container = K.CreateAuraContainer(self, {
		point = { "BOTTOMLEFT", self.Health, "TOPLEFT", 0, db.NameSize + 32 },
		size = db.AuraSize,
		spacing = db.AuraSpacing,
		perRow = db.MaxAuras,
		anchorPoint = "BOTTOMLEFT",
		growthH = "Right",
		growthV = "Up",
		dispelBorder = true,
		shadow = true,
		slots = { { key = "npdebuffs", filter = filter, max = db.MaxAuras } },
	})
	self.KKUI_Debuffs = container
	if container then
		K.TrackAuraContainer(self, container)
	end
end

-- Private auras: boss and encounter auras Blizzard only reveals to the affected
-- player. The oUF element hands the anchor frames to the client, which draws and
-- times them, so this only sizes and positions the row. Sits above the debuffs
-- (or the health bar when debuffs are off) and grows right from a centred row.
local function BuildPrivateAuras(self)
	if not C.Nameplate.PrivateAuras then
		return
	end
	local db = C.Nameplate
	local size = db.PrivateAuraSize or db.AuraSize
	local num = 3

	local base = db.NameSize + 32
	if db.ShowDebuffs then
		base = base + db.AuraSize + db.AuraSpacing
	end

	local frame = CreateFrame("Frame", nil, self)
	frame:SetSize(num * size + (num - 1) * db.AuraSpacing, size)
	frame:SetPoint("BOTTOM", self.Health, "TOP", 0, base)
	frame.size = size
	frame.num = num
	frame.spacing = db.AuraSpacing
	frame.growthX = "RIGHT"
	frame.growthY = "UP"
	frame.initialAnchor = "BOTTOMLEFT"
	frame.maxCols = num
	frame.showDispelIcon = true
	self.PrivateAuras = frame
end

-- Target highlight overlay, classification, and quest markers. Their visibility
-- is driven from PostUpdateHealth, here we only create them.
local function BuildIndicators(self)
	local db = C.Nameplate

	if db.ShowClassification then
		local icon = self.Health:CreateTexture(nil, "OVERLAY")
		icon:SetSize(db.NameSize + 6, db.NameSize + 6)
		icon:SetPoint("RIGHT", self.Name, "LEFT", -2, 0)
		icon:Hide()
		self.Classification = icon
	end

	if db.ShowQuestIcon then
		local quest = self.Health:CreateTexture(nil, "OVERLAY")
		quest:SetSize(db.NameSize + 8, db.NameSize + 8)
		quest:SetPoint("LEFT", self.Name, "RIGHT", 2, 0)
		quest:SetAtlas("adventureguide-microbutton-alert")
		quest:Hide()
		self.QuestIcon = quest

		-- Remaining objective count beside the marker.
		local count = self.Health:CreateFontString(nil, "OVERLAY")
		K.SetFont(count, db.NameSize - 1, K.FontOutlineStyle())
		count:SetPoint("LEFT", quest, "RIGHT", 1, 0)
		count:SetTextColor(0.6, 0.8, 1)
		self.QuestCount = count
	end

	-- Soft shadow behind the name in name-only mode, so the bare name still
	-- reads over the world. Its own texture, shown only while name-only.
	if db.FriendlyNameOnly then
		local shadow = self:CreateTexture(nil, "BACKGROUND", nil, -1)
		shadow:SetAtlas("Rewards-Shadow")
		shadow:SetPoint("CENTER", self.Name, "CENTER", 0, 0)
		shadow:SetSize(140, 18)
		shadow:Hide()
		self.NameShadow = shadow
	end
end

-- ---------------------------------------------------------------------------
-- Shared style
-- ---------------------------------------------------------------------------

function Module.Style(self, unit)
	-- Do not size `self`: oUF anchors it to the whole nameplate. The health bar
	-- carries the visible size, and everything else hangs off it.
	BuildHealth(self)
	BuildName(self)
	BuildCastbar(self)
	BuildDebuffs(self)
	BuildPrivateAuras(self)
	BuildIndicators(self)

	-- Raid target marker above the health bar.
	local raid = self.Health:CreateTexture(nil, "OVERLAY")
	raid:SetSize(20, 20)
	raid:SetPoint("BOTTOM", self.Name, "TOP", 0, 2)
	self.RaidTargetIndicator = raid

	-- Unitless events, fired on every plate by oUF, keep the target accent and
	-- the quest marker current without waiting on a health tick.
	self:RegisterEvent("PLAYER_TARGET_CHANGED", OnTargetChanged, true)
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", OnMouseover, true)
	if self.QuestIcon then
		self:RegisterEvent("QUEST_LOG_UPDATE", OnQuestLogUpdate, true)
	end
end
