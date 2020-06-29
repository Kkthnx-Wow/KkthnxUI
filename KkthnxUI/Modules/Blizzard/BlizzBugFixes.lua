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