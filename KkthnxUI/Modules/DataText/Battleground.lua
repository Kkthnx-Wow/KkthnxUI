-- local K, C, L = unpack(select(2, ...))
-- if C["DataText"].Battleground ~= true then return end

-- -- Lua API
-- local select = select
-- local string_format = string.format

-- -- Wow API
-- local CurrentMapID = CurrentMapID
-- local GetBattlefieldScore = GetBattlefieldScore
-- local GetBattlefieldStatData = GetBattlefieldStatData
-- local GetCurrentMapAreaID = GetCurrentMapAreaID
-- local GetNumBattlefieldScores = GetNumBattlefieldScores
-- local IsInInstance = IsInInstance
-- local RAID_CLASS_COLORS = RAID_CLASS_COLORS
-- local RequestBattlefieldScoreData = RequestBattlefieldScoreData
-- local SetMapToCurrentZone = SetMapToCurrentZone
-- local UnitClass = UnitClass

-- -- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- -- GLOBALS: GameTooltip

-- local MyName = UnitName("player")
-- local NameColor = K.RGBToHex(K.Color.r, K.Color.g, K.Color.b)
-- local ValueColor = K.RGBToHex(1, 1, 1)

-- local int = 2

-- -- Map IDs
-- local WSG = 443
-- local TP = 626
-- local AV = 401
-- local SOTA = 512
-- local IOC = 540
-- local EOTS = 482
-- local TBFG = 736
-- local AB = 461
-- local TOK = 856
-- local SSM = 860

-- local DataTextBG = CreateFrame("Frame", nil, UIParent)
-- DataTextBG:CreatePanel("Invisible", 300, C["Media"].FontSize, unpack(C.Position.BGScore))
-- DataTextBG:EnableMouse(true)

-- local function OnEnter(self)
-- 	local NumScores = GetNumBattlefieldScores()

-- 	for i = 1, NumScores do
-- 		local Name, KillingBlows, HonorableKills, Deaths, HonorGained, _, _, _, _, DamageDone, HealingDone = GetBattlefieldScore(i)

-- 		if (Name and Name == MyName) then
-- 			local CurMapID = GetCurrentMapAreaID()
-- 			local Color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
-- 			local ClassColor = string_format("|cff%.2x%.2x%.2x", Color.r * 255, Color.g * 255, Color.b * 255)
-- 			SetMapToCurrentZone()
-- 			GameTooltip:SetOwner(self, "ANCHOR_NONE")
-- 			GameTooltip:SetPoint(K.GetAnchors(self))
-- 			GameTooltip:ClearLines()
-- 			GameTooltip:AddDoubleLine(L.DataText.StatsFor, ClassColor..Name.."|r")
-- 			GameTooltip:AddLine(" ")
-- 			GameTooltip:AddDoubleLine(L.DataText.KillingBlow, KillingBlows, 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(L.DataText.HonorableKill, HonorableKills, 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(L.DataText.Death, Deaths, 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(L.DataText.Honor, string_format("%d", HonorGained), 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(L.DataText.Damage, DamageDone, 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(L.DataText.Healing, HealingDone, 1, 1, 1)

-- 			-- Add extra statistics based on what BG you're in.
-- 			if (CurMapID == WSG or CurMapID == TP) then
-- 				GameTooltip:AddDoubleLine(L.DataText.FlagCapture, GetBattlefieldStatData(i, 1), 1, 1, 1)
-- 				GameTooltip:AddDoubleLine(L.DataText.FlagReturn, GetBattlefieldStatData(i, 2), 1, 1, 1)
-- 			elseif (CurMapID == EOTS) then
-- 				GameTooltip:AddDoubleLine(L.DataText.FlagCapture, GetBattlefieldStatData(i, 1), 1, 1, 1)
-- 			elseif (CurMapID == AV) then
-- 				GameTooltip:AddDoubleLine(L.DataText.GraveyardAssault, GetBattlefieldStatData(i, 1), 1, 1, 1)
-- 				GameTooltip:AddDoubleLine(L.DataText.GraveyardDefend, GetBattlefieldStatData(i, 2), 1, 1, 1)
-- 				GameTooltip:AddDoubleLine(L.DataText.TowerAssault, GetBattlefieldStatData(i, 3), 1, 1, 1)
-- 				GameTooltip:AddDoubleLine(L.DataText.TowerDefend, GetBattlefieldStatData(i, 4), 1, 1, 1)
-- 			elseif (CurMapID == SOTA) then
-- 				GameTooltip:AddDoubleLine(L.DataText.DemolisherDestroy, GetBattlefieldStatData(i, 1), 1, 1, 1)
-- 				GameTooltip:AddDoubleLine(L.DataText.GateDestroy, GetBattlefieldStatData(i, 2), 1, 1, 1)
-- 			elseif (CurMapID == IOC or CurMapID == TBFG or CurMapID == AB) then
-- 				GameTooltip:AddDoubleLine(L.DataText.BaseAssault, GetBattlefieldStatData(i, 1), 1, 1, 1)
-- 				GameTooltip:AddDoubleLine(L.DataText.BaseDefend, GetBattlefieldStatData(i, 2), 1, 1, 1)
-- 			elseif (CurrentMapID == TOK) then
-- 				GameTooltip:AddDoubleLine(L.DataText.OrbPossession, GetBattlefieldStatData(i, 1), 1, 1, 1)
-- 				GameTooltip:AddDoubleLine(L.DataText.VictoryPts, GetBattlefieldStatData(i, 2), 1, 1, 1)
-- 			elseif (CurrentMapID == SSM) then
-- 				GameTooltip:AddDoubleLine(L.DataText.CartControl, GetBattlefieldStatData(i, 1), 1, 1, 1)
-- 			end

-- 			GameTooltip:Show()
-- 		end
-- 	end
-- end

-- local function OnLeave()
-- 	GameTooltip:Hide()
-- end

-- local function OnUpdate(self, t)
-- 	int = int - t

-- 	if (int < 0) then
-- 		local Amount
-- 		RequestBattlefieldScoreData()
-- 		local NumScores = GetNumBattlefieldScores()

-- 		for i = 1, NumScores do
-- 			local Name, KillingBlows, _, _, HonorGained, _, _, _, _, DamageDone, HealingDone = GetBattlefieldScore(i)

-- 			if (HealingDone > DamageDone) then
-- 				Amount = (NameColor..L.DataText.Healing.."|r"..ValueColor..K.ShortValue(HealingDone).."|r")
-- 			else
-- 				Amount = (NameColor..L.DataText.Damage.."|r"..ValueColor..K.ShortValue(DamageDone).."|r")
-- 			end

-- 			if (Name and Name == MyName) then
-- 				self.Text1:SetText(Amount)
-- 				self.Text2:SetText(NameColor..L.DataText.Honor.."|r"..ValueColor..string_format("%d", HonorGained).."|r")
-- 				self.Text3:SetText(NameColor..L.DataText.KillingBlow.."|r"..ValueColor..KillingBlows.."|r")
-- 			end
-- 		end

-- 		int = 2
-- 	end
-- end

-- local function OnEvent(self)
-- 	local InInstance, InstanceType = IsInInstance()

-- 	if (InInstance and (InstanceType == "pvp")) then
-- 		self:Show()
-- 	else
-- 		self:Hide()
-- 		self.Text1:SetText("")
-- 		self.Text2:SetText("")
-- 		self.Text3:SetText("")
-- 	end
-- end

-- local Text1 = K.SetFontString(DataTextBG, C["Media"].Font, C["Media"].FontSize, C["DataText"].Outline and "OUTLINE" or "", "LEFT")
-- Text1:SetShadowOffset(C["DataText"].Outline and 0 or 1.25, C["DataText"].Outline and -0 or -1.25)
-- Text1:SetPoint("LEFT", 5, 0)
-- Text1:SetHeight(DataTextBG:GetHeight())
-- DataTextBG.Text1 = Text1

-- local Text2 = K.SetFontString(DataTextBG, C["Media"].Font, C["Media"].FontSize, C["DataText"].Outline and "OUTLINE" or "")
-- Text2:SetShadowOffset(C["DataText"].Outline and 0 or 1.25, C["DataText"].Outline and -0 or -1.25)
-- Text2:SetPoint("LEFT", Text1, "RIGHT", 5, 0)
-- Text2:SetHeight(DataTextBG:GetHeight())
-- DataTextBG.Text2 = Text2

-- local Text3 = K.SetFontString(DataTextBG, C["Media"].Font, C["Media"].FontSize, C["DataText"].Outline and "OUTLINE" or "")
-- Text3:SetShadowOffset(C["DataText"].Outline and 0 or 1.25, C["DataText"].Outline and -0 or -1.25)
-- Text3:SetPoint("LEFT", Text2, "RIGHT", 5, 0)
-- Text3:SetHeight(DataTextBG:GetHeight())
-- DataTextBG.Text3 = Text3

-- DataTextBG:RegisterEvent("PLAYER_ENTERING_WORLD")
-- DataTextBG:SetScript("OnUpdate", OnUpdate)
-- DataTextBG:SetScript("OnEvent", OnEvent)
-- DataTextBG:SetScript("OnEnter", OnEnter)
-- DataTextBG:SetScript("OnLeave", OnLeave)