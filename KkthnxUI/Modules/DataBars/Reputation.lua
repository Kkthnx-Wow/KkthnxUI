local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Reputation", "AceEvent-3.0")

-- Sourced: ElvUI (Elvz)

local _G = _G
local format = format

local C_Reputation_GetFactionParagonInfo = K.Legion735 and _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = K.Legion735 and _G.C_Reputation.IsFactionParagon
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetWatchedFactionInfo, GetNumFactions, GetFactionInfo = _G.GetWatchedFactionInfo, _G.GetNumFactions, _G.GetFactionInfo
local InCombatLockdown = _G.InCombatLockdown
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local REPUTATION, STANDING = _G.REPUTATION, _G.STANDING

local ReputationFont = K.GetFont(C["DataBars"].Font)
local ReputationTexture = K.GetTexture(C["DataBars"].Texture)

local backupColor = FACTION_BAR_COLORS[1]
local FactionStandingLabelUnknown = UNKNOWN
function Module:UpdateReputation(event)
	if not C["DataBars"].ReputationEnable then return end

	local bar = self.reputationBar

	local ID, isFriend, friendText, standingLabel
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()

	if K.Legion735 then
		if factionID and C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue and threshold then
				min, max = 0, threshold
				value = currentValue % threshold
				if hasRewardPending then
					value = value + threshold
				end
			end
		end
	end

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
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()

	if K.Legion735 then
		if factionID and C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue and threshold then
				min, max = 0, threshold
				value = currentValue % threshold
				if hasRewardPending then
					value = value + threshold
				end
			end
		end
	end

	if name then
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(" ")

		local friendID, friendTextLevel, _
		if factionID then
			friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
		end

		GameTooltip:AddDoubleLine(STANDING..":", (friendID and friendTextLevel) or _G["FACTION_STANDING_LABEL"..reaction], 1, 1, 1)
		GameTooltip:AddDoubleLine(REPUTATION..":", format("%d / %d (%d%%)", value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
	end
	GameTooltip:Show()
end

function Module:ReputationBar_OnLeave()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
	end

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

function Module:ReputationBar_OnClick()
	ToggleCharacter("ReputationFrame")
end

function Module:UpdateReputationDimensions()
	self.reputationBar:SetSize(Minimap:GetWidth() or C["DataBars"].ReputationWidth, C["DataBars"].ReputationHeight)
	self.reputationBar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, C["DataBars"].Outline and "OUTLINE" or "", "CENTER")
	self.reputationBar.text:SetShadowOffset(C["DataBars"].Outline and 0 or 1.25, C["DataBars"].Outline and -0 or -1.25)
	self.reputationBar.text:SetSize(self.reputationBar:GetWidth() - 4, C["Media"].FontSize - 1)
	self.reputationBar.spark:SetSize(16, self.reputationBar:GetHeight())

	if C["DataBars"].MouseOver then
		self.reputationBar:SetAlpha(0.25)
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
	self.reputationBar = CreateFrame("Button", "Reputation", K.PetBattleHider)
	self.reputationBar:SetPoint("TOP", Minimap, "BOTTOM", 0, -24)
	self.reputationBar:SetScript("OnEnter", Module.ReputationBar_OnEnter)
	self.reputationBar:SetScript("OnLeave", Module.ReputationBar_OnLeave)
	self.reputationBar:SetScript("OnClick", Module.ReputationBar_OnClick)
	self.reputationBar:SetFrameStrata("LOW")
	self.reputationBar:Hide()

	self.reputationBar.statusBar = CreateFrame("StatusBar", nil, self.reputationBar)
	self.reputationBar.statusBar:SetAllPoints()
	self.reputationBar.statusBar:SetStatusBarTexture(ReputationTexture)

	self.reputationBar.statusBar.Backgrounds = self.reputationBar.statusBar:CreateTexture(nil, "BACKGROUND", -1)
	self.reputationBar.statusBar.Backgrounds:SetAllPoints()
	self.reputationBar.statusBar.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	self.reputationBar.statusBar.Borders = CreateFrame("Frame", nil, self.reputationBar.statusBar)
	self.reputationBar.statusBar.Borders:SetAllPoints()
	K.CreateBorder(self.reputationBar.statusBar.Borders)

	self.reputationBar.text = self.reputationBar.statusBar:CreateFontString(nil, "OVERLAY")
	self.reputationBar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, C["DataBars"].Outline and "OUTLINE" or "", "CENTER")
	self.reputationBar.text:SetSize(self.reputationBar:GetWidth() - 4, C["Media"].FontSize - 1)
	self.reputationBar.text:SetShadowOffset(C["DataBars"].Outline and 0 or 1.25, C["DataBars"].Outline and -0 or -1.25)
	self.reputationBar.text:SetPoint("CENTER")

	self.reputationBar.spark = self.reputationBar.statusBar:CreateTexture(nil, "OVERLAY")
	self.reputationBar.spark:SetTexture(C["Media"].Spark_16)
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