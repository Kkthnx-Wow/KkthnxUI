--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Minimap/Time.lua
	Purpose:
		The time datatext across the bottom of the minimap. Honours the game's
		clock CVars, flags pending calendar invites in red, and shows a lockout
		summary on hover. Left-click opens the calendar, right-click the stopwatch.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Minimap")

local _G = _G
local format = string.format
local date = _G.date
local tonumber = tonumber

local GetGameTime = _G.GetGameTime
local GetCVarBool = _G.GetCVarBool
local ToggleCalendar = _G.ToggleCalendar
local ToggleTimeManager = _G.ToggleTimeManager
local GameTime_GetLocalTime = _G.GameTime_GetLocalTime
local GameTime_GetGameTime = _G.GameTime_GetGameTime
local RequestRaidInfo = _G.RequestRaidInfo
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local SecondsToTime = _G.SecondsToTime
local C_Calendar = _G.C_Calendar
local C_DateAndTime = _G.C_DateAndTime

local Minimap = _G.Minimap

-- Current time string plus whether calendar invites are pending. Honours the
-- military-time and local-time CVars like the Blizzard clock does.
local function TimeText()
	local pending = C_Calendar and C_Calendar.GetNumPendingInvites and C_Calendar.GetNumPendingInvites() > 0
	local hour, minute
	if GetCVarBool("timeMgrUseLocalTime") then
		hour, minute = tonumber(date("%H")), tonumber(date("%M"))
	else
		hour, minute = GetGameTime()
	end
	hour = hour or 0
	minute = minute or 0

	if GetCVarBool("timeMgrUseMilitaryTime") then
		return format("%02d:%02d", hour, minute), pending
	end
	local suffix = hour < 12 and "AM" or "PM"
	local h = hour % 12
	if h == 0 then
		h = 12
	end
	return format("%d:%02d %s", h, minute, suffix), pending
end

-- Hover tooltip: date, both clocks, and this character's saved instance lockouts.
function Module:TimeTooltip(anchor)
	if RequestRaidInfo then
		RequestRaidInfo()
	end
	GameTooltip:SetOwner(anchor, "ANCHOR_LEFT")
	GameTooltip:ClearLines()

	local today = C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime and C_DateAndTime.GetCurrentCalendarTime()
	if today and _G.FULLDATE and _G.CALENDAR_WEEKDAY_NAMES and _G.CALENDAR_FULLDATE_MONTH_NAMES then
		GameTooltip:AddLine(format(_G.FULLDATE, _G.CALENDAR_WEEKDAY_NAMES[today.weekday], _G.CALENDAR_FULLDATE_MONTH_NAMES[today.month], today.monthDay, today.year), K.Colors.info[1], K.Colors.info[2], K.Colors.info[3])
		GameTooltip:AddLine(" ")
	end
	if GameTime_GetLocalTime then
		GameTooltip:AddDoubleLine(_G.TIMEMANAGER_TOOLTIP_LOCALTIME or "Local Time", GameTime_GetLocalTime(true), K.Colors.info[1], K.Colors.info[2], K.Colors.info[3], 1, 1, 1)
	end
	if GameTime_GetGameTime then
		GameTooltip:AddDoubleLine(_G.TIMEMANAGER_TOOLTIP_REALMTIME or "Realm Time", GameTime_GetGameTime(true), K.Colors.info[1], K.Colors.info[2], K.Colors.info[3], 1, 1, 1)
	end

	local saved = GetNumSavedInstances and GetNumSavedInstances() or 0
	local shownHeader = false
	for i = 1, saved do
		local name, _, reset, _, locked, extended, _, _, _, diffName = GetSavedInstanceInfo(i)
		if name and (locked or extended) then
			if not shownHeader then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(_G.RAID_INFO or "Saved Instances", K.Colors.info[1], K.Colors.info[2], K.Colors.info[3])
				shownHeader = true
			end
			local r, g, b = extended and 0.3 or 1, 1, extended and 0.3 or 1
			GameTooltip:AddDoubleLine(format("%s|cffaaaaaa %s|r", name, diffName or ""), SecondsToTime(reset or 0, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cff669dffLeft Click|r Calendar   |cff669dffRight Click|r Stopwatch", 0.6, 0.6, 0.6)
	GameTooltip:Show()
end

function Module:CreateClock()
	if not C.Minimap.ShowClock then
		return
	end

	local clock = CreateFrame("Button", nil, Minimap)
	clock:SetSize(64, 16)
	clock:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 4)
	clock:RegisterForClicks("AnyUp")

	local text = clock:CreateFontString(nil, "OVERLAY")
	K.SetFont(text, C.Minimap.ClockFontSize or 12, K.FontOutlineStyle())
	-- Centred rather than filling the button, so the strip below can hug the time
	-- itself instead of stretching the full click area.
	text:SetPoint("CENTER")
	clock.Text = text
	self.clock = clock

	-- The shared strip, spanning the full map width like the zone name and the
	-- coordinates rather than hugging the time. Parented to the map, not the button,
	-- so it can reach wider than the click area.
	local shade = K.CreateTextShade(Minimap, "ARTWORK", 6)
	shade.Holder:SetPoint("LEFT", Minimap, "LEFT", 0, 0)
	shade.Holder:SetPoint("RIGHT", Minimap, "RIGHT", 0, 0)
	shade.Holder:SetPoint("TOP", text, "TOP", 0, 2)
	shade.Holder:SetHeight((C.Minimap.ClockFontSize or 12) + 6)
	shade:SetColor(K.StripColor[1], K.StripColor[2], K.StripColor[3], K.GradientAlpha.strip)
	shade:Show()
	clock.Shade = shade

	clock:SetScript("OnMouseUp", function(_, button)
		if button == "RightButton" then
			if ToggleTimeManager then
				ToggleTimeManager()
			end
		elseif ToggleCalendar then
			ToggleCalendar()
		end
	end)
	clock:SetScript("OnEnter", function(self2)
		Module:TimeTooltip(self2)
	end)
	clock:SetScript("OnLeave", GameTooltip_Hide)

	-- Self-throttled updater on the datatext itself.
	local elapsed = 1
	clock:SetScript("OnUpdate", function(_, delta)
		elapsed = elapsed + delta
		if elapsed < 1 then
			return
		end
		elapsed = 0
		local str, pending = TimeText()
		text:SetText(str)
		if pending then
			text:SetTextColor(1, 0.2, 0.2)
		else
			text:SetTextColor(1, 1, 1)
		end
	end)
end
