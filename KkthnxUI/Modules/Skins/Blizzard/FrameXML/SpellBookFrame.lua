local K, C = KkthnxUI[1], KkthnxUI[2]

local pairs = pairs
local table_insert = table.insert
local GetProfessionInfo = GetProfessionInfo
local SPELLS_PER_PAGE = SPELLS_PER_PAGE or 6
local hooksecurefunc = hooksecurefunc

local function HandleSkillButton(button)
	if not button or InCombatLockdown() then
		return
	end

	button:SetCheckedTexture(0)
	button:SetPushedTexture(0)

	if button.IconTexture then
		button.IconTexture:SetTexCoord(unpack(K.TexCoords))
		button.IconTexture:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
		button.IconTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
		if not button.KKUI_Border then
			button:CreateBorder(nil, nil, nil, nil, -7, nil, nil, nil, nil, 3)
			button.KKUI_Border = true
		end
	end

	local nameFrame = _G[button:GetName() .. "NameFrame"]
	if nameFrame then
		nameFrame:Hide()
	end
end

local function ReskinSpellButton(spellButton)
	if not spellButton then
		return
	end

	local iconTexture = _G[spellButton:GetName() .. "IconTexture"]
	local slotFrame = _G[spellButton:GetName() .. "SlotFrame"]
	local bu = spellButton

	slotFrame:SetAlpha(0)
	bu.EmptySlot:SetAlpha(0)
	bu.UnlearnedFrame:SetAlpha(0)
	bu.SpellHighlightTexture:SetAlpha(0)
	bu:SetCheckedTexture(0)
	bu:SetPushedTexture(0)
	bu:SetHighlightTexture(0)

	iconTexture:SetTexCoord(unpack(K.TexCoords))

	if not bu.bg then
		bu.bg = CreateFrame("Frame", nil, bu)
		bu.bg:SetFrameLevel(bu:GetFrameLevel())
		bu.bg:SetAllPoints(iconTexture)
		bu.bg:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Spellbook-SpellBackground", nil, nil, nil, { 1, 1, 1 })
		bu.bg = true
	end

	bu.NewSpellHighlightTexture = CreateFrame("Frame", nil, bu, "BackdropTemplate")
	bu.NewSpellHighlightTexture:SetFrameLevel(bu:GetFrameLevel() + 2)
	bu.NewSpellHighlightTexture:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 16 })
	bu.NewSpellHighlightTexture:SetPoint("TOPLEFT", bu, -7, 7)
	bu.NewSpellHighlightTexture:SetPoint("BOTTOMRIGHT", bu, 7, -7)
	bu.NewSpellHighlightTexture:SetBackdropBorderColor(1, 223 / 255, 0)
	bu.NewSpellHighlightTexture:Hide()

	hooksecurefunc(bu.SpellHighlightTexture, "SetShown", function(_, value)
		if value and not bu.NewSpellHighlightTexture:IsShown() then
			bu.NewSpellHighlightTexture:Show()
		end
	end)

	hooksecurefunc(bu.SpellHighlightTexture, "Hide", function()
		if bu.NewSpellHighlightTexture:IsShown() then
			bu.NewSpellHighlightTexture:Hide()
		end
	end)
end

local function ReskinProfessionButton(professionButton)
	local statusBar = professionButton.statusBar
	statusBar:StripTextures()
	statusBar:SetHeight(16)
	statusBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	statusBar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, 0.6, 0, 1), CreateColor(0, 0.8, 0, 1))
	statusBar.rankText:SetPoint("CENTER")
	statusBar:CreateBorder()

	if professionButton.SpellButton1 then
		HandleSkillButton(professionButton.SpellButton1)
	end
	if professionButton.SpellButton2 then
		HandleSkillButton(professionButton.SpellButton2)
	end
end

local function ReskinProfessionIcons(professionIndex)
	local professionButton = _G["PrimaryProfession" .. professionIndex]
	local iconBorder = _G["PrimaryProfession" .. professionIndex .. "IconBorder"]
	local professionIcon = professionButton.icon

	iconBorder:Hide()
	professionButton.professionName:ClearAllPoints()
	professionButton.professionName:SetPoint("TOPLEFT", 100, -4)
	professionIcon:SetAlpha(1)
	professionIcon:SetDesaturated(false)
	professionIcon:SetTexCoord(unpack(K.TexCoords))

	local bg = CreateFrame("Frame", nil, professionButton)
	bg:SetAllPoints(professionIcon)
	bg:SetFrameLevel(professionButton:GetFrameLevel())
	bg:CreateBorder()
end

local function HideTutorialButtons()
	if C["General"].NoTutorialButtons then
		_G.SpellBookFrameTutorialButton:Hide()
	end
end

table_insert(C.defaultThemes, function()
	-- if not C["Skins"].BlizzardFrames then
	-- 	return
	-- end

	-- local professionTexture = K.GetTexture(C["General"].Texture)

	-- for i = 1, SPELLS_PER_PAGE do
	-- 	ReskinSpellButton(_G["SpellButton" .. i])
	-- end

	-- local professions = { "PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3" }
	-- for i, profession in pairs(professions) do
	-- 	ReskinProfessionButton(_G[profession])
	-- 	if i <= 2 then
	-- 		ReskinProfessionIcons(i)
	-- 	end
	-- end

	-- hooksecurefunc("FormatProfession", function(frame, index)
	-- 	if InCombatLockdown() then
	-- 		return
	-- 	end

	-- 	if index then
	-- 		local _, texture = GetProfessionInfo(index)
	-- 		if frame.icon and texture then
	-- 			frame.icon:SetTexture(texture)
	-- 		end
	-- 	end
	-- end)

	-- HideTutorialButtons()
end)
