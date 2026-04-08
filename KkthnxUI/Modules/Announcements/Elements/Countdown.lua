--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Simple pull countdown announcer (/pc or /jenkins).
-- - Design: Uses an OnUpdate handler on a hidden frame to manage timing intervals for chat messages.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache frequently used globals for chat announcement performance.
local UnitName, CreateFrame, SendChatMessage, IsInGroup, IsInRaid, UnitAffectingCombat = UnitName, CreateFrame, SendChatMessage, IsInGroup, IsInRaid, UnitAffectingCombat

-- ---------------------------------------------------------------------------
-- PULL COUNTDOWN
-- ---------------------------------------------------------------------------

function Module:CreatePullCountdown()
	local PullCountdownHandler = CreateFrame("Frame")
	local delay, target
	local interval, lastupdate = 1.5, 0

	-- REASON: Ensure states are fully cleared to allow re-triggering or aborting.
	local function reset()
		PullCountdownHandler:SetScript("OnUpdate", nil)
		delay, target, lastupdate = nil, nil, 0
	end

	-- REASON: OnUpdate manages the non-blocking countdown sequence.
	local function pull(_, elapsed)
		target = UnitName("target") or ""

		if not delay then
			-- NOTE: This initial message starts the '3.. 2.. 1..' flow.
			SendChatMessage((L["Pulling In"]):format(target, 3), K.CheckChat())
			delay = 2
		end

		lastupdate = lastupdate + elapsed
		if lastupdate >= interval then
			lastupdate = 0
			if delay > 0 then
				SendChatMessage(tostring(delay) .. "..", K.CheckChat())
				delay = delay - 1
			else
				SendChatMessage(L["Leeeeeroy!"], K.CheckChat())
				reset()
			end
		end
	end

	-- ---------------------------------------------------------------------------
	-- PUBLIC API
	-- ---------------------------------------------------------------------------

	function Module.Pull(timer)
		if not C["Announcements"].PullCountdown then
			return
		end

		-- WARNING: Verification - prevent accidental spam if the player is not in a group or is in combat.
		if not (IsInGroup() or IsInRaid()) or UnitAffectingCombat("player") then
			K.Print("You must be in a group or raid and not in combat to use this feature.")
			return
		end

		-- NOTE: Toggle functionality allows aborting a countdown already in progress.
		if PullCountdownHandler:GetScript("OnUpdate") then
			reset()
			SendChatMessage(L["Pull ABORTED!"], K.CheckChat())
		else
			delay = tonumber(timer) or 3
			PullCountdownHandler:SetScript("OnUpdate", pull)
		end
	end

	-- ---------------------------------------------------------------------------
	-- SLASH COMMANDS
	-- ---------------------------------------------------------------------------

	_G.SLASH_KKUI_PULLCOUNTDOWN1 = "/jenkins"
	_G.SLASH_KKUI_PULLCOUNTDOWN2 = "/pc"
	_G.SlashCmdList["KKUI_PULLCOUNTDOWN"] = function(msg)
		Module.Pull(msg)
	end
end
