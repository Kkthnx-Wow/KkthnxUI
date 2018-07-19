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
local UnitClass = _G.UnitClass

local NameColor = K.RGBToHex(K.Color.r, K.Color.g, K.Color.b)
local ValueColor = K.RGBToHex(1, 1, 1)

local DataTextBG = CreateFrame("Frame", nil, UIParent)
DataTextBG:SetSize(300, 13)
DataTextBG:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -4)
DataTextBG:SetFrameLevel(0)
DataTextBG:SetFrameStrata("BACKGROUND")
DataTextBG:EnableMouse(true)

local function OnEnter(self)
	local NumScores = GetNumBattlefieldScores()
	local NumExtraStats = GetNumBattlefieldStats()

	for i = 1, NumScores do
		local Name, KillingBlows, HonorableKills, Deaths, HonorGained, _, _, _, _, DamageDone, HealingDone = GetBattlefieldScore(i)

		if (Name and Name == K.Name) then
			local CurrentMapID = C_Map.GetBestMapForUnit("player")
			local Color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
			local ClassColor = format("|cff%.2x%.2x%.2x", Color.r * 255, Color.g * 255, Color.b * 255)

			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, K.Scale(-4))
			GameTooltip:ClearLines()
			GameTooltip:SetPoint("TOP", self, "BOTTOM", 0, -1)
			GameTooltip:ClearLines()
			GameTooltip:AddDoubleLine(L["DataText"].StatsFor, ClassColor..Name.."|r")
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(KILLING_BLOWS, KillingBlows, 1, 1, 1)
			GameTooltip:AddDoubleLine(HONORABLE_KILLS, HonorableKills, 1, 1, 1)
			GameTooltip:AddDoubleLine(DEATHS, Deaths, 1, 1, 1)
			GameTooltip:AddDoubleLine(HONOR, format("%d", HonorGained), 1, 1, 1)
			GameTooltip:AddDoubleLine(DAMAGE, DamageDone, 1, 1, 1)
			GameTooltip:AddDoubleLine(HEALS, HealingDone, 1, 1, 1)

			for j = 1, NumExtraStats do
				GameTooltip:AddDoubleLine(GetBattlefieldStatInfo(j), GetBattlefieldStatData(i, j), 1,1,1)
			end
			
			break
		end
	end
	
	GameTooltip:Show()
end

local function OnLeave()
	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

local int = 2
local function OnUpdate(_, t)
	int = int - t

	if (int < 0) then
		local Amount
		local NumScores = GetNumBattlefieldScores()

		RequestBattlefieldScoreData()

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