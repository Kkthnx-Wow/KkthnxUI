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

-- Create Table To Store Revealed Overlays And Info
local overlayTextures = {}
local pATex, pHTex, pNTex = "TaxiNode_Continent_Alliance", "TaxiNode_Continent_Horde", "TaxiNode_Continent_Neutral"

do
	-- Create Checkbox
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

	-- Handle Clicks
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

	-- Set Checkbox State
	frame:SetScript("OnShow", function()
		if KkthnxUIData[GetRealmName()][UnitName("player")].RevealWorldMap == true then
			frame:SetChecked(true)
		else
			frame:SetChecked(false)
		end
	end)

	-- Function To Refresh Overlays (Blizzard_SharedMapDataProviders\MapExplorationDataProvider)
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

		-- Store Already Explored Tiles In A Table So They Can Be Ignored
		local TileExists = {}
		local exploredMapTextures = C_MapExplorationInfo_GetExploredMapTextures(mapID)

		if exploredMapTextures then
			for _, exploredTextureInfo in ipairs(exploredMapTextures) do
				local key = exploredTextureInfo.textureWidth .. ":" .. exploredTextureInfo.textureHeight .. ":" .. exploredTextureInfo.offsetX .. ":" .. exploredTextureInfo.offsetY
				TileExists[key] = true
			end
		end

		-- Get The Sizes
		pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
		local layers = C_Map_GetMapArtLayers(mapID)
		local layerInfo = layers and layers[pin.layerIndex]

		if not layerInfo then
			return
		end

		local TILE_SIZE_WIDTH = layerInfo.tileWidth
		local TILE_SIZE_HEIGHT = layerInfo.tileHeight

		-- Show Textures If They Are In Database And Have Not Been Explored
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

	-- Show Overlays On Startup
	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		hooksecurefunc(pin, "RefreshOverlays", MapExplorationPin_RefreshOverlays)
	end

	-- WorldMapPlus WowHeadLinks
	-- Get Localised Wowhead URL
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

	-- Achievements Frame
	-- Achievement Link Function
	local function DoWowheadAchievementFunc()
		-- Create Editbox
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

		-- Create Hidden Font String (used For Setting Width Of Editbox)
		aEB.z = aEB:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		aEB.z:Hide()

		-- Store Last Link In Case Editbox Is Cleared
		local lastAchievementLink

		-- Function To Set Editbox Value
		hooksecurefunc("AchievementFrameAchievements_SelectButton", function(self)
			local achievementID = self.id or nil
			if achievementID then
				-- Set Editbox Text
				aEB:SetText("https://" .. wowheadLoc .. "/achievement=" .. achievementID)
				lastAchievementLink = aEB:GetText()
				-- Set Hidden Fontstring Then Resize Editbox To Match
				aEB.z:SetText(aEB:GetText())
				aEB:SetWidth(aEB.z:GetStringWidth() + 90)
				-- Get Achievement Title For Tooltip
				local achievementLink = GetAchievementLink(self.id)
				if achievementLink then
					aEB.tiptext = achievementLink:match("%[(.-)%]")
				end
				-- Show The Editbox
				aEB:Show()
			end
		end)

		local r, g, b = 0.2, 1.0, 0.2

		-- Create Tooltip
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
			-- Set Link Text Again If It's Changed Since It Was Set
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

		-- Hide Editbox When Achievement Is Deselected
		hooksecurefunc("AchievementFrameAchievements_ClearSelection", function()
			aEB:Hide()
		end)
		hooksecurefunc("AchievementCategoryButton_OnClick", function()
			aEB:Hide()
		end)
	end

	-- Run Function When Achievement Ui Is Loaded
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

	-- World Map Frame
	-- Hide The Title Text
	WorldMapFrameTitleText:Hide()

	-- Create Editbox
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

	-- Create Hidden Font String (used For Setting Width Of Editbox)
	mEB.z = mEB:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mEB.z:Hide()

	-- Function To Set Editbox Value
	local function SetQuestInBox()
		local questID
		if QuestMapFrame.DetailsFrame:IsShown() then
			-- Get Quest Id From Currently Showing Quest In Details Panel
			questID = QuestMapFrame_GetDetailQuestID()
		else
			-- Get Quest Id From Currently Selected Quest On World Map
			questID = GetSuperTrackedQuestID()
		end
		if questID then
			-- Hide Editbox If Quest Id Is Invalid
			if questID == 0 then mEB:Hide() else mEB:Show() end
			-- Set editbox text
			mEB:SetText("https://" .. wowheadLoc .. "/quest=" .. questID)
			-- Set Hidden Fontstring Then Resize Editbox To Match
			mEB.z:SetText(mEB:GetText())
			mEB:SetWidth(mEB.z:GetStringWidth() + 90)
			-- Get Quest Title For Tooltip
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

	-- Set Url When Super Tracked Quest Changes And On Startup
	mEB:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED")
	mEB:SetScript("OnEvent", SetQuestInBox)
	SetQuestInBox()

	-- Set Url When Quest Details Frame Is Shown Or Hidden
	hooksecurefunc("QuestMapFrame_ShowQuestDetails", SetQuestInBox)
	hooksecurefunc("QuestMapFrame_CloseQuestDetails", SetQuestInBox)

	local r, g, b = 0.2, 1.0, 0.2

	-- Create Tooltip
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
end

do
	-- Show Old Dungeon And Raid Location Icons.
	-- Add Caverns of Time portal to Shattrath if reputation with Keepers of Time is revered or higher
	local _, _, standingID = GetFactionInfoByID(989)
	if standingID and standingID >= 7 then
		-- Shattrath City
		K.WorldMapPlusPinData[111] = {{74.7, 31.4, "Caverns of Time", "Portal from Zephyr", pNTex},}
	end

	-- Get player faction (used to prevent opposite faction portals from showing)
	local playerFaction = UnitFactionGroup("player")
	local KkthnxUIMix = CreateFromMixins(MapCanvasDataProviderMixin)

	function KkthnxUIMix:RefreshAllData()
		-- Remove all pins created by KkthnxUItrix Maps
		self:GetMap():RemoveAllPinsByTemplate("KkthnxUIMapsGlobalPinTemplate")

		-- Make new pins
		local pMapID = WorldMapFrame.mapID
		if K.WorldMapPlusPinData[pMapID] then
			local count = #K.WorldMapPlusPinData[pMapID]
			for i = 1, count do

				-- Do nothing if pinInfo has no entry for zone we are looking at
				local pinInfo = K.WorldMapPlusPinData[pMapID][i]
				if not pinInfo then return nil end

				-- Get POI if any quest requirements have been met
				if not pinInfo[6] or pinInfo[6] and not pinInfo[7] and IsQuestFlaggedCompleted(pinInfo[6]) or pinInfo[6] and pinInfo[7] and IsQuestFlaggedCompleted(pinInfo[6]) and not IsQuestFlaggedCompleted(pinInfo[7]) then
					if playerFaction == "Alliance" and pinInfo[5] ~= pHTex or playerFaction == "Horde" and pinInfo[5] ~= pATex then
						local myPOI = {}
						myPOI["position"] = CreateVector2D(pinInfo[1] / 100, pinInfo[2] / 100)
						myPOI["name"] = pinInfo[3]
						myPOI["description"] = pinInfo[4]
						myPOI["atlasName"] = pinInfo[5]
						self:GetMap():AcquirePin("KkthnxUIMapsGlobalPinTemplate", myPOI)
					end
				end
			end
		end
	end

	KkthnxUIMapsGlobalPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")

	function KkthnxUIMapsGlobalPinMixin:OnAcquired(myInfo)
		BaseMapPoiPinMixin.OnAcquired(self, myInfo)
	end

	WorldMapFrame:AddDataProvider(CreateFromMixins(KkthnxUIMix))
end