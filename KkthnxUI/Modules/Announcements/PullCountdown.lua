local K, C, L = select(2, ...):unpack()
if C.Announcements.PullCountdown ~= true then return end

local format = string.format
local tostring, tonumber = tostring, tonumber
local CreateFrame = CreateFrame
local SendChatMessage = SendChatMessage
local UnitName = UnitName

-- Pull Countdown(by Dridzt)
local frame = CreateFrame("Frame", "PullCountdown")
local timerframe = CreateFrame("Frame")
local firstdone, delay, target
local interval = 1.5
local lastupdate = 0

local function reset()
	timerframe:SetScript("OnUpdate", nil)
	firstdone, delay, target = nil, nil, nil
	lastupdate = 0
end

local function pull(self, elapsed)
	local tname = UnitName("target")
	if tname then
		target = tname
	else
		target = ""
	end
	if not firstdone then
		SendChatMessage(format(L.Announce.PCMessage, target, tostring(delay)), K.CheckChat(true))
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
			SendChatMessage(L.Announce.PCGo, K.CheckChat(true))
			reset()
		end
	end
end

function frame.Pull(timer)
	delay = timer or 3
	if timerframe:GetScript("OnUpdate") then
		reset()
		SendChatMessage(L.Announce.PCAborted, K.CheckChat(true))
	else
		timerframe:SetScript("OnUpdate", pull)
	end
end

SlashCmdList.PULLCOUNTDOWN = function(msg)
	if tonumber(msg) ~= nil then
		frame.Pull(msg)
	else
		frame.Pull()
	end
end
SLASH_PULLCOUNTDOWN1 = "/pc"