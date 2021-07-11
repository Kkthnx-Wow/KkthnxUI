local K, C = unpack(select(2, ...))
local Module = K:GetModule("Minimap")

-- Sourced: NDui (Siweia)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local string_find = _G.string.find
local string_match = _G.string.match
local string_upper = _G.string.upper
local table_insert = _G.table.insert

local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local Minimap = _G.Minimap
local PlaySound = _G.PlaySound
local UIParent = _G.UIParent

function Module:CreateRecycleBin()
	if not C["Minimap"].ShowRecycleBin then
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
	if C["Minimap"].RecycleBinPosition.Value == 1 then
		bu:SetPoint("BOTTOMLEFT", -7, -7)
	elseif C["Minimap"].RecycleBinPosition.Value == 2 then
		bu:SetPoint("BOTTOMRIGHT", 7, -7)
	elseif C["Minimap"].RecycleBinPosition.Value == 3 then
		bu:SetPoint("TOPLEFT", -7, 7)
	elseif C["Minimap"].RecycleBinPosition.Value == 4 then
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
	if C["Minimap"].RecycleBinPosition.Value == 1 or C["Minimap"].RecycleBinPosition.Value == 2 then
		bin:SetPoint("BOTTOMRIGHT", bu, "BOTTOMLEFT", -3, 7)
	elseif C["Minimap"].RecycleBinPosition.Value == 3 or C["Minimap"].RecycleBinPosition.Value == 4 then
		bin:SetPoint("BOTTOMRIGHT", bu, "BOTTOMLEFT", -3, -21)
	else
		bin:SetPoint("BOTTOMRIGHT", bu, "BOTTOMLEFT", -3, 7)
	end
	bin:SetSize(width, height)
	bin:Hide()

	local function hideBinButton()
		bin:Hide()
	end

	local function clickFunc()
		PlaySound(825)
		UIFrameFadeOut(bin, 0.5, 1, 0)
		C_Timer_After(0.5, hideBinButton)
	end

	local ignoredButtons = {
		["GatherMatePin"] = true,
		["HandyNotes.-Pin"] = true,
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
				end
				region:ClearAllPoints()
				region:SetAllPoints()
				if not isGoodLookingIcon[name] then
					region:SetTexCoord(unpack(K.TexCoords))
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

				-- if child:HasScript("OnClick") then
				-- 	child:HookScript("OnClick", clickFunc)
				-- end

				if child:IsObjectType("Button") then
					child:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square") -- prevent nil function
					child:GetHighlightTexture():SetAllPoints(child)
				elseif child:IsObjectType("Frame") then
					child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
					child.highlight:SetPoint("TOPLEFT", child, "TOPLEFT", 2, -2)
					child.highlight:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", -2, 2)
					child.highlight:SetColorTexture(1, 1, 1, .25)
				end

				-- Naughty Addons
				local name = child:GetName()
				if name == "DBMMinimapButton" then
					child:SetScript("OnMouseDown", nil)
					child:SetScript("OnMouseUp", nil)
				elseif name == "BagSync_MinimapButton" then
					-- child:HookScript("OnMouseUp", clickFunc)
				end

				child.styled = true
			end
		end
	end

	local function CollectRubbish()
		local numChildren = Minimap:GetNumChildren()
		if numChildren ~= numMinimapChildren then
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
			C_Timer_After(pendingTime, CollectRubbish)
		end
	end

	local shownButtons = {}
	local function SortRubbish()
		if #buttons == 0 then
			return
		end

		table.wipe(shownButtons)
		for _, button in pairs(buttons) do
			if next(button) and button:IsShown() then -- fix for fuxking AHDB
				table_insert(shownButtons, button)
			end
		end

		local lastbutton
		for index, button in pairs(shownButtons) do
			button:ClearAllPoints()
			if not lastbutton then
				button:SetPoint("BOTTOMRIGHT", bin, -6, 6)
			elseif mod(index, iconsPerRow) == 1 then
				button:SetPoint("TOP", shownButtons[index - iconsPerRow], "BOTTOM", 0, -6)
			else
				button:SetPoint("RIGHT", lastbutton, "LEFT", -6, 0)
			end
			lastbutton = button
		end

		local numShown = #shownButtons
		local row = numShown == 0 and 1 or K.Round((numShown + rowMult) / iconsPerRow)
		local newHeight = row * 37 + 3
		bin:SetHeight(newHeight)
	end

	bu:SetScript("OnClick", function()
		if bin:IsShown() then
			clickFunc()
		else
			PlaySound(825)
			SortRubbish()
			UIFrameFadeIn(bin, 0.5, 0, 1)
		end
	end)

	CollectRubbish()
end