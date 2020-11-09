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

	local buttons = {}
	local blackList = {
		["GameTimeFrame"] = true,
		["MiniMapLFGFrame"] = true,
		["BattlefieldMinimap"] = true,
		["MinimapBackdrop"] = true,
		["TimeManagerClockButton"] = true,
		["FeedbackUIButton"] = true,
		["HelpOpenTicketButton"] = true,
		["MiniMapBattlefieldFrame"] = true,
		["QueueStatusMinimapButton"] = true,
		["GarrisonLandingPageMinimapButton"] = true,
		["MinimapZoneTextButton"] = true,
		["RecycleBinFrame"] = true,
		["RecycleBinToggleButton"] = true,
	}

	local bu = CreateFrame("Button", "RecycleBinToggleButton", Minimap)
	bu:SetAlpha(0.6)
	bu:SetSize(16, 16)
	bu:ClearAllPoints()
	bu:SetPoint("BOTTOMLEFT", -7, -7)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface\\COMMON\\Indicator-Gray")
	bu:SetHighlightTexture("Interface\\COMMON\\Indicator-Yellow")
	bu:SetPushedTexture("Interface\\COMMON\\Indicator-Green")
	K.AddTooltip(bu, "ANCHOR_LEFT", "Minimap RecycleBin|n|nCollects minimap buttons and makes them accessible through a pop out menu", "white")

	local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	bin:SetSize(220, 30)
	bin:SetPoint("RIGHT", bu, "LEFT", -3, 14)
	bin:CreateBorder()
	bin:Hide()
	bin:SetFrameStrata("LOW")

	local function hideBinButton()
		bin:Hide()
	end

	local function clickFunc()
		K.UIFrameFadeOut(bin, 0.5, 1, 0)
		C_Timer_After(0.5, hideBinButton)
		PlaySound(825)
	end

	local secureAddons = {
		["HANDYNOTESPIN"] = true,
		["GATHERMATEPIN"] = true,
	}

	local function isButtonSecure(name)
		name = string_upper(name)
		for addonName in pairs(secureAddons) do
			if string_match(name, addonName) then
				return true
			end
		end
	end

	local isCollecting
	local function CollectRubbish()
		if isCollecting then
			return
		end
		isCollecting = true

		for _, child in ipairs({Minimap:GetChildren()}) do
			local name = child:GetName()
			if name and not blackList[name] and not isButtonSecure(name) then
				if child:GetObjectType() == "Button" or string_match(string_upper(name), "BUTTON") then
					child:SetParent(bin)
					child:SetSize(22, 22)
					for j = 1, child:GetNumRegions() do
						local region = select(j, child:GetRegions())
						if region:GetObjectType() == "Texture" then
							local texture = region:GetTexture() or ""
							if string_find(texture, "Interface\\CharacterFrame") or string_find(texture, "Interface\\Minimap") then
								region:SetTexture(nil)
							elseif texture == 136430 or texture == 136467 then
								region:SetTexture(nil)
							end
							region:ClearAllPoints()
							region:SetAllPoints()
							region:SetTexCoord(unpack(K.TexCoords))
						end
					end

					if child:HasScript("OnDragStart") then
						child:SetScript("OnDragStart", nil)
					end

					if child:HasScript("OnDragStop") then
						child:SetScript("OnDragStop", nil)
					end

					if child:HasScript("OnClick") then
						child:HookScript("OnClick", clickFunc)
					end

					if child:GetObjectType() == "Button" then
						child:SetHighlightTexture(C["Media"].Blank) -- prevent nil function
						child:GetHighlightTexture():SetPoint("TOPLEFT", child, "TOPLEFT", 2, -2)
						child:GetHighlightTexture():SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", -2, 2)
						child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					elseif child:GetObjectType() == "Frame" then
						child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
						child.highlight:SetPoint("TOPLEFT", child, "TOPLEFT", 2, -2)
						child.highlight:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", -2, 2)
						child.highlight:SetColorTexture(1, 1, 1, .25)
					end
					child:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

					-- Naughty Addons
					if name == "DBMMinimapButton" then
						child:SetScript("OnMouseDown", nil)
						child:SetScript("OnMouseUp", nil)
					elseif name == "BagSync_MinimapButton" then
						child:HookScript("OnMouseUp", clickFunc)
					end

					table_insert(buttons, child)
				end
			end
		end

		isCollecting = nil
	end

	local function SortRubbish()
		if #buttons == 0 then
			return
		end

		local lastbutton
		for _, button in pairs(buttons) do
			if button.IsShown and button:IsShown() then
				button:ClearAllPoints()
				if not lastbutton then
					button:SetPoint("RIGHT", bin, -4, 0)
				else
					button:SetPoint("RIGHT", lastbutton, "LEFT", -5, 0)
				end
				lastbutton = button
			end
		end
	end

	bu:SetScript("OnClick", function()
		SortRubbish()
		if bin:IsShown() then
			clickFunc()
		else
			K.UIFrameFadeIn(bin, 0.5, 0, 1)
			PlaySound(825)
		end
	end)

	C_Timer_After(0.4, function()
		CollectRubbish()
		SortRubbish()
	end)
end