--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Enhance Blizzard SuperTrackedFrame — pin alpha by distance, custom
--   distance text, ETA under the arrow, auto-track user waypoints.
-- - Design: Method overrides gate on C["WorldMap"].MapPinNavigation. Full visual
--   revert needs /reload (can't un-override methods). /way lives in CreateCustomWaypoint.
--   C_Navigation.GetDistance has no secret tags (Resources 12.0.7) — plain math.
--   ETA FontString copies DistanceText shadow (not CreatePlainFS) — Slug shadow
--   regression on 12.0.7 if we used our plain-font helper here.
-- - Events: USER_WAYPOINT_UPDATED, SUPER_TRACKING_CHANGED, CVAR_UPDATE
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("WorldMap")

local _G = _G
local abs, floor, max = math.abs, math.floor, math.max
local format = string.format
local GetCVar = GetCVar
local GetTime = GetTime
local GetCursorPosition = GetCursorPosition
local Round = Round
local FrameDeltaLerp = FrameDeltaLerp
local ClampedPercentageBetween = ClampedPercentageBetween
local TIMER_MINUTES_DISPLAY = TIMER_MINUTES_DISPLAY
local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local C_Map = C_Map
local C_Navigation = C_Navigation
local C_SuperTrack = C_SuperTrack
local C_Timer_After = C_Timer.After

local GetDistance = C_Navigation and C_Navigation.GetDistance
local WasClampedToScreen = C_Navigation and C_Navigation.WasClampedToScreen
local HasValidScreenPosition = C_Navigation and C_Navigation.HasValidScreenPosition

local styled = false
local eventsRegistered = false
local navCvarEnabled = true
local lastDistance, lastUpdate, emaSpeed = nil, 0, nil
local origMethods

local ETA_SAMPLE_INTERVAL = 0.5
local ETA_RETREAT_SPEED = -3
local ETA_APPROACH_SPEED = 0.5

local function cfg()
	return C["WorldMap"]
end

local function IsEnabled()
	return cfg().MapPinNavigation
end

local function NavCvarEnabled()
	if not cfg().MapPinRespectNavCVar then
		return true
	end
	return navCvarEnabled
end

local function DistanceInRange(distance)
	local minD = cfg().MapPinMinDistance or 0
	local maxD = cfg().MapPinMaxDistance or 0
	if distance < minD then
		return false
	end
	if maxD > 0 and distance > maxD then
		return false
	end
	return true
end

local function FormatDistance(distance)
	local measure = " yds"
	if cfg().MapPinUseMeters then
		distance = distance * 0.9144
		measure = " m"
	end
	if cfg().MapPinShortNumbers and distance > 1000 then
		return format("%sK%s", Round(distance / 100) / 10, measure)
	end
	return format("%d%s", Round(distance), measure)
end

local function HideEta(frame)
	if frame and frame.TimeText then
		frame.TimeText:Hide()
	end
	lastDistance, lastUpdate, emaSpeed = nil, 0, nil
end

local function ShowEta(frame, distance, speed)
	if not (frame.TimeText and speed and speed > 0) then
		return
	end
	local eta = abs(distance / max(speed, 0.1))
	local etaMin, etaSec = floor(eta / 60), floor(eta % 60)
	frame.TimeText:SetFormattedText(TIMER_MINUTES_DISPLAY, etaMin, etaSec)
	frame.TimeText:Show()
end

local function UpdateEta(frame, elapsed)
	if not IsEnabled() or not cfg().MapPinShowEta then
		HideEta(frame)
		return
	end
	if not GetDistance then
		return
	end
	if WasClampedToScreen and WasClampedToScreen() then
		if frame.TimeText then
			frame.TimeText:Hide()
		end
		return
	end

	lastUpdate = lastUpdate + (elapsed or 0)
	if lastUpdate < ETA_SAMPLE_INTERVAL then
		return
	end

	local distance = GetDistance()
	if distance == nil then
		return
	end
	if distance <= 0 then
		HideEta(frame)
		return
	end

	-- Seed the first sample; `prev = lastDistance or distance` would always yield zero speed.
	if lastDistance == nil then
		lastDistance = distance
		lastUpdate = 0
		return
	end

	local prev = lastDistance
	local instSpeed = (prev - distance) / lastUpdate
	lastDistance = distance
	lastUpdate = 0

	if instSpeed < ETA_RETREAT_SPEED then
		if frame.TimeText then
			frame.TimeText:Hide()
		end
		emaSpeed = nil
		return
	end

	if instSpeed >= ETA_APPROACH_SPEED then
		emaSpeed = emaSpeed and (emaSpeed * 0.6 + instSpeed * 0.4) or instSpeed
		ShowEta(frame, distance, emaSpeed)
	elseif emaSpeed and emaSpeed > 0 then
		emaSpeed = emaSpeed * 0.95
		ShowEta(frame, distance, emaSpeed)
	elseif frame.TimeText then
		frame.TimeText:Hide()
	end
end

local function GetTargetAlphaBaseValue(frame)
	if not origMethods then
		return 0
	end
	if not IsEnabled() then
		return origMethods.GetTargetAlphaBaseValue(frame)
	end
	if not NavCvarEnabled() then
		return 0
	end

	local distance = GetDistance and GetDistance()
	if distance == nil then
		return origMethods.GetTargetAlphaBaseValue(frame)
	end

	if not DistanceInRange(distance) then
		return 0
	end

	if frame.isClamped then
		return (cfg().MapPinAlphaClamped or 100) / 100
	end
	if distance > (cfg().MapPinFadeDistance or 1000) then
		return (cfg().MapPinAlphaLong or 60) / 100
	end
	return (cfg().MapPinAlphaShort or 100) / 100
end

local function UpdateDistanceText(frame)
	if not origMethods then
		return
	end
	if not IsEnabled() then
		return origMethods.UpdateDistanceText(frame)
	end

	if not frame.isClamped then
		local distance = GetDistance and GetDistance()
		if distance ~= nil then
			frame.DistanceText:SetText(FormatDistance(distance))
			frame.distance = distance
		end
	end

	frame.DistanceText:SetShown(not frame.isClamped)
	if frame.TimeText then
		frame.TimeText:SetShown(not frame.isClamped and cfg().MapPinShowEta)
	end
end

local function GetTargetAlpha(frame)
	if not origMethods then
		return 0
	end
	if not HasValidScreenPosition or not HasValidScreenPosition() then
		return 0
	end

	if frame.transparentUntil and frame.transparentUntil > GetTime() then
		return 0
	end
	frame.transparentUntil = nil

	local additionalFade = 1.0
	if IsEnabled() and cfg().MapPinFadeMouseOver and frame:IsMouseOver() then
		local mouseX, mouseY = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale()
		mouseX = mouseX / scale
		mouseY = mouseY / scale
		local centerX, centerY = frame:GetCenter()
		frame.mouseToNavVec:SetXY(mouseX - centerX, mouseY - centerY)
		local mouseToNavDistanceSq = frame.mouseToNavVec:GetLengthSquared()
		additionalFade = ClampedPercentageBetween(mouseToNavDistanceSq, 0, frame.navFrameRadiusSq * 2)
	elseif not IsEnabled() then
		return origMethods.GetTargetAlpha(frame)
	end

	return FrameDeltaLerp(frame:GetAlpha(), GetTargetAlphaBaseValue(frame) * additionalFade, 0.1)
end

local function InstallFrameOverrides(frame)
	if frame.__kkuiMapPinInstalled or not origMethods then
		return
	end
	frame.__kkuiMapPinInstalled = true
	frame.GetTargetAlphaBaseValue = GetTargetAlphaBaseValue
	frame.UpdateDistanceText = UpdateDistanceText
	frame.GetTargetAlpha = GetTargetAlpha
end

local function StyleSuperTrackedFrame(frame)
	if styled or not (frame and frame.DistanceText) then
		return
	end
	styled = true

	if not origMethods then
		origMethods = {
			GetTargetAlphaBaseValue = frame.GetTargetAlphaBaseValue,
			UpdateDistanceText = frame.UpdateDistanceText,
			GetTargetAlpha = frame.GetTargetAlpha,
		}
	end

	local fontPath, size, flags = frame.DistanceText:GetFont()
	frame.DistanceText:SetFont(fontPath or (select(1, _G.KkthnxUIFont:GetFont())), size or 12, flags)

	local time = frame:CreateFontString(nil, "BACKGROUND")
	time:SetFont(fontPath or (select(1, _G.KkthnxUIFont:GetFont())), size or 12, flags)
	local sox, soy = frame.DistanceText:GetShadowOffset()
	time:SetShadowOffset(sox, soy)
	local sr, sg, sb, sa = frame.DistanceText:GetShadowColor()
	time:SetShadowColor(sr, sg, sb, sa)
	local tr, tg, tb = frame.DistanceText:GetTextColor()
	time:SetTextColor(tr, tg, tb)
	time:SetPoint("TOP", frame.DistanceText, "BOTTOM", 0, -2)
	time:SetHeight(20)
	time:SetJustifyV("TOP")
	time:SetWordWrap(false)
	time:Hide()
	frame.TimeText = time

	InstallFrameOverrides(frame)

	frame:HookScript("OnUpdate", function(self, elapsed)
		UpdateEta(self, elapsed)
	end)
	frame:HookScript("OnHide", HideEta)
end

local function OnQuestNavLoaded(_, addon)
	if addon == "Blizzard_QuestNavigation" then
		StyleSuperTrackedFrame(_G.SuperTrackedFrame)
		K:UnregisterEvent("ADDON_LOADED", OnQuestNavLoaded)
	end
end

local function EnsureSuperTrackStyled()
	local frame = _G.SuperTrackedFrame
	if frame then
		StyleSuperTrackedFrame(frame)
		return
	end
	if C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_QuestNavigation") then
		StyleSuperTrackedFrame(_G.SuperTrackedFrame)
		return
	end
	K:RegisterEvent("ADDON_LOADED", OnQuestNavLoaded)
end

local function OnUserWaypointUpdated()
	if not IsEnabled() or not cfg().MapPinAutoTrack then
		return
	end
	if C_Map.HasUserWaypoint and C_Map.HasUserWaypoint() then
		C_Timer_After(0, function()
			if cfg().MapPinAutoTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
				C_SuperTrack.SetSuperTrackedUserWaypoint(true)
			end
		end)
	end
end

local function OnSuperTrackingChanged()
	if not IsEnabled() then
		return
	end
	HideEta(_G.SuperTrackedFrame)
	if C_SuperTrack.IsSuperTrackingQuest and C_SuperTrack.IsSuperTrackingQuest() then
		if C_SuperTrack.SetSuperTrackedUserWaypoint then
			C_SuperTrack.SetSuperTrackedUserWaypoint(false)
		end
	end
end

local function OnCVarUpdate(_, cvarName)
	if cvarName == "showInGameNavigation" or cvarName == "SHOW_IN_GAME_NAVIGATION" then
		navCvarEnabled = GetCVar("showInGameNavigation") == "1"
	end
end

function Module:CreateWorldMapPins()
	if not IsEnabled() then
		if eventsRegistered then
			K:UnregisterEvent("USER_WAYPOINT_UPDATED", OnUserWaypointUpdated)
			K:UnregisterEvent("SUPER_TRACKING_CHANGED", OnSuperTrackingChanged)
			K:UnregisterEvent("CVAR_UPDATE", OnCVarUpdate)
			eventsRegistered = false
		end
		HideEta(_G.SuperTrackedFrame)
		return
	end

	navCvarEnabled = GetCVar("showInGameNavigation") == "1"
	EnsureSuperTrackStyled()

	if eventsRegistered then
		return
	end
	eventsRegistered = true
	K:RegisterEvent("USER_WAYPOINT_UPDATED", OnUserWaypointUpdated)
	K:RegisterEvent("SUPER_TRACKING_CHANGED", OnSuperTrackingChanged)
	K:RegisterEvent("CVAR_UPDATE", OnCVarUpdate)
end

function Module:UpdateWorldMapPins()
	self:CreateWorldMapPins()
	if not cfg().MapPinShowEta then
		HideEta(_G.SuperTrackedFrame)
	end
end
