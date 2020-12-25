local K, C, L = unpack(select(2, ...))
if C["Announcements"].PullCountdown ~= true then
	return
end

local _G = _G

local UnitName = _G.UnitName
local CreateFrame = _G.CreateFrame
local SendChatMessage = _G.SendChatMessage

do -- Sourced: Pull Countdown (Dridzt)
	local PullCountdown = CreateFrame("Frame", "KKUI_PullCountdown")
	local PullCountdownHandler = CreateFrame("Frame")
	local firstdone, delay, target
	local interval = 1.5
	local lastupdate = 0

	local function reset()
		PullCountdownHandler:SetScript("OnUpdate", nil)
		firstdone, delay, target = nil, nil, nil
		lastupdate = 0
	end

	local function pull(_, elapsed)
		local tname = UnitName("target")
		if tname then
			target = tname
		else
			target = ""
		end

		if not firstdone then
			SendChatMessage((L["Pulling In"]):format(target, tostring(delay)), K.CheckChat(true))
			firstdone = true
			delay = delay - 1
		end

		lastupdate = lastupdate + elapsed
		if lastupdate >= interval then
			lastupdate = 0
			if delay > 0 then
				SendChatMessage(tostring(delay).."..", K.CheckChat(true))
				delay = delay - 1
			else
				SendChatMessage(L["Leeeeeroy!"], K.CheckChat(true))
				reset()
			end
		end
	end

	function PullCountdown.Pull(timer)
		delay = timer or 3
		if PullCountdownHandler:GetScript("OnUpdate") then
			reset()
			SendChatMessage(L["Pull ABORTED!"], K.CheckChat(true))
		else
			PullCountdownHandler:SetScript("OnUpdate", pull)
		end
	end

	_G.SLASH_PULLCOUNTDOWN1 = "/jenkins"
	_G.SLASH_PULLCOUNTDOWN2 = "/pc"
	_G.SlashCmdList["PULLCOUNTDOWN"] = function(msg)
		if(tonumber(msg) ~= nil) then
			PullCountdown.Pull(msg)
		else
			PullCountdown.Pull()
		end
	end
end