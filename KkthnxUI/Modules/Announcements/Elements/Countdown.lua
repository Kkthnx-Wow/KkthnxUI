local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

local UnitName = UnitName
local CreateFrame = CreateFrame
local SendChatMessage = SendChatMessage

function Module:CreatePullCountdown()
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
			SendChatMessage((L["Pulling In"]):format(target, tostring(delay)), K.CheckChat())
			firstdone = true
			delay = delay - 1
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

		delay = timer or 3
		if PullCountdownHandler:GetScript("OnUpdate") then
			reset()
			SendChatMessage(L["Pull ABORTED!"], K.CheckChat())
		else
			PullCountdownHandler:SetScript("OnUpdate", pull)
		end
	end

	_G.SLASH_KKUI_PULLCOUNTDOWN1 = "/jenkins"
	_G.SLASH_KKUI_PULLCOUNTDOWN2 = "/pc"
	_G.SlashCmdList["KKUI_PULLCOUNTDOWN"] = function(msg)
		if tonumber(msg) ~= nil then
			Module.Pull(msg)
		else
			Module.Pull()
		end
	end
end
