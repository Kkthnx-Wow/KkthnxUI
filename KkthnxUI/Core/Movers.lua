--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Universal UI element movement and positioning system.
-- - Design: Persistent anchor tracking, manual trimming, and Blizzard Edit Mode suppression.
-- - Events: PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Mover")

-- PERF: Cache Lua globals for speed and consistency.
local _G = _G
local ipairs, pcall, tostring, type, unpack = ipairs, pcall, tostring, type, unpack
local table_insert = table.insert
local table_wipe = table.wipe
local math_rad = math.rad

local CANCEL = CANCEL
local CreateFrame = CreateFrame
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local LOCK = LOCK
local NONE = NONE
local OKAY = OKAY
local PlaySound = PlaySound
local RESET = RESET
local SOUNDKIT = SOUNDKIT
local StaticPopup_Show = StaticPopup_Show
local UIErrorsFrame = UIErrorsFrame
local UIParent = UIParent

-- ---------------------------------------------------------------------------
-- FRAME MOVER SYSTEM
-- ---------------------------------------------------------------------------

local MoverList = {}
local f
local updater

-- REASON: Main entry point to make any frame moveable. Creates an overlay "mover"
-- that acts as the anchor for the target frame.
function K:Mover(text, value, anchor, width, height)
	-- NOTE: Safety check to ensure K:Mover is called correctly as a method.
	if not self or type(self) ~= "table" then
		return
	end

	local key = "Mover"

	-- NOTE: Use unique naming to facilitate debugging and avoid potential global table overlaps.
	local uniqueName = "KKUI_Mover_" .. tostring(value or "Anon")

	-- SpawnCoreUnitFrames / live settings rebuilds call Mover again with the same key
	-- (PlayerCB, TargetCB, …). Reuse the existing button — CreateFrame with the same
	-- global name would orphan the old one in MoverList and fight over DB saves.
	local existing = _G[uniqueName]
	if existing then
		if width or height then
			existing:SetSize(width or existing:GetWidth(), height or existing:GetHeight())
		end
		if self.ClearAllPoints and self.SetPoint then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", existing)
		end
		return existing
	end

	local mover = CreateFrame("Button", uniqueName, UIParent)
	mover:SetWidth(width or (self.GetWidth and self:GetWidth() or 50))
	mover:SetHeight(height or (self.GetHeight and self:GetHeight() or 50))
	mover:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 38 / 255, 125 / 255, 206 / 255, 80 / 255 })
	mover:Hide()

	mover.text = K.CreateFontString(mover, 12, text, "")
	mover.text:SetWordWrap(true)

	-- REASON: Load saved position from DB if it exists, otherwise use the hardcoded default.
	if not KkthnxUIDB.Variables[K.Realm][K.Name][key][value] then
		mover:SetPoint(unpack(anchor))
	else
		mover:SetPoint(unpack(KkthnxUIDB.Variables[K.Realm][K.Name][key][value]))
	end

	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:SetFrameStrata("HIGH")
	mover:RegisterForDrag("LeftButton")
	mover.__key = key
	mover.__value = value
	mover.__anchor = anchor
	mover:SetScript("OnEnter", Module.Mover_OnEnter)
	mover:SetScript("OnLeave", Module.Mover_OnLeave)
	mover:SetScript("OnDragStart", Module.Mover_OnDragStart)
	mover:SetScript("OnDragStop", Module.Mover_OnDragStop)
	mover:SetScript("OnMouseUp", Module.Mover_OnClick)

	table_insert(MoverList, mover)

	-- WARNING: Ensure the target frame supports standard positioning methods to avoid script errors.
	if self.ClearAllPoints and self.SetPoint then
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", mover)
	else
		error("K:Mover: 'self' does not have valid frame methods (ClearAllPoints, SetPoint).")
	end

	return mover
end

-- ---------------------------------------------------------------------------
-- POINT CALCULATION & TRIMMING
-- ---------------------------------------------------------------------------

-- REASON: Calculates the nearest screen quadrant to determine the best anchor point.
-- This ensures movers remain relatively positioned during resolution or scale changes.
function Module:CalculateMoverPoints(mover, trimX, trimY)
	local screenWidth = K.Round(UIParent:GetRight() or 0)
	local screenHeight = K.Round(UIParent:GetTop() or 0)
	local screenCenter = K.Round(UIParent:GetCenter() or 0)
	local x, y = mover:GetCenter()

	-- NOTE: Handle nil coordinates defensively if frame state is invalid.
	if not x or not y then
		return 0, 0, "CENTER"
	end

	local LEFT = screenWidth / 3
	local RIGHT = screenWidth * 2 / 3
	local TOP = screenHeight / 2
	local point

	if y >= TOP then
		point = "TOP"
		y = -(screenHeight - mover:GetTop())
	else
		point = "BOTTOM"
		y = mover:GetBottom()
	end

	if x >= RIGHT then
		point = point .. "RIGHT"
		x = mover:GetRight() - screenWidth
	elseif x <= LEFT then
		point = point .. "LEFT"
		x = mover:GetLeft()
	else
		x = x - screenCenter
	end

	x = x + (trimX or 0)
	y = y + (trimY or 0)
	x, y = K.Round(x), K.Round(y)

	return x, y, point
end

-- NOTE: Updates the coordinate display in the Mover Console UI.
function Module:UpdateTrimFrame()
	if not f then
		return
	end

	local x, y = Module:CalculateMoverPoints(self)
	f.__x:SetText(x)
	f.__y:SetText(y)
	f.__x.__current = x
	f.__y.__current = y
	f.__trimText:SetText(self.text:GetText())
end

-- REASON: Applies manual coordinate fine-tuning (trimming) and saves immediately to DB.
function Module:DoTrim(trimX, trimY)
	local mover = updater.__owner
	if mover then
		local x, y, point = Module:CalculateMoverPoints(mover, trimX, trimY)
		f.__x:SetText(x)
		f.__y:SetText(y)
		f.__x.__current = x
		f.__y.__current = y
		mover:ClearAllPoints()
		mover:SetPoint(point, UIParent, point, x, y)
		KkthnxUIDB.Variables[K.Realm][K.Name][mover.__key][mover.__value] = { point, "UIParent", point, x, y }
	end
end

-- ---------------------------------------------------------------------------
-- MOVER EVENT HANDLERS
-- ---------------------------------------------------------------------------

function Module:Mover_OnClick(btn)
	-- REASON: Shift+RightClick provides a quick toggle for visibility on standard movers.
	if IsShiftKeyDown() and btn == "RightButton" then
		self:Hide()
	-- REASON: Ctrl+RightClick restores the hardcoded default position for the specific element.
	elseif IsControlKeyDown() and btn == "RightButton" then
		self:ClearAllPoints()
		self:SetPoint(unpack(self.__anchor))
		KkthnxUIDB.Variables[K.Realm][K.Name][self.__key][self.__value] = nil
	end

	updater.__owner = self
	Module.UpdateTrimFrame(self)
end

function Module:Mover_OnEnter()
	self.KKUI_Background:SetVertexColor(K.r, K.g, K.b, 0.8)
	self.text:SetTextColor(1, 0.8, 0)
end

function Module:Mover_OnLeave()
	self.KKUI_Background:SetVertexColor(38 / 255, 125 / 255, 206 / 255, 80 / 255)
	self.text:SetTextColor(1, 1, 1)
end

function Module:Mover_OnDragStart()
	self:StartMoving()
	Module.UpdateTrimFrame(self)
	updater.__owner = self
	updater:Show()
end

function Module:Mover_OnDragStop()
	self:StopMovingOrSizing()
	local orig, _, tar, x, y = self:GetPoint()
	x = K.Round(x)
	y = K.Round(y)

	self:ClearAllPoints()
	self:SetPoint(orig, "UIParent", tar, x, y)
	KkthnxUIDB.Variables[K.Realm][K.Name][self.__key][self.__value] = { orig, "UIParent", tar, x, y }
	Module.UpdateTrimFrame(self)
	updater:Hide()
end

-- ---------------------------------------------------------------------------
-- LOCK & UNLOCK LOGIC
-- ---------------------------------------------------------------------------

function Module:UnlockElements()
	-- PERF: Use ipairs for array iteration.
	for i = 1, #MoverList do
		local mover = MoverList[i]
		if not mover:IsShown() and not mover.isDisable then
			mover:Show()
		end
	end

	f:Show()
end

function Module:LockElements()
	-- PERF: Use ipairs for array iteration.
	for i = 1, #MoverList do
		local mover = MoverList[i]
		mover:Hide()
	end

	f:Hide()
	-- NOTE: Ensure related systems are also locked and grid overlays are removed.
	_G.SlashCmdList["KKUI_TOGGLEGRID"]("1")
end

-- REASON: Resetting all mover logic requires a full UI reload to re-initialize original positions.
_G.StaticPopupDialogs["RESET_MOVER"] = {
	text = "Are you sure to reset frames position?",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		table_wipe(KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"])
		_G.ReloadUI()
	end,
}

-- ---------------------------------------------------------------------------
-- MOVER CONSOLE UI
-- ---------------------------------------------------------------------------

-- REASON: Creates the on-screen control panel for managing anchors and fine-tuning positions.
-- Layout uses extra padding so KKUI CreateBorder seams don't collide.
local function CreateConsole()
	if f then
		return
	end

	local PANEL_W = 220
	local BTN_W, BTN_H, BTN_GAP = 100, 24, 6
	local BTN_ROW_W = BTN_W * 2 + BTN_GAP -- Lock + Grids
	local SIDE_PAD = (PANEL_W - BTN_ROW_W) / 2 -- keep both rows flush to the same left edge

	f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint("TOP", 0, -150)
	f:SetSize(PANEL_W, 96)
	f:SetFrameStrata("DIALOG")
	f:SetFrameLevel(200)
	-- Opaque fill — default ColorBackdrop is 0.9 alpha and HIGH-strata movers bleed through.
	f:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 0.06, 0.06, 0.06, 1 })

	f.text = K.CreateFontString(f, 13, K.Title .. " Movers Config", "", "system", "TOP", 0, -10)
	f.text:SetWordWrap(false)

	-- Row 1: Lock | Grids   Row 2: Reset (same outer width as the pair above)
	local bu, text = {}, { LOCK, "Grids", RESET }
	for i = 1, 3 do
		bu[i] = CreateFrame("Button", nil, f)
		bu[i]:SetSize(i == 3 and BTN_ROW_W or BTN_W, BTN_H)
		bu[i]:SkinButton()

		bu[i].text = bu[i]:CreateFontString(nil, "OVERLAY")
		bu[i].text:SetPoint("CENTER")
		bu[i].text:SetFontObject(K.UIFont)
		bu[i].text:SetText(text[i])
		bu[i].text:SetWordWrap(false)

		if i == 1 then
			bu[i]:SetPoint("BOTTOMLEFT", SIDE_PAD, 34)
		elseif i == 2 then
			bu[i]:SetPoint("LEFT", bu[1], "RIGHT", BTN_GAP, 0)
		else
			bu[i]:SetPoint("TOPLEFT", bu[1], "BOTTOMLEFT", 0, -BTN_GAP)
		end
	end

	bu[1]:SetScript("OnClick", Module.LockElements)

	bu[2]:SetScript("OnClick", function()
		_G.SlashCmdList["KKUI_TOGGLEGRID"]("64")
	end)

	bu[3]:SetScript("OnClick", function()
		StaticPopup_Show("RESET_MOVER")
	end)

	-- NOTE: Use the mover frame utility to make the console window itself draggable.
	local header = CreateFrame("Frame", nil, f)
	header:SetSize(PANEL_W, 28)
	header:SetPoint("TOP")
	K.CreateMoverFrame(header, f)

	local tips = K.InfoColor .. "|nCTRL + " .. L["Right Click"] .. K.SystemColor .. " = Reset Mover" .. K.InfoColor .. "|nSHIFT + " .. L["Right Click"] .. K.SystemColor .. " = Hide Panel"
	header.title = "Mover Tips"
	K.AddTooltip(header, "ANCHOR_TOP", tips)

	local tex = header:CreateTexture()
	tex:SetSize(24, 24)
	tex:SetPoint("TOPRIGHT", -2, -2)
	tex:SetTexture("Interface\\Common\\Help-i")

	-- ---------------------------------------------------------------------------
	-- TRIMMING CONTROLS
	-- ---------------------------------------------------------------------------

	local frame = CreateFrame("Frame", nil, f)
	frame:SetSize(PANEL_W, 88)
	frame:SetPoint("TOP", f, "BOTTOM", 0, -4)
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(200)
	frame:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 0.06, 0.06, 0.06, 1 })
	f.__trimText = K.CreateFontString(frame, 12, NONE, "", "system", "BOTTOM", 0, 8)

	local function CreateCoordBox(parent, label, anchor, x, y)
		local box = CreateFrame("EditBox", nil, parent)
		box:SetSize(60, 20)
		box:SetAutoFocus(false)
		box:SetTextInsets(5, 5, 0, 0)
		box:SetFontObject(K.UIFont)
		box:CreateBorder()
		box:SetJustifyH("CENTER")
		box:SetScript("OnEscapePressed", box.ClearFocus)
		box:SetScript("OnEnterPressed", box.ClearFocus)
		box:SetPoint(anchor, parent, "TOPLEFT", x, y)

		-- Sibling on the trim frame, center-aligned to the box — not parented to the EditBox
		-- (EditBox font metrics sit high and make "X:"/"Y:" look floated).
		local fs = K.CreateFontString(parent, 13, label, "", "system")
		fs:ClearAllPoints()
		fs:SetPoint("RIGHT", box, "LEFT", -6, 0)

		box.__current = 0
		return box
	end

	local xBox = CreateCoordBox(frame, "X:", "TOPLEFT", 36, -12)
	xBox:HookScript("OnEnterPressed", function(self)
		local value = tonumber(self:GetText())
		if value then
			local diff = value - self.__current
			self.__current = value
			Module:DoTrim(diff)
		end
	end)
	f.__x = xBox

	local yBox = CreateCoordBox(frame, "Y:", "TOPLEFT", 36, -38)
	yBox:HookScript("OnEnterPressed", function(self)
		local value = tonumber(self:GetText())
		if value then
			local diff = value - self.__current
			self.__current = value
			Module:DoTrim(nil, diff)
		end
	end)
	f.__y = yBox

	-- D-pad: own pad frame so borders get real gaps (SkinButton edges collide under ~4px).
	local pad = CreateFrame("Frame", nil, frame)
	pad:SetSize(76, 60)
	pad:SetPoint("TOPRIGHT", -10, -8)

	local arrows = {}
	local arrowLayout = {
		[1] = { degree = 180, offset = -1, point = "LEFT", rel = "LEFT", x = 0, y = 0 }, -- left
		[2] = { degree = 0, offset = 1, point = "RIGHT", rel = "RIGHT", x = 0, y = 0 }, -- right
		[3] = { degree = 90, offset = 1, point = "TOP", rel = "TOP", x = 0, y = 0 }, -- up
		[4] = { degree = -90, offset = -1, point = "BOTTOM", rel = "BOTTOM", x = 0, y = 0 }, -- down
	}
	local function arrowOnClick(self)
		local modKey = IsModifierKeyDown()
		if self.__index < 3 then
			Module:DoTrim(self.__offset * (modKey and 10 or 1))
		else
			Module:DoTrim(nil, self.__offset * (modKey and 10 or 1))
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end

	for i = 1, 4 do
		local layout = arrowLayout[i]
		arrows[i] = CreateFrame("Button", nil, pad)
		arrows[i]:SetSize(18, 18)
		arrows[i]:SkinButton()
		arrows[i]:SetPoint(layout.point, pad, layout.rel, layout.x, layout.y)

		arrows[i].Icon = arrows[i]:CreateTexture(nil, "ARTWORK")
		arrows[i].Icon:SetTexture("Interface\\OPTIONSFRAME\\VoiceChat-Play")
		arrows[i].Icon:SetPoint("TOPLEFT", 2, -2)
		arrows[i].Icon:SetPoint("BOTTOMRIGHT", -2, 2)
		arrows[i].Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		arrows[i].Icon:SetRotation(math_rad(layout.degree))

		arrows[i].__index = i
		arrows[i].__offset = layout.offset
		arrows[i]:SetScript("OnClick", arrowOnClick)
	end

	-- WARNING: Force elements to lock if combat begins to avoid frame movement during protected state.
	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				Module:LockElements()
				K:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			Module:UnlockElements()
			K:UnregisterEvent(event, showLater)
		end
	end
	K:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)
end

-- ---------------------------------------------------------------------------
-- SLASH COMMAND REGISTRY
-- ---------------------------------------------------------------------------

_G.SlashCmdList["KKUI_MOVEUI"] = function()
	-- WARNING: UI movement is restricted in combat to prevent protected UI taint.
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT)
		return
	end
	CreateConsole()
	Module:UnlockElements()
end
_G.SLASH_KKUI_MOVEUI1 = "/moveui"
_G.SLASH_KKUI_MOVEUI2 = "/mui"
_G.SLASH_KKUI_MOVEUI3 = "/mm"
_G.SLASH_KKUI_MOVEUI4 = "/mmm"

_G.SlashCmdList["KKUI_LOCKUI"] = function()
	CreateConsole()
	Module:LockElements()
end
_G.SLASH_KKUI_LOCKUI1 = "/lockui"
_G.SLASH_KKUI_LOCKUI2 = "/lui"

-- ---------------------------------------------------------------------------
-- MODULE INITIALIZATION
-- ---------------------------------------------------------------------------

function Module:OnEnable()
	updater = CreateFrame("Frame")
	updater:Hide()
	updater:SetScript("OnUpdate", function()
		Module.UpdateTrimFrame(updater.__owner)
	end)

	local loadMoverModules = {
		"DisableBlizzardMover",
	}

	-- PERF: Use ipairs for array iteration.
	for _, funcName in ipairs(loadMoverModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- BLIZZARD EDIT MODE SUPPRESSION
-- ---------------------------------------------------------------------------

-- Incident (EditMode, Jul 2026): writing Dummy/Noop onto EditModeManagerFrame.AccountSettings
-- taints that mixin. On enter, EditModeFrameSetup then runs RefreshEncounterEvents /
-- RefreshPartyFrames under KKUI taint → secureexecuterange + secret values explode
-- (EncounterWarningsViewElements, CompactUnitFrame_UpdateHealthColor, HideSystemSelections).
-- Leave DisableBlizzardMover empty for the same reason.
-- CUF burial lives in UnitFrames DisableBlizzardRaidFrames (reparent + OnShow hide).
function Module:DisableBlizzardMover()
	-- Intentionally empty — do not patch AccountSettings.
end
