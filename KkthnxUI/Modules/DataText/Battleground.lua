local K, C, L = unpack(select(2, ...))
if C["DataText"].Battleground ~= true then return end

local _G = _G
local select = select
local string_format = string.format

local CurrentMapID = _G.CurrentMapID
local GetBattlefieldScore = _G.GetBattlefieldScore
local GetBattlefieldStatData = _G.GetBattlefieldStatData
local GetCurrentMapAreaID = _G.GetCurrentMapAreaID
local GetNumBattlefieldScores = _G.GetNumBattlefieldScores
local IsInInstance = _G.IsInInstance
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local RequestBattlefieldScoreData = _G.RequestBattlefieldScoreData
local SetMapToCurrentZone = _G.SetMapToCurrentZone
local UnitClass = _G.UnitClass

local NameColor = K.RGBToHex(K.Color.r, K.Color.g, K.Color.b)
local ValueColor = K.RGBToHex(1, 1, 1)

-- Map IDs
local WSG = 443
local TP = 626
local AV = 401
local SOTA = 512
local IOC = 540
local EOTS = 482
local TBFG = 736
local AB = 461
local TOK = 856
local SSM = 860
local DG = 935
local ASH = 978

local DataTextBG = CreateFrame("Frame", nil, UIParent)
DataTextBG:CreatePanel("Invisible", 300, 13, "TOPLEFT", UIParent, "TOPLEFT", 0, -4)
DataTextBG:EnableMouse(true)

local function OnEnter(self)
	local NumScores = GetNumBattlefieldScores()

	for i = 1, NumScores do
		local Name, KillingBlows, HonorableKills, Deaths, HonorGained, _, _, _, _, DamageDone, HealingDone = GetBattlefieldScore(i)

		if (Name and Name == K.Name) then
			local CurMapID = GetCurrentMapAreaID()
			local Color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class]
			local ClassColor = string_format("|cff%.2x%.2x%.2x", Color.r * 255, Color.g * 255, Color.b * 255)
			SetMapToCurrentZone()
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -10, 0)
			GameTooltip:ClearLines()

			GameTooltip:AddDoubleLine(L["DataText"].StatsFor, ClassColor..Name.."|r")
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(L["DataText"].KillingBlow, KillingBlows, 1, 1, 1)
			GameTooltip:AddDoubleLine(L["DataText"].HonorableKill, HonorableKills, 1, 1, 1)
			GameTooltip:AddDoubleLine(L["DataText"].Death, Deaths, 1, 1, 1)
			GameTooltip:AddDoubleLine(L["DataText"].Honor, string_format("%d", HonorGained), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["DataText"].Damage, K.ShortValue(DamageDone), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["DataText"].Healing, K.ShortValue(HealingDone), 1, 1, 1)

			-- Add extra statistics based on what BG you're in.
			if (CurMapID == WSG or CurMapID == TP) then
				GameTooltip:AddDoubleLine(L["DataText"].FlagCapture, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["DataText"].FlagReturn, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif (CurMapID == EOTS) then
				GameTooltip:AddDoubleLine(L["DataText"].FlagCapture, GetBattlefieldStatData(i, 1), 1, 1, 1)
			elseif (CurMapID == AV) then
				GameTooltip:AddDoubleLine(L["DataText"].GraveyardAssault, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["DataText"].GraveyardDefend, GetBattlefieldStatData(i, 2), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["DataText"].TowerAssault, GetBattlefieldStatData(i, 3), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["DataText"].TowerDefend, GetBattlefieldStatData(i, 4), 1, 1, 1)
			elseif (CurMapID == SOTA) then
				GameTooltip:AddDoubleLine(L["DataText"].DemolisherDestroy, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["DataText"].GateDestroy, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif (CurMapID == IOC or CurMapID == TBFG or CurMapID == AB or CurMapID == ASH) then
				GameTooltip:AddDoubleLine(L["DataText"].BaseAssault, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["DataText"].BaseDefend, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif (CurrentMapID == TOK) then
				GameTooltip:AddDoubleLine(L["DataText"].OrbPossession, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["DataText"].VictoryPts, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif (CurrentMapID == SSM) then
				GameTooltip:AddDoubleLine(L["DataText"].CartControl, GetBattlefieldStatData(i, 1), 1, 1, 1)
			elseif (CurrentMapID == DG) then
				GameTooltip:AddDoubleLine(L["DataText"].CartControl, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["DataText"].BaseAssault, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["DataText"].BaseDefend, GetBattlefieldStatData(i, 2), 1, 1, 1)
			end
			break
		end
	end
	GameTooltip:Show()
end

local function OnLeave()
	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide() -- WHY??? BECAUSE FUCK GAMETOOLTIP, THATS WHY!!
	end
end

local int = 2
local function OnUpdate(self, t)
	int = int - t

	if (int < 0) then
		local Amount
		RequestBattlefieldScoreData()
		local NumScores = GetNumBattlefieldScores()

		for i = 1, NumScores do
			local Name, KillingBlows, _, _, HonorGained, _, _, _, _, DamageDone, HealingDone = GetBattlefieldScore(i)

			if (HealingDone > DamageDone) then
				Amount = (NameColor..L["DataText"].Healing.."|r"..ValueColor..K.ShortValue(HealingDone).."|r")
			else
				Amount = (NameColor..L["DataText"].Damage.."|r"..ValueColor..K.ShortValue(DamageDone).."|r")
			end

			if (Name and Name == K.Name) then
				DataTextBG.Text1:SetText(Amount)
				DataTextBG.Text2:SetText(NameColor..L["DataText"].Honor.."|r"..ValueColor..string_format("%d", HonorGained).."|r")
				DataTextBG.Text3:SetText(NameColor..L["DataText"].KillingBlow.."|r"..ValueColor..KillingBlows.."|r")
			end
		end

		int = 2
	end
end

local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		local InInstance, InstanceType = IsInInstance()

		if (InInstance and (InstanceType == "pvp")) then
			self:Show()
		else
			self:Hide()
			DataTextBG.Text1:SetText("")
			DataTextBG.Text2:SetText("")
			DataTextBG.Text3:SetText("")
		end
	end
end

DataTextBG.Text1 = K.SetFontString(DataTextBG, C["Media"].Font, C["Media"].FontSize, C["DataText"].Outline and "OUTLINE" or "", "LEFT")
DataTextBG.Text1:SetShadowOffset(C["DataText"].Outline and 0 or 1.25, C["DataText"].Outline and -0 or -1.25)
DataTextBG.Text1:SetPoint("LEFT", 5, 0)
DataTextBG.Text1:SetHeight(DataTextBG:GetHeight())
DataTextBG.Text1 = DataTextBG.Text1

DataTextBG.Text2 = K.SetFontString(DataTextBG, C["Media"].Font, C["Media"].FontSize, C["DataText"].Outline and "OUTLINE" or "")
DataTextBG.Text2:SetShadowOffset(C["DataText"].Outline and 0 or 1.25, C["DataText"].Outline and -0 or -1.25)
DataTextBG.Text2:SetPoint("LEFT", DataTextBG.Text1, "RIGHT", 5, 0)
DataTextBG.Text2:SetHeight(DataTextBG:GetHeight())
DataTextBG.Text2 = DataTextBG.Text2

DataTextBG.Text3 = K.SetFontString(DataTextBG, C["Media"].Font, C["Media"].FontSize, C["DataText"].Outline and "OUTLINE" or "")
DataTextBG.Text3:SetShadowOffset(C["DataText"].Outline and 0 or 1.25, C["DataText"].Outline and -0 or -1.25)
DataTextBG.Text3:SetPoint("LEFT", DataTextBG.Text2, "RIGHT", 5, 0)
DataTextBG.Text3:SetHeight(DataTextBG:GetHeight())
DataTextBG.Text3 = DataTextBG.Text3

DataTextBG:RegisterEvent("PLAYER_ENTERING_WORLD")
DataTextBG:SetScript("OnUpdate", OnUpdate)
DataTextBG:SetScript("OnEvent", OnEvent)
DataTextBG:SetScript("OnEnter", OnEnter)
DataTextBG:SetScript("OnLeave", OnLeave)
OnUpdate(DataTextBG, 2)