local K, C = unpack(select(2, ...))

local _G = _G
local pairs = pairs
local table_insert = table.insert

local BOOKTYPE_PROFESSION = _G.BOOKTYPE_PROFESSION
local GetProfessionInfo = _G.GetProfessionInfo
local IsPassiveSpell = _G.IsPassiveSpell
local SPELLS_PER_PAGE = _G.SPELLS_PER_PAGE
local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	local professionTexture = K.GetTexture(C["UITextures"].SkinTextures)

	for i = 1, SPELLS_PER_PAGE do
		local bu = _G["SpellButton"..i]
		local ic = _G["SpellButton"..i.."IconTexture"]

		_G["SpellButton"..i.."SlotFrame"]:SetAlpha(0)
		bu.EmptySlot:SetAlpha(0)
		bu.UnlearnedFrame:SetAlpha(0)
		bu:SetCheckedTexture("")
		bu:SetPushedTexture("")

		ic:SetTexCoord(unpack(K.TexCoords))
		ic.bg = ic:CreateBorder()

		local NewBorder = CreateFrame("Frame", nil, bu, "BackdropTemplate")
		NewBorder:SetBackdrop({edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 16})
		NewBorder:SetPoint("TOPLEFT", bu, -7, 7)
		NewBorder:SetPoint("BOTTOMRIGHT", bu, 7, -7)
		NewBorder:SetBackdropBorderColor(1, 1, 0)
		NewBorder:Hide()

		hooksecurefunc(bu.SpellHighlightTexture, "SetShown", function(_, value)
			if value == true then
				NewBorder:Show()
			end
		end)

		hooksecurefunc(bu.SpellHighlightTexture, "Hide", function()
			NewBorder:Hide()
		end)
	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
			return
		end

		for i = 1, SPELLS_PER_PAGE do
			local button = _G["SpellButton"..i]
			if button.SpellHighlightTexture then
				button.SpellHighlightTexture:SetTexture("")
			end
		end

		local slot = SpellBook_GetSpellBookSlot(self)
		local isPassive = IsPassiveSpell(slot, SpellBookFrame.bookType)
		local name = self:GetName()
		local highlightTexture = _G[name.."Highlight"]
		highlightTexture:SetPoint("TOPLEFT", 2, -2)
		highlightTexture:SetPoint("BOTTOMRIGHT", -2, 2)
		if isPassive then
			highlightTexture:SetColorTexture(1, 1, 1, 0)
		else
			highlightTexture:SetColorTexture(1, 1, 1, .25)
		end

		local ic = _G[name.."IconTexture"]
		if ic.bg then
			ic.bg:SetShown(ic:IsShown())
		end
	end)

	-- Professions
	local professions = {"PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3"}
	for i, button in pairs(professions) do
		local bu = _G[button]
		bu.statusBar:StripTextures()
		bu.statusBar:SetStatusBarTexture(professionTexture)
		bu.statusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .6, 0, 0, .8, 0)
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

		local icon = bu.iconTexture
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", 2, -2)
		icon:SetPoint("BOTTOMRIGHT", -2, 2)
		icon:SetTexCoord(unpack(K.TexCoords))

		icon.bg = CreateFrame("Frame", nil, bu)
		icon.bg:SetAllPoints(icon)
		icon.bg:SetFrameLevel(bu:GetFrameLevel())
		icon.bg:CreateBorder()

		local check = bu:GetCheckedTexture()
		check:SetColorTexture(0, 1, 0, 0.3)
		check:SetPoint("TOPLEFT", button, 2, -2)
		check:SetPoint("BOTTOMRIGHT", button, -2, 2)
	end

	for i = 1, 2 do
		local bu = _G["PrimaryProfession"..i]
		_G["PrimaryProfession"..i.."IconBorder"]:Hide()
		bu.professionName:ClearAllPoints()
		bu.professionName:SetPoint("TOPLEFT", 100, -4)
		bu.icon:SetAlpha(0.6)
		bu.icon:SetDesaturated(false)
		bu.icon:SetTexCoord(unpack(K.TexCoords))
	end

	hooksecurefunc("FormatProfession", function(frame, index)
		if index then
			local _, texture = GetProfessionInfo(index)
			if frame.icon and texture then
				frame.icon:SetTexture(texture)
			end
		end
	end)
end)