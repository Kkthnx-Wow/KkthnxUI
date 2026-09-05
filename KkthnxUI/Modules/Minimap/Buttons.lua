--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Minimap/Buttons.lua
	Purpose:
		Gather the stray addon buttons that pile up around the minimap into one
		bordered grid, opened by a small dot in the corner. Buttons are matched by shape
		(a small frame or button parented to the minimap) with a blacklist for the
		Blizzard pieces we keep in place.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Minimap")

local _G = _G
local GameTooltip = _G.GameTooltip
local ceil = math.ceil
local ipairs = ipairs
local select = select
local strfind = string.find
local strupper = string.upper

local Minimap = _G.Minimap

-- Frames that live near the minimap but are ours to keep, not collect.
local IGNORE = {
	MiniMapTracking = true,
	MinimapZoomIn = true,
	MinimapZoomOut = true,
	MinimapNorthTag = true,
	GameTimeFrame = true,
	MinimapCluster = true,
	MinimapBackdrop = true,
	QueueStatusButton = true,
	QueueStatusMinimapButton = true,
	MiniMapMailFrame = true,
	MinimapZoneTextButton = true,
	TimeManagerClockButton = true,
	ExpansionLandingPageMinimapButton = true,
	GarrisonLandingPageMinimapButton = true,
	MiniMapLFGFrame = true,
	BattlefieldMinimap = true,
}

-- Map-pin providers that parent icons to the minimap but must never be collected
-- (HandyNotes, GatherMate, TomTom and friends). Matched as a substring.
local IGNORE_PATTERNS = {
	"HandyNotes",
	"GatherMate",
	"Pin",
	"Cluster",
	"TomTom",
	"Poi",
}

-- Blizzard icon border / mask textures that should be stripped so a collected
-- button reads as a clean square. Matched by file id or path fragment.
local STRIP_TEXTURES = {
	[136430] = true, -- MiniMap-TrackingBorder
	[136467] = true, -- old minimap button border
}

-- Crop a texture, coping with the 12.0 masked icons (HUD atlases, addons that
-- round their own button). A masked texture rejects SetTexCoord, so strip any
-- mask textures first and then crop, with a pcall as the final guard for the
-- SetMask file path case, which has no getter to detect.
local function SafeSetTexCoord(texture, ...)
	if not (texture and texture.SetTexCoord) then
		return
	end
	if texture.GetNumMaskTextures and texture.GetMaskTexture and texture.RemoveMaskTexture then
		for i = texture:GetNumMaskTextures(), 1, -1 do
			local mask = texture:GetMaskTexture(i)
			if mask then
				texture:RemoveMaskTexture(mask)
			end
		end
	end
	pcall(texture.SetTexCoord, texture, ...)
end

local function IsPin(name)
	for _, pattern in ipairs(IGNORE_PATTERNS) do
		if strfind(name, pattern) then
			return true
		end
	end
	return false
end

-- A button looks collectible if it is a Button (or a frame Blizzard/addons named
-- like one) sized like an icon and is not one of ours or a map pin.
local function IsCollectible(child)
	local name = child:GetName()
	if not name or IGNORE[name] then
		return false
	end
	-- Never collect our own frames (the tab and panel), which would create a
	-- circular anchor since the panel is anchored to the tab.
	if strfind(name, "^KKUI") or IsPin(name) then
		return false
	end
	local objType = child:GetObjectType()
	if objType ~= "Button" and not (objType == "Frame" and strfind(strupper(name), "BUTTON")) then
		return false
	end
	local width = child:GetWidth()
	if not width or width < 15 or width > 40 then
		return false
	end
	return true
end

-- Square and stretch every texture region of `frame` to fill `button`, so an
-- icon fills its slot no matter where or how big it started. Known border and
-- background art is stripped instead of kept.
local function SkinRegions(frame, button)
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region and region.GetObjectType and region:GetObjectType() == "Texture" then
			local texture = region:GetTexture()
			if texture and (STRIP_TEXTURES[texture] or (type(texture) == "string" and (strfind(texture, "Border") or strfind(texture, "TrackingBorder") or strfind(texture, "Background")))) then
				region:SetTexture(nil)
				region:Hide()
			else
				-- Fill the slot, then crop the icon's own round frame off.
				region:ClearAllPoints()
				region:SetAllPoints(button)
				SafeSetTexCoord(region, 0.08, 0.92, 0.08, 0.92)
			end
		end
	end
end

-- Strip Blizzard's circular border/mask art and crop the icon square so the
-- button matches our flat look. Runs once per button.
local function KillButtonTextures(child)
	if child.__kkuiStripped then
		return
	end
	child.__kkuiStripped = true

	SkinRegions(child, child)

	-- Some addons draw their icon on a child frame rather than a direct region,
	-- so walk one level down too, anchoring those icons to the button as well.
	for i = 1, child:GetNumChildren() do
		local sub = select(i, child:GetChildren())
		if sub and sub.GetNumRegions then
			SkinRegions(sub, child)
		end
	end

	-- Some buttons re-assert a drag script that yanks them back to the map edge.
	if child.SetScript then
		if child:HasScript("OnDragStart") then
			child:SetScript("OnDragStart", nil)
		end
		if child:HasScript("OnDragStop") then
			child:SetScript("OnDragStop", nil)
		end
	end
end

function Module:CollectButtons()
	local panel = CreateFrame("Frame", "KKUI_MinimapButtonPanel", Minimap)
	panel:SetFrameStrata("MEDIUM")
	panel:SetFrameLevel(Minimap:GetFrameLevel() + 4)
	K.CreateGradientBackground(panel, 0.92)
	K.CreateBorder(panel)
	panel:Hide()
	self.buttonPanel = panel

	local collected = {}
	local positioning = false
	-- Forward declared: the toggle dot, created below but driven from Layout so it
	-- can hide itself when there is nothing to collect.
	local tab

	-- The corner the dot lives in decides which way everything grows. The grid
	-- fills away from the minimap edge: from the top for top corners, the bottom
	-- for bottom corners, and toward the map for the horizontal side, so the first
	-- button always sits nearest the dot.
	local corner = C.Minimap.ButtonCorner or "BOTTOMLEFT"
	local anchorV = strfind(corner, "TOP") and "TOP" or "BOTTOM"
	local anchorH = strfind(corner, "LEFT") and "RIGHT" or "LEFT"
	local buttonAnchor = anchorV .. anchorH

	-- Collected buttons sit in a tidy grid inside the panel: square-cropped icons,
	-- a small even gap, and just enough padding to clear the panel border. No
	-- per-button border, since the panel already frames them and a border on every
	-- icon reads as busy clutter, so the icons stay clean.
	local SIZE = 26
	local GAP = 4
	local PAD = 6
	local PER_ROW = 8

	local function Layout()
		local count = #collected
		-- No point offering a toggle for an empty bin: hide the dot (and any open
		-- panel) until there is at least one button to show.
		if tab then
			tab:SetShown(count > 0)
		end
		if count == 0 then
			panel:Hide()
			panel:SetSize(SIZE + PAD * 2, SIZE + PAD * 2)
			return
		end

		local perRow = count < PER_ROW and count or PER_ROW
		local rows = ceil(count / perRow)
		panel:SetSize(perRow * SIZE + (perRow - 1) * GAP + PAD * 2, rows * SIZE + (rows - 1) * GAP + PAD * 2)

		positioning = true
		for i, button in ipairs(collected) do
			local col = (i - 1) % perRow
			local row = ceil(i / perRow) - 1
			button:SetParent(panel)
			-- Lift the button above the panel's own background and border textures,
			-- which live on the panel frame, so a low-level addon button is not drawn
			-- behind them.
			button:SetFrameLevel(panel:GetFrameLevel() + 2)
			button:SetSize(SIZE, SIZE)
			button:ClearAllPoints()
			-- Offsets flow from the anchored corner: positive toward the opposite
			-- edge, negative when the anchor is on the far side.
			local dx = PAD + col * (SIZE + GAP)
			local dy = PAD + row * (SIZE + GAP)
			button:SetPoint(buttonAnchor, panel, buttonAnchor, anchorH == "LEFT" and dx or -dx, anchorV == "BOTTOM" and dy or -dy)
			button:Show()
			KillButtonTextures(button)
		end
		positioning = false
	end
	self.RelayoutMinimapButtons = Layout

	local function Scan()
		for _, child in ipairs({ Minimap:GetChildren() }) do
			if IsCollectible(child) and not child.__collected then
				child.__collected = true
				collected[#collected + 1] = child
				-- Some library buttons yank themselves back to the minimap edge on
				-- their own events. Re-assert our layout whenever one is moved.
				hooksecurefunc(child, "SetPoint", function()
					if not positioning and not child.__relayoutQueued then
						child.__relayoutQueued = true
						C_Timer.After(0, function()
							child.__relayoutQueued = false
							Layout()
						end)
					end
				end)
			end
		end
		Layout()
	end

	-- A small gold dot tucked into the chosen minimap corner. Click it to open or
	-- close the button grid.
	tab = CreateFrame("Button", "KKUI_MinimapButtonTab", Minimap)
	tab:SetSize(12, 12)
	tab:SetPoint(corner, Minimap, corner, 0, 0)
	tab:SetFrameLevel(Minimap:GetFrameLevel() + 6)
	local icon = tab:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetAtlas("LevelUp-Dot-Gold")
	icon:SetAlpha(0.7)
	self.buttonTab = tab

	-- The grid flies out horizontally away from the minimap: left from a left
	-- corner, right from a right one, aligned to the dot's top or bottom edge.
	local flyLeft = strfind(corner, "LEFT")
	panel:ClearAllPoints()
	panel:SetPoint(anchorV .. (flyLeft and "RIGHT" or "LEFT"), tab, anchorV .. (flyLeft and "LEFT" or "RIGHT"), flyLeft and -4 or 4, 0)

	local function ClosePanel()
		panel:Hide()
		icon:SetAlpha(0.7)
	end
	local function OpenPanel()
		panel.__idle = 0
		panel:Show()
		icon:SetAlpha(1)
	end

	-- Click to toggle. The panel also closes itself once the cursor has been away
	-- from both the dot and the grid for a moment, so it never lingers over the map.
	local IDLE_CLOSE = 1.5
	tab:SetScript("OnClick", function()
		if panel:IsShown() then
			ClosePanel()
		else
			OpenPanel()
		end
	end)
	panel:SetScript("OnUpdate", function(self, elapsed)
		if tab:IsMouseOver() or self:IsMouseOver() then
			self.__idle = 0
		else
			self.__idle = (self.__idle or 0) + elapsed
			if self.__idle > IDLE_CLOSE then
				ClosePanel()
			end
		end
	end)

	-- Tooltip on the dot, anchored away from the minimap edge it sits against so it
	-- never spills off screen from a right-hand corner.
	local tipAnchor = strfind(corner, "LEFT") and "ANCHOR_RIGHT" or "ANCHOR_LEFT"
	tab:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, tipAnchor)
		GameTooltip:AddLine(L["Minimap Buttons"])
		GameTooltip:AddLine(L["Click to open or close the collected addon buttons."], K.Colors.muted[1], K.Colors.muted[2], K.Colors.muted[3], true)
		GameTooltip:Show()
	end)
	tab:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- Scan now and again shortly after login, since some addons add their button
	-- late during the load sequence.
	Scan()
	C_Timer.After(5, Scan)
end
