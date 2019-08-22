--------------
-- FIX ME SOON
--------------

-- local K, C, L = unpack(select(2, ...))
-- local Module = CreateFrame("Frame", nil, UIParent)

-- local _G = _G
-- local string_format = string.format

-- local DAMAGE = _G.DAMAGE
-- local DEATHS = _G.DEATHS
-- local GameTooltip = _G.GameTooltip
-- local GetBattlefieldScore = _G.GetBattlefieldScore
-- local GetBattlefieldStatData = _G.GetBattlefieldStatData
-- local GetBattlefieldStatInfo = _G.GetBattlefieldStatInfo
-- local GetNumBattlefieldScores = _G.GetNumBattlefieldScores
-- local GetNumBattlefieldStats = _G.GetNumBattlefieldStats
-- local HEALS = _G.HEALS
-- local HONOR = _G.HONOR
-- local HONORABLE_KILLS = _G.HONORABLE_KILLS
-- local IsInInstance = _G.IsInInstance
-- local KILLING_BLOWS = _G.KILLING_BLOWS
-- local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS

-- Module.NameColor = K.RGBToHex(K.Color.r, K.Color.g, K.Color.b)
-- Module.ValueColor = K.RGBToHex(1, 1, 1)

-- local int = 2
-- function Module:OnEnter()
-- 	local NumScores = GetNumBattlefieldScores()
-- 	local NumExtraStats = GetNumBattlefieldStats()

-- 	for i = 1, NumScores do
-- 		local Name, KillingBlows, HonorableKills, Deaths, HonorGained, _, _, _, _, DamageDone, HealingDone = GetBattlefieldScore(i)

-- 		if (Name and Name == K.Name) then
-- 			local Color = RAID_CLASS_COLORS[K.Class]
-- 			local ClassColor = string_format("|cff%.2x%.2x%.2x", Color.r * 255, Color.g * 255, Color.b * 255)

-- 			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
-- 			GameTooltip:ClearLines()
-- 			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
-- 			GameTooltip:ClearLines()
-- 			GameTooltip:AddDoubleLine(L["DataText"].StatsFor, ClassColor..Name.."|r")
-- 			GameTooltip:AddLine(" ")
-- 			GameTooltip:AddDoubleLine(KILLING_BLOWS, KillingBlows, 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(HONORABLE_KILLS, HonorableKills, 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(DEATHS, Deaths, 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(HONOR, string_format("%d", HonorGained), 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(DAMAGE, K.ShortValue(DamageDone), 1, 1, 1)
-- 			GameTooltip:AddDoubleLine(HEALS, K.ShortValue(HealingDone), 1, 1, 1)

-- 			for j = 1, NumExtraStats do
-- 				GameTooltip:AddDoubleLine(GetBattlefieldStatInfo(j), GetBattlefieldStatData(i, j), 1,1,1)
-- 			end

-- 			break
-- 		end
-- 	end

-- 	GameTooltip:Show()
-- end

-- function Module:OnLeave()
-- 	GameTooltip:Hide()
-- end

-- function Module:OnUpdate(t)
-- 	int = int - t

-- 	if (int < 0) then
-- 		local Amount
-- 		local NumScores = GetNumBattlefieldScores()

-- 		RequestBattlefieldScoreData()

-- 		for i = 1, NumScores do
-- 			local Name, KillingBlows, _, _, HonorGained, _, _, _, _, DamageDone, HealingDone = GetBattlefieldScore(i)

-- 			if (HealingDone > DamageDone) then
-- 				Amount = (Module.NameColor..L["DataText"].Healing.."|r"..Module.ValueColor..K.ShortValue(HealingDone).."|r")
-- 			else
-- 				Amount = (Module.NameColor..L["DataText"].Damage.."|r"..Module.ValueColor..K.ShortValue(DamageDone).."|r")
-- 			end

-- 			if (Name and Name == K.Name) then
-- 				self.Text1:SetText(Amount)
-- 				self.Text2:SetText(Module.NameColor..L["DataText"].Honor.."|r"..Module.ValueColor..string_format("%d", HonorGained).."|r")
-- 				self.Text3:SetText(Module.NameColor..L["DataText"].KillingBlow.."|r"..Module.ValueColor..KillingBlows.."|r")
-- 			end
-- 		end

-- 		int = 2
-- 	end
-- end

-- function Module:OnEvent()
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

-- function Module:OnEnable()
-- 	if not (C["DataText"].Battleground) then
-- 		return
-- 	end

-- 	local DataText_Font = K.GetFont(C["UIFonts"].DataTextFonts)

-- 	Module:SetSize(300, 13)
-- 	Module:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -4)
-- 	Module:SetFrameLevel(4)
-- 	Module:SetFrameStrata("BACKGROUND")

-- 	local Text1 = Module:CreateFontString(nil, "OVERLAY")
-- 	Text1:SetFontObject(DataText_Font)
-- 	Text1:SetPoint("LEFT", 5, 0)
-- 	Text1:SetHeight(Module:GetHeight())
-- 	Module.Text1 = Text1

-- 	local Text2 = Module:CreateFontString(nil, "OVERLAY")
-- 	Text2:SetFontObject(DataText_Font)
-- 	Text2:SetPoint("LEFT", Module.Text1, "RIGHT", 5, 0)
-- 	Text2:SetHeight(Module:GetHeight())
-- 	Module.Text2 = Text2

-- 	local Text3 = Module:CreateFontString(nil, "OVERLAY")
-- 	Text3:SetFontObject(DataText_Font)
-- 	Text3:SetPoint("LEFT", Module.Text2, "RIGHT", 5, 0)
-- 	Text3:SetHeight(Module:GetHeight())
-- 	Module.Text3 = Text3

-- 	Module:RegisterEvent("PLAYER_ENTERING_WORLD")
-- 	Module:SetScript("OnUpdate", Module.OnUpdate)
-- 	Module:SetScript("OnEvent", Module.OnEvent)
-- 	Module:SetScript("OnEnter", Module.OnEnter)
-- 	Module:SetScript("OnLeave", Module.OnLeave)
-- end

-- Module:OnEnable()