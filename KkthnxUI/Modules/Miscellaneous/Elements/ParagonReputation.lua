local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local math_floor = _G.math.floor
local mod = _G.mod
local select = _G.select
local string_format = _G.string.format
local table_remove = _G.table.remove
local unpack = _G.unpack

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local C_QuestLog_GetLogIndexForQuestID = _G.C_QuestLog.GetLogIndexForQuestID
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = _G.C_Reputation.IsFactionParagon
local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local FONT_COLOR_CODE_CLOSE = _G.FONT_COLOR_CODE_CLOSE
local FauxScrollFrame_GetOffset = _G.FauxScrollFrame_GetOffset
local GameTooltip_AddQuestRewardsToTooltip = _G.GameTooltip_AddQuestRewardsToTooltip
local GameTooltip_SetDefaultAnchor = _G.GameTooltip_SetDefaultAnchor
local GetFactionInfo = _G.GetFactionInfo
local GetFactionInfoByID = _G.GetFactionInfoByID
local GetItemInfo = _G.GetItemInfo
local GetNumFactions = _G.GetNumFactions
local GetQuestLogCompletionText = _G.GetQuestLogCompletionText
local GetSelectedFaction = _G.GetSelectedFaction
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local HIGHLIGHT_FONT_COLOR = _G.HIGHLIGHT_FONT_COLOR
local HIGHLIGHT_FONT_COLOR_CODE = _G.HIGHLIGHT_FONT_COLOR_CODE
local NUM_FACTIONS_DISPLAYED = _G.NUM_FACTIONS_DISPLAYED
local PlaySound = _G.PlaySound
local REPUTATION_PROGRESS_FORMAT = _G.REPUTATION_PROGRESS_FORMAT
local UIFrameFadeIn = _G.UIFrameFadeIn
local UIFrameFadeOut = _G.UIFrameFadeOut

local ACTIVE_TOAST = false
local WAITING_TOAST = {}

local PARAGON_QUEST_ID = {
	-- [questID] = {factionID,rewardID}
	-- Legion
	[48976] = {2170, 152922}, -- Argussian Reach
	[46777] = {2045, 152108}, -- Armies of Legionfall
	[48977] = {2165, 152923}, -- Army of the Light
	[46745] = {1900, 152102}, -- Court of Farondis
	[46747] = {1883, 152103}, -- Dreamweavers
	[46743] = {1828, 152104}, -- Highmountain Tribes
	[46748] = {1859, 152105}, -- The Nightfallen
	[46749] = {1894, 152107}, -- The Wardens
	[46746] = {1948, 152106}, -- Valarjar
	-- Battle for Azeroth
	-- Neutral
	[54453] = {2164, 166298}, --Champions of Azeroth
	[58096] = {2415, 174483}, --Rajani
	[55348] = {2391, 170061}, --Rustbolt Resistance
	[54451] = {2163, 166245}, --Tortollan Seekers
	[58097] = {2417, 174484}, --Uldum Accord
	-- Horde
	[54460] = {2156, 166282}, --Talanji's Expedition
	[54455] = {2157, 166299}, --The Honorbound
	[53982] = {2373, 169940}, --The Unshackled
	[54461] = {2158, 166290}, --Voldunai
	[54462] = {2103, 166292}, --Zandalari Empire
	-- Alliance
	[54456] = {2161, 166297}, --Order of Embers
	[54458] = {2160, 166295}, --Proudmoore Admiralty
	[54457] = {2162, 166294}, --Storm's Wake
	[54454] = {2159, 166300}, --The 7th Legion
	[55976] = {2400, 169939}, --Waveblade Ankoan
	-- Shadowlands
	[61100] = {2413, 180648}, --Court of Harvesters
	[61097] = {2407, 180647}, --The Ascended
	[61095] = {2410, 180646}, --The Undying Army
	[61098] = {2465, 180649} --The Wild Hunt
}

function Module:ColorWatchbar(bar)
	if not C["Misc"].ParagonEnable then
		return
	end

	local factionID = select(6, GetWatchedFactionInfo())
	if factionID and C_Reputation_IsFactionParagon(factionID) then
		bar:SetBarColor(unpack(C["Misc"].ParagonColor))
	end
end

function Module:SetupParagonTooltip(self)
	if not C["Misc"].ParagonEnable then
		return
	end

	local _, _, rewardQuestID, hasRewardPending = C_Reputation_GetFactionParagonInfo(self.factionID)
	print(self.factionID)
	if hasRewardPending then
		local questIndex = C_QuestLog_GetLogIndexForQuestID(rewardQuestID)
		local description = GetQuestLogCompletionText(questIndex) or ""
		_G.EmbeddedItemTooltip:SetText(L["Paragon"])
		_G.EmbeddedItemTooltip:AddLine(description, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
		GameTooltip_AddQuestRewardsToTooltip(_G.EmbeddedItemTooltip, rewardQuestID)
		_G.EmbeddedItemTooltip:Show()
	else
		_G.EmbeddedItemTooltip:Hide()
	end
end

function Module:Tooltip(bar, event)
	if not bar.questID then
		return
	end

	if event == "OnEnter" then
		local _, link = GetItemInfo(PARAGON_QUEST_ID[bar.questID][2])
		if link ~= nil then
			_G.GameTooltip:SetOwner(bar, "ANCHOR_NONE")
			_G.GameTooltip:SetPoint("LEFT", bar, "RIGHT", 10, 0)
			_G.GameTooltip:SetHyperlink(link)
			_G.GameTooltip:Show()
		end
	elseif event == "OnLeave" then
		GameTooltip_SetDefaultAnchor(_G.GameTooltip, UIParent)
		_G.GameTooltip:Hide()
	end
end

function Module:HookReputationBars()
	for n = 1, NUM_FACTIONS_DISPLAYED do
		if _G["ReputationBar"..n] then
			_G["ReputationBar"..n]:HookScript("OnEnter", function(self)
				Module:Tooltip(self, "OnEnter")
			end)

			_G["ReputationBar"..n]:HookScript("OnLeave", function(self)
				Module:Tooltip(self, "OnLeave")
			end)
		end
	end
end

function Module:ShowToast(name, text)
	ACTIVE_TOAST = true

	if C["Misc"].ParagonToastSound then
		PlaySound(44295, "master", true)
	end

	Module.toast:EnableMouse(false)
	Module.toast.title:SetText(name)
	Module.toast.title:SetAlpha(0)
	Module.toast.description:SetText(text)
	Module.toast.description:SetAlpha(0)
	UIFrameFadeIn(Module.toast, .5, 0, 1)

	C_Timer_After(.5, function()
		UIFrameFadeIn(Module.toast.title, .5, 0, 1)
	end)

	C_Timer_After(.75, function()
		UIFrameFadeIn(Module.toast.description, .5, 0, 1)
	end)

	C_Timer_After(C["Misc"].ParagonToastFade, function()
		UIFrameFadeOut(Module.toast, 1, 1, 0)
	end)

	C_Timer_After(C["Misc"].ParagonToastFade + 1.25, function()
		Module.toast:Hide()
		ACTIVE_TOAST = false
		if #WAITING_TOAST > 0 then
			Module:WaitToast()
		end
	end)
end

function Module:WaitToast()
	local name, text = unpack(WAITING_TOAST[1])
	table_remove(WAITING_TOAST, 1)
	Module:ShowToast(name, text)
end

function Module:CreateToast()
	local toast = CreateFrame("FRAME", "ParagonReputation_Toast", UIParent, "BackdropTemplate")
	toast:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 250)
	toast:SetSize(302, 70)
	toast:SetClampedToScreen(true)
	toast:Hide()

	toast.texture = toast:CreateTexture(nil,"BACKGROUND")
	toast.texture:SetPoint("TOPLEFT", toast, "TOPLEFT", -6, 4)
	toast.texture:SetPoint("BOTTOMRIGHT", toast, "BOTTOMRIGHT", 4, -4)
	toast.texture:SetTexture("Interface\\Garrison\\GarrisonToast")
	toast.texture:SetTexCoord(0, .61, .33, .48)

	-- [Toast] Create Title Text
	toast.title = toast:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	toast.title:SetPoint("TOPLEFT", toast, "TOPLEFT", 23, -10)
	toast.title:SetWidth(260)
	toast.title:SetHeight(16)
	toast.title:SetJustifyV("TOP")
	toast.title:SetJustifyH("LEFT")

	-- [Toast] Create Description Text
	toast.description = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	toast.description:SetPoint("TOPLEFT", toast.title, "TOPLEFT", 1, -23)
	toast.description:SetWidth(258)
	toast.description:SetHeight(32)
	toast.description:SetJustifyV("TOP")
	toast.description:SetJustifyH("LEFT")

	Module.toast = toast
end

function Module:QUEST_ACCEPTED(_, questID)
	if C["Misc"].ParagonToast and PARAGON_QUEST_ID[questID] then
		local name = GetFactionInfoByID(PARAGON_QUEST_ID[questID][1])
		local text = GetQuestLogCompletionText(C_QuestLog_GetLogIndexForQuestID(questID))
		if ACTIVE_TOAST then
			WAITING_TOAST[#WAITING_TOAST + 1] = {name, text} -- Toast is already active, put this info on the line.
		else
			self:ShowToast(name, text)
		end
	end
end

function Module:CreateBarOverlay(factionBar)
	if factionBar.ParagonOverlay then
		return
	end

	local overlay = CreateFrame("FRAME", nil, factionBar)
	overlay:SetAllPoints(factionBar)
	overlay:SetFrameLevel(3)

	overlay.bar = overlay:CreateTexture("ARTWORK", nil, nil, -1)
	overlay.bar:SetTexture(C["MediaMisc"].Texture)
	overlay.bar:SetPoint("TOP", overlay)
	overlay.bar:SetPoint("BOTTOM", overlay)
	overlay.bar:SetPoint("LEFT", overlay)

	overlay.edge = overlay:CreateTexture("ARTWORK", nil, nil, -1)
	overlay.edge:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	overlay.edge:SetPoint("CENTER", overlay.bar, "RIGHT")
	overlay.edge:SetBlendMode("ADD")
	overlay.edge:SetSize(38, 38) -- Arbitrary value, I hope there isn't an AddOn that skins the bar and the glow doesnt look right with this size.

	factionBar.ParagonOverlay = overlay
end

function Module:ChangeReputationBars()
	if not C["Misc"].ParagonEnable then
		return
	end

	local ReputationFrame = _G.ReputationFrame
	ReputationFrame.paragonFramesPool:ReleaseAll()
	local factionOffset = FauxScrollFrame_GetOffset(_G.ReputationListScrollFrame)
	for n = 1, NUM_FACTIONS_DISPLAYED, 1 do
		local factionIndex = factionOffset + n
		local factionRow = _G["ReputationBar"..n]
		local factionBar = _G["ReputationBar"..n.."ReputationBar"]
		local factionStanding = _G["ReputationBar"..n.."ReputationBarFactionStanding"]
		if factionIndex <= GetNumFactions() then
			local name, _, _, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(factionIndex)
			if factionID and C_Reputation_IsFactionParagon(factionID) then
				local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
				factionRow.questID = rewardQuestID
				if currentValue then
					local r, g, b = unpack(C["Misc"].ParagonColor)
					local value = mod(currentValue, threshold)
					if hasRewardPending then
						local paragonFrame = ReputationFrame.paragonFramesPool:Acquire()
						paragonFrame.factionID = factionID
						paragonFrame:SetPoint("RIGHT", factionRow, 11, 0)
						paragonFrame.Glow:SetShown(true)
						paragonFrame.Check:SetShown(true)
						paragonFrame:Show()

						-- If value is 0 we force it to 1 so we don't get 0 as result, math...
						local over = ((value <= 0 and 1) or value) / threshold
						if not factionBar.ParagonOverlay then
							Module:CreateBarOverlay(factionBar)
						end

						factionBar.ParagonOverlay:Show()
						factionBar.ParagonOverlay.bar:SetWidth(factionBar.ParagonOverlay:GetWidth() * over)
						factionBar.ParagonOverlay.bar:SetVertexColor(r + .15, g + .15, b + .15)
						factionBar.ParagonOverlay.edge:SetVertexColor(r + .2, g + .2, b + .2, (over > .05 and .75) or 0)
						value = value + threshold
					else
						if factionBar.ParagonOverlay then
							factionBar.ParagonOverlay:Hide()
						end
					end
					factionBar:SetMinMaxValues(0, threshold)
					factionBar:SetValue(value)
					factionBar:SetStatusBarColor(r, g, b)
					factionRow.rolloverText = HIGHLIGHT_FONT_COLOR_CODE.." " ..string_format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(value), BreakUpLargeNumbers(threshold))..FONT_COLOR_CODE_CLOSE

					local count = math_floor(currentValue / threshold)
					if hasRewardPending then
						count = count - 1
					end

					if C["Misc"].ParagonText.Value == 1 then
						factionStanding:SetText(L["Paragon"])
						factionRow.standingText = L["Paragon"]
					elseif C["Misc"].ParagonText.Value == 2 then
						factionStanding:SetText(L["Exalted"])
						factionRow.standingText = L["Exalted"]
					elseif C["Misc"].ParagonText.Value == 4 then
						factionStanding:SetText(BreakUpLargeNumbers(value))
						factionRow.standingText = BreakUpLargeNumbers(value)
					elseif C["Misc"].ParagonText.Value == 3 then
						if count > 0 then
							factionStanding:SetText(L["Paragon"].." x "..count)
							factionRow.standingText = (L["Paragon"].." x "..count)
						else
							factionStanding:SetText(L["Paragon"].." + ")
							factionRow.standingText = (L["Paragon"].." + ")
						end
					elseif C["Misc"].ParagonText.Value == 5 then
						factionStanding:SetText(" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
						factionRow.standingText = (" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
						factionRow.rolloverText = nil
					elseif C["Misc"].ParagonText.Value == 6 then
						if hasRewardPending then
							value = value - threshold
							factionStanding:SetText("+"..BreakUpLargeNumbers(value))
							factionRow.standingText = "+"..BreakUpLargeNumbers(value)
						else
							value = threshold - value
							factionStanding:SetText(BreakUpLargeNumbers(value))
							factionRow.standingText = BreakUpLargeNumbers(value)
						end
						factionRow.rolloverText = nil
					end

					if factionIndex == GetSelectedFaction() and _G.ReputationDetailFrame:IsShown() then
						if count > 0 then
							_G.ReputationDetailFactionName:SetText(name.." |cffffffffx"..count.."|r")
						end
					end
				end
			else
				factionRow.questID = nil
				if factionBar.ParagonOverlay then
					factionBar.ParagonOverlay:Hide()
				end
			end
		else
			factionRow:Hide()
		end
	end
end

function Module:CreateParagonReputation()
	if not C["Misc"].ParagonEnable then
		return
	end

	if IsAddOnLoaded("ParagonReputation") then
		return
	end

	K:RegisterEvent("QUEST_ACCEPTED", Module.QUEST_ACCEPTED)

	hooksecurefunc(ReputationBarMixin, "Update", Module.ColorWatchbar)
	hooksecurefunc("ReputationParagonFrame_SetupParagonTooltip", Module.SetupParagonTooltip)
	hooksecurefunc("ReputationFrame_Update", Module.ChangeReputationBars)

	Module:HookReputationBars()
	Module:CreateToast()
	K.Mover(Module.toast, "ParagonToastMover", "ParagonToastMover", {"TOP", UIParent, "TOP", 0, -196}, 302, 70)
end