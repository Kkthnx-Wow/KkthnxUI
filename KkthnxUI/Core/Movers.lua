--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Movers.lua
	Purpose:
		Placement system. Anything the user can drag gets a mover: an invisible
		frame of the same size that the real widget anchors to. Moving the mover
		moves the widget, and only the mover position is saved.

		Dragging is hand rolled rather than StartMoving so we can snap to the
		screen centre, the screen edges, and the edges of other movers, with live
		guides, an optional grid, and live coordinates. Positions are stored per
		profile as an offset from the UIParent centre so they survive resolution
		and scale changes.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

local ipairs = ipairs
local pairs = pairs
local abs = math.abs
local InCombatLockdown = InCombatLockdown
local GetCursorPosition = GetCursorPosition

local movers = {}      -- key -> mover frame
local moverOrder = {}  -- creation order, for deterministic reset
local editing = false
local panel
local gridShown = false

local SNAP = 8 -- snap distance in UIParent pixels

-- A warm, in-world palette so the placement tools read as a natural part of the
-- game rather than a developer overlay: muted gold accents, soft parchment grid,
-- deep bronze highlights.
local THEME = {
	coords = { 0.85, 0.72, 0.42 }, -- warm gold coordinate text
	grid = { 0.72, 0.60, 0.40, 0.10 }, -- soft parchment grid lines
	center = { 0.70, 0.50, 0.25, 0.40 }, -- deeper bronze centre cross
	backdrop = { 0.16, 0.11, 0.06, 0.78 }, -- warm dark mover fill
	flash = { 0.98, 0.82, 0.40, 1 }, -- bright gold hover / locate flash
	rest = { 1, 1, 1, 1 }, -- resting border colour
}

-- ---------------------------------------------------------------------------
-- Storage
-- ---------------------------------------------------------------------------

local function Store()
	KkthnxUIDB.movers = KkthnxUIDB.movers or {}
	local profile = K:GetActiveProfileName() or "Default"
	local store = KkthnxUIDB.movers[profile]
	if not store then
		store = {}
		KkthnxUIDB.movers[profile] = store
	end
	return store
end

local function ApplyOffset(mover, offsetX, offsetY)
	Store()[mover.moverKey] = { offsetX, offsetY }
	mover:ClearAllPoints()
	mover:SetPoint("CENTER", UIParent, "CENTER", offsetX, offsetY)
end

local function RestorePosition(mover)
	mover:ClearAllPoints()
	local saved = Store()[mover.moverKey]
	if saved then
		mover:SetPoint("CENTER", UIParent, "CENTER", saved[1], saved[2])
		return
	end
	local point = mover.moverDefault
	mover:SetPoint(point[1], point[2] or UIParent, point[3] or point[1], point[4] or 0, point[5] or 0)
end

-- Current position as a whole-pixel offset from the UIParent centre.
local function CurrentOffset(mover)
	local cx, cy = mover:GetCenter()
	local ux, uy = UIParent:GetCenter()
	if not cx or not ux then
		return 0, 0
	end
	return K.Round(cx - ux), K.Round(cy - uy)
end

-- ---------------------------------------------------------------------------
-- Guides and grid
-- ---------------------------------------------------------------------------

local guideV, guideH
local function Guides()
	if not guideV then
		-- A dedicated top strata frame so the guide lines float above everything.
		local holder = CreateFrame("Frame", nil, UIParent)
		holder:SetAllPoints(UIParent)
		holder:SetFrameStrata("TOOLTIP")

		guideV = holder:CreateTexture(nil, "OVERLAY")
		guideV:SetColorTexture(0.4, 0.9, 0.4, 0.9)
		guideV:SetWidth(1)
		guideV:Hide()
		guideH = holder:CreateTexture(nil, "OVERLAY")
		guideH:SetColorTexture(0.4, 0.9, 0.4, 0.9)
		guideH:SetHeight(1)
		guideH:Hide()
	end
	return guideV, guideH
end

local grid
local function BuildGrid()
	if grid then
		return grid
	end
	grid = CreateFrame("Frame", "KKUI_MoverGrid", UIParent)
	grid:SetAllPoints(UIParent)
	grid:SetFrameStrata("BACKGROUND")

	local w, h = UIParent:GetWidth(), UIParent:GetHeight()
	local step = 32
	local function Line(vertical, pos)
		local tex = grid:CreateTexture(nil, "BACKGROUND")
		tex:SetColorTexture(THEME.grid[1], THEME.grid[2], THEME.grid[3], THEME.grid[4])
		if vertical then
			tex:SetSize(1, h)
			tex:SetPoint("LEFT", UIParent, "LEFT", pos, 0)
		else
			tex:SetSize(w, 1)
			tex:SetPoint("TOP", UIParent, "TOP", 0, -pos)
		end
	end
	for x = 0, w, step do
		Line(true, x)
	end
	for y = 0, h, step do
		Line(false, y)
	end
	-- Bronze centre cross, a touch stronger than the grid lines.
	local cv = grid:CreateTexture(nil, "ARTWORK")
	cv:SetColorTexture(THEME.center[1], THEME.center[2], THEME.center[3], THEME.center[4])
	cv:SetSize(1, h)
	cv:SetPoint("CENTER")
	local ch = grid:CreateTexture(nil, "ARTWORK")
	ch:SetColorTexture(THEME.center[1], THEME.center[2], THEME.center[3], THEME.center[4])
	ch:SetSize(w, 1)
	ch:SetPoint("CENTER")

	grid:Hide()
	return grid
end

function K.ToggleMoverGrid(show)
	if show == nil then
		show = not gridShown
	end
	gridShown = show
	BuildGrid():SetShown(show)
end

-- ---------------------------------------------------------------------------
-- Snapping
-- ---------------------------------------------------------------------------

-- Collect candidate snap lines in UIParent-centre-offset space. X lines come
-- from the screen centre/edges and every other mover's left/centre/right, Y
-- lines likewise from top/centre/bottom.
local function SnapTargets(self)
	local ux, uy = UIParent:GetCenter()
	local halfW, halfH = UIParent:GetWidth() / 2, UIParent:GetHeight() / 2
	local xs = { 0, -halfW, halfW }
	local ys = { 0, halfH, -halfH }

	for _, mover in ipairs(moverOrder) do
		if mover ~= self and mover:IsShown() then
			local cx, cy = mover:GetCenter()
			if cx then
				local ox, oy = cx - ux, cy - uy
				local hw, hh = mover:GetWidth() / 2, mover:GetHeight() / 2
				xs[#xs + 1] = ox
				xs[#xs + 1] = ox - hw
				xs[#xs + 1] = ox + hw
				ys[#ys + 1] = oy
				ys[#ys + 1] = oy - hh
				ys[#ys + 1] = oy + hh
			end
		end
	end
	return xs, ys
end

-- Snap the mover's nearest edge/centre to a target line within SNAP. Returns the
-- adjusted offset and the snapped screen coordinate for the guide (or nil).
-- The three candidate edges are measured from the original value, and only the
-- single closest match is applied. Mutating value inside the loop would let two
-- in-range edges stack their offsets and overshoot the snap line.
local function SnapAxis(value, half, targets)
	local edges = { value, value - half, value + half }
	local best, bestLine, bestDelta
	for _, edge in ipairs(edges) do
		for _, target in ipairs(targets) do
			local d = abs(edge - target)
			if d <= SNAP and (not best or d < best) then
				best = d
				bestLine = target
				bestDelta = target - edge
			end
		end
	end
	if bestDelta then
		value = value + bestDelta
	end
	return value, bestLine
end

-- ---------------------------------------------------------------------------
-- Dragging
-- ---------------------------------------------------------------------------

local function OnMoveUpdate(self)
	-- GetCursorPosition returns unscaled coordinates, dividing by this frame's own
	-- effective scale converts them to its local space, matching GetCenter and the
	-- SetPoint offsets used below.
	local scale = self:GetEffectiveScale()
	local mx, my = GetCursorPosition()
	local cx = mx / scale - self.__grabX
	local cy = my / scale - self.__grabY
	local ux, uy = UIParent:GetCenter()
	local ox, oy = cx - ux, cy - uy

	local xs, ys = SnapTargets(self)
	local lineX, lineY
	ox, lineX = SnapAxis(ox, self:GetWidth() / 2, xs)
	oy, lineY = SnapAxis(oy, self:GetHeight() / 2, ys)

	self:ClearAllPoints()
	self:SetPoint("CENTER", UIParent, "CENTER", K.Round(ox), K.Round(oy))

	if self.Coords then
		self.Coords:SetFormattedText("%d, %d", K.Round(ox), K.Round(oy))
	end

	-- Position the guide lines at any snapped axis.
	local vg, hg = Guides()
	if lineX then
		vg:ClearAllPoints()
		vg:SetPoint("CENTER", UIParent, "CENTER", lineX, 0)
		vg:SetHeight(UIParent:GetHeight())
		vg:Show()
	else
		vg:Hide()
	end
	if lineY then
		hg:ClearAllPoints()
		hg:SetPoint("CENTER", UIParent, "CENTER", 0, lineY)
		hg:SetWidth(UIParent:GetWidth())
		hg:Show()
	else
		hg:Hide()
	end
end

local function OnDragStart(self)
	if InCombatLockdown() then
		return
	end
	-- Match OnMoveUpdate: convert the cursor into this frame's local space with its
	-- own effective scale so the grab offset stays exact under any UI scale.
	local scale = self:GetEffectiveScale()
	local mx, my = GetCursorPosition()
	local cx, cy = self:GetCenter()
	self.__grabX = mx / scale - cx
	self.__grabY = my / scale - cy
	self:SetScript("OnUpdate", OnMoveUpdate)
end

local function OnDragStop(self)
	self:SetScript("OnUpdate", nil)
	local ox, oy = CurrentOffset(self)
	ApplyOffset(self, ox, oy)
	local vg, hg = Guides()
	vg:Hide()
	hg:Hide()
end

-- Arrow keys nudge the focused mover one pixel at a time.
local nudge = {
	UP = { 0, 1 },
	DOWN = { 0, -1 },
	LEFT = { -1, 0 },
	RIGHT = { 1, 0 },
}

local function OnKeyDown(self, key)
	local step = nudge[key]
	if not step then
		self:SetPropagateKeyboardInput(true)
		return
	end
	self:SetPropagateKeyboardInput(false)
	local ox, oy = CurrentOffset(self)
	ApplyOffset(self, ox + step[1], oy + step[2])
	if self.Coords then
		self.Coords:SetFormattedText("%d, %d", ox + step[1], oy + step[2])
	end
end

-- ---------------------------------------------------------------------------
-- Factory
-- ---------------------------------------------------------------------------

function K.CreateMover(frame, key, label, defaultPoint, width, height, attachPoint)
	if movers[key] then
		return movers[key]
	end

	local mover = CreateFrame("Frame", "KKUI_Mover_" .. key, UIParent)
	mover:SetSize(width or frame:GetWidth(), height or frame:GetHeight())
	mover:SetFrameStrata("HIGH")
	mover:SetClampedToScreen(true)
	mover:EnableMouse(false)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", OnDragStart)
	mover:SetScript("OnDragStop", OnDragStop)
	mover:Hide()

	mover.moverKey = key
	mover.moverDefault = defaultPoint
	mover.moverLabel = label or key

	K.CreateBackdrop(mover, THEME.backdrop)

	local text = mover:CreateFontString(nil, "OVERLAY")
	K.SetFont(text, 11, K.FontOutlineStyle())
	text:SetPoint("CENTER")
	text:SetText(mover.moverLabel)
	text:SetWordWrap(false)
	mover.Label = text

	-- Live coordinates shown along the top edge while dragging, lifted a few
	-- pixels so the text clears the border cleanly.
	local coords = mover:CreateFontString(nil, "OVERLAY")
	K.SetFont(coords, 10, K.FontOutlineStyle())
	coords:SetPoint("BOTTOM", mover, "TOP", 0, 5)
	coords:SetTextColor(THEME.coords[1], THEME.coords[2], THEME.coords[3])
	mover.Coords = coords

	-- A click (mouse up, including right after a drag) opens the nudge popup for
	-- this mover so you can type exact coordinates or step it a pixel at a time.
	mover:SetScript("OnMouseUp", function(self)
		if editing then
			K.OpenMoverPopup(self)
		end
	end)

	mover:SetScript("OnEnter", function(self)
		if not editing then
			return
		end
		self:EnableKeyboard(true)
		self:SetScript("OnKeyDown", OnKeyDown)
		self.KKUI_Border:SetVertexColor(THEME.flash[1], THEME.flash[2], THEME.flash[3], THEME.flash[4])
	end)
	mover:SetScript("OnLeave", function(self)
		self:EnableKeyboard(false)
		self:SetScript("OnKeyDown", nil)
		self.KKUI_Border:SetVertexColor(THEME.rest[1], THEME.rest[2], THEME.rest[3], THEME.rest[4])
	end)

	RestorePosition(mover)

	frame:ClearAllPoints()
	frame:SetPoint(attachPoint or "TOPLEFT", mover, attachPoint or "TOPLEFT", 0, 0)

	movers[key] = mover
	moverOrder[#moverOrder + 1] = mover
	frame.KKUI_Mover = mover

	return mover
end

-- Let a frame be dragged directly with the left mouse button, the way a bag or
-- loot window moves. The drag moves the frame, then on release its mover is
-- slid underneath and the position saved through the normal mover storage, so it
-- survives a reload and still resets from the Move UI panel.
function K.EnableFrameDrag(frame)
	local mover = frame.KKUI_Mover
	if not mover then
		return
	end
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetClampedToScreen(true)
	frame:SetScript("OnDragStart", function(self)
		if InCombatLockdown() or editing then
			return
		end
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local left, top = self:GetLeft(), self:GetTop()
		if not left then
			return
		end
		-- Match the mover to the frame's new corner, then persist by centre offset
		-- and re-anchor the frame to the mover as usual.
		mover:ClearAllPoints()
		mover:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
		local ox, oy = CurrentOffset(mover)
		ApplyOffset(mover, ox, oy)
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", mover, "TOPLEFT", 0, 0)
	end)
end

function K.GetMover(key)
	return movers[key]
end

-- Ordered list of { key, label } for the config GUI mover list.
function K.GetMoverList()
	local list = {}
	for _, mover in ipairs(moverOrder) do
		list[#list + 1] = { key = mover.moverKey, label = mover.moverLabel }
	end
	return list
end

-- Reset a single mover to its default and flash it so it is easy to spot.
function K.ResetMover(key)
	local mover = movers[key]
	if not mover then
		return
	end
	Store()[key] = nil
	RestorePosition(mover)
end

function K.FlashMover(key)
	local mover = movers[key]
	if not mover or not editing then
		return
	end
	mover.KKUI_Border:SetVertexColor(THEME.flash[1], THEME.flash[2], THEME.flash[3], THEME.flash[4])
	C_Timer.After(0.6, function()
		if mover.KKUI_Border then
			mover.KKUI_Border:SetVertexColor(THEME.rest[1], THEME.rest[2], THEME.rest[3], THEME.rest[4])
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Per-mover popup: name, X/Y inputs, and directional nudge pad
-- ---------------------------------------------------------------------------

local popup, popupTarget

local function RefreshPopup()
	if not popup or not popupTarget then
		return
	end
	local ox, oy = CurrentOffset(popupTarget)
	popup.Title:SetText(popupTarget.moverLabel)
	popup.X:SetText(ox)
	popup.Y:SetText(oy)
	popup.X:SetCursorPosition(0)
	popup.Y:SetCursorPosition(0)
end

local function Nudge(dx, dy)
	if not popupTarget then
		return
	end
	local ox, oy = CurrentOffset(popupTarget)
	ApplyOffset(popupTarget, ox + dx, oy + dy)
	RefreshPopup()
end

local function ApplyInputs()
	if not popupTarget then
		return
	end
	local x = tonumber(popup.X:GetText())
	local y = tonumber(popup.Y:GetText())
	if x and y then
		ApplyOffset(popupTarget, K.Round(x), K.Round(y))
	end
	RefreshPopup()
end

local function BuildPopup()
	if popup then
		return popup
	end

	popup = CreateFrame("Frame", "KKUI_MoverPopup", UIParent)
	popup:SetSize(232, 178)
	popup:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 260)
	popup:SetFrameStrata("DIALOG")
	popup:SetMovable(true)
	popup:EnableMouse(true)
	popup:RegisterForDrag("LeftButton")
	popup:SetScript("OnDragStart", popup.StartMoving)
	popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
	K.CreateGradientBackground(popup)
	K.CreateBorder(popup)

	local title = popup:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 12, K.FontOutlineStyle())
	title:SetPoint("TOP", 0, -8)
	title:SetTextColor(THEME.coords[1], THEME.coords[2], THEME.coords[3])
	popup.Title = title

	local close = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	K.SkinCloseButton(close)

	-- A subtle secondary box that groups the nudge pad and the X/Y inputs so they
	-- read as one linked control cluster.
	local group = CreateFrame("Frame", nil, popup)
	group:SetPoint("TOPLEFT", popup, "TOPLEFT", 12, -30)
	group:SetSize(208, 100)
	K.CreateBackground(group, 0.1, 0.08, 0.05, 0.55)
	K.CreateBorder(group)

	-- Directional nudge pad on the left, a clean plus with 2px gaps. Each button
	-- carries a real arrow texture (SquareButtonTextures, tinted gold) rather than
	-- a typed character, so it renders crisply regardless of the active font.
	local ARROW = {
		up = { 0.45312500, 0.64062500, 0.01562500, 0.20312500 },
		down = { 0.45312500, 0.64062500, 0.20312500, 0.01562500 },
		left = { 0.23437500, 0.42187500, 0.01562500, 0.20312500 },
		right = { 0.42187500, 0.23437500, 0.01562500, 0.20312500 },
	}
	local function MakeArrow(dir, x, y, dx, dy)
		local b = CreateFrame("Button", nil, group, "UIPanelButtonTemplate")
		b:SetSize(28, 26)
		b:SetPoint("TOPLEFT", group, "TOPLEFT", x, y)
		K.SkinButton(b)

		local arrow = b:CreateTexture(nil, "OVERLAY")
		arrow:SetTexture("Interface\\BUTTONS\\SquareButtonTextures")
		arrow:SetTexCoord(ARROW[dir][1], ARROW[dir][2], ARROW[dir][3], ARROW[dir][4])
		arrow:SetVertexColor(THEME.coords[1], THEME.coords[2], THEME.coords[3])
		arrow:SetSize(12, 12)
		arrow:SetPoint("CENTER")

		b:SetScript("OnClick", function()
			Nudge(dx, dy)
		end)
		return b
	end

	MakeArrow("up", 40, -8, 0, 1)
	MakeArrow("left", 10, -37, -1, 0)
	MakeArrow("right", 70, -37, 1, 0)
	MakeArrow("down", 40, -66, 0, -1)

	-- X and Y inputs stacked on the right, inside the same group.
	local function MakeInput(label, yOff)
		local text = group:CreateFontString(nil, "OVERLAY")
		K.SetFont(text, 11, K.FontOutlineStyle())
		text:SetPoint("TOPLEFT", group, "TOPLEFT", 112, yOff)
		text:SetText(label)

		local edit = CreateFrame("EditBox", nil, group, "InputBoxTemplate")
		edit:SetSize(74, 22)
		edit:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 4, -3)
		edit:SetAutoFocus(false)
		edit:SetNumeric(false)
		edit:SetScript("OnEnterPressed", function(self)
			self:ClearFocus()
			ApplyInputs()
		end)
		edit:SetScript("OnEscapePressed", edit.ClearFocus)
		K.SkinEditBox(edit)
		return edit
	end

	popup.X = MakeInput("X", -8)
	popup.Y = MakeInput("Y", -52)

	local reset = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
	reset:SetSize(208, 24)
	reset:SetPoint("TOPLEFT", group, "BOTTOMLEFT", 0, -10)
	reset:SetText(L["Reset"])
	K.SkinButton(reset)
	reset:SetScript("OnClick", function()
		if popupTarget then
			K.ResetMover(popupTarget.moverKey)
			RefreshPopup()
		end
	end)

	return popup
end

-- Open the popup targeting a specific mover.
local function OpenPopup(mover)
	popupTarget = mover
	BuildPopup()
	RefreshPopup()
	popup:Show()
end
K.OpenMoverPopup = OpenPopup

-- ---------------------------------------------------------------------------
-- Edit mode
-- ---------------------------------------------------------------------------

local function BuildPanel()
	if panel then
		return panel
	end

	panel = CreateFrame("Frame", "KKUI_MoverPanel", UIParent)
	panel:SetSize(240, 132)
	panel:SetPoint("TOP", UIParent, "TOP", 0, -120)
	panel:SetFrameStrata("DIALOG")
	panel:SetMovable(true)
	panel:EnableMouse(true)
	panel:RegisterForDrag("LeftButton")
	panel:SetScript("OnDragStart", panel.StartMoving)
	panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
	K.CreateGradientBackground(panel)
	K.CreateBorder(panel)

	local title = panel:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 13, K.FontOutlineStyle())
	title:SetPoint("TOP", panel, "TOP", 0, -8)
	title:SetTextColor(THEME.coords[1], THEME.coords[2], THEME.coords[3])
	title:SetText(L["Move UI"])

	local hint = panel:CreateFontString(nil, "OVERLAY")
	K.SetFont(hint, 10, K.FontOutlineStyle())
	hint:SetPoint("TOP", title, "BOTTOM", 0, -6)
	hint:SetWidth(220)
	hint:SetJustifyH("CENTER")
	hint:SetSpacing(3)
	hint:SetText(L["Drag to move, edges snap. Hover and use arrow keys to nudge."])

	-- Left-aligned under the hint block so it lands on the panel's grid line.
	local gridCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
	gridCheck:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 4, -8)
	K.SkinCheckBox(gridCheck)
	gridCheck.Text:SetText(L["Grid"])
	gridCheck.Text:ClearAllPoints()
	gridCheck.Text:SetPoint("LEFT", gridCheck, "RIGHT", 4, 0)
	K.SetFont(gridCheck.Text, 12)
	gridCheck:SetChecked(gridShown)
	gridCheck:SetScript("OnClick", function(self)
		K.ToggleMoverGrid(self:GetChecked() and true or false)
	end)

	local lock = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	lock:SetSize(100, 22)
	lock:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 10)
	lock:SetText(L["Lock"])
	K.SkinButton(lock)
	lock:SetScript("OnClick", function()
		K.ToggleMovers(false)
	end)

	local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	reset:SetSize(100, 22)
	reset:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
	reset:SetText(L["Reset All"])
	K.SkinButton(reset)
	reset:SetScript("OnClick", function()
		K.ResetMovers()
	end)

	return panel
end

function K.ToggleMovers(show)
	if show == nil then
		show = not editing
	end
	if show and InCombatLockdown() then
		K.Print(L["Cannot move frames during combat."])
		return
	end

	editing = show

	for _, mover in ipairs(moverOrder) do
		mover:EnableMouse(show)
		mover:SetShown(show)
		if not show then
			mover:EnableKeyboard(false)
			mover:SetScript("OnKeyDown", nil)
			mover:SetScript("OnUpdate", nil)
		end
	end

	BuildPanel():SetShown(show)
	if not show then
		if gridShown then
			K.ToggleMoverGrid(false)
		end
		if popup then
			popup:Hide()
		end
	end
end

function K.MoversEnabled()
	return editing
end

function K.ResetMovers()
	local store = Store()
	for key in pairs(store) do
		store[key] = nil
	end
	for _, mover in ipairs(moverOrder) do
		RestorePosition(mover)
	end
	K.Print(L["Frame positions reset."])
end

-- Leaving combat is the first safe moment to place anything that was blocked.
local combat = CreateFrame("Frame")
combat:RegisterEvent("PLAYER_REGEN_DISABLED")
combat:SetScript("OnEvent", function()
	if editing then
		K.ToggleMovers(false)
	end
end)
