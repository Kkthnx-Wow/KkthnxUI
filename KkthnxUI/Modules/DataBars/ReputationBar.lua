local K, C, L = unpack(select(2, ...))

local Module = K:NewModule("Reputation_DataBar", "AceEvent-3.0")

local _G = _G
local format = format

local GetFriendshipReputation = GetFriendshipReputation
local GetWatchedFactionInfo, GetNumFactions, GetFactionInfo = GetWatchedFactionInfo, GetNumFactions, GetFactionInfo
local InCombatLockdown = InCombatLockdown
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local REPUTATION, STANDING = REPUTATION, STANDING

local ReputationFont = K.GetFont(C["DataBars"].Font)
local ReputationTexture = K.GetTexture(C["DataBars"].Texture)

local backupColor = FACTION_BAR_COLORS[1]
local FactionStandingLabelUnknown = UNKNOWN
function Module:UpdateReputation(event)
	if not C["DataBars"].ReputationEnable then return end

	local bar = self.reputationBar

	local ID, isFriend, friendText, standingLabel
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()

	local numFactions = GetNumFactions()

	if not name then
		bar:Hide()
	elseif name then
		bar:Show()

		local color = FACTION_BAR_COLORS[reaction] or backupColor
		bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)

		bar.statusBar:SetMinMaxValues(min, max)
		bar.statusBar:SetValue(value)

		for i = 1, numFactions do
			local factionName, _, standingID,_,_,_,_,_,_,_,_,_,_, factionID = GetFactionInfo(i)
			local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
			if factionName == name then
				if friendID ~= nil then
					isFriend = true
					friendText = friendTextLevel
				else
					ID = standingID
				end
			end
		end

		if ID then
			standingLabel = _G["FACTION_STANDING_LABEL"..ID]
		else
			standingLabel = FactionStandingLabelUnknown
		end

		-- Prevent a division by zero
		local maxMinDiff = max - min
		if (maxMinDiff == 0) then
			maxMinDiff = 1
		end

		local text = format("%s: %d%% [%s]", name, ((value - min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)

		bar.text:SetText(text)
	end
end

function Module:ReputationBar_OnEnter()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()

	if name then
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(" ")

		local friendID, friendTextLevel, _
		if factionID then
			friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
		end

		GameTooltip:AddDoubleLine(STANDING..':', (friendID and friendTextLevel) or _G['FACTION_STANDING_LABEL'..reaction], 1, 1, 1)
		GameTooltip:AddDoubleLine(REPUTATION..":", format("%d / %d (%d%%)", value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
	end
	GameTooltip:Show()
end

function Module:ReputationBar_OnLeave()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
	end

	GameTooltip:Hide()
end

function Module:ReputationBar_OnClick()
	ToggleCharacter("ReputationFrame")
end

function Module:UpdateReputationDimensions()
	self.reputationBar:SetSize(Minimap:GetWidth() or C["DataBars"].ReputationWidth, C["DataBars"].ReputationHeight)
	self.reputationBar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, C["DataBars"].Outline and "OUTLINE" or "", "CENTER")
	self.reputationBar.text:SetShadowOffset(C["DataBars"].Outline and 0 or 1.25, C["DataBars"].Outline and -0 or -1.25)
	self.reputationBar.text:SetSize(self.reputationBar:GetWidth() - 4, C["Media"].FontSize - 1)

	if C["DataBars"].MouseOver then
		self.reputationBar:SetAlpha(0)
	else
		self.reputationBar:SetAlpha(1)
	end
end

function Module:EnableDisable_ReputationBar()
	if C["DataBars"].ReputationEnable then
		self:RegisterEvent("UPDATE_FACTION", "UpdateReputation")
		self:UpdateReputation()
	else
		self:UnregisterEvent("UPDATE_FACTION")
		self.reputationBar:Hide()
	end
end

function Module:OnEnable()
	self.reputationBar = CreateFrame("Button", "KkthnxUI_ReputationBar", K.PetBattleHider)
	self.reputationBar:SetPoint("TOP", Minimap, "BOTTOM", 0, -24)
	self.reputationBar:SetScript("OnEnter", Module.ReputationBar_OnEnter)
	self.reputationBar:SetScript("OnLeave", Module.ReputationBar_OnLeave)
	self.reputationBar:SetScript("OnClick", Module.ReputationBar_OnClick)
	self.reputationBar:SetFrameStrata('LOW')
	self.reputationBar:Hide()

	self.reputationBar.statusBar = CreateFrame("StatusBar", nil, self.reputationBar)
	self.reputationBar.statusBar:SetAllPoints()
	self.reputationBar.statusBar:SetStatusBarTexture(ReputationTexture)
	self.reputationBar.statusBar:SetTemplate("Transparent")

	self.reputationBar.text = self.reputationBar.statusBar:CreateFontString(nil, "OVERLAY")
	self.reputationBar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, C["DataBars"].Outline and "OUTLINE" or "", "CENTER")
	self.reputationBar.text:SetSize(self.reputationBar:GetWidth() - 4, C["Media"].FontSize - 1)
	self.reputationBar.text:SetShadowOffset(C["DataBars"].Outline and 0 or 1.25, C["DataBars"].Outline and -0 or -1.25)
	self.reputationBar.text:SetPoint("CENTER")

	self.reputationBar.spark = self.reputationBar.statusBar:CreateTexture(nil, "ARTWORK", nil, 1)
	self.reputationBar.spark:SetWidth(12)
	self.reputationBar.spark:SetHeight(self.reputationBar.statusBar:GetHeight() * 3)
	self.reputationBar.spark:SetTexture(C["Media"].Spark)
	self.reputationBar.spark:SetBlendMode("ADD")
	self.reputationBar.spark:SetPoint("CENTER", self.reputationBar.statusBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	self.reputationBar.eventFrame = CreateFrame("Frame")
	self.reputationBar.eventFrame:Hide()
	self.reputationBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.reputationBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.reputationBar.eventFrame:SetScript("OnEvent", function(self, event) Module:UpdateReputation(event) end)

	self:UpdateReputationDimensions()

	K.Movers:RegisterFrame(self.reputationBar)
	self:EnableDisable_ReputationBar()
end