--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Minimap/Core.lua
	Purpose:
		A square, bordered minimap. Owns the frame setup (mover, border, square
		mask), the Blizzard clutter cleanup, and mouse wheel zoom, then hands off
		to the sibling files for the datatexts, right-click menu, and button
		collector. Written flavor aware so it degrades gracefully where some frames
		do not exist.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("Minimap")

local _G = _G
local C_AddOns = C_AddOns

local Minimap = _G.Minimap

-- Reparent a frame offscreen only if it exists on this client. A hidden parent
-- keeps it gone even when Blizzard tries to re-show it.
local hiddenParent
local function Banish(frame)
	if not frame then
		return
	end
	if not hiddenParent then
		hiddenParent = _G.KKUI_HiddenParent
		if not hiddenParent then
			hiddenParent = CreateFrame("Frame", "KKUI_HiddenParent", UIParent)
			hiddenParent:Hide()
		end
	end
	frame:SetParent(hiddenParent)
	if frame.UnregisterAllEvents then
		frame:UnregisterAllEvents()
	end
end

-- Pin down every leftover Blizzard piece, we render our own location and time.
local function HideBlizzardBits()
	Banish(_G.GameTimeFrame) -- calendar button
	Banish(_G.TimeManagerClockButton) -- clock
	Banish(_G.MinimapZoomIn)
	Banish(_G.MinimapZoomOut)
	Banish(_G.MinimapNorthTag)
	Banish(_G.MinimapCompassTexture)
	Banish(_G.AddonCompartmentFrame)

	local cluster = _G.MinimapCluster
	if cluster then
		Banish(cluster.BorderTop)
		Banish(cluster.ZoneTextButton)
		cluster:EnableMouse(false)
		-- Keep the tracking button around for its menu logic but take it off the
		-- map. We drive tracking from our own right-click menu instead.
		if cluster.Tracking then
			cluster.Tracking:SetAlpha(0)
			cluster.Tracking:EnableMouse(false)
		end
	end
	if _G.MinimapCompassTexture then
		_G.MinimapCompassTexture:SetAlpha(0)
	end

	-- Kill the archaeology and quest "blob" rings Blizzard paints over the map.
	if Minimap.SetArchBlobRingScalar then
		Minimap:SetArchBlobRingScalar(0)
	end
	if Minimap.SetQuestBlobRingScalar then
		Minimap:SetQuestBlobRingScalar(0)
	end
	if Minimap.SetQuestBlobRingAlpha then
		Minimap:SetQuestBlobRingAlpha(0)
	end
	if Minimap.SetArchBlobRingAlpha then
		Minimap:SetArchBlobRingAlpha(0)
	end
end

-- The expansion / garrison landing page button floats wherever Blizzard drops it,
-- which reads as clutter on the square map. Tuck it into the bottom-left corner
-- and hold it there, since the client re-anchors it on show.
local function TidyLandingButton()
	local button = _G.ExpansionLandingPageMinimapButton or _G.GarrisonLandingPageMinimapButton
	if not button then
		return
	end
	local function reanchor()
		if button.__kkuiAnchoring then
			return
		end
		button.__kkuiAnchoring = true
		button:ClearAllPoints()
		button:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, -2)
		button:SetScale(0.85)
		button.__kkuiAnchoring = false
	end
	reanchor()
	hooksecurefunc(button, "SetPoint", reanchor)
end

-- The LFG/queue eye floats at a stock spot off the minimap. Pin it to the
-- bottom-right corner and hold it there (the client re-anchors it as queues come
-- and go), and point its status popup off the button so it opens cleanly.
local function TidyQueueStatus()
	local button = _G.QueueStatusButton
	if not button then
		return
	end
	button:SetParent(Minimap)
	local function reanchor()
		if button.__kkuiAnchoring then
			return
		end
		button.__kkuiAnchoring = true
		button:ClearAllPoints()
		button:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 4)
		button:SetScale(0.55)
		button.__kkuiAnchoring = false
	end
	reanchor()
	hooksecurefunc(button, "SetPoint", reanchor)

	local popup = _G.QueueStatusFrame
	if popup then
		popup:ClearAllPoints()
		popup:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 0, 4)
	end
end

-- The instance difficulty flag and the mail indicator both hang off
-- MinimapCluster, which we hide most of, so out of the box they sit against the
-- stock border rather than our square map.
--
-- Blizzard re-anchors both from two places: MinimapCluster:SetHeaderUnderneath
-- flips them when the header moves, and the global MiniMapIndicatorFrame_UpdatePosition
-- re-points the indicator frame whenever the tracking button shows or hides. So
-- pinning once is not enough, both re-anchor paths get a hook.
function Module:TidyIndicators()
	local cluster = _G.MinimapCluster
	if not cluster then
		return
	end

	-- Difficulty flag, top right of the map.
	local difficulty = cluster.InstanceDifficulty
	if difficulty then
		local function PinDifficulty()
			if difficulty.__kkuiAnchoring then
				return
			end
			difficulty.__kkuiAnchoring = true
			difficulty:ClearAllPoints()
			difficulty:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 2, 2)
			difficulty.__kkuiAnchoring = false
		end
		PinDifficulty()
		hooksecurefunc(difficulty, "SetPoint", PinDifficulty)
		self.PinDifficulty = PinDifficulty
	end

	-- Mail (and the crafting order indicator beside it) sit just above the clock,
	-- falling back to the bottom of the map when the clock is switched off.
	local indicator = cluster.IndicatorFrame
	if indicator then
		local function PinIndicator()
			if indicator.__kkuiAnchoring then
				return
			end
			indicator.__kkuiAnchoring = true
			indicator:ClearAllPoints()
			local clock = Module.clock
			if clock then
				indicator:SetPoint("BOTTOM", clock, "TOP", 0, 4)
			else
				indicator:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 6)
			end
			indicator.__kkuiAnchoring = false
		end
		PinIndicator()
		hooksecurefunc(indicator, "SetPoint", PinIndicator)
		if _G.MiniMapIndicatorFrame_UpdatePosition then
			hooksecurefunc("MiniMapIndicatorFrame_UpdatePosition", PinIndicator)
		end
		self.PinIndicator = PinIndicator
	end

	-- Both are flipped and re-pointed when the header side changes.
	if cluster.SetHeaderUnderneath then
		hooksecurefunc(cluster, "SetHeaderUnderneath", function()
			if self.PinDifficulty then
				self.PinDifficulty()
			end
			if self.PinIndicator then
				self.PinIndicator()
			end
		end)
	end
end

-- ---------------------------------------------------------------------------
-- Zoom via mouse wheel
-- ---------------------------------------------------------------------------

-- Shared timer that snaps the zoom back out after a spell of no wheel input, so
-- the map does not sit zoomed in forever. Disabled when the delay is 0.
local zoomResetTimer

local function OnMouseWheel(_, delta)
	local zoom = Minimap:GetZoom()
	if delta > 0 then
		if zoom < Minimap:GetZoomLevels() - 1 then
			Minimap:SetZoom(zoom + 1)
		end
	elseif zoom > 0 then
		Minimap:SetZoom(zoom - 1)
	end

	local delay = C.Minimap.ZoomResetDelay or 0
	if delay > 0 then
		if zoomResetTimer then
			zoomResetTimer:Cancel()
		end
		zoomResetTimer = C_Timer.NewTimer(delay, function()
			if Minimap:GetZoom() > 0 then
				Minimap:SetZoom(0)
			end
		end)
	end
end

-- The hybrid minimap (archaeology digsites and the like) draws over the minimap
-- with its own circular canvas, so out of the box it ignores our wheel zoom and
-- keeps a round shape that clashes with our square map. Match it to ours: wheel
-- zoom on the canvas and a square mask. Loaded on demand, so this runs once its
-- addon is present.
function Module:SetupHybridMinimap()
	local hybrid = _G.HybridMinimap
	if not hybrid then
		return
	end
	if hybrid.MapCanvas then
		hybrid.MapCanvas:EnableMouseWheel(true)
		hybrid.MapCanvas:SetScript("OnMouseWheel", OnMouseWheel)
	end
	if C.Minimap.Square and hybrid.CircleMask and hybrid.CircleMask.SetTexture then
		hybrid.CircleMask:SetTexture(C.Media.Textures.White8x8)
	end
end

-- ---------------------------------------------------------------------------
-- Enable
-- ---------------------------------------------------------------------------

function Module:OnEnable()
	if not C.Minimap.Enable then
		return
	end

	local db = C.Minimap
	local size = db.Size

	-- Square mask for a clean bordered look.
	if db.Square and Minimap.SetMaskTexture then
		Minimap:SetMaskTexture(C.Media.Textures.White8x8)
	end

	Minimap:SetSize(size, size)

	-- Position through a mover so it lands where the user put it, defaulting to
	-- the top right corner like the original layout.
	local mover = K.CreateMover(Minimap, "Minimap", "Minimap", { "TOPRIGHT", UIParent, "TOPRIGHT", -4, -4 }, size, size)
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", mover)
	self.mover = mover

	-- Border in the KkthnxUI style, optional.
	if db.ShowBorder ~= false then
		K.CreateBorder(Minimap)
	end

	-- Mouse wheel zoom, the right-click menu is wired up in Tracking.lua.
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", OnMouseWheel)
	if self.SetupClickMenu then
		self:SetupClickMenu()
	end

	-- Fade the map out until you hover it, so it sits quietly when you are not
	-- reading it. A throttled hover check covers the map and its children.
	if db.MouseoverFade then
		local faded = db.FadeAlpha or 0.25
		Minimap:SetAlpha(faded)
		local elapsed = 0
		Minimap:HookScript("OnUpdate", function(self, delta)
			elapsed = elapsed + delta
			if elapsed < 0.1 then
				return
			end
			elapsed = 0
			self:SetAlpha(self:IsMouseOver() and 1 or faded)
		end)
	end

	-- Strip the leftover Blizzard clutter (calendar, clock, zone text, compass).
	HideBlizzardBits()
	TidyLandingButton()
	TidyQueueStatus()

	-- Datatexts, built in Location.lua and Time.lua.
	if self.CreateLocation then
		self:CreateLocation()
	end
	if self.CreateClock then
		self:CreateClock()
	end
	if self.CreateCoords then
		self:CreateCoords()
	end
	if self.CreatePerformance then
		self:CreatePerformance()
	end

	-- After the datatexts, since the mail indicator anchors above the clock.
	self:TidyIndicators()

	-- Corral stray addon minimap buttons into a tidy hover panel.
	if db.CollectButtons and self.CollectButtons then
		self:CollectButtons()
	end

	-- Match the hybrid (digsite) minimap to ours. It is load-on-demand, so style it
	-- now if present, otherwise wait for its addon.
	if C_AddOns and C_AddOns.IsAddOnLoaded("Blizzard_HybridMinimap") then
		self:SetupHybridMinimap()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end

function Module:ADDON_LOADED(_, addon)
	if addon == "Blizzard_HybridMinimap" then
		self:SetupHybridMinimap()
		self:UnregisterEvent("ADDON_LOADED")
	end
end
