local K, C = unpack(select(2, ...))
if C["Nameplates"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Nameplates.lua code!")
	return
end

local _G = _G
local pairs = pairs
local select = select
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match

local CreateFrame = _G.CreateFrame
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetBattlefieldScore = _G.GetBattlefieldScore
local GetInstanceInfo = _G.GetInstanceInfo
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs
local GetNumBattlefieldScores = _G.GetNumBattlefieldScores
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local UnitIsPlayer = _G.UnitIsPlayer
local UnitName = _G.UnitName
local UnitReaction = _G.UnitReaction
local UNKNOWN = _G.UNKNOWN

-- Taken from Blizzard_TalentUI.lua
local healerSpecIDs = {
	105, -- Druid Restoration
	270, -- Monk Mistweaver
	65,	 -- Paladin Holy
	256, -- Priest Discipline
	257, -- Priest Holy
	264, -- Shaman Restoration
}

Module.HealerSpecs = {}
Module.Healers = {}
Module.exClass = {}

Module.exClass.DEATHKNIGHT = true
Module.exClass.MAGE = true
Module.exClass.ROGUE = true
Module.exClass.WARLOCK = true
Module.exClass.WARRIOR = true

-- Get localized healing spec names
for _, specID in pairs(healerSpecIDs) do
	local _, name = GetSpecializationInfoByID(specID)
	if name and not Module.HealerSpecs[name] then
		Module.HealerSpecs[name] = true
	end
end

function Module:CheckBGHealers()
	local name, _, talentSpec
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i)
		if name then
			name = string_gsub(name,"%-"..string_gsub(K.Realm,"[%s%-]",""),"")
			if name and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			elseif name and self.Healers[name] then
				self.Healers[name] = nil
			end
		end
	end
end

function Module:CheckArenaHealers()
	local numOpps = GetNumArenaOpponentSpecs()
	if not (numOpps > 1) then
		return
	end

	for i = 1, 5 do
		local name, realm = UnitName(string_format("arena%d", i))
		if name and name ~= UNKNOWN then
			realm = (realm and realm ~= "") and string_gsub(realm,"[%s%-]","")
			if realm then name = name.."-"..realm end
			local s = GetArenaOpponentSpec(i)
			local _, talentSpec = nil, UNKNOWN
			if s and s > 0 then
				_, talentSpec = GetSpecializationInfoByID(s)
			end

			if talentSpec and talentSpec ~= UNKNOWN and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			end
		end
	end
end

function Module:CreateNameplates()
	local NameplateTexture = K.GetTexture(C["Nameplates"].Texture)
	local Font = K.GetFont(C["Nameplates"].Font)

	self:SetScale(UIParent:GetEffectiveScale())
	self:SetSize(C["Nameplates"].Width, C["Nameplates"].Height)
	self:SetPoint("CENTER", 0, 0)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameStrata(self:GetFrameStrata())
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetHeight(C["Nameplates"].Height - C["Nameplates"].CastHeight - 1)
	self.Health:SetWidth(self:GetWidth())
	self.Health:SetStatusBarTexture(NameplateTexture)
	self.Health:CreateShadow(true)

	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorReaction = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.Smooth = C["Nameplates"].Smooth
	self.Health.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10

	if C["Nameplates"].HealthValue == true then
		self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self.Health.Value:SetFontObject(Font)
		self:Tag(self.Health.Value, C["Nameplates"].HealthFormat.Value)
	end

	self.Level = self.Health:CreateFontString(nil, "OVERLAY")
	self.Level:SetJustifyH("RIGHT")
	self.Level:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Level:SetFontObject(Font)
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetJustifyH("LEFT")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Level, "BOTTOMLEFT")
	self.Name:SetFontObject(Font)
	self.Name:SetWordWrap(false) -- Why is this even a thing? Text wrapping is just fucking ugly.
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetFrameStrata(self:GetFrameStrata())
	self.Power:SetHeight(C["Nameplates"].CastHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)
	self.Power:SetStatusBarTexture(NameplateTexture)
	self.Power:CreateShadow(true)

	self.Power.IsHidden = false
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.Smooth = C["Nameplates"].Smooth
	self.Power.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10
	self.Power.PostUpdate = Module.NameplatePowerAndCastBar

	if C["Nameplates"].TrackAuras == true then
		self.Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
		self.Debuffs:SetWidth(C["Nameplates"].Width)
		self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -4)
		self.Debuffs.num = 5 * 2
		self.Debuffs.spacing = 3
		self.Debuffs.size = ((((self.Debuffs:GetWidth() - (self.Debuffs.spacing * (self.Debuffs.num / 2 - 1))) / self.Debuffs.num)) * 2)
		self.Debuffs:SetHeight(self.Debuffs.size * 2)
		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs.onlyShowPlayer = true
		self.Debuffs.filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY"
		self.Debuffs.disableMouse = true
		self.Debuffs.PostCreateIcon = Module.PostCreateAura
		self.Debuffs.PostUpdateIcon = Module.PostUpdateAura
	end

	self.Castbar = CreateFrame("StatusBar", "TargetCastbar", self)
	self.Castbar:SetFrameStrata(self:GetFrameStrata())
	self.Castbar:SetStatusBarTexture(NameplateTexture)
	self.Castbar:SetFrameLevel(6)
	self.Castbar:SetHeight(C["Nameplates"].CastHeight)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetSize(32, self:GetHeight())
	self.Castbar.Spark:SetTexture(C["Media"].Spark_64)
	self.Castbar.Spark:SetBlendMode("ADD")

	self.Castbar.timeToHold = 0.4
	self.Castbar.CustomDelayText = Module.CustomCastDelayText
	self.Castbar.CustomTimeText = Module.CustomTimeText
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostChannelStart = Module.PostCastStart
	self.Castbar.PostCastStop = Module.PostCastStop
	self.Castbar.PostChannelStop = Module.PostCastStop
	self.Castbar.PostChannelUpdate = Module.PostChannelUpdate
	self.Castbar.PostCastInterruptible = Module.PostCastInterruptible
	self.Castbar.PostCastNotInterruptible = Module.PostCastNotInterruptible
	self.Castbar.PostCastFailed = Module.PostCastFailedOrInterrupted
	self.Castbar.PostCastInterrupted = Module.PostCastFailedOrInterrupted

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
	self.Castbar.Time:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", 0, -2)
	self.Castbar.Time:SetJustifyH("RIGHT")
	self.Castbar.Time:SetFontObject(Font)
	self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(self:GetHeight() + 2, self:GetHeight() + 3)
	self.Castbar.Button:CreateShadow(true)
	self.Castbar.Button:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

	self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetAllPoints()
	self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Shield:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]])
	self.Castbar.Shield:SetSize(50, 50)
	self.Castbar.Shield:SetPoint("RIGHT", self.Castbar, "LEFT", 26, 12)

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFontObject(Font)
	self.Castbar.Text:SetPoint("TOPLEFT", self.Castbar, "BOTTOMLEFT", 0, -2)
	self.Castbar.Text:SetPoint("TOPRIGHT", self.Castbar.Time, "TOPLEFT")
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
	self.Castbar.Text:SetWordWrap(false)

	self.Castbar:SetScript("OnShow", Module.NameplatePowerAndCastBar)
	self.Castbar:SetScript("OnHide", Module.NameplatePowerAndCastBar)

	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(32, 32)
	self.RaidTargetIndicator:SetPoint("BOTTOM", self.Debuffs or self, "TOP", 0, 10)

	self.QuestIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.QuestIcon:SetPoint("RIGHT", self.Health, "LEFT", 2, 0)
	self.QuestIcon:SetSize(self.Health:GetHeight() + 14, self.Health:GetHeight() + 14)
	self.QuestIcon:SetTexture("Interface\\BUTTONS\\AdventureGuideMicrobuttonAlert") -- "Interface\\MINIMAP\\ObjectIcons"
	self.QuestIcon:Hide()

	--[[
	Class Power (Combo Points, Insanity, etc...)

	The following CVars toggle visibility
	of the personal resouce display (classpower):

	nameplateShowSelf
	nameplateResourceOnTarget

	Note that class resources above will only be visible on
	the target as long as the player nameplate is visible too.
	This might not always be the case, but it can
	to a certain degree be adjusted with the following CVars:

	nameplatePersonalShowAlways
	nameplatePersonalShowInCombat
	nameplatePersonalShowWithTarget
	nameplatePersonalHideDelaySeconds
	--]]

	if C["Nameplates"].ClassResource then -- replace with config option
		Module.CreateNamePlateClassPower(self)
		if (K.Class == "MONK") then
			-- Module.CreateNamePlateStaggerBar(self)
		elseif (K.Class == "DEATHKNIGHT") then
			Module.CreateNamePlateRuneBar(self)
		end
	else
		self.ClassPowerText = self:CreateFontString(nil, "OVERLAY")
		self.ClassPowerText:SetFontObject(Font)
		self.ClassPowerText:SetFont(select(1, self.ClassPowerText:GetFont()), 26, select(3, self.ClassPowerText:GetFont()))
		self.ClassPowerText:SetPoint("TOP", self.Health, "BOTTOM", 0, -10)
		self.ClassPowerText:SetWidth(C["Nameplates"].Width)
		if K.Class == "DEATHKNIGHT" then
			self:Tag(self.ClassPowerText, "[runes]", "player")
		else
			self:Tag(self.ClassPowerText, "[KkthnxUI:ClassPower]", "player")
		end
		self.ClassPowerText:Hide()
	end

	-- use Tooltip scanning to obtain the quest icon to show isObjectiveQuest or isProgressQuest.
	local unitTip = CreateFrame('GameTooltip', "KkthnxUIQuestTooltip", nil, 'GameTooltipTemplate')
	function Module:UpdateQuestUnit(unit)
		if unit == "player" then
			return
		end

		local name, instType, instID = GetInstanceInfo()
		if name and (instType == "raid" or instID == 8) then
			self.QuestIcon:Hide()
			return
		end

		local isObjectiveQuest, isProgressQuest
		unitTip:SetOwner(WorldFrame, "ANCHOR_NONE")
		unitTip:SetUnit(unit)

		for i = 2, unitTip:NumLines() do
			local textLine = _G[unitTip:GetName() .. "TextLeft" .. i]
			local text = textLine:GetText()
			if textLine and text then
				local r, g, b = textLine:GetTextColor()
				if r > 0.99 and g > 0.82 and b == 0.0 then
					isProgressQuest = true
				else
					local unitName, progress = string_match(text, "^ ([^ ]-) ?%- (.+)$") -- nil or '' if 1 is missing but 2 is there
						if (not unitName or unitName == "" or unitName == K.Name) and progress then
						local current, goal = string_match(progress, "(%d+)/(%d+)")
						if current and goal and current ~= goal then
							isObjectiveQuest = true
						end
					end
				end
			end
		end

		if isObjectiveQuest or isProgressQuest then
			self.QuestIcon:Show()
		else
			self.QuestIcon:Hide()
		end
	end

	if C["Nameplates"].ClassIcons then
		self.Class = CreateFrame("Frame", nil, self)
		self.Class:SetSize(self:GetHeight() + 2, self:GetHeight() + 3)
		self.Class:CreateShadow(true)
		self.Class:SetPoint("TOPRIGHT", self, "TOPLEFT", -4, 0)

		self.Class.Icon = self.Class:CreateTexture(nil, "ARTWORK")
		self.Class.Icon:SetAllPoints()
		self.Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
		self.Class.Icon:SetTexCoord(0, 0, 0, 0)
	end

	-- Create Totem Icon
	if C["Nameplates"].Totems then
		self.Totem = CreateFrame("Frame", nil, self)
		self.Totem:SetSize((C["Nameplates"].Height * 2 * K.NoScaleMult) + 8, (C["Nameplates"].Height * 2 * K.NoScaleMult) + 8)
		self.Totem:CreateShadow(true)
		self.Totem:SetPoint("BOTTOM", self.Health, "TOP", 0, 38)

		self.Totem.Icon = self.Totem:CreateTexture(nil, "ARTWORK")
		self.Totem.Icon:SetAllPoints()
	end

	-- Create Healer Icon
	if C["Nameplates"].MarkHealers then
		self.HealerTexture = self:CreateTexture(nil, "OVERLAY")
		self.HealerTexture:SetPoint("BOTTOM", self.Health, "TOP", 0, 38)
		self.HealerTexture:SetSize(40, 40)
		self.HealerTexture:SetTexture([[Interface\AddOns\KkthnxUI\Media\Nameplates\UI-Plate-Healer.tga]])
		self.HealerTexture:Hide()
	end

	if C["Nameplates"].TargetArrow then
		self.TopArrow = self:CreateTexture(nil, "OVERLAY")
		self.TopArrow:SetPoint("BOTTOM", self.Debuffs, "TOP", 0, 30)
		self.TopArrow:SetSize(50, 50)
		self.TopArrow:SetTexture([[Interface\AddOns\KkthnxUI\Media\Nameplates\UI-Plate-Arrow-Top.tga]])
		self.TopArrow:Hide()

		--self.LeftArrow = self:CreateTexture(nil, "BACKGROUND", nil, -5)
		--self.LeftArrow:SetTexture([[Interface\AddOns\KkthnxUI\Media\Nameplates\UI-Plate-Arrow-Left.tga]])
		--self.LeftArrow:Size(45)
		--self.LeftArrow:Hide()

		--self.RightArrow = self:CreateTexture(nil, "BACKGROUND", nil, -5)
		--self.RightArrow:SetTexture([[Interface\AddOns\KkthnxUI\Media\Nameplates\UI-Plate-Arrow-Right.tga]])
		--self.RightArrow:Size(45)
		--self.RightArrow:Hide()
	end

	if C["Nameplates"].EliteIcon then
		self.EliteIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.EliteIcon:SetSize(self.Health:GetHeight() + 4, self.Health:GetHeight() + 4)
		self.EliteIcon:SetParent(self.Health)
		self.EliteIcon:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
		self.EliteIcon:SetTexture("Interface\\TARGETINGFRAME\\Nameplates")
		self.EliteIcon:Hide()
	end

	--[[self:EnableMouse(false)
	self.Health:EnableMouse(false)
	self.Power:EnableMouse(false)
	self.Castbar:EnableMouse(false)--]]

	self.HealthPrediction = Module.CreateHealthPrediction(self, C["Nameplates"].Width)
	Module.CreateDebuffHighlight(self)
	Module.CreatePvPIndicator(self, "nameplate", self, self:GetHeight(), self:GetHeight() + 3)

	do
		-- Elite Icon Events
		if C["Nameplates"].EliteIcon then
			self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.NameplateEliteIcon)
			self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", Module.NameplateEliteIcon)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.NameplateEliteIcon)
			self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", Module.NameplateEliteIcon)
		end

		-- Highlight Plate Events
		self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.HighlightPlate)
		self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", Module.HighlightPlate)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.HighlightPlate)

		-- Target Alpha Events
		self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.UpdateNameplateTarget)
		self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", Module.UpdateNameplateTarget)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateNameplateTarget)

		if C["Nameplates"].ClassIcons then
			self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.NameplateClassIcons)
			self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", Module.NameplateClassIcons)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.NameplateClassIcons)
		end

		-- Totem Icon Events
		if C["Nameplates"].Totems then
			self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.UpdatePlateTotems)
			self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", Module.UpdatePlateTotems)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdatePlateTotems)
		end

		-- Healer Icon Events
		if C["Nameplates"].MarkHealers then
			self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.DisplayHealerTexture)
			self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", Module.DisplayHealerTexture)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.DisplayHealerTexture)
		end

		-- Threat Plate Events
		if C["Nameplates"].Threat then
			self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE", Module.ThreatPlate)
			self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Module.ThreatPlate)
			-- Threat Plate PostUpdate Function
			self.Health.PostUpdate = function()
				Module.ThreatPlate(self)
			end
		end
	end
end