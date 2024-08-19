local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

local UnitName, CreateFrame, SendChatMessage, IsInGroup, IsInRaid, UnitAffectingCombat = UnitName, CreateFrame, SendChatMessage, IsInGroup, IsInRaid, UnitAffectingCombat

function Module:CreatePullCountdown()
	local PullCountdownHandler = CreateFrame("Frame")
	local delay, target
	local interval, lastupdate = 1.5, 0

	local function reset()
		PullCountdownHandler:SetScript("OnUpdate", nil)
		delay, target, lastupdate = nil, nil, 0
	end

	local function pull(_, elapsed)
		target = UnitName("target") or ""

		if not delay then
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

	function Module.Pull(timer)
		if not C["Announcements"].PullCountdown then
			return
		end
		if not (IsInGroup() or IsInRaid()) or UnitAffectingCombat("player") then
			K.Print("You must be in a group or raid and not in combat to use this feature.")
			return
		end

		if PullCountdownHandler:GetScript("OnUpdate") then
			reset()
			SendChatMessage(L["Pull ABORTED!"], K.CheckChat())
		else
			delay = tonumber(timer) or 3
			PullCountdownHandler:SetScript("OnUpdate", pull)
		end
	end

	_G.SLASH_KKUI_PULLCOUNTDOWN1 = "/jenkins"
	_G.SLASH_KKUI_PULLCOUNTDOWN2 = "/pc"
	_G.SlashCmdList["KKUI_PULLCOUNTDOWN"] = function(msg)
		Module.Pull(msg)
	end
end
