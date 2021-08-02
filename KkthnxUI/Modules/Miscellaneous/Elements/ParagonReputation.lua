local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local floor = _G.floor
local format = _G.format
local mod = _G.mod
local select = _G.select
local tremove = _G.tremove
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

local function ColorWatchbar(self)
	if not C["Misc"].ParagonEnable then
		return
	end

	local factionID = select(6, GetWatchedFactionInfo())
	if factionID and C_Reputation_IsFactionParagon(factionID) then
		self:SetBarColor(unpack(C["Misc"].ParagonColor))
	end
end

local function SetupParagonTooltip(self)
	local _, _, rewardQuestID, hasRewardPending = C_Reputation_GetFactionParagonInfo(self.factionID)
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

function Module:Tooltip(self, event)
	if not self.questID or not C.ParagonQuestID[self.questID] then
		return
	end

	if event == "OnEnter" then
		local _, link = GetItemInfo(C.ParagonQuestID[self.questID].cache)
		if link then
			_G.GameTooltip:SetOwner(self, "ANCHOR_NONE")
			_G.GameTooltip:SetPoint("LEFT", self, "RIGHT", 10, 0)
			_G.GameTooltip:SetHyperlink(link)
			_G.GameTooltip:Show()
		end
	elseif event == "OnLeave" then
		GameTooltip_SetDefaultAnchor(_G.GameTooltip, UIParent)
		_G.GameTooltip:Hide()
	end
end

local function HookReputationBars()
	for n = 1, NUM_FACTIONS_DISPLAYED do
		if _G["ReputationBar"..n] then
			_G["ReputationBar"..n]:HookScript("OnEnter",function(self)
				Module:Tooltip(self, "OnEnter")
			end)

			_G["ReputationBar"..n]:HookScript("OnLeave",function(self)
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

	UIFrameFadeIn(Module.toast, 0.5, 0, 1)

	C_Timer_After(0.5, function()
		UIFrameFadeIn(Module.toast.title, 0.5, 0, 1)
	end)

	C_Timer_After(0.75, function()
		UIFrameFadeIn(Module.toast.description, 0.5, 0, 1)
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
	tremove(WAITING_TOAST, 1)
	Module:ShowToast(name, text)
end

local function CreateToast()
	local toast = CreateFrame("FRAME", "KKUI_ParagonReputation_Toast", UIParent, "BackdropTemplate")
	toast:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 250)
	toast:SetSize(302, 70)
	toast:SetClampedToScreen(true)
	toast:Hide()

	-- Create Title Text
	toast.title = toast.title or toast:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	toast.title:SetPoint("TOPLEFT", toast, "TOPLEFT", 23, -10)
	toast.title:SetWidth(260)
	toast.title:SetHeight(16)
	toast.title:SetJustifyV("TOP")
	toast.title:SetJustifyH("LEFT")

	-- Create Description Text
	toast.description = toast.description or toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	toast.description:SetPoint("TOPLEFT", toast.title, "TOPLEFT", 1, -23)
	toast.description:SetWidth(258)
	toast.description:SetHeight(32)
	toast.description:SetJustifyV("TOP")
	toast.description:SetJustifyH("LEFT")

	Module.toast = toast
end

function Module:QUEST_ACCEPTED(_, questID)
	if C["Misc"].ParagonEnable and C.ParagonQuestID[questID] then
		local name = GetFactionInfoByID(C.ParagonQuestID[questID].factionID)
		local text = GetQuestLogCompletionText(C_QuestLog_GetLogIndexForQuestID(questID))
		if ACTIVE_TOAST then
			WAITING_TOAST[#WAITING_TOAST + 1] = {name, text} --Toast is already active, put this info on the line.
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

	overlay.bar = overlay.bar or overlay:CreateTexture("ARTWORK", nil, nil, -1)
	overlay.bar:SetTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
	overlay.bar:SetPoint("TOP", overlay)
	overlay.bar:SetPoint("BOTTOM", overlay)
	overlay.bar:SetPoint("LEFT", overlay)

	overlay.edge = overlay.edge or overlay:CreateTexture("ARTWORK", nil, nil, -1)
	overlay.edge:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	overlay.edge:SetPoint("CENTER", overlay.bar, "RIGHT")
	overlay.edge:SetBlendMode("ADD")
	overlay.edge:SetSize(38, 38) -- Arbitrary value, I hope there isn't an AddOn that skins the bar and the glow doesnt look right with this size.

	factionBar.ParagonOverlay = overlay
end

local function ChangeReputationBars()
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
					factionRow.rolloverText = HIGHLIGHT_FONT_COLOR_CODE.." " ..format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(value), BreakUpLargeNumbers(threshold)) ..FONT_COLOR_CODE_CLOSE

					local count = floor(currentValue / threshold)
					if hasRewardPending then
						count = count - 1
					end

					local ParagonRepValue = C["Misc"].ParagonText.Value
					if ParagonRepValue == 1 then
						factionStanding:SetText(L["Paragon"])
						factionRow.standingText = L["Paragon"]
					elseif ParagonRepValue == 2 then
						factionStanding:SetText(L["Exalted"])
						factionRow.standingText = L["Exalted"]
					elseif ParagonRepValue == 4 then
						factionStanding:SetText(BreakUpLargeNumbers(value))
						factionRow.standingText = BreakUpLargeNumbers(value)
					elseif ParagonRepValue == 3 then
						if count > 0 then
							factionStanding:SetText(L["Paragon"].." x "..count)
							factionRow.standingText = (L["Paragon"].." x "..count)
						else
							factionStanding:SetText(L["Paragon"].." + ")
							factionRow.standingText = (L["Paragon"].." + ")
						end
					elseif ParagonRepValue == 5 then
						factionStanding:SetText(" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
						factionRow.standingText = (" "..BreakUpLargeNumbers(value).." / "..BreakUpLargeNumbers(threshold))
						factionRow.rolloverText = nil
					elseif ParagonRepValue == 6 then
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

	K:RegisterEvent("QUEST_ACCEPTED", Module.QUEST_ACCEPTED)

	hooksecurefunc(_G.ReputationBarMixin, "Update", ColorWatchbar)
	hooksecurefunc("ReputationParagonFrame_SetupParagonTooltip", SetupParagonTooltip)
	hooksecurefunc("ReputationFrame_Update", ChangeReputationBars)

	HookReputationBars()
	CreateToast()
	K.Mover(Module.toast, "ParagonToastMover", "ParagonToastMover", {"TOP", UIParent, "TOP", 0, -196}, 302, 70)
end