--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Collects minimap buttons into a pop-out "Recycle Bin" to reduce clutter.
-- - Design: Scans Minimap children, reskins buttons, and reparents them to a custom frame.
-- - Events: Scanned periodically via CollectRubbish.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Minimap")

-- PERF: Localize global functions and environment for faster lookups.
local ipairs = _G.ipairs
local pairs = _G.pairs
local select = _G.select
local string_find = _G.string.find
local string_match = _G.string.match
local string_upper = _G.string.upper
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe
local type = _G.type

local _G = _G
local C_Timer_NewTimer = _G.C_Timer and _G.C_Timer.NewTimer
local CreateFrame = _G.CreateFrame
local Minimap = _G.Minimap
local PlaySound = _G.PlaySound
local UIFrameFadeIn = _G.UIFrameFadeIn
local UIFrameFadeOut = _G.UIFrameFadeOut
local UIParent = _G.UIParent

-- Constants
local SOUNDKIT_IG_MAINMENU_OPTION_CHECKBOX_ON = 825
local BIN_WIDTH, BIN_HEIGHT = 220, 30
local ICONS_PER_ROW = 6
local ROW_MULT = ICONS_PER_ROW / 2 - 1
local PENDING_TIME, TIME_THRESHOLD = 5, 12
local AUTO_CLOSE_SECONDS = 6

-- REASON: Buttons/frames we never want to collect to avoid breaking core UI or map functionality.
local BLACKLIST = {
	["BattlefieldMinimap"] = true,
	["FeedbackUIButton"] = true,
	["GameTimeFrame"] = true,
	["GarrisonLandingPageMinimapButton"] = true,
	["MiniMapBattlefieldFrame"] = true,
	["MiniMapLFGFrame"] = true,
	["MinimapBackdrop"] = true,
	["MinimapZoneTextButton"] = true,
	["QueueStatusMinimapButton"] = true,
	["RecycleBinFrame"] = true,
	["RecycleBinToggleButton"] = true,
	["TimeManagerClockButton"] = true,
}

-- REASON: Patterns for "pins"/buttons that shouldn't be moved to the bin as they are part of the map display.
local IGNORED_BUTTONS = {
	["GatherMatePin"] = true,
	["HandyNotes.-Pin"] = true,
	["TTMinimapButton"] = true,
}

-- REASON: Addons that already provide high-quality square icons; we skip standard texcoord adjustments for these.
local GOOD_LOOKING_ICON = {
	["Narci_MinimapButton"] = true,
	["ZygorGuidesViewerMapIcon"] = true,
}

-- REASON: Textures (fileIDs) we strip from collected buttons to achieve a clean look.
local REMOVED_TEXTURES = {
	[136430] = true,
	[136467] = true,
}

local function isButtonIgnored(name)
	for pattern in pairs(IGNORED_BUTTONS) do
		if string_match(name, pattern) then
			return true
		end
	end
end

local toggleAnchors = {
	[1] = { "BOTTOMLEFT", -7, -7 },
	[2] = { "BOTTOMRIGHT", 7, -7 },
	[3] = { "TOPLEFT", -7, 7 },
	[4] = { "TOPRIGHT", 7, 7 },
}

local function getToggleAnchor(position)
	local anchor = toggleAnchors[position] or toggleAnchors[1]
	return unpack(anchor)
end

local binAnchors = {
	[1] = { "BOTTOMRIGHT", -3, 7 },
	[2] = { "BOTTOMRIGHT", -3, 7 },
	[3] = { "BOTTOMRIGHT", -3, -21 },
	[4] = { "BOTTOMRIGHT", -3, -21 },
}

local function getBinAnchor(position)
	local anchor = binAnchors[position] or binAnchors[1]
	return unpack(anchor)
end

function Module:CreateRecycleBin()
	if not C["Minimap"].ShowRecycleBin then
		-- REASON: Feature disabled: safely cancel timers and hide frames to free resources.
		if _G.RecycleBinFrame and _G.RecycleBinFrame.Cleanup then
			_G.RecycleBinFrame:Cleanup()
		end
		if _G.RecycleBinFrame then
			_G.RecycleBinFrame:Hide()
		end
		if _G.RecycleBinToggleButton then
			_G.RecycleBinToggleButton:Hide()
		end
		return
	end

	-- REASON: Reuses existing frames if they were already created during a session toggling.
	if _G.RecycleBinFrame then
		_G.RecycleBinFrame:Show()
	end
	if _G.RecycleBinToggleButton then
		_G.RecycleBinToggleButton:Show()
		return
	end

	local toggleButton = CreateFrame("Button", "RecycleBinToggleButton", Minimap)
	toggleButton:SetAlpha(0.6)
	toggleButton:SetSize(16, 16)
	toggleButton:ClearAllPoints()
	do
		local point, x, y = getToggleAnchor(C["Minimap"].RecycleBinPosition)
		toggleButton:SetPoint(point, x, y)
	end

	toggleButton.Icon = toggleButton:CreateTexture(nil, "ARTWORK")
	toggleButton.Icon:SetAllPoints()
	toggleButton.Icon:SetTexture("Interface\\COMMON\\Indicator-Gray")
	toggleButton:SetHighlightTexture("Interface\\COMMON\\Indicator-Yellow")
	toggleButton:SetPushedTexture("Interface\\COMMON\\Indicator-Green")
	K.AddTooltip(toggleButton, "ANCHOR_LEFT", "Minimap RecycleBin|n|nCollects minimap buttons and makes them accessible through a pop out menu", "white")

	local recycleBinFrame = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	recycleBinFrame:ClearAllPoints()
	do
		local point, x, y = getBinAnchor(C["Minimap"].RecycleBinPosition)
		recycleBinFrame:SetPoint(point, toggleButton, "BOTTOMLEFT", x, y)
	end
	recycleBinFrame:SetSize(BIN_WIDTH, BIN_HEIGHT)
	recycleBinFrame:Hide()

	local autoCloseTimer
	local currentIndex = 0
	local numMinimapChildren = 0
	local binButtons, shownButtons = {}, {}

	local function stopAutoCloseTimer()
		if autoCloseTimer then
			autoCloseTimer:Cancel()
			autoCloseTimer = nil
		end
	end

	local function hideBin()
		recycleBinFrame:Hide()
	end

	local function closeBin()
		PlaySound(SOUNDKIT_IG_MAINMENU_OPTION_CHECKBOX_ON)
		UIFrameFadeOut(recycleBinFrame, 0.5, recycleBinFrame:GetAlpha(), 0)
		K.Delay(0.5, hideBin)
	end

	local function startAutoCloseTimer()
		-- REASON: Guard against older clients missing the C_Timer API to avoid LUA errors.
		if not C_Timer_NewTimer then
			return
		end

		if autoCloseTimer then
			autoCloseTimer:Cancel()
		end

		autoCloseTimer = C_Timer_NewTimer(AUTO_CLOSE_SECONDS, function()
			if recycleBinFrame:IsShown() then
				closeBin()
			end
		end)
	end

	-- REASON: Expose cleanup to facilitate immediate session-level disabling without reload.
	recycleBinFrame.Cleanup = function()
		table_wipe(binButtons)
		table_wipe(shownButtons)
		numMinimapChildren = 0
		currentIndex = 0
		stopAutoCloseTimer()
	end

	recycleBinFrame:SetScript("OnEnter", stopAutoCloseTimer)
	recycleBinFrame:SetScript("OnLeave", startAutoCloseTimer)
	toggleButton:SetScript("OnEnter", stopAutoCloseTimer)
	toggleButton:SetScript("OnLeave", startAutoCloseTimer)

	local function reskinMinimapButton(child, name)
		for i = 1, child:GetNumRegions() do
			local region = select(i, child:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				local texture = region:GetTexture()
				if texture and (REMOVED_TEXTURES[texture] or (type(texture) == "string" and (string_find(texture, "Interface\\CharacterFrame") or string_find(texture, "Interface\\Minimap")))) then
					region:SetTexture(nil)
					region:Hide()
				else
					if not region.__ignored then
						region:ClearAllPoints()
						region:SetAllPoints()
					end
					if not GOOD_LOOKING_ICON[name] then
						region:SetTexCoord(unpack(K.TexCoords))
					end
				end
			end
		end

		child:SetSize(22, 22)

		-- REASON: Defensive check to avoid creating redundant borders during multiple scans.
		if not child.__kkthnx_recyclebin_border then
			if child.CreateBorder then
				child:CreateBorder()
			end
			child.__kkthnx_recyclebin_border = true
		end

		table_insert(binButtons, child)
	end

	local function killMinimapButtons()
		for _, child in ipairs(binButtons) do
			if child and not child.styled then
				child:SetParent(recycleBinFrame)

				-- REASON: Strip dragging scripts to prevent the bin from becoming unusable or cluttered.
				if child:HasScript("OnDragStop") then
					child:SetScript("OnDragStop", nil)
				end
				if child:HasScript("OnDragStart") then
					child:SetScript("OnDragStart", nil)
				end

				if child:HasScript("OnClick") then
					child:HookScript("OnClick", closeBin)
				end

				if child:IsObjectType("Button") then
					child:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
					local hl = child:GetHighlightTexture()
					if hl then
						hl:SetAllPoints(child)
					end
				elseif child:IsObjectType("Frame") then
					child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
					child.highlight:SetPoint("TOPLEFT", child, "TOPLEFT", 2, -2)
					child.highlight:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", -2, 2)
					child.highlight:SetColorTexture(1, 1, 1, 0.25)
				end

				-- REASON: Handle specific addons that behave non-standardly when their parent is changed.
				local name = child.GetName and child:GetName()
				if name == "DBMMinimapButton" then
					child:SetScript("OnMouseDown", nil)
					child:SetScript("OnMouseUp", nil)
				elseif name == "BagSync_MinimapButton" then
					child:HookScript("OnMouseUp", closeBin)
				elseif name == "WIM3MinimapButton" then
					child.SetParent = K.Noop
					child:SetFrameStrata("DIALOG")
					child.SetFrameStrata = K.Noop
				end

				child.styled = true
			end
		end
	end

	local function sortRubbish()
		if #binButtons == 0 then
			return
		end

		table_wipe(shownButtons)
		for _, button in ipairs(binButtons) do
			-- REASON: Guard defensively as some addons create unusual/uninitialized objects.
			if button and button.IsShown and button:IsShown() then
				table_insert(shownButtons, button)
			end
		end

		local numShown = #shownButtons
		local row = (numShown == 0) and 1 or K.Round((numShown + ROW_MULT) / ICONS_PER_ROW)
		recycleBinFrame:SetHeight(row * 37 + 3)

		for index, button in ipairs(shownButtons) do
			button:ClearAllPoints()

			if index == 1 then
				button:SetPoint("BOTTOMRIGHT", recycleBinFrame, -6, 6)
			elseif row == 1 or (row > 1 and ((index - 1) % row) == 0) then
				button:SetPoint("RIGHT", shownButtons[index - row], "LEFT", -6, 0)
			else
				button:SetPoint("BOTTOM", shownButtons[index - 1], "TOP", 0, 6)
			end
		end
	end

	local function collectRubbish()
		if not C["Minimap"].ShowRecycleBin then
			-- REASON: Wipe state if the feature is disabled during a collection pass.
			recycleBinFrame:Cleanup()
			return
		end

		local numChildren = Minimap:GetNumChildren()
		if numChildren ~= numMinimapChildren then
			-- REASON: Pack children once to avoid multiple costly GetChildren calls.
			local children = { Minimap:GetChildren() }
			for i = 1, numChildren do
				local child = children[i]
				local name = child and child.GetName and child:GetName()

				if name and not child.isExamed and not BLACKLIST[name] then
					if (child:IsObjectType("Button") or string_find(string_upper(name), "BUTTON")) and not isButtonIgnored(name) then
						reskinMinimapButton(child, name)
					end
					child.isExamed = true
				end
			end

			numMinimapChildren = numChildren
		end

		killMinimapButtons()

		-- REASON: Throttles scanning to ensure we don't waste CPU after the initial login flurry.
		currentIndex = currentIndex + 1
		if currentIndex < TIME_THRESHOLD then
			K.Delay(PENDING_TIME, collectRubbish)
		end
	end

	toggleButton:SetScript("OnClick", function()
		if recycleBinFrame:IsShown() then
			stopAutoCloseTimer()
			closeBin()
		else
			PlaySound(SOUNDKIT_IG_MAINMENU_OPTION_CHECKBOX_ON)
			sortRubbish()
			UIFrameFadeIn(recycleBinFrame, 0.5, recycleBinFrame:GetAlpha(), 1)
			startAutoCloseTimer()
		end
	end)

	collectRubbish()
end
