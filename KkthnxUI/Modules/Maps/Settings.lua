--[[-----------------------------------------------------------------------------
-- Live GUI refresh for minimap and world map settings.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local MinimapModule = K:GetModule("Minimap")
local WorldMapModule = K:GetModule("WorldMap")
local DataTextModule = K:GetModule("DataText")

local function refreshLocationText()
	if DataTextModule.UpdateLocationTextVisibility then
		DataTextModule:UpdateLocationTextVisibility()
	end
end

local function OnMinimapSetting(configPath)
	local key = configPath:match("^Minimap%.(.+)$")
	if not key then
		return
	end

	if key == "Size" then
		MinimapModule:UpdateMinimapScale()
	elseif key == "EasyVolume" then
		MinimapModule:UpdateEasyVolume()
	elseif key == "MailPulse" then
		MinimapModule:UpdateMailPulse()
	elseif key == "ShowRecycleBin" or key == "RecycleBinPosition" then
		MinimapModule:UpdateRecycleBin()
	elseif key == "Calendar" then
		MinimapModule:UpdateCalendar()
	elseif key == "QueueStatusText" then
		MinimapModule:UpdateQueueStatusText()
	elseif key == "Enable" then
		MinimapModule:SetMinimapEnabled(C["Minimap"].Enable)
	elseif key == "LocationText" then
		refreshLocationText()
	end
end

local function OnWorldMapSetting(configPath)
	local key = configPath:match("^WorldMap%.(.+)$")
	if not key then
		return
	end

	if key == "FadeWhenMoving" or key == "AlphaWhenMoving" then
		WorldMapModule:UpdateMapFading()
	elseif key == "SmallWorldMap" then
		WorldMapModule:UpdateMapSize()
	elseif key == "MapRevealGlow" then
		WorldMapModule:UpdateMapReveal()
	end
end

K:RegisterSettingPrefixCallback("Minimap.", OnMinimapSetting)
K:RegisterSettingPrefixCallback("WorldMap.", OnWorldMapSetting)
