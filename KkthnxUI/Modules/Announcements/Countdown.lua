local K, C, L = unpack(select(2, ...))
if C["Announcements"].PullCountdown ~= true then
	return
end

local _G = _G

local UnitName = _G.UnitName
local IsInGroup = _G.IsInGroup
local CreateFrame = _G.CreateFrame
local IsInRaid = _G.IsInRaid
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local SendChatMessage = _G.SendChatMessage
local IsEveryoneAssistant = _G.IsEveryoneAssistant
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = _G.LE_PARTY_CATEGORY_INSTANCE

-- Sourced: Pull Countdown (Dridzt)
do
	local PullCountdown = CreateFrame("Frame", "PullCountdown")
	local PullCountdownHandler = CreateFrame("Frame")
	local firstdone, delay, target
	local interval = 1.5
	local lastupdate = 0

	local function reset()
		PullCountdownHandler:SetScript("OnUpdate", nil)
		firstdone, delay, target = nil, nil, nil
		lastupdate = 0
	end

	local function setmsg(warning)
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			return "PARTY" -- "INSTANCE_CHAT"
		elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
			if warning and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant()) then
				return "RAID_WARNING"
			else
				return "RAID"
			end
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
			return "PARTY"
		end

		return "SAY"
	end

	local function pull(_, elapsed)
		local tname = UnitName("target")
		if tname then
			target = tname
		else
			target = ""
		end

		if not firstdone then
			SendChatMessage((L["Pulling In"]):format(target, tostring(delay)), setmsg(true))
			firstdone = true
			delay = delay - 1
		end

		lastupdate = lastupdate + elapsed
		if lastupdate >= interval then
			lastupdate = 0
			if delay > 0 then
				SendChatMessage(tostring(delay).."..", setmsg(true))
				delay = delay - 1
			else
				SendChatMessage(L["Leeeeeroy!"], setmsg(true))
				reset()
			end
		end
	end

	function PullCountdown.Pull(timer)
		delay = timer or 3
		if PullCountdownHandler:GetScript("OnUpdate") then
			reset()
			SendChatMessage(L["Pull ABORTED!"], setmsg(true))
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