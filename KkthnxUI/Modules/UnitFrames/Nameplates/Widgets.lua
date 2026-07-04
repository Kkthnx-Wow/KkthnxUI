--[[-----------------------------------------------------------------------------
-- Dungeon M+ progress, rare/elite classify icon, PvP class icon on nameplates.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")
local NP = Module.NP

local string_format = string.format
local unpack = unpack
local select = select
local CreateFrame = CreateFrame

local C_Scenario_GetInfo = C_Scenario.GetInfo
local C_Scenario_GetStepInfo = C_Scenario.GetStepInfo
local C_ScenarioInfo_GetCriteriaInfo = C_ScenarioInfo.GetCriteriaInfo
local LE_SCENARIO_TYPE_CHALLENGE_MODE = LE_SCENARIO_TYPE_CHALLENGE_MODE
local UnitClassification = UnitClassification
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local mdtCacheData = NP.mdtCacheData
local NPClassifies = NP.NPClassifies

function Module:AddDungeonProgress(self)
	if not C["Nameplate"].AKSProgress then
		return
	end

	self.progressText = K.CreateFontString(self, 13, "", "", false, "LEFT", 0, 0)
	self.progressText:ClearAllPoints()
	self.progressText:SetPoint("LEFT", self, "RIGHT", 5, 0)
end

function Module:UpdateDungeonProgress(unit)
	if not self.progressText or not MDT then
		return
	end

	if unit ~= self.unit then
		return
	end
	self.progressText:SetText("")

	local name, _, _, _, _, _, _, _, _, scenarioType = C_Scenario_GetInfo()
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
		local value = MDT:GetEnemyForces(self.npcID)
		if value and value > 0 then
			local total = mdtCacheData[name]
			if not total then
				local numCriteria = select(3, C_Scenario_GetStepInfo())
				for criteriaIndex = 1, numCriteria do
					local criteriaInfo = C_ScenarioInfo_GetCriteriaInfo(criteriaIndex)
					if criteriaInfo and criteriaInfo.isWeightedProgress then
						mdtCacheData[name] = criteriaInfo.totalQuantity
						total = mdtCacheData[name]
						break
					end
				end
			end

			if total then
				self.progressText:SetText(string_format("+%.2f", value / total * 100))
			end
		end
	end
end

function Module:AddCreatureIcon(self)
	local classifyIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	classifyIndicator:SetPoint("RIGHT", self.nameText, "LEFT", 8, 0)
	classifyIndicator:SetSize(14, 14)
	classifyIndicator:Hide()

	self.ClassifyIndicator = classifyIndicator
end

function Module:UpdateUnitClassify(unit)
	if not self.ClassifyIndicator then
		return
	end

	unit = unit or self.unit
	self.ClassifyIndicator:Hide()

	local class = UnitClassification(unit)
	local data = class and NPClassifies[class]
	if data then
		self.ClassifyIndicator:SetTexture(C["Media"].Textures.StarIcon)
		self.ClassifyIndicator:SetVertexColor(unpack(data.color))
		self.ClassifyIndicator:SetDesaturated(data.desaturate)
		self.ClassifyIndicator:Show()
	end
end

function Module:AddClassIcon(self)
	if not C["Nameplate"].ClassIcon then
		return
	end

	self.Class = CreateFrame("Frame", nil, self)
	self.Class:SetSize(self:GetHeight() * 2 + 3, self:GetHeight() * 2 + 3)
	self.Class:SetPoint("BOTTOMLEFT", self.Castbar, "BOTTOMRIGHT", 3, 0)
	self.Class:CreateShadow(true)

	self.Class.Icon = self.Class:CreateTexture(nil, "OVERLAY")
	self.Class.Icon:SetAllPoints()
	self.Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
	self.Class.Icon:SetTexCoord(0, 0, 0, 0)
end

function Module:UpdateClassIcon(self, unit)
	if not C["Nameplate"].ClassIcon then
		return
	end

	local reaction = UnitReaction(unit, "player")
	if UnitIsPlayer(unit) and (reaction and reaction <= 4) then
		local _, class = UnitClass(unit)

		if class and CLASS_ICON_TCOORDS[class] then
			local texcoord = CLASS_ICON_TCOORDS[class]
			self.Class.Icon:SetTexCoord(texcoord[1] + 0.015, texcoord[2] - 0.02, texcoord[3] + 0.018, texcoord[4] - 0.02)
			self.Class:Show()
		else
			self.Class.Icon:SetTexCoord(0, 0, 0, 0)
			self.Class:Hide()
		end
	else
		self.Class.Icon:SetTexCoord(0, 0, 0, 0)
		self.Class:Hide()
	end
end
