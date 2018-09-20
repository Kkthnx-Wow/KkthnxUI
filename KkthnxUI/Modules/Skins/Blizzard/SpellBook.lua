local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local pairs = pairs
local table_insert = table.insert

local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local SPELLS_PER_PAGE = _G.SPELLS_PER_PAGE

local function LoadSpellBookSkin()
	local professionTexture = K.GetTexture(C["Skins"].Texture)

	-- Skin SpellButtons
	local function SpellButtons(self, first)
		for i = 1, SPELLS_PER_PAGE do
			local button = _G["SpellButton" .. i]
			local slot = _G["SpellButton" .. i .. "SlotFrame"]
			local icon = _G["SpellButton" .. i .. "IconTexture"]

			if not InCombatLockdown() then
				button:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 5)
			end

			if first then
				button:CreateBorder()
				button.EmptySlot:SetTexture("")
				button.UnlearnedFrame:SetTexture("")
				slot:SetTexture("") -- swirly thing
				icon:SetTexCoord(unpack(K.TexCoords))
			end
		end
	end
	SpellButtons(nil, true)
	hooksecurefunc("SpellButton_UpdateButton", SpellButtons)

	-- Profession Tab
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
		"SecondaryProfession3SpellButtonRight"
	}

	local professionheaders = {
		"PrimaryProfession1",
		"PrimaryProfession2",
		"SecondaryProfession1",
		"SecondaryProfession2",
		"SecondaryProfession3"
	}

	for _, header in pairs(professionheaders) do
		_G[header.."Missing"]:SetTextColor(1, 0.8, 0)
		_G[header.."Missing"]:SetShadowColor(0, 0, 0)
		_G[header.."Missing"]:SetShadowOffset(1, -1)
		_G[header].missingText:SetTextColor(.04, .04, .04)
	end

	for _, button in pairs(professionbuttons) do
		local icon = _G[button.."IconTexture"]
		local rank = _G[button.."SubSpellName"]
		local button = _G[button]
		button:StripTextures()

		if rank then
			rank:SetTextColor(1, 1, 1)
		end

		button:GetCheckedTexture():SetColorTexture(0, 1, 0, 0.3)
		button:GetCheckedTexture():SetPoint("TOPLEFT", button, 4, -4)
		button:GetCheckedTexture():SetPoint("BOTTOMRIGHT", button, -4, 4)

		button.cooldown:SetPoint("TOPLEFT", button, 5, -5)
		button.cooldown:SetPoint("BOTTOMRIGHT", button, -5, 5)

		if icon then
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", 3, -3)
			icon:SetPoint("BOTTOMRIGHT", -3, 3)

			if not button.Backdrop then
				button:CreateBackdrop()
				button.Backdrop:SetFrameLevel(button:GetFrameLevel())
				button.Backdrop:SetAllPoints(icon)
			end
		end
	end

	hooksecurefunc("UpdateProfessionButton", function()
		for _, button in pairs(professionbuttons) do
			local button = _G[button]
			button:GetHighlightTexture():SetPoint("TOPLEFT", button, 3, -3)
			button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, -3, 3)
		end
	end)

	local professionstatusbars = {
		"PrimaryProfession1StatusBar",
		"PrimaryProfession2StatusBar",
		"SecondaryProfession1StatusBar",
		"SecondaryProfession2StatusBar",
		"SecondaryProfession3StatusBar"
	}

	for _, statusbar in pairs(professionstatusbars) do
		local statusbar = _G[statusbar]
		statusbar:StripTextures()
		statusbar:SetStatusBarTexture(professionTexture)
		statusbar:SetStatusBarColor(0, 0.8, 0)
		statusbar:CreateBorder()

		statusbar.rankText:ClearAllPoints()
		statusbar.rankText:SetPoint("CENTER")
	end
end

table_insert(Module.SkinFuncs["KkthnxUI"], LoadSpellBookSkin)