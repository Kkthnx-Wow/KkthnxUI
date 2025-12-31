local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Minimap")

-- Sourced: NDui (Siweia)
-- Edited: KkthnxUI (Kkthnx)

-- Lua
local _G = _G
local pairs = pairs
local ipairs = ipairs
local select = select
local type = type

local string_find = string.find
local string_match = string.match
local string_upper = string.upper

local table_insert = table.insert
local table_wipe = table.wipe

-- WoW
local CreateFrame = CreateFrame
local Minimap = Minimap
local PlaySound = PlaySound
local UIParent = UIParent
local UIFrameFadeIn = UIFrameFadeIn
local UIFrameFadeOut = UIFrameFadeOut
local C_Timer_NewTimer = C_Timer and C_Timer.NewTimer

-- Constants
local SOUNDKIT_IG_MAINMENU_OPTION_CHECKBOX_ON = 825
local BIN_WIDTH, BIN_HEIGHT = 220, 30
local ICONS_PER_ROW = 6
local ROW_MULT = ICONS_PER_ROW / 2 - 1
local PENDING_TIME, TIME_THRESHOLD = 5, 12
local AUTO_CLOSE_SECONDS = 6

-- Buttons/frames we never want to collect
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

-- Patterns for "pins"/buttons that shouldn't be moved
local IGNORED_BUTTONS = {
	["GatherMatePin"] = true,
	["HandyNotes.-Pin"] = true,
	["TTMinimapButton"] = true,
}

-- Some addons already provide good-looking square icons
local GOOD_LOOKING_ICON = {
	["Narci_MinimapButton"] = true,
	["ZygorGuidesViewerMapIcon"] = true,
}

-- Textures we strip (fileIDs)
local REMOVED_TEXTURES = {
	[136430] = true,
	[136467] = true,
}

local function IsButtonIgnored(name)
	for pattern in pairs(IGNORED_BUTTONS) do
		if string_match(name, pattern) then
			return true
		end
	end
end

local function GetToggleAnchor(position)
	if position == 1 then
		return "BOTTOMLEFT", -7, -7
	elseif position == 2 then
		return "BOTTOMRIGHT", 7, -7
	elseif position == 3 then
		return "TOPLEFT", -7, 7
	elseif position == 4 then
		return "TOPRIGHT", 7, 7
	end

	-- Default to bottom-left if the config value is invalid
	return "BOTTOMLEFT", -7, -7
end

local function GetBinAnchor(position)
	if position == 1 or position == 2 then
		return "BOTTOMRIGHT", -3, 7
	elseif position == 3 or position == 4 then
		return "BOTTOMRIGHT", -3, -21
	end

	-- Default bin anchor if the config value is invalid
	return "BOTTOMRIGHT", -3, 7
end

function Module:CreateRecycleBin()
	if not C["Minimap"].ShowRecycleBin then
		-- Feature disabled: stop timers and hide frames
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

	-- Reuse existing frames if they were already created
	if _G.RecycleBinFrame then
		_G.RecycleBinFrame:Show()
	end
	if _G.RecycleBinToggleButton then
		_G.RecycleBinToggleButton:Show()
		return
	end

	local bu = CreateFrame("Button", "RecycleBinToggleButton", Minimap)
	bu:SetAlpha(0.6)
	bu:SetSize(16, 16)
	bu:ClearAllPoints()
	do
		local point, x, y = GetToggleAnchor(C["Minimap"].RecycleBinPosition)
		bu:SetPoint(point, x, y)
	end

	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface\\COMMON\\Indicator-Gray")
	bu:SetHighlightTexture("Interface\\COMMON\\Indicator-Yellow")
	bu:SetPushedTexture("Interface\\COMMON\\Indicator-Green")
	K.AddTooltip(bu, "ANCHOR_LEFT", "Minimap RecycleBin|n|nCollects minimap buttons and makes them accessible through a pop out menu", "white")

	local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	bin:ClearAllPoints()
	do
		local point, x, y = GetBinAnchor(C["Minimap"].RecycleBinPosition)
		bin:SetPoint(point, bu, "BOTTOMLEFT", x, y)
	end
	bin:SetSize(BIN_WIDTH, BIN_HEIGHT)
	bin:Hide()

	local autoCloseTimer
	local currentIndex = 0
	local numMinimapChildren = 0
	local buttons, shownButtons = {}, {}

	local function StopAutoCloseTimer()
		if autoCloseTimer then
			autoCloseTimer:Cancel()
			autoCloseTimer = nil
		end
	end

	local function HideBin()
		bin:Hide()
	end

	local function CloseBin()
		PlaySound(SOUNDKIT_IG_MAINMENU_OPTION_CHECKBOX_ON)
		UIFrameFadeOut(bin, 0.5, bin:GetAlpha(), 0)
		K.Delay(0.5, HideBin)
	end

	local function StartAutoCloseTimer()
		-- Timer API missing on very old clients: skip auto-close
		if not C_Timer_NewTimer then
			return
		end

		if autoCloseTimer then
			autoCloseTimer:Cancel()
		end

		autoCloseTimer = C_Timer_NewTimer(AUTO_CLOSE_SECONDS, function()
			if bin:IsShown() then
				CloseBin()
			end
		end)
	end

	-- Expose cleanup so we can cancel timers immediately when disabling the feature
	bin.Cleanup = function()
		table_wipe(buttons)
		table_wipe(shownButtons)
		numMinimapChildren = 0
		currentIndex = 0
		StopAutoCloseTimer()
	end

	bin:SetScript("OnEnter", StopAutoCloseTimer)
	bin:SetScript("OnLeave", StartAutoCloseTimer)
	bu:SetScript("OnEnter", StopAutoCloseTimer)
	bu:SetScript("OnLeave", StartAutoCloseTimer)

	local function ReskinMinimapButton(child, name)
		-- Remove common border/mask textures and normalize icon texcoords
		for i = 1, child:GetNumRegions() do
			local region = select(i, child:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				local texture = region:GetTexture()

				local shouldRemove = false
				if texture ~= nil then
					-- GetTexture can be a fileID (number) or file path (string)
					if REMOVED_TEXTURES[texture] then
						shouldRemove = true
					elseif type(texture) == "string" then
						if string_find(texture, "Interface\\CharacterFrame") or string_find(texture, "Interface\\Minimap") then
							shouldRemove = true
						end
					end
				end

				if shouldRemove then
					region:SetTexture(nil)
					region:Hide()
				else
					if not region.__ignored then
						region:ClearAllPoints()
						region:SetAllPoints()
					end
					if not GOOD_LOOKING_ICON[name] then
						region:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
					end
				end
			end
		end

		child:SetSize(22, 22)

		-- Avoid creating multiple borders if this is run more than once
		if not child.__kkthnx_recyclebin_border then
			if child.CreateBorder then
				child:CreateBorder()
			end
			child.__kkthnx_recyclebin_border = true
		end

		table_insert(buttons, child)
	end

	local function KillMinimapButtons()
		for _, child in ipairs(buttons) do
			if child and not child.styled then
				child:SetParent(bin)

				if child:HasScript("OnDragStop") then
					child:SetScript("OnDragStop", nil)
				end
				if child:HasScript("OnDragStart") then
					child:SetScript("OnDragStart", nil)
				end

				if child:HasScript("OnClick") then
					child:HookScript("OnClick", CloseBin)
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

				-- Some addons behave oddly on minimap buttons; patch known offenders
				local name = child.GetName and child:GetName()
				if name == "DBMMinimapButton" then
					child:SetScript("OnMouseDown", nil)
					child:SetScript("OnMouseUp", nil)
				elseif name == "BagSync_MinimapButton" then
					child:HookScript("OnMouseUp", CloseBin)
				elseif name == "WIM3MinimapButton" then
					child.SetParent = K.Noop
					child:SetFrameStrata("DIALOG")
					child.SetFrameStrata = K.Noop
				end

				child.styled = true
			end
		end
	end

	local function SortRubbish()
		if #buttons == 0 then
			return
		end

		table_wipe(shownButtons)
		for _, button in ipairs(buttons) do
			-- Some addons create unusual objects here; guard defensively
			if button and button.IsShown and button:IsShown() then
				table_insert(shownButtons, button)
			end
		end

		local numShown = #shownButtons
		local row = (numShown == 0) and 1 or K.Round((numShown + ROW_MULT) / ICONS_PER_ROW)
		bin:SetHeight(row * 37 + 3)

		for index, button in ipairs(shownButtons) do
			button:ClearAllPoints()

			if index == 1 then
				button:SetPoint("BOTTOMRIGHT", bin, -6, 6)
			elseif row == 1 or (row > 1 and ((index - 1) % row) == 0) then
				button:SetPoint("RIGHT", shownButtons[index - row], "LEFT", -6, 0)
			else
				button:SetPoint("BOTTOM", shownButtons[index - 1], "TOP", 0, 6)
			end
		end
	end

	local function CollectRubbish()
		if not C["Minimap"].ShowRecycleBin then
			-- Disabled mid-scan: wipe state and cancel timers
			bin:Cleanup()
			return
		end

		local numChildren = Minimap:GetNumChildren()
		if numChildren ~= numMinimapChildren then
			-- Minimap:GetChildren() returns varargs; pack once to avoid repeated calls
			local children = { Minimap:GetChildren() }
			for i = 1, numChildren do
				local child = children[i]
				local name = child and child.GetName and child:GetName()

				if name and not child.isExamed and not BLACKLIST[name] then
					if (child:IsObjectType("Button") or string_match(string_upper(name), "BUTTON")) and not IsButtonIgnored(name) then
						ReskinMinimapButton(child, name)
					end
					child.isExamed = true
				end
			end

			numMinimapChildren = numChildren
		end

		KillMinimapButtons()

		currentIndex = currentIndex + 1
		if currentIndex < TIME_THRESHOLD then
			K.Delay(PENDING_TIME, CollectRubbish)
		end
	end

	bu:SetScript("OnClick", function()
		if bin:IsShown() then
			StopAutoCloseTimer()
			CloseBin()
		else
			PlaySound(SOUNDKIT_IG_MAINMENU_OPTION_CHECKBOX_ON)
			SortRubbish()
			UIFrameFadeIn(bin, 0.5, bin:GetAlpha(), 1)
			StartAutoCloseTimer()
		end
	end)

	CollectRubbish()
end
