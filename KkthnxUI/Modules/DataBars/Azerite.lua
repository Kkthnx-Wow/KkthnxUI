local K, C = unpack(select(2, ...))
local Module = K:NewModule("Azerite", "AceEvent-3.0")

-- Sourced: ElvUI (Elvz)

local _G = _G

local floor = floor
local format = string.format

local C_AzeriteItem_FindActiveAzeriteItem = _G.C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = _G.C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = _G.C_AzeriteItem.GetPowerLevel
local Item = _G.Item
local ARTIFACT_POWER = _G.ARTIFACT_POWER

local AnchorY
function Module:UpdateAzerite(event, unit)
	if not C["DataBars"].AzeriteEnable then
		return
	end

	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end

	if (event == "PLAYER_ENTERING_WORLD") then
		self.azeriteBar.eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

	local bar = self.azeriteBar
	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()

	if not azeriteItemLocation then
		bar:Hide()
	elseif azeriteItemLocation then
		bar:Show()

		local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		bar.statusBar:SetMinMaxValues(0, totalLevelXP)
		bar.statusBar:SetValue(xp)

		local text = format("%s%% [%s]", floor(xp / totalLevelXP * 100), currentLevel)

		bar.text:SetText(text)
	end
end

function Module:AzeriteBar_OnEnter()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
	local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
	local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
	local xpToNextLevel = totalLevelXP - xp

	self.itemDataLoadedCancelFunc = azeriteItem:ContinueWithCancelOnItemLoad(function()
		local azeriteItemName = azeriteItem:GetItemName()

		-- From Blizz Code
		-- GameTooltip:SetText(AZERITE_POWER_TOOLTIP_TITLE:format(currentLevel, xpToNextLevel), HIGHLIGHT_FONT_COLOR:GetRGB())
		-- GameTooltip:AddLine(AZERITE_POWER_TOOLTIP_BODY:format(azeriteItemName))

		GameTooltip:AddDoubleLine(ARTIFACT_POWER, azeriteItemName.." ("..currentLevel..")", nil,  nil, nil, 0.90, 0.80, 0.50) -- Temp Locale
		GameTooltip:AddLine(" ")

		GameTooltip:AddDoubleLine("AP:", format(" %d / %d (%d%%)", xp, totalLevelXP, xp / totalLevelXP  * 100), 1, 1, 1)
		GameTooltip:AddDoubleLine("Remaining:", format(" %d (%d%% - %d ".."Bars"..")", xpToNextLevel, xpToNextLevel / totalLevelXP * 100, 10 * xpToNextLevel / totalLevelXP), 1, 1, 1)

		GameTooltip:Show()
	end)
end

function Module:AzeriteBar_OnLeave()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
	end

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

function Module:AzeriteBar_OnClick()

end

function Module:UpdateAzeriteDimensions()
	self.azeriteBar:SetSize(Minimap:GetWidth() or C["DataBars"].AzeriteWidth, C["DataBars"].AzeriteHeight)
	self.azeriteBar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, C["DataBars"].Outline and "OUTLINE" or "", "CENTER")
	self.azeriteBar.text:SetShadowOffset(C["DataBars"].Outline and 0 or 1.25, C["DataBars"].Outline and - 0 or - 1.25)
	self.azeriteBar.spark:SetSize(16, self.azeriteBar:GetHeight())

	if C["DataBars"].MouseOver then
		self.azeriteBar:SetAlpha(0.25)
	else
		self.azeriteBar:SetAlpha(1)
	end
end

function Module:EnableDisable_AzeriteBar()
	if C["DataBars"].AzeriteEnable then
		self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "UpdateAzerite")
		self:RegisterEvent("UNIT_INVENTORY_CHANGED", "UpdateAzerite")

		self:UpdateAzerite()
	else
		self:UnregisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
		self:UnregisterEvent("UNIT_INVENTORY_CHANGED")

		self.azeriteBar:Hide()
	end
end

function Module:OnEnable()
	local IsXPCheck = ((UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) or IsXPUserDisabled())
	local ArtifactFont = K.GetFont(C["DataBars"].Font)
	local ArtifactTexture = K.GetTexture(C["DataBars"].Texture)

	if K.Level == _G.MAX_PLAYER_LEVEL or IsXPCheck then
		AnchorY = -6
	else
		AnchorY = -24
	end

	self.azeriteBar = CreateFrame("Button", "Azerite", K.PetBattleHider)
	self.azeriteBar:SetPoint("TOP", Minimap, "BOTTOM", 0, AnchorY)
	self.azeriteBar:SetScript("OnEnter", Module.AzeriteBar_OnEnter)
	self.azeriteBar:SetScript("OnLeave", Module.AzeriteBar_OnLeave)
	self.azeriteBar:SetScript("OnClick", Module.AzeriteBar_OnClick)
	self.azeriteBar:SetFrameStrata("LOW")
	self.azeriteBar:Hide()

	self.azeriteBar.statusBar = CreateFrame("StatusBar", nil, self.azeriteBar)
	self.azeriteBar.statusBar:SetAllPoints()
	self.azeriteBar.statusBar:SetStatusBarTexture(ArtifactTexture)
	self.azeriteBar.statusBar:SetStatusBarColor(.901, .8, .601)
	self.azeriteBar.statusBar:SetMinMaxValues(0, 325)

	self.azeriteBar.statusBar:CreateBorder()

	self.azeriteBar.eventFrame = CreateFrame("Frame")
	self.azeriteBar.eventFrame:Hide()
	self.azeriteBar.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.azeriteBar.eventFrame:SetScript("OnEvent", function(_, event)
		Module:UpdateAzerite(event)
	end)

	self.azeriteBar.text = self.azeriteBar.statusBar:CreateFontString(nil, "OVERLAY")
	self.azeriteBar.text:SetFontObject(ArtifactFont)
	self.azeriteBar.text:SetFont(select(1, self.azeriteBar.text:GetFont()), 11, select(3, self.azeriteBar.text:GetFont()))
	self.azeriteBar.text:SetPoint("CENTER")

	self.azeriteBar.spark = self.azeriteBar.statusBar:CreateTexture(nil, "OVERLAY")
	self.azeriteBar.spark:SetTexture(C["Media"].Spark_16)
	self.azeriteBar.spark:SetBlendMode("ADD")
	self.azeriteBar.spark:SetPoint("CENTER", self.azeriteBar.statusBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	self:UpdateAzeriteDimensions()
	K.Movers:RegisterFrame(self.azeriteBar)
	self:EnableDisable_AzeriteBar()
end