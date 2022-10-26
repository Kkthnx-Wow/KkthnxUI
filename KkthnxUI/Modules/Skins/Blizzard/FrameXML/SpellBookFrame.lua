local K, C = unpack(KkthnxUI)

local _G = _G
local pairs = pairs
local table_insert = table.insert

local GetProfessionInfo = _G.GetProfessionInfo
local SPELLS_PER_PAGE = _G.SPELLS_PER_PAGE
local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local professionTexture = K.GetTexture(C["General"].Texture)

	for i = 1, SPELLS_PER_PAGE do
		local bu = _G["SpellButton" .. i]
		local ic = _G["SpellButton" .. i .. "IconTexture"]

		_G["SpellButton" .. i .. "SlotFrame"]:SetAlpha(0)
		bu.EmptySlot:SetAlpha(0)
		bu.UnlearnedFrame:SetAlpha(0)
		bu:SetCheckedTexture(C["Media"].Textures.BlankTexture)
		bu:SetPushedTexture(C["Media"].Textures.BlankTexture)

		ic:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		bu.bg = CreateFrame("Frame", nil, bu)
		bu.bg:SetFrameLevel(bu:GetFrameLevel())
		bu.bg:SetAllPoints(ic)
		bu.bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Spellbook-SpellBackground", nil, nil, nil, 1, 1, 1)

		local newHighlight = CreateFrame("Frame", nil, bu, "BackdropTemplate")
		newHighlight:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 16 })
		newHighlight:SetPoint("TOPLEFT", bu, -6, 6)
		newHighlight:SetPoint("BOTTOMRIGHT", bu, 6, -6)
		newHighlight:SetBackdropBorderColor(1, 1, 0)
		newHighlight:Hide()

		hooksecurefunc(bu.SpellHighlightTexture, "SetShown", function(_, value)
			if value == true then
				newHighlight:Show()
			end
		end)

		hooksecurefunc(bu.SpellHighlightTexture, "Hide", function()
			newHighlight:Hide()
		end)
	end

	-- Professions
	local professions = { "PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3" }
	for i, button in pairs(professions) do
		local bu = _G[button]
		bu.statusBar:StripTextures()
		bu.statusBar:SetStatusBarTexture(professionTexture)
		-- bu.statusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, 0.6, 0, 0, 0.8, 0)
		bu.statusBar.rankText:SetPoint("CENTER")
		bu.statusBar:CreateBorder()
		if i > 2 then
			bu.statusBar:ClearAllPoints()
			bu.statusBar:SetPoint("BOTTOMLEFT", 16, 4)
		end
	end

	local professionbuttons = {
		"PrimaryProfession1SpellButtonTop",
		"PrimaryProfession1SpellButtonBottom",
		"PrimaryProfession2SpellButtonTop",
		"PrimaryProfession2SpellButtonBottom",
		"SecondaryProfession1SpellButtonLeft",
		"SecondaryProfession1SpellButtonRight",
		"SecondaryProfession2SpellButtonLeft",
		"SecondaryProfession2SpellButtonRight",
		"SecondaryProfession3SpellButtonLeft",
		"SecondaryProfession3SpellButtonRight",
	}

	for _, button in pairs(professionbuttons) do
		local bu = _G[button]
		bu:StripTextures()
		bu:SetPushedTexture("")

		-- local icon = bu.iconTexture
		-- icon:ClearAllPoints()
		-- icon:SetPoint("TOPLEFT", 2, -2)
		-- icon:SetPoint("BOTTOMRIGHT", -2, 2)
		-- icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		-- icon.bg = CreateFrame("Frame", nil, bu)
		-- icon.bg:SetAllPoints(icon)
		-- icon.bg:SetFrameLevel(bu:GetFrameLevel())
		-- icon.bg:CreateBorder()

		local check = bu:GetCheckedTexture()
		check:SetColorTexture(0, 1, 0, 0.3)
		check:SetPoint("TOPLEFT", button, 2, -2)
		check:SetPoint("BOTTOMRIGHT", button, -2, 2)
	end

	for i = 1, 2 do
		local bu = _G["PrimaryProfession" .. i]
		_G["PrimaryProfession" .. i .. "IconBorder"]:Hide()

		bu.professionName:ClearAllPoints()
		bu.professionName:SetPoint("TOPLEFT", 100, -4)

		bu.icon:SetDesaturated(false)
		bu.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetAllPoints(bu.icon)
		bg:SetFrameLevel(bu:GetFrameLevel())
		bg:CreateBorder()
	end

	hooksecurefunc("FormatProfession", function(frame, index)
		if index then
			local _, texture = GetProfessionInfo(index)
			if frame.icon and texture then
				frame.icon:SetTexture(texture)
			end
		end
	end)

	if C["General"].NoTutorialButtons then
		_G.SpellBookFrameTutorialButton:Kill()
	end
end)
