local K, C, L = unpack(select(2, ...))
if C["WorldMap"].WorldMapPlus ~= true then
	return
end

-- Sourced: Leatrix_Maps by Leatrix

local _G = _G
local ipairs = ipairs
local math_ceil = math.ceil
local mod = mod
local pairs = pairs
local string_split = string.split
local table_insert = tinsert
local tonumber = tonumber

local C_Map_GetMapArtID = _G.C_Map.GetMapArtID
local C_Map_GetMapArtLayers = _G.C_Map.GetMapArtLayers
local C_MapExplorationInfo_GetExploredMapTextures = _G.C_MapExplorationInfo.GetExploredMapTextures
local CreateFrame = _G.CreateFrame
local GameLocale = _G.GetLocale()
local GameTooltip = _G.GameTooltip
local GetAchievementLink = _G.GetAchievementLink
local GetQuestLink = _G.GetQuestLink
local GetRealmName = _G.GetRealmName
local GetSuperTrackedQuestID = _G.GetSuperTrackedQuestID
local hooksecurefunc = _G.hooksecurefunc
local IsAddOnLoaded = _G.IsAddOnLoaded
local UnitName = _G.UnitName

-- Create table to store revealed overlays
local overlayTextures = {}

-- Create checkbox
local frame = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame, "OptionsCheckButtonTemplate")
frame:SetSize(24, 24)
frame:SetPoint("TOPRIGHT", -130, 0)

frame.f = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.f:SetPoint("LEFT", 24, 0)
frame.f:SetText(L["Maps"].Reveal)
frame:SetHitRectInsets(0, 0 - frame.f:GetWidth(), 0, 0)
frame.f:Show()

function frame.UpdateTooltip(self)
	if (GameTooltip:IsForbidden()) then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)

	local r, g, b = 0.2, 1.0, 0.2

	if KkthnxUIData[GetRealmName()][UnitName("player")].RevealWorldMap == true then
		GameTooltip:AddLine(L["Maps"].HideUnDiscovered)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Maps"].DisableToHide, r, g, b)
	else
		GameTooltip:AddLine(L["Maps"].RevealHidden)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Maps"].EnableToShow, r, g, b)
	end

	GameTooltip:Show()
end

frame:HookScript("OnEnter", function(self)
	if (GameTooltip:IsForbidden()) then
		return
	end

	self:UpdateTooltip()
end)

frame:HookScript("OnLeave", function()
	if (GameTooltip:IsForbidden()) then
		return
	end

	GameTooltip:Hide()
end)

-- Handle clicks
frame:SetScript("OnClick", function(self)
	if frame:GetChecked() == true then
		KkthnxUIData[GetRealmName()][UnitName("player")].RevealWorldMap = true
		for i = 1, #overlayTextures do
			overlayTextures[i]:Show()
		end
	else
		KkthnxUIData[GetRealmName()][UnitName("player")].RevealWorldMap = false
		for i = 1, #overlayTextures do
			overlayTextures[i]:Hide()
		end
	end

	if (GameTooltip:IsForbidden()) then
		return
	end

	if (GameTooltip:GetOwner() == self) then
		self:UpdateTooltip()
	end
end)

-- Set checkbox state
frame:SetScript("OnShow", function()
	if KkthnxUIData[GetRealmName()][UnitName("player")].RevealWorldMap == true then
		frame:SetChecked(true)
	else
		frame:SetChecked(false)
	end
end)

-- Function to refresh overlays (Blizzard_SharedMapDataProviders\MapExplorationDataProvider)
local function MapExplorationPin_RefreshOverlays(pin, fullUpdate)
	overlayTextures = {}
	local mapID = WorldMapFrame.mapID

	if not mapID then
		return
	end

	local artID = C_Map_GetMapArtID(mapID)

	if not artID or not K.WorldMapPlusData[artID] then
		return
	end

	-- Store already explored tiles in a table so they can be ignored
	local TileExists = {}
	local exploredMapTextures = C_MapExplorationInfo_GetExploredMapTextures(mapID)

	if exploredMapTextures then
		for _, exploredTextureInfo in ipairs(exploredMapTextures) do
			local key = exploredTextureInfo.textureWidth .. ":" .. exploredTextureInfo.textureHeight .. ":" .. exploredTextureInfo.offsetX .. ":" .. exploredTextureInfo.offsetY
			TileExists[key] = true
		end
	end

	-- Get the sizes
	pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
	local layers = C_Map_GetMapArtLayers(mapID)
	local layerInfo = layers and layers[pin.layerIndex]

	if not layerInfo then
		return
	end

	local TILE_SIZE_WIDTH = layerInfo.tileWidth
	local TILE_SIZE_HEIGHT = layerInfo.tileHeight

	-- Show textures if they are in database and have not been explored
	for key, files in pairs(K.WorldMapPlusData[artID]) do
		if not TileExists[key] then
			local width, height, offsetX, offsetY = string_split(":", key)
			local fileDataIDs = {string_split(",", files)}
			local numTexturesWide = math_ceil(width / TILE_SIZE_WIDTH)
			local numTexturesTall = math_ceil(height / TILE_SIZE_HEIGHT)
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight

			for j = 1, numTexturesTall do
				if (j < numTexturesTall) then
					texturePixelHeight = TILE_SIZE_HEIGHT
					textureFileHeight = TILE_SIZE_HEIGHT
				else
					texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
					if (texturePixelHeight == 0) then
						texturePixelHeight = TILE_SIZE_HEIGHT
					end
					textureFileHeight = 16
					while (textureFileHeight < texturePixelHeight) do
						textureFileHeight = textureFileHeight * 2
					end
				end

				for k = 1, numTexturesWide do
					local texture = pin.overlayTexturePool:Acquire()
					if (k < numTexturesWide) then
						texturePixelWidth = TILE_SIZE_WIDTH
						textureFileWidth = TILE_SIZE_WIDTH
					else
						texturePixelWidth = mod(width, TILE_SIZE_WIDTH)
						if (texturePixelWidth == 0) then
							texturePixelWidth = TILE_SIZE_WIDTH
						end
						textureFileWidth = 16
						while(textureFileWidth < texturePixelWidth) do
							textureFileWidth = textureFileWidth * 2
						end
					end

					texture:SetSize(texturePixelWidth, texturePixelHeight)
					texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
					texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k - 1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
					texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
					texture:SetDrawLayer("ARTWORK", -1)

					if KkthnxUIData[GetRealmName()][UnitName("player")].RevealWorldMap == true then
						texture:Show()

						if fullUpdate then
							pin.textureLoadGroup:AddTexture(texture)
						end
					else
						texture:Hide()
					end

					table_insert(overlayTextures, texture)
				end
			end
		end
	end
end

-- Show overlays on startup
for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
	hooksecurefunc(pin, "RefreshOverlays", MapExplorationPin_RefreshOverlays)
end

-- WorldMapPlus WoWHeadLinks
-- Get localised Wowhead URL
local wowheadLoc
if GameLocale == "deDE" then
	wowheadLoc = "de.wowhead.com"
elseif GameLocale == "esMX" then wowheadLoc = "es.wowhead.com"
elseif GameLocale == "esES" then wowheadLoc = "es.wowhead.com"
elseif GameLocale == "frFR" then wowheadLoc = "fr.wowhead.com"
elseif GameLocale == "itIT" then wowheadLoc = "it.wowhead.com"
elseif GameLocale == "ptBR" then wowheadLoc = "pt.wowhead.com"
elseif GameLocale == "ruRU" then wowheadLoc = "ru.wowhead.com"
elseif GameLocale == "koKR" then wowheadLoc = "ko.wowhead.com"
elseif GameLocale == "zhCN" then wowheadLoc = "cn.wowhead.com"
elseif GameLocale == "zhTW" then wowheadLoc = "cn.wowhead.com"
else
	wowheadLoc = "wowhead.com"
end

-- Achievements frame
-- Achievement link function
local function DoWowheadAchievementFunc()
	-- Create editbox
	local aEB = CreateFrame("EditBox", nil, AchievementFrame)
	aEB:ClearAllPoints()
	aEB:SetPoint("BOTTOMRIGHT", -50, 1)
	aEB:SetHeight(16)
	aEB:SetFontObject("GameFontNormalSmall")
	aEB:SetBlinkSpeed(0)
	aEB:SetJustifyH("RIGHT")
	aEB:SetAutoFocus(false)
	aEB:EnableKeyboard(false)
	aEB:SetHitRectInsets(90, 0, 0, 0)
	aEB:SetScript("OnKeyDown", function() end)
	aEB:SetScript("OnMouseUp", function()
		if aEB:IsMouseOver() then
			aEB:HighlightText()
		else
			aEB:HighlightText(0, 0)
		end
	end)

	-- Create hidden font string (used for setting width of editbox)
	aEB.z = aEB:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	aEB.z:Hide()

	-- Store last link in case editbox is cleared
	local lastAchievementLink

	-- Function to set editbox value
	hooksecurefunc("AchievementFrameAchievements_SelectButton", function(self)
		local achievementID = self.id or nil
		if achievementID then
			-- Set editbox text
			aEB:SetText("https://" .. wowheadLoc .. "/achievement=" .. achievementID)
			lastAchievementLink = aEB:GetText()
			-- Set hidden fontstring then resize editbox to match
			aEB.z:SetText(aEB:GetText())
			aEB:SetWidth(aEB.z:GetStringWidth() + 90)
			-- Get achievement title for tooltip
			local achievementLink = GetAchievementLink(self.id)
			if achievementLink then
				aEB.tiptext = achievementLink:match("%[(.-)%]")
			end
			-- Show the editbox
			aEB:Show()
		end
	end)

	local r, g, b = 0.2, 1.0, 0.2

	-- Create tooltip
	aEB:HookScript("OnEnter", function()
		aEB:HighlightText()
		aEB:SetFocus()

		if GameTooltip:IsForbidden() then
			return
		end

		GameTooltip:SetOwner(aEB, "ANCHOR_TOP", 0, 10)
		GameTooltip:AddLine(aEB.tiptext)
		GameTooltip:AddLine(L["Maps"].PressToCopy, r, g, b)

		GameTooltip:Show()
	end)

	aEB:HookScript("OnLeave", function()
		-- Set link text again if it's changed since it was set
		if aEB:GetText() ~= lastAchievementLink then
			aEB:SetText(lastAchievementLink)
		end

		aEB:HighlightText(0, 0)
		aEB:ClearFocus()

		if GameTooltip:IsForbidden() then
			return
		end

		GameTooltip:Hide()
	end)

	-- Hide editbox when achievement is deselected
	hooksecurefunc("AchievementFrameAchievements_ClearSelection", function()
		aEB:Hide()
	end)
	hooksecurefunc("AchievementCategoryButton_OnClick", function()
		aEB:Hide()
	end)
end

-- Run function when achievement UI is loaded
if IsAddOnLoaded("Blizzard_AchievementUI") then
	DoWowheadAchievementFunc()
else
	local waitAchievementsFrame = CreateFrame("FRAME")
	waitAchievementsFrame:RegisterEvent("ADDON_LOADED")
	waitAchievementsFrame:SetScript("OnEvent", function(_, _, arg1)
		if arg1 == "Blizzard_AchievementUI" then
			DoWowheadAchievementFunc()
			waitAchievementsFrame:UnregisterAllEvents()
		end
	end)
end

-- World map frame
-- Hide the title text
WorldMapFrameTitleText:Hide()

-- Create editbox
local mEB = CreateFrame("EditBox", nil, WorldMapFrame.BorderFrame)
mEB:ClearAllPoints()
mEB:SetPoint("TOPLEFT", 100, -4)
mEB:SetHeight(16)
mEB:SetFontObject("GameFontNormal")
mEB:SetBlinkSpeed(0)
mEB:SetAutoFocus(false)
mEB:EnableKeyboard(false)
mEB:SetHitRectInsets(0, 90, 0, 0)
mEB:SetScript("OnKeyDown", function() end)
mEB:SetScript("OnMouseUp", function()
	if mEB:IsMouseOver() then
		mEB:HighlightText()
	else
		mEB:HighlightText(0, 0)
	end
end)

-- Create hidden font string (used for setting width of editbox)
mEB.z = mEB:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
mEB.z:Hide()

-- Function to set editbox value
local function SetQuestInBox()
	local questID
	if QuestMapFrame.DetailsFrame:IsShown() then
		-- Get quest ID from currently showing quest in details panel
		questID = QuestMapFrame_GetDetailQuestID()
	else
		-- Get quest ID from currently selected quest on world map
		questID = GetSuperTrackedQuestID()
	end
	if questID then
		-- Hide editbox if quest ID is invalid
		if questID == 0 then mEB:Hide() else mEB:Show() end
		-- Set editbox text
		mEB:SetText("https://" .. wowheadLoc .. "/quest=" .. questID)
		-- Set hidden fontstring then resize editbox to match
		mEB.z:SetText(mEB:GetText())
		mEB:SetWidth(mEB.z:GetStringWidth() + 90)
		-- Get quest title for tooltip
		local questLink = GetQuestLink(questID) or nil
		if questLink then
			mEB.tiptext = questLink:match("%[(.-)%]")
		else
			mEB.tiptext = ""
			if mEB:IsMouseOver() and WorldMapTooltip:IsShown() then
				WorldMapTooltip:Hide()
			end
		end
	end
end

-- Set URL when super tracked quest changes and on startup
mEB:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED")
mEB:SetScript("OnEvent", SetQuestInBox)
SetQuestInBox()

-- Set URL when quest details frame is shown or hidden
hooksecurefunc("QuestMapFrame_ShowQuestDetails", SetQuestInBox)
hooksecurefunc("QuestMapFrame_CloseQuestDetails", SetQuestInBox)

local r, g, b = 0.2, 1.0, 0.2

-- Create tooltip
mEB:HookScript("OnEnter", function()
	mEB:HighlightText()
	mEB:SetFocus()
	WorldMapTooltip:SetOwner(mEB, "ANCHOR_BOTTOM", 0, -10)
	WorldMapTooltip:AddLine(mEB.tiptext)
	WorldMapTooltip:AddLine(L["Maps"].PressToCopy, r, g, b)

	if GameTooltip:IsForbidden() then
		return
	end

	WorldMapTooltip:Show()
end)

mEB:HookScript("OnLeave", function()
	mEB:HighlightText(0, 0)
	mEB:ClearFocus()

	if not GameTooltip:IsForbidden() then
		WorldMapTooltip:Hide()
	end

	SetQuestInBox()
end)