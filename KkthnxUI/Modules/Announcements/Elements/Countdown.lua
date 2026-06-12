--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Simple pull countdown announcer (/pc or /jenkins).
-- - Design: Uses C_Timer.NewTicker for clean interval-based chat messages. Replaces the
--           previous OnUpdate approach which accumulated elapsed time every frame.
-- - Events: N/A (slash command driven)
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache frequently used globals for chat announcement performance.
local UnitName = UnitName
local SendChatMessage = SendChatMessage
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitAffectingCombat = UnitAffectingCombat

local C_Timer_NewTicker = C_Timer.NewTicker

-- ---------------------------------------------------------------------------
-- PULL COUNTDOWN
-- ---------------------------------------------------------------------------

function Module:CreatePullCountdown()
	local ticker
	local delay

	-- REASON: Cancel the active ticker and reset state cleanly.
	local function reset()
		if ticker then
			ticker:Cancel()
			ticker = nil
		end
		delay = nil
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
		if ticker then
			reset()
			SendChatMessage(L["Pull ABORTED!"], K.CheckChat())
			return
		end

		local target = UnitName("target") or ""
		delay = tonumber(timer) or 3

		-- REASON: Send the initial "Pulling in X seconds" message immediately, then tick
		-- every 1.5s. C_Timer.NewTicker replaces the old OnUpdate elapsed accumulator,
		-- which ran every frame (~60 calls/sec) just to track 1.5-second intervals.
		SendChatMessage((L["Pulling In"]):format(target, delay), K.CheckChat())

		ticker = C_Timer_NewTicker(1.5, function()
			if delay > 0 then
				SendChatMessage(tostring(delay) .. "..", K.CheckChat())
				delay = delay - 1
			else
				SendChatMessage(L["Leeeeeroy!"], K.CheckChat())
				reset()
			end
		end)
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
