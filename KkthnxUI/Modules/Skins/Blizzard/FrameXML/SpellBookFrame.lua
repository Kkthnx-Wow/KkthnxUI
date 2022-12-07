local K, C = unpack(KkthnxUI)

local _G = _G
local pairs = pairs
local table_insert = table.insert

local GetProfessionInfo = _G.GetProfessionInfo
local SPELLS_PER_PAGE = _G.SPELLS_PER_PAGE or 6
local hooksecurefunc = _G.hooksecurefunc

local function handleSkillButton(button)
	if not button then
		return
	end
	button:SetCheckedTexture(0)
	button:SetPushedTexture(0)
	button.IconTexture:SetAllPoints()
	button.IconTexture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	button.bg = CreateFrame("Frame", nil, button)
	button.bg:SetFrameLevel(button:GetFrameLevel())
	button.bg:SetAllPoints(button)
	button.bg:CreateBorder()

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
		local bu = _G["SpellButton" .. i]
		local ic = _G["SpellButton" .. i .. "IconTexture"]

		_G["SpellButton" .. i .. "SlotFrame"]:SetAlpha(0)
		bu.EmptySlot:SetAlpha(0)
		bu.UnlearnedFrame:SetAlpha(0)
		bu:SetCheckedTexture(0)
		bu:SetPushedTexture(0)

		ic:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		if not bu.bg then
			bu.bg = CreateFrame("Frame", nil, bu)
			bu.bg:SetFrameLevel(bu:GetFrameLevel())
			bu.bg:SetAllPoints(ic)
			bu.bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Spellbook-SpellBackground", nil, nil, nil, 1, 1, 1)
			bu.bg = true
		end

		hooksecurefunc(bu.SpellHighlightTexture, "SetShown", function(_, value)
			if value == true then
				K.CustomGlow.AutoCastGlow_Start(bu)
			end
		end)

		hooksecurefunc(bu.SpellHighlightTexture, "Hide", function()
			K.CustomGlow.AutoCastGlow_Stop(bu)
		end)
	end

	-- Professions
	local professions = { "PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3" }
	for i, button in pairs(professions) do
		local bu = _G[button]
		bu.professionName:SetTextColor(1, 1, 1)
		bu.missingHeader:SetTextColor(1, 1, 1)
		bu.missingText:SetTextColor(1, 1, 1)

		bu.statusBar:StripTextures()
		bu.statusBar:SetHeight(16)
		bu.statusBar:SetStatusBarTexture(professionTexture)
		bu.statusBar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, 0.6, 0, 1), CreateColor(0, 0.8, 0, 1))
		bu.statusBar.rankText:SetPoint("CENTER")
		bu.statusBar:CreateBorder()
		if i > 2 then
			bu.statusBar:ClearAllPoints()
			bu.statusBar:SetPoint("BOTTOMLEFT", 16, 3)
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
