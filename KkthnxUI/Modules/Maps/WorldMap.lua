local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("WorldMap")

local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local CreateFrame = CreateFrame
local IsPlayerMoving = IsPlayerMoving
local PLAYER = PLAYER
local SetUIPanelAttribute = SetUIPanelAttribute
local UIParent = UIParent
local hooksecurefunc = hooksecurefunc

local currentMapID, playerCoords, cursorCoords
local smallerMapScale = 0.8

function Module:SetLargeWorldMap()
	WorldMapFrame:SetParent(UIParent)
	WorldMapFrame:SetScale(1)
	WorldMapFrame.ScrollContainer.Child:SetScale(smallerMapScale)

	if WorldMapFrame:GetAttribute("UIPanelLayout-area") ~= "center" then
		SetUIPanelAttribute(WorldMapFrame, "area", "center")
	end

	if WorldMapFrame:GetAttribute("UIPanelLayout-allowOtherPanels") ~= true then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end

	WorldMapFrame:OnFrameSizeChanged()
	if WorldMapFrame:GetMapID() then
		WorldMapFrame.NavBar:Refresh()
	end
end

function Module:UpdateMaximizedSize()
	local width, height = WorldMapFrame:GetSize()
	local magicNumber = (1 - smallerMapScale) * 100
	WorldMapFrame:SetSize((width * smallerMapScale) - (magicNumber + 2), (height * smallerMapScale) - 2)
end

function Module:SynchronizeDisplayState()
	if WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint("CENTER", UIParent)
	end
end

function Module:SetSmallWorldMap()
	if not WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -94)
	end
end

function Module:WorldMapOnShow(event)
	if Module.mapSized then
		return
	end

	-- Don't do this in combat, there are secure elements here.
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.WorldMapOnShow)
		return
		-- Only ever need this event once.
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent(event, Module.WorldMapOnShow)
	end

	if WorldMapFrame:IsMaximized() then
		WorldMapFrame:UpdateMaximizedSize()
		Module:SetLargeWorldMap()
	else
		Module:SetSmallWorldMap()
	end

	-- Never again!
	Module.mapSized = true
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
	-- normally we would check GetCVarBool("mapFade") here instead of the setting
	return C["WorldMap"].FadeWhenMoving and not _G.WorldMapFrame:IsMouseOver()
end

function Module:MapFadeOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.2 then
		local object = self.FadeObject
		local settings = object and object.FadeSettings
		if not settings then
			return
		end

		local fadeOut = IsPlayerMoving() and (not settings.fadePredicate or settings.fadePredicate())
		local endAlpha = (fadeOut and (settings.minAlpha or 0.5)) or settings.maxAlpha or 1
		local startAlpha = WorldMapFrame:GetAlpha()

		object.timeToFade = settings.durationSec or 0.5
		object.startAlpha = startAlpha
		object.endAlpha = endAlpha
		object.diffAlpha = endAlpha - startAlpha

		if object.fadeTimer then
			object.fadeTimer = nil
		end

		UIFrameFade(_G.WorldMapFrame, object)

		self.elapsed = 0
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
		fadeFrame = CreateFrame("Frame")
		fadeFrame:SetScript("OnUpdate", Module.MapFadeOnUpdate)
		frame:HookScript("OnHide", Module.StopMapFromFading)
	end

	if not fadeFrame.FadeObject then
		fadeFrame.FadeObject = {}
	end

	if not fadeFrame.FadeObject.FadeSettings then
		fadeFrame.FadeObject.FadeSettings = {}
	end

	local settings = fadeFrame.FadeObject.FadeSettings
	settings.fadePredicate = Module.MapShouldFade
	settings.durationSec = 0.2
	settings.minAlpha = C["WorldMap"].AlphaWhenMoving
	settings.maxAlpha = 1

	fadeFrame:Show()
end

function Module:UpdateMapFade(_, _, _, fadePredicate) -- self is frame
	if self:IsShown() and (self == _G.WorldMapFrame and fadePredicate ~= Module.MapShouldFade) then
		-- blizzard spams code in OnUpdate and doesnt finish their functions, so we shut their fader down :L
		PlayerMovementFrameFader.RemoveFrame(self)

		-- replacement function which is complete :3
		if C["WorldMap"].FadeWhenMoving then
			Module:EnableMapFading(self)
		end
	end
end

function Module:OnEnable()
	if C["WorldMap"].Coordinates then
		local coordsFrame = CreateFrame("FRAME", nil, WorldMapFrame.ScrollContainer)
		coordsFrame:SetSize(WorldMapFrame:GetWidth(), 17)
		coordsFrame:SetPoint("BOTTOMLEFT", 17)
		coordsFrame:SetPoint("BOTTOMRIGHT", 0)

		coordsFrame.Texture = coordsFrame:CreateTexture(nil, "BACKGROUND")
		coordsFrame.Texture:SetAllPoints()
		coordsFrame.Texture:SetTexture(C["Media"].Textures.White8x8Texture)
		coordsFrame.Texture:SetVertexColor(0.04, 0.04, 0.04, 0.5)

		-- Create cursor coordinates frame
		cursorCoords = WorldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
		cursorCoords:SetFontObject(K.UIFontOutline)
		cursorCoords:SetFont(select(1, cursorCoords:GetFont()), 13, select(3, cursorCoords:GetFont()))
		cursorCoords:SetSize(200, 16)
		cursorCoords:SetParent(coordsFrame)
		cursorCoords:ClearAllPoints()
		cursorCoords:SetPoint("BOTTOMLEFT", 152, 1)
		cursorCoords:SetTextColor(255 / 255, 204 / 255, 102 / 255)
		cursorCoords:SetAlpha(0.9)

		-- Create player coordinates frame
		playerCoords = WorldMapFrame.ScrollContainer:CreateFontString(nil, "OVERLAY")
		playerCoords:SetFontObject(K.UIFontOutline)
		playerCoords:SetFont(select(1, playerCoords:GetFont()), 13, select(3, playerCoords:GetFont()))
		playerCoords:SetSize(200, 16)
		playerCoords:SetParent(coordsFrame)
		playerCoords:ClearAllPoints()
		playerCoords:SetPoint("BOTTOMRIGHT", -132, 1)
		playerCoords:SetTextColor(255 / 255, 204 / 255, 102 / 255)
		playerCoords:SetAlpha(0.9)

		hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", self.UpdateMapID)
		hooksecurefunc(WorldMapFrame, "OnMapChanged", self.UpdateMapID)

		local CoordsUpdater = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
		CoordsUpdater:SetScript("OnUpdate", self.UpdateCoords)
	end

	if C["WorldMap"].SmallWorldMap then
		smallerMapScale = C["WorldMap"].SmallWorldMapScale or 0.9

		WorldMapFrame.BlackoutFrame.Blackout:SetTexture(nil)
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		hooksecurefunc(WorldMapFrame, "Maximize", self.SetLargeWorldMap)
		hooksecurefunc(WorldMapFrame, "Minimize", self.SetSmallWorldMap)
		hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", self.SynchronizeDisplayState)
		hooksecurefunc(WorldMapFrame, "UpdateMaximizedSize", self.UpdateMaximizedSize)

		WorldMapFrame:HookScript("OnShow", function()
			Module:WorldMapOnShow()
		end)
	end

	-- This lets us control the maps fading function
	hooksecurefunc(PlayerMovementFrameFader, "AddDeferredFrame", self.UpdateMapFade)

	if C["General"].NoTutorialButtons then
		WorldMapFrame.BorderFrame.Tutorial:Kill()
	end

	-- Enable/Disable map fading when moving
	-- currently we dont need to touch this cvar because we have our own control for this currently
	-- see the comment in "Module:UpdateMapFade" about "durationSec" for more information
	-- SetCVar("mapFade", C["WorldMap"].AlphaWhenMoving and 1 or 0)
	self:CreateWorldMapReveal()
	self:CreateWowHeadLinks()
end
