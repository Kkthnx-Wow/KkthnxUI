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

-- HonorFrameLoadTaint workaround
-- credit: https://www.townlong-yak.com/bugs/afKy4k-HonorFrameLoadTaint
do
	if (_G.UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0) < 2 then
		_G.UIDROPDOWNMENU_VALUE_PATCH_VERSION = 2
		hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
			if _G.UIDROPDOWNMENU_VALUE_PATCH_VERSION ~= 2 then
				return
			end

			for i=1, _G.UIDROPDOWNMENU_MAXLEVELS do
				for j=1, _G.UIDROPDOWNMENU_MAXBUTTONS do
					local b = _G["DropDownList"..i.."Button"..j]
					if not (issecurevariable(b, "value") or b:IsShown()) then
						b.value = nil
						repeat
							j, b["fx"..j] = j + 1, nil
						until issecurevariable(b, "value")
					end
				end
			end
		end)
	end
end

-- CommunitiesUI taint workaround
-- credit: https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeTaint
do
	if (_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
		_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
		hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
			if _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
				return
			end

			if _G.UIDROPDOWNMENU_OPEN_MENU and _G.UIDROPDOWNMENU_OPEN_MENU ~= frame and not issecurevariable(_G.UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
				_G.UIDROPDOWNMENU_OPEN_MENU = nil
				local t, f, prefix, i = _G, issecurevariable, " \0", 1
				repeat
					i, t[prefix..i] = i + 1, nil
				until f("UIDROPDOWNMENU_OPEN_MENU")
			end
		end)
	end
end

-- CommunitiesUI taint workaround #2
-- credit: https://www.townlong-yak.com/bugs/YhgQma-SetValueRefreshTaint
do
	if (_G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION or 0) < 1 then
		_G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION = 1
		local function CleanDropdowns()
			if _G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION ~= 1 then
				return
			end

			local f, f2 = _G.FriendsFrame, _G.FriendsTabHeader
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
end

-- Garbage collection is being overused and misused,
-- and it"s causing lag and performance drops.
-- do
-- 	local blizzardCollectgarbage = _G.collectgarbage

-- 	blizzardCollectgarbage("setpause", 110)
-- 	blizzardCollectgarbage("setstepmul", 200)

-- 	_G.collectgarbage = function(opt, arg)
-- 		if (opt == "collect") or (opt == nil) then
-- 		elseif (opt == "count") then
-- 			return blizzardCollectgarbage(opt, arg)
-- 		elseif (opt == "setpause") then
-- 			return blizzardCollectgarbage("setpause", 110)
-- 		elseif opt == "setstepmul" then
-- 			return blizzardCollectgarbage("setstepmul", 200)
-- 		elseif (opt == "stop") then
-- 		elseif (opt == "restart") then
-- 		elseif (opt == "step") then
-- 			if (arg ~= nil) then
-- 				if (arg <= 10000) then
-- 					return blizzardCollectgarbage(opt, arg)
-- 				end
-- 			else
-- 				return blizzardCollectgarbage(opt, arg)
-- 			end
-- 		else
-- 			return blizzardCollectgarbage(opt, arg)
-- 		end
-- 	end

-- 	-- Memory usage is unrelated to performance, and tracking memory usage does not track "bad" addons.
-- 	-- Developers can uncomment this line to enable the functionality when looking for memory leaks,
-- 	-- but for the average end-user this is a completely pointless thing to track.
-- 	_G.UpdateAddOnMemoryUsage = function() end
-- end

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
do
	local CloseQuestFixFrame = CreateFrame("Frame")
	CloseQuestFixFrame:RegisterEvent("GOSSIP_SHOW")
	CloseQuestFixFrame:RegisterEvent("QUEST_ACCEPTED")
	CloseQuestFixFrame:RegisterEvent("QUEST_COMPLETE")
	CloseQuestFixFrame:RegisterEvent("QUEST_DETAIL")
	CloseQuestFixFrame:RegisterEvent("QUEST_FINISHED")
	CloseQuestFixFrame:RegisterEvent("QUEST_GREETING")
	CloseQuestFixFrame:RegisterEvent("QUEST_PROGRESS")
	CloseQuestFixFrame:RegisterEvent("QUEST_TURNED_IN")

	local function CloseQuestIfDone()
		if not greetingsShown and questDetailsOpened < 1 and ((_G.QuestFrame and _G.QuestFrame:IsShown()) or (_G.ImmersionFrame and _G.ImmersionFrame:IsShown())) then
			_G.CloseQuest()
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

	CloseQuestFixFrame:SetScript("OnEvent", function(_, event)
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
			if _G.QuestFrame and not _G.QuestFrame:IsShown() then
				questDetailsOpened = 0
				greetingsShown = false
			end

			-- The order in which QUEST_ACCEPTED and QUEST_DETAIL of the next quest happen is indeterministic.
			-- Hence we have to use this counter such that CloseQuestIfDone() finds 1 or 0 depending
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