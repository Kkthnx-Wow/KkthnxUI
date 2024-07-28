local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("WorldMap")

local _G = _G

local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local CreateFrame = CreateFrame
local CreateFrame = CreateFrame
local IsPlayerMoving = IsPlayerMoving
local IsPlayerMoving = IsPlayerMoving
local PLAYER = PLAYER
local PlayerMovementFrameFader = PlayerMovementFrameFader
local UIParent = UIParent
local hooksecurefunc = hooksecurefunc
local hooksecurefunc = hooksecurefunc

local currentMapID, playerCoords, cursorCoords
local smallerMapScale = 0.8

function Module:SetLargeWorldMap()
	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:SetParent(UIParent)
	WorldMapFrame:SetScale(1)
	WorldMapFrame.ScrollContainer.Child:SetScale(smallerMapScale)

	WorldMapFrame:OnFrameSizeChanged()
	if WorldMapFrame:GetMapID() then
		WorldMapFrame.NavBar:Refresh()
	end
end

function Module:UpdateMaximizedSize()
	local WorldMapFrame = _G.WorldMapFrame
	local width, height = WorldMapFrame:GetSize()
	local magicNumber = (1 - smallerMapScale) * 100
	WorldMapFrame:SetSize((width * smallerMapScale) - (magicNumber + 2), (height * smallerMapScale) - 2)
end

function Module:SynchronizeDisplayState()
	local WorldMapFrame = _G.WorldMapFrame
	if WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint("CENTER", UIParent)
	end

	K.RestoreMoverFrame(self)
end

function Module:SetSmallWorldMap()
	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -94)
end

function Module:GetCursorCoords()
	if not WorldMapFrame.ScrollContainer:IsMouseOver() then
		return
	end

	local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
	if cursorX < 0 or cursorX > 1 or cursorY < 0 or cursorY > 1 then
		return
	end

	return cursorX, cursorY
end

local function CoordsFormat(owner, none)
	local text = none and ": --, --" or ": %.1f, %.1f"
	return owner .. K.MyClassColor .. text
end

function Module:UpdateCoords(elapsed)
	local WorldMapFrame = _G.WorldMapFrame
	if not WorldMapFrame:IsShown() then
		return
	end

	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.2 then
		local cursorX, cursorY = Module:GetCursorCoords()
		if cursorX and cursorY then
			cursorCoords:SetFormattedText(CoordsFormat("Mouse"), 100 * cursorX, 100 * cursorY)
		else
			cursorCoords:SetText(CoordsFormat("Mouse", true))
		end

		if not currentMapID then
			playerCoords:SetText(CoordsFormat(PLAYER, true))
		else
			local x, y = K.GetPlayerMapPos(currentMapID)
			if not x or (x == 0 and y == 0) then
				playerCoords:SetText(CoordsFormat(PLAYER, true))
			else
				playerCoords:SetFormattedText(CoordsFormat(PLAYER), 100 * x, 100 * y)
			end
		end

		self.elapsed = 0
	end
end

function Module:UpdateMapID()
	if self:GetMapID() == C_Map_GetBestMapForUnit("player") then
		currentMapID = self:GetMapID()
	else
		currentMapID = nil
	end
end

function Module:MapShouldFade()
	-- normally we would check GetCVarBool('mapFade') here instead of the setting
	return C["WorldMap"].FadeWhenMoving and not _G.WorldMapFrame:IsMouseOver()
end

function Module:MapFadeOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		self.elapsed = 0

		local object = self.FadeObject
		local settings = object and object.FadeSettings
		if not settings then
			return
		end

		local fadeOut = IsPlayerMoving() and (not settings.fadePredicate or settings.fadePredicate())
		local endAlpha = (fadeOut and (settings.minAlpha or 0.5)) or settings.maxAlpha or 1
		local startAlpha = _G.WorldMapFrame:GetAlpha()

		object.timeToFade = settings.durationSec or 0.5
		object.startAlpha = startAlpha
		object.endAlpha = endAlpha
		object.diffAlpha = endAlpha - startAlpha

		if object.fadeTimer then
			object.fadeTimer = nil
		end

		UIFrameFade(_G.WorldMapFrame, object)
	end
end

local fadeFrame
function Module:StopMapFromFading()
	if fadeFrame then
		fadeFrame:Hide()
	end
end

function Module:EnableMapFading(frame)
	if not fadeFrame then
		fadeFrame = CreateFrame("FRAME")
		fadeFrame:SetScript("OnUpdate", Module.MapFadeOnUpdate)
		frame:HookScript("OnHide", Module.StopMapFromFading)

		fadeFrame.FadeObject = {}
		fadeFrame.FadeObject.FadeSettings = {}
	end

	local settings = fadeFrame.FadeObject.FadeSettings
	settings.fadePredicate = Module.MapShouldFade
	settings.durationSec = 0.2
	settings.minAlpha = C["WorldMap"].AlphaWhenMoving
	settings.maxAlpha = 1

	fadeFrame:Show()
end

function Module:UpdateMapFade(minAlpha, maxAlpha, durationSec, fadePredicate) -- self is frame
	if self:IsShown() and (self == _G.WorldMapFrame and fadePredicate ~= Module.MapShouldFade) then
		-- blizzard spams code in OnUpdate and doesnt finish their functions, so we shut their fader down :L
		PlayerMovementFrameFader.RemoveFrame(self)

		-- replacement function which is complete :3
		if C["WorldMap"].FadeWhenMoving then
			Module:EnableMapFading(self)
		end
	end
end

function Module:WorldMap_OnShow()
	-- Update coordinates if necessary
	if Module.CoordsUpdater then
		Module.CoordsUpdater:SetScript("OnUpdate", Module.UpdateCoords)
	end

	-- Check if the map has been size adjusted already
	if Module.mapSizeAdjusted then
		return
	end

	-- Resize the map if necessary
	local frame = _G.WorldMapFrame
	local maxed = frame:IsMaximized()
	if maxed then -- Call this outside of smallerWorldMap
		frame:UpdateMaximizedSize()
	end

	-- Set the appropriate map size
	if C["WorldMap"].SmallWorldMap then
		if maxed then
			Module:SetLargeWorldMap()
		else
			Module:SetSmallWorldMap()
		end
	end

	-- Mark the map as size adjusted
	Module.mapSizeAdjusted = true
end

function Module:WorldMap_OnHide()
	if Module.CoordsUpdater then
		Module.CoordsUpdater:SetScript("OnUpdate", nil)
	end
end

function Module:OnEnable()
	local WorldMapFrame = _G.WorldMapFrame
	if C["WorldMap"].Coordinates then
		-- Define the desired color (#F0C500 or RGB values 240/255, 197/255, 0)
		local textColor = { r = 240 / 255, g = 197 / 255, b = 0 }

		-- Create the coordinates frame
		local coordsFrame = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
		coordsFrame:SetSize(WorldMapFrame:GetWidth(), 17)
		coordsFrame:SetPoint("BOTTOMLEFT", 17)
		coordsFrame:SetPoint("BOTTOMRIGHT", 0)

		-- Background texture for the coordinates frame
		coordsFrame.Texture = coordsFrame:CreateTexture(nil, "BACKGROUND")
		coordsFrame.Texture:SetAllPoints()
		coordsFrame.Texture:SetTexture(C["Media"].Textures.White8x8Texture)
		coordsFrame.Texture:SetVertexColor(0.04, 0.04, 0.04, 0.5)

		-- Create the cursor coordinates text
		cursorCoords = WorldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
		cursorCoords:SetFontObject(K.UIFontOutline)
		cursorCoords:SetFont(select(1, cursorCoords:GetFont()), 13, select(3, cursorCoords:GetFont()))
		cursorCoords:SetSize(200, 16)
		cursorCoords:SetParent(coordsFrame)
		cursorCoords:ClearAllPoints()
		cursorCoords:SetPoint("BOTTOMLEFT", 152, 1)
		cursorCoords:SetTextColor(textColor.r, textColor.g, textColor.b)
		cursorCoords:SetAlpha(0.9)

		-- Create the player coordinates text
		playerCoords = WorldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
		playerCoords:SetFontObject(K.UIFontOutline)
		playerCoords:SetFont(select(1, playerCoords:GetFont()), 13, select(3, playerCoords:GetFont()))
		playerCoords:SetSize(200, 16)
		playerCoords:SetParent(coordsFrame)
		playerCoords:ClearAllPoints()
		playerCoords:SetPoint("BOTTOMRIGHT", -132, 1)
		playerCoords:SetTextColor(textColor.r, textColor.g, textColor.b)
		playerCoords:SetAlpha(0.9)

		hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", self.UpdateMapID)
		hooksecurefunc(WorldMapFrame, "OnMapChanged", self.UpdateMapID)

		self.CoordsUpdater = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
		self.CoordsUpdater:SetScript("OnUpdate", self.UpdateCoords)
	end

	if C["WorldMap"].SmallWorldMap then
		smallerMapScale = C["WorldMap"].SmallWorldMapScale or 0.9

		K.CreateMoverFrame(WorldMapFrame, nil, true)

		WorldMapFrame.BlackoutFrame.Blackout:SetTexture()
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		hooksecurefunc(WorldMapFrame, "Maximize", self.SetLargeWorldMap)
		hooksecurefunc(WorldMapFrame, "Minimize", self.SetSmallWorldMap)
		hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", self.SynchronizeDisplayState)
		hooksecurefunc(WorldMapFrame, "UpdateMaximizedSize", self.UpdateMaximizedSize)
	end

	WorldMapFrame:HookScript("OnShow", Module.WorldMap_OnShow)
	WorldMapFrame:HookScript("OnHide", Module.WorldMap_OnHide)

	hooksecurefunc(PlayerMovementFrameFader, "AddDeferredFrame", Module.UpdateMapFade)

	if C["General"].NoTutorialButtons then
		WorldMapFrame.BorderFrame.Tutorial:Kill()
	end

	local loadWorldMapModules = {
		"CreateWorldMapReveal",
		"CreateWowHeadLinks",
		"CreateWorldMapPins",
	}

	for _, funcName in ipairs(loadWorldMapModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
