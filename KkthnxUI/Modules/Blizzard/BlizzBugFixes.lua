local K = unpack(select(2, ...))

local _G = _G

local issecurevariable = _G.issecurevariable
local hooksecurefunc = _G.hooksecurefunc
local QuestGetAutoAccept = _G.QuestGetAutoAccept
local GetTime = _G.GetTime

local questDetailsOpened = 0
local greetingsShown = false
local lastQuestDetail = GetTime()
local _AddonTooltip_Update = AddonTooltip_Update

-- Temporary Blizzard Fixs

do
	InterfaceOptionsFrameCancel:SetScript("OnClick", function()
		InterfaceOptionsFrameOkay:Click()
	end)

	-- https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeCommunitiesTaint
	if (UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
		UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
		hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
			if UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
				return
			end

			if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU ~= frame and not issecurevariable(UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
				UIDROPDOWNMENU_OPEN_MENU = nil
				local t, f, prefix, i = _G, issecurevariable, " \0", 1
				repeat i, t[prefix .. i] = i + 1
				until f("UIDROPDOWNMENU_OPEN_MENU")
			end
		end)
	end

	-- https://www.townlong-yak.com/bugs/YhgQma-SetValueRefreshTaint
	if (COMMUNITY_UIDD_REFRESH_PATCH_VERSION or 0) < 1 then
		COMMUNITY_UIDD_REFRESH_PATCH_VERSION = 1
		local function CleanDropdowns()
			if COMMUNITY_UIDD_REFRESH_PATCH_VERSION ~= 1 then
				return
			end

			local f, f2 = FriendsFrame, FriendsTabHeader
			local s = f:IsShown()

			f:Hide()
			f:Show()

			if not f2:IsShown() then
				f2:Show()
				f2:Hide()
			end

			if not s then
				f:Hide()
			end
		end

		hooksecurefunc("Communities_LoadUI", CleanDropdowns)
		hooksecurefunc("SetCVar", function(n)
			if n == "lastSelectedClubId" then
				CleanDropdowns()
			end
		end)
	end

	-- https://www.townlong-yak.com/bugs/Mx7CWN-RefreshOverread
	if (UIDD_REFRESH_OVERREAD_PATCH_VERSION or 0) < 1 then
		UIDD_REFRESH_OVERREAD_PATCH_VERSION = 1
		local function drop(t, k)
			local c = 42
			t[k] = nil
			while not issecurevariable(t, k) do
				if t[c] == nil then
					t[c] = nil
				end

				c = c + 1
			end
		end

		hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
			if UIDD_REFRESH_OVERREAD_PATCH_VERSION ~= 1 then
				return
			end

			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local d = _G["DropDownList"..i]
				if d and d.numButtons then
					for j = d.numButtons + 1, UIDROPDOWNMENU_MAXBUTTONS do
						local b, _ = _G["DropDownList"..i.."Button"..j]
						_ = issecurevariable(b, "checked") or drop(b, "checked")
						_ = issecurevariable(b, "notCheckable") or drop(b, "notCheckable")
					end
				end
			end
		end)
	end
end

-- Garbage collection is being overused and misused,
-- and it"s causing lag and performance drops.
do
	local blizzardCollectgarbage = _G.collectgarbage

	blizzardCollectgarbage("setpause", 110)
	blizzardCollectgarbage("setstepmul", 200)

	_G.collectgarbage = function(opt, arg)
		if (opt == "collect") or (opt == nil) then
		elseif (opt == "count") then
			return blizzardCollectgarbage(opt, arg)
		elseif (opt == "setpause") then
			return blizzardCollectgarbage("setpause", 110)
		elseif opt == "setstepmul" then
			return blizzardCollectgarbage("setstepmul", 200)
		elseif (opt == "stop") then
		elseif (opt == "restart") then
		elseif (opt == "step") then
			if (arg ~= nil) then
				if (arg <= 10000) then
					return blizzardCollectgarbage(opt, arg)
				end
			else
				return blizzardCollectgarbage(opt, arg)
			end
		else
			return blizzardCollectgarbage(opt, arg)
		end
	end

	-- Memory usage is unrelated to performance, and tracking memory usage does not track "bad" addons.
	-- Developers can uncomment this line to enable the functionality when looking for memory leaks,
	-- but for the average end-user this is a completely pointless thing to track.
	_G.UpdateAddOnMemoryUsage = function() end
end

-- Fix blizz bug in addon list
do
	function AddonTooltip_Update(owner)
		if not owner then
			return
		end

		if owner:GetID() < 1 then
			return
		end

		_AddonTooltip_Update(owner)
	end
end

-- Close Quest Fix
-- https://www.curseforge.com/wow/addons/close-quest-fix
do
	local function CloseQuestIfDone()
		if not greetingsShown and questDetailsOpened < 1 and ( (QuestFrame and QuestFrame:IsShown()) or (ImmersionFrame and ImmersionFrame:IsShown()) ) then
			CloseQuest()
		end
	end

	-- For some quest givers it is possible to click on the NPC repeatedly and get a
	-- QUEST_DETAIL event every time without another event in between. To prevent the
	-- questDetailsOpened counter from growing infinitely we reset it after 1 second.
	-- We cannot reset it immediately because the actual purpose of this counter is
	-- to register the indeterministic opening and closing of two successive quests.
	local function ResetQuestDetailsOpened()
		if questDetailsOpened > 1 then
			questDetailsOpened = 1
		end
	end

	local CloseQuestEventFrame = CreateFrame("Frame")
	CloseQuestEventFrame:RegisterEvent("GOSSIP_SHOW")
	CloseQuestEventFrame:RegisterEvent("QUEST_ACCEPTED")
	CloseQuestEventFrame:RegisterEvent("QUEST_COMPLETE")
	CloseQuestEventFrame:RegisterEvent("QUEST_DETAIL")
	CloseQuestEventFrame:RegisterEvent("QUEST_FINISHED")
	CloseQuestEventFrame:RegisterEvent("QUEST_GREETING")
	CloseQuestEventFrame:RegisterEvent("QUEST_PROGRESS")
	CloseQuestEventFrame:RegisterEvent("QUEST_TURNED_IN")
	CloseQuestEventFrame:SetScript("OnEvent", function(_, event)
		if IsAddOnLoaded("CloseQuestFix") then
			return
		end

		-- Initialise NPC interaction.
		-- Some NPC interaction is initialised with just QUESTLINE_UPDATE,
		-- but we leave this out here for now!
		if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" or event == "QUEST_PROGRESS" or event == "QUEST_COMPLETE" then
			K:CancelAllTimers()
			questDetailsOpened = 0
			greetingsShown = true

			-- To reset the questDetailsOpened counter,
			-- if a quest started with QUEST_DETAIL is declined.
		elseif event == "QUEST_FINISHED" then
			if QuestFrame and not QuestFrame:IsShown() then
				questDetailsOpened = 0
				greetingsShown = false
			end

			-- The order in which QUEST_ACCEPTED and QUEST_DETAIL of the next quest happen is indeterministic.
			-- Hence we have to use this counter such that CloseIfDone() finds 1 or 0 depending
			-- on whether another QUEST_DETAIL has been opened.
		elseif event == "QUEST_DETAIL" then
			lastQuestDetail = GetTime()
			questDetailsOpened = questDetailsOpened + 1
			greetingsShown = false
			K:ScheduleTimer(ResetQuestDetailsOpened, 1.0)
		elseif event == "QUEST_ACCEPTED" and not QuestGetAutoAccept() then
			questDetailsOpened = questDetailsOpened - 1
			-- Must not be negative, otherwise a later QUEST_DETAIL may not increase over 0.
			if questDetailsOpened < 0 then
				questDetailsOpened = 0
			end

			if GetTime() - lastQuestDetail > 0.2 then
				K:ScheduleTimer(CloseQuestIfDone, 0.5)
			end

			-- Some quests (e.g. "Wolves at Our Heels") also do not close after handing them in!
		elseif event == "QUEST_TURNED_IN" then
			K:ScheduleTimer(CloseQuestIfDone, 0.5)
		end
	end)
end