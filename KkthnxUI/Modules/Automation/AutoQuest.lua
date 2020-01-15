local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")
local AutoQuestEventFrame = CreateFrame("Frame")

local _G = _G
local string_split = _G.string.split

local AcceptQuest = _G.AcceptQuest
local CloseQuest = _G.CloseQuest
local CompleteQuest = _G.CompleteQuest
local ConfirmAcceptQuest = _G.ConfirmAcceptQuest
local GameTooltip = _G.GameTooltip
local GetActiveTitle = _G.GetActiveTitle
local GetAvailableTitle = _G.GetAvailableTitle
local GetGossipActiveQuests = _G.GetGossipActiveQuests
local GetGossipAvailableQuests = _G.GetGossipAvailableQuests
local GetItemInfo = _G.GetItemInfo
local GetItemInfoInstant = _G.GetItemInfoInstant
local GetNumActiveQuests = _G.GetNumActiveQuests
local GetNumAvailableQuests = _G.GetNumAvailableQuests
local GetNumGossipActiveQuests = _G.GetNumGossipActiveQuests
local GetNumGossipAvailableQuests = _G.GetNumGossipAvailableQuests
local GetNumQuestChoices = _G.GetNumQuestChoices
local GetQuestItemInfo = _G.GetQuestItemInfo
local GetQuestLogIndexByID = _G.GetQuestLogIndexByID
local GetQuestLogIsAutoComplete = _G.GetQuestLogIsAutoComplete
local GetQuestMoneyToGet = _G.GetQuestMoneyToGet
local GetQuestReward = _G.GetQuestReward
local HideUIPanel = _G.HideUIPanel
local IsQuestCompletable = _G.IsQuestCompletable
local IsShiftKeyDown = _G.IsShiftKeyDown
local QuestGetAutoAccept = _G.QuestGetAutoAccept
local SelectActiveQuest = _G.SelectActiveQuest
local SelectAvailableQuest = _G.SelectAvailableQuest
local SelectGossipActiveQuest = _G.SelectGossipActiveQuest
local SelectGossipAvailableQuest = _G.SelectGossipAvailableQuest
local ShowQuestComplete = _G.ShowQuestComplete
local StaticPopup_Hide = _G.StaticPopup_Hide
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID

local isCheckButtonCreated
local function SetupAutoQuestCheckButton()
	if isCheckButtonCreated then
		return
	end

	local AutoQuestCheckButton = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame, "OptionsCheckButtonTemplate")
	AutoQuestCheckButton:SetPoint("TOPRIGHT", -140, 0)
	AutoQuestCheckButton:SetSize(24, 24)
	AutoQuestCheckButton.text = AutoQuestCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AutoQuestCheckButton.text:SetPoint("LEFT", 24, 0)
	AutoQuestCheckButton.text:SetText("Auto Quest")
	AutoQuestCheckButton:SetHitRectInsets(0, 0 - AutoQuestCheckButton.text:GetWidth(), 0, 0)
	AutoQuestCheckButton:SetChecked(KkthnxUIData[K.Realm][K.Name].AutoQuest)
	AutoQuestCheckButton:SetScript("OnClick", function(self)
		KkthnxUIData[K.Realm][K.Name].AutoQuest = self:GetChecked()
	end)

	isCheckButtonCreated = true

	function AutoQuestCheckButton.UpdateTooltip(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)

		local r, g, b = 0.2, 1.0, 0.2

		if KkthnxUIData[K.Realm][K.Name].AutoQuest == true then
			GameTooltip:AddLine("Disable Auto Accept")
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Disable to not auto accept.", r, g, b)
		else
			GameTooltip:AddLine("Enable Auto Accept")
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Enable to auto accept.", r, g, b)
		end

		GameTooltip:Show()
	end

	AutoQuestCheckButton:HookScript("OnEnter", function(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		self:UpdateTooltip()
	end)

	AutoQuestCheckButton:HookScript("OnLeave", function()
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:Hide()
	end)

	AutoQuestCheckButton:SetScript("OnClick", function(self)
		KkthnxUIData[K.Realm][K.Name].AutoQuest = self:GetChecked()
	end)
end

-- Funcion to ignore specific NPCs
local function isNpcBlocked(actionType)
	local npcGuid = UnitGUID("target")
	if npcGuid then
		local _, _, _, _, _, npcID = string_split("-", npcGuid)
		npcID = tonumber(npcID)
		if npcID then
			if K.AutoQuestBlockedNPC[npcID] then
				return true
			elseif actionType == "Select" and K.AutoQuestBlockedSelectNPC[npcID] then
				return true
			end
		end
	end
end

-- Function to check if quest ID is blocked
local function IsQuestIDBlocked(questID)
	if questID then
		if questID == 43923	-- Starlight Rose
		or questID == 43924	-- Leyblood
		or questID == 43925	-- Runescale Koi
		then
			return true
		end
	end
end

-- Function to check if quest requires currency or a crafting reagent
local function QuestRequiresCurrency()
	for i = 1, 6 do
		local progItem = _G["QuestProgressItem" ..i] or nil
		if progItem and progItem:IsShown() and progItem.type == "required" then
			if progItem.objectType == "currency" then
				-- Quest requires currency so do nothing
				return true
			elseif progItem.objectType == "item" then
				-- Quest requires an item
				local name = GetQuestItemInfo("required", i)
				if name then
					local itemID = GetItemInfoInstant(name)
					if itemID then
						local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, isCraftingReagent = GetItemInfo(itemID)
						if isCraftingReagent then
							-- Item is a crafting reagent so do nothing
							return true
						end

						if itemID == 104286 then -- Quivering Firestorm Egg
							return true
						end
					end
				end
			end
		end
	end
end

-- Function to check if quest requires gold
local function QuestRequiresGold()
	local goldRequiredAmount = GetQuestMoneyToGet()
	if goldRequiredAmount and goldRequiredAmount > 0 then
		return true
	end
end

-- Clear progress items when quest interaction has ceased
AutoQuestEventFrame:SetScript("OnEvent", function(_, event, arg1)
	if event == "QUEST_FINISHED" then
		for i = 1, 6 do
			local progItem = _G["QuestProgressItem"..i] or nil
			if progItem and progItem:IsShown() then
				progItem:Hide()
			end
		end

		return
	end

	if IsShiftKeyDown() or not KkthnxUIData[K.Realm][K.Name].AutoQuest then
		return
	end

	-- Accept quests with a quest detail window
	if event == "QUEST_DETAIL" then
		-- Don't accept blocked quests
		if isNpcBlocked("Accept") then
			return
		end

		-- Accept quest
		if QuestGetAutoAccept() then
			-- Quest has already been accepted by Wow so close the quest detail window
			CloseQuest()
		else
			-- Quest has not been accepted by Wow so accept it
			AcceptQuest()
			HideUIPanel(QuestFrame)
		end
	end

	-- Accept quests which require confirmation (such as sharing escort quests)
	if event == "QUEST_ACCEPT_CONFIRM" then
		ConfirmAcceptQuest()
		StaticPopup_Hide("QUEST_ACCEPT")
	end

	-- Turn-in progression quests
	if event == "QUEST_PROGRESS" and IsQuestCompletable() then
		-- Don't continue quests for blocked NPCs
		if isNpcBlocked("Complete") then
			return
		end

		-- Don't continue if quest requires currency
		if QuestRequiresCurrency() then
			return
		end

		-- Don't continue if quest requires gold
		if QuestRequiresGold() then
			return
		end

		-- Continue quest
		CompleteQuest()
	end

	-- Turn in completed quests if only one reward item is being offered
	if event == "QUEST_COMPLETE" then
		-- Don't complete quests for blocked NPCs
		if isNpcBlocked("Complete") then
			return
		end

		-- Don't complete if quest requires currency
		if QuestRequiresCurrency() then
			return
		end

		-- Don't complete if quest requires gold
		if QuestRequiresGold() then
			return
		end

		-- Complete quest
		if GetNumQuestChoices() <= 1 then
			GetQuestReward(GetNumQuestChoices())
		end
	end

	-- Show quest dialog for quests that use the objective tracker (it will be completed automatically)
	if event == "QUEST_AUTOCOMPLETE" then
		local index = GetQuestLogIndexByID(arg1)
		if GetQuestLogIsAutoComplete(index) then
			ShowQuestComplete(index)
		end
	end

	-- Select quests automatically
	if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then
		-- Select quests
		if UnitExists("npc") or QuestFrameGreetingPanel:IsShown() or GossipFrameGreetingPanel:IsShown() then
			-- Don't select quests for blocked NPCs
			if isNpcBlocked("Select") then
				return
			end

			-- Select quests
			if event == "QUEST_GREETING" then
				-- Select quest greeting completed quests
				for i = 1, GetNumActiveQuests() do
					local title, isComplete = GetActiveTitle(i)
					if title and isComplete then
						return SelectActiveQuest(i)
					end
				end

				-- Select quest greeting available quests
				for i = 1, GetNumAvailableQuests() do
					local title, isComplete = GetAvailableTitle(i)
					if title and not isComplete then
						return SelectAvailableQuest(i)
					end
				end
			else
				-- Select gossip completed quests
				for i = 1, GetNumGossipActiveQuests() do
					local title, _, _, isComplete = select(i * 7 - 6, GetGossipActiveQuests())
					if title and isComplete then
						return SelectGossipActiveQuest(i)
					end
				end

				-- Select gossip available quests
				for i = 1, GetNumGossipAvailableQuests() do
					local title, _, _, _, _, _, _, questID = select(i * 8 - 7, GetGossipAvailableQuests())
					if title then
						if not questID or not IsQuestIDBlocked(questID) then
							return SelectGossipAvailableQuest(i)
						end
					end
				end
			end
		end
	end
end)

function Module:CreateAutoQuesting()
	if C["Automation"].AutoQuest then
		WorldMapFrame:HookScript("OnShow", SetupAutoQuestCheckButton)

		AutoQuestEventFrame:RegisterEvent("QUEST_DETAIL")
		AutoQuestEventFrame:RegisterEvent("QUEST_ACCEPT_CONFIRM")
		AutoQuestEventFrame:RegisterEvent("QUEST_PROGRESS")
		AutoQuestEventFrame:RegisterEvent("QUEST_COMPLETE")
		AutoQuestEventFrame:RegisterEvent("QUEST_GREETING")
		AutoQuestEventFrame:RegisterEvent("QUEST_AUTOCOMPLETE")
		AutoQuestEventFrame:RegisterEvent("GOSSIP_SHOW")
		AutoQuestEventFrame:RegisterEvent("QUEST_FINISHED")
	else
		AutoQuestEventFrame:UnregisterAllEvents()
	end
end