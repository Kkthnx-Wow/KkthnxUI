local K, C = KkthnxUI[1], KkthnxUI[2]

local pairs = pairs
local table_insert = table.insert

local GetProfessionInfo = GetProfessionInfo
local SPELLS_PER_PAGE = SPELLS_PER_PAGE or 6
local hooksecurefunc = hooksecurefunc

local function handleSkillButton(button)
	if not button then
		return
	end
	button:SetCheckedTexture(0)
	button:SetPushedTexture(0)

	if button.IconTexture then
		button.IconTexture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		button.IconTexture:ClearAllPoints()
		button.IconTexture:SetPoint("TOPLEFT", 4, -4)
		button.IconTexture:SetPoint("BOTTOMRIGHT", -4, 4)

		if not button.KKUI_Backdrop then
			button:CreateBackdrop(2, -2, -2, 2)
		end
	end

	local nameFrame = _G[button:GetName() .. "NameFrame"]
	if nameFrame then
		nameFrame:Hide()
	end
end

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local professionTexture = K.GetTexture(C["General"].Texture)

	for i = 1, SPELLS_PER_PAGE do
		-- get the spell button and its icon texture
		local bu = _G["SpellButton" .. i]
		local ic = _G["SpellButton" .. i .. "IconTexture"]

		-- hide unnecessary textures and elements
		_G["SpellButton" .. i .. "SlotFrame"]:SetAlpha(0)
		bu.EmptySlot:SetAlpha(0)
		bu.UnlearnedFrame:SetAlpha(0)
		bu.SpellHighlightTexture:SetAlpha(0)
		bu:SetCheckedTexture(0)
		bu:SetPushedTexture(0)
		bu:SetHighlightTexture(0)

		-- set the texture coordinates for the icon
		ic:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		-- create and set up the background for the spell button
		if not bu.bg then
			bu.bg = CreateFrame("Frame", nil, bu)
			bu.bg:SetFrameLevel(bu:GetFrameLevel())
			bu.bg:SetAllPoints(ic)
			bu.bg:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Spellbook-SpellBackground", nil, nil, nil, { 1, 1, 1 })
			bu.bg = true
		end

		-- create a new highlight texture for new spells
		bu.NewSpellHighlightTexture = CreateFrame("Frame", nil, bu, "BackdropTemplate")
		bu.NewSpellHighlightTexture:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 16 })
		bu.NewSpellHighlightTexture:SetPoint("TOPLEFT", bu, -6, 6)
		bu.NewSpellHighlightTexture:SetPoint("BOTTOMRIGHT", bu, 6, -6)
		bu.NewSpellHighlightTexture:SetBackdropBorderColor(255 / 255, 223 / 255, 0 / 255)
		bu.NewSpellHighlightTexture:Hide()

		-- hook the set shown function for the spell highlight texture to show the new highlight texture instead
		hooksecurefunc(bu.SpellHighlightTexture, "SetShown", function(_, value)
			if value == true then
				if not bu.NewSpellHighlightTexture:IsShown() then
					bu.NewSpellHighlightTexture:Show()
				end
			end
		end)

		-- hook the hide function for the spell highlight texture to hide the new highlight texture instead
		hooksecurefunc(bu.SpellHighlightTexture, "Hide", function()
			if bu.NewSpellHighlightTexture:IsShown() then
				bu.NewSpellHighlightTexture:Hide()
			end
		end)
	end

	-- Professions
	local professions = { "PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3" }
	for i, button in pairs(professions) do
		local bu = _G[button]
		local sb = bu.statusBar
		sb:StripTextures()
		sb:SetHeight(16)
		sb:SetStatusBarTexture(professionTexture)
		sb:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, 0.6, 0, 1), CreateColor(0, 0.8, 0, 1))
		sb.rankText:SetPoint("CENTER")
		sb:CreateBorder()
		if i > 2 then
			sb:ClearAllPoints()
			sb:SetPoint("BOTTOMLEFT", 16, 3)
		end

		handleSkillButton(bu.SpellButton1)
		handleSkillButton(bu.SpellButton2)
	end

	for i = 1, 2 do
		local bu = _G["PrimaryProfession" .. i]
		_G["PrimaryProfession" .. i .. "IconBorder"]:Hide()

		bu.professionName:ClearAllPoints()
		bu.professionName:SetPoint("TOPLEFT", 100, -4)
		bu.icon:SetAlpha(1)
		bu.icon:SetDesaturated(false)
		bu.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetAllPoints(bu.icon)
		bg:SetFrameLevel(bu:GetFrameLevel())
		bg:CreateBorder()
	end

	-- Fix the profession icons
	hooksecurefunc("FormatProfession", function(frame, index)
		if index then
			local _, texture = GetProfessionInfo(index)
			if frame.icon and texture then
				frame.icon:SetTexture(texture)
			end
		end
	end)

	-- Remove the tutorial button
	if C["General"].NoTutorialButtons then
		_G.SpellBookFrameTutorialButton:Kill()
	end
end)
