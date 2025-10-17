local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Minimap")

-- Sourced: NDui (Siweia)
-- Edited: KkthnxUI (Kkthnx)

local string_find = string.find
local string_match = string.match
local string_upper = string.upper
local table_insert = table.insert
local table_wipe = table.wipe

local CreateFrame = CreateFrame
local Minimap = Minimap
local PlaySound = PlaySound
local UIParent = UIParent

function Module:CreateRecycleBin()
	if not C["Minimap"].ShowRecycleBin then
		-- Clean up if feature is disabled
		if _G.RecycleBinFrame then
			_G.RecycleBinFrame:Hide()
		end
		if _G.RecycleBinToggleButton then
			_G.RecycleBinToggleButton:Hide()
		end
		return
	end

	-- Show existing frames if they exist
	if _G.RecycleBinFrame then
		_G.RecycleBinFrame:Show()
	end
	if _G.RecycleBinToggleButton then
		_G.RecycleBinToggleButton:Show()
		return
	end

	local blackList = {
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

	local bu = CreateFrame("Button", "RecycleBinToggleButton", Minimap)
	bu:SetAlpha(0.6)
	bu:SetSize(16, 16)
	bu:ClearAllPoints()
	if C["Minimap"].RecycleBinPosition == 1 then
		bu:SetPoint("BOTTOMLEFT", -7, -7)
	elseif C["Minimap"].RecycleBinPosition == 2 then
		bu:SetPoint("BOTTOMRIGHT", 7, -7)
	elseif C["Minimap"].RecycleBinPosition == 3 then
		bu:SetPoint("TOPLEFT", -7, 7)
	elseif C["Minimap"].RecycleBinPosition == 4 then
		bu:SetPoint("TOPRIGHT", 7, 7)
	else
		bu:SetPoint("BOTTOMLEFT", -7, -7)
	end

	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface\\COMMON\\Indicator-Gray")
	bu:SetHighlightTexture("Interface\\COMMON\\Indicator-Yellow")
	bu:SetPushedTexture("Interface\\COMMON\\Indicator-Green")
	K.AddTooltip(bu, "ANCHOR_LEFT", "Minimap RecycleBin|n|nCollects minimap buttons and makes them accessible through a pop out menu", "white")

	local width, height = 220, 30
	local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	bin:ClearAllPoints()
	if C["Minimap"].RecycleBinPosition == 1 or C["Minimap"].RecycleBinPosition == 2 then
		bin:SetPoint("BOTTOMRIGHT", bu, "BOTTOMLEFT", -3, 7)
	elseif C["Minimap"].RecycleBinPosition == 3 or C["Minimap"].RecycleBinPosition == 4 then
		bin:SetPoint("BOTTOMRIGHT", bu, "BOTTOMLEFT", -3, -21)
	else
		bin:SetPoint("BOTTOMRIGHT", bu, "BOTTOMLEFT", -3, 7)
	end
	bin:SetSize(width, height)
	bin:Hide()

	local function hideBinButton()
		bin:Hide()
	end

	local function clickFunc(force)
		if force == 1 then
			PlaySound(825)
			UIFrameFadeOut(bin, 0.5, bin:GetAlpha(), 0)
			K.Delay(0.5, hideBinButton)
		end
	end

	-- Auto-close functionality
	local autoCloseTimer
	local function StartAutoCloseTimer()
		if autoCloseTimer then
			autoCloseTimer:Cancel()
		end
		autoCloseTimer = C_Timer.NewTimer(6, function()
			if bin:IsShown() then
				clickFunc(1)
			end
		end)
	end

	local function StopAutoCloseTimer()
		if autoCloseTimer then
			autoCloseTimer:Cancel()
			autoCloseTimer = nil
		end
	end

	-- Mouse enter/leave handlers for auto-close
	bin:SetScript("OnEnter", function()
		StopAutoCloseTimer()
	end)

	bin:SetScript("OnLeave", function()
		StartAutoCloseTimer()
	end)

	bu:SetScript("OnEnter", function()
		StopAutoCloseTimer()
	end)

	bu:SetScript("OnLeave", function()
		StartAutoCloseTimer()
	end)

	local ignoredButtons = {
		["GatherMatePin"] = true,
		["HandyNotes.-Pin"] = true,
		["TTMinimapButton"] = true,
	}

	local function isButtonIgnored(name)
		for addonName in pairs(ignoredButtons) do
			if string_match(name, addonName) then
				return true
			end
		end
	end

	local isGoodLookingIcon = {
		["Narci_MinimapButton"] = true,
		["ZygorGuidesViewerMapIcon"] = true,
	}

	local iconsPerRow = 6
	local rowMult = iconsPerRow / 2 - 1
	local currentIndex, pendingTime, timeThreshold = 0, 5, 12
	local buttons, numMinimapChildren = {}, 0
	local removedTextures = {
		[136430] = true,
		[136467] = true,
	}

	local function ReskinMinimapButton(child, name)
		for j = 1, child:GetNumRegions() do
			local region = select(j, child:GetRegions())
			if region:IsObjectType("Texture") then
				local texture = region:GetTexture() or ""
				if removedTextures[texture] or string_find(texture, "Interface\\CharacterFrame") or string_find(texture, "Interface\\Minimap") then
					region:SetTexture(nil)
					region:Hide() -- hide CircleMask
				end
				if not region.__ignored then
					region:ClearAllPoints()
					region:SetAllPoints()
				end
				if not isGoodLookingIcon[name] then
					region:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				end
			end
			child:SetSize(22, 22)
			child:CreateBorder()
		end

		table_insert(buttons, child)
	end

	local function KillMinimapButtons()
		for _, child in pairs(buttons) do
			if not child.styled then
				child:SetParent(bin)
				if child:HasScript("OnDragStop") then
					child:SetScript("OnDragStop", nil)
				end

				if child:HasScript("OnDragStart") then
					child:SetScript("OnDragStart", nil)
				end

				if child:HasScript("OnClick") then
					child:HookScript("OnClick", clickFunc)
				end

				if child:IsObjectType("Button") then
					child:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square") -- prevent nil function
					child:GetHighlightTexture():SetAllPoints(child)
				elseif child:IsObjectType("Frame") then
					child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
					child.highlight:SetPoint("TOPLEFT", child, "TOPLEFT", 2, -2)
					child.highlight:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", -2, 2)
					child.highlight:SetColorTexture(1, 1, 1, 0.25)
				end

				-- Naughty Addons
				local name = child:GetName()
				if name == "DBMMinimapButton" then
					child:SetScript("OnMouseDown", nil)
					child:SetScript("OnMouseUp", nil)
				elseif name == "BagSync_MinimapButton" then
					child:HookScript("OnMouseUp", clickFunc)
				elseif name == "WIM3MinimapButton" then
					child.SetParent = K.Noop
					child:SetFrameStrata("DIALOG")
					child.SetFrameStrata = K.Noop
				end

				child.styled = true
			end
		end
	end

	local shownButtons = {}
	local function SortRubbish()
		if #buttons == 0 then
			return
		end

		table_wipe(shownButtons)
		for _, button in pairs(buttons) do
			if button and button.IsShown and button:IsShown() then -- fix for fuxking AHDB
				table_insert(shownButtons, button)
			end
		end

		local numShown = #shownButtons
		local row = numShown == 0 and 1 or K.Round((numShown + rowMult) / iconsPerRow)
		local newHeight = row * 37 + 3
		bin:SetHeight(newHeight)

		for index, button in pairs(shownButtons) do
			button:ClearAllPoints()
			if index == 1 then
				button:SetPoint("BOTTOMRIGHT", bin, -6, 6)
			elseif row > 1 and mod(index, row) == 1 or row == 1 then
				button:SetPoint("RIGHT", shownButtons[index - row], "LEFT", -6, 0)
			else
				button:SetPoint("BOTTOM", shownButtons[index - 1], "TOP", 0, 6)
			end
		end
	end

	-- Add cleanup function for when feature is disabled
	local function CleanupCollectButtons()
		table_wipe(buttons)
		table_wipe(shownButtons)
		numMinimapChildren = 0
		currentIndex = 0
		StopAutoCloseTimer()
	end

	-- Improved collection function with better error handling
	local function CollectRubbish()
		if not C["Minimap"].ShowRecycleBin then
			CleanupCollectButtons()
			return
		end

		local numChildren = Minimap:GetNumChildren()
		if numChildren ~= numMinimapChildren then
			-- examine new children
			for i = 1, numChildren do
				local child = select(i, Minimap:GetChildren())
				local name = child and child.GetName and child:GetName()
				if name and not child.isExamed and not blackList[name] then
					if (child:IsObjectType("Button") or string_match(string_upper(name), "BUTTON")) and not isButtonIgnored(name) then
						ReskinMinimapButton(child, name)
					end
					child.isExamed = true
				end
			end

			numMinimapChildren = numChildren
		end

		KillMinimapButtons()

		currentIndex = currentIndex + 1
		if currentIndex < timeThreshold then
			-- schedule another call if within time threshold
			K.Delay(pendingTime, CollectRubbish)
		end
	end

	bu:SetScript("OnClick", function()
		if bin:IsShown() then
			StopAutoCloseTimer()
			clickFunc(1)
		else
			PlaySound(825)
			SortRubbish()
			UIFrameFadeIn(bin, 0.5, bin:GetAlpha(), 1)
			StartAutoCloseTimer()
		end
	end)

	CollectRubbish()
end
