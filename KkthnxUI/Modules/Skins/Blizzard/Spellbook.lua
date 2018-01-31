local K, C = unpack(select(2, ...))

local _G = _G
local pairs, select, unpack = pairs, select, unpack

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown

local function LoadSkin()
	local SpellBookFrame = _G["SpellBookFrame"]

	--Skin SpellButtons
	local function SpellButtons(self, first)
		for i = 1, SPELLS_PER_PAGE do
			local button = _G["SpellButton"..i]
			local icon = _G["SpellButton"..i.."IconTexture"]

			if not InCombatLockdown() then
				button:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 5)
			end

			if first then
				for i = 1, button:GetNumRegions() do
					local region = select(i, button:GetRegions())
					if region:GetObjectType() == "Texture" then
						if region ~= button.FlyoutArrow and region ~= button.GlyphIcon and region ~= button.GlyphActivate
						and region ~= button.AbilityHighlight and region ~= button.SpellHighlightTexture then
							region:SetTexture(nil)
						end
					end
				end
			end

			if button.shine then
				button.shine:ClearAllPoints()
				button.shine:Point("TOPLEFT", button, "TOPLEFT", -3, 3)
				button.shine:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
			end

			if icon then
				icon:SetTexCoord(unpack(K.TexCoords))
				icon:ClearAllPoints()
				icon:SetAllPoints()

				if not button.Backdrop then
					button:CreateBackdrop("Transparent", true)
					button.Backdrop:SetFrameLevel(button:GetFrameLevel())
				end
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
		"SecondaryProfession3SpellButtonRight",
		"SecondaryProfession4SpellButtonLeft",
		"SecondaryProfession4SpellButtonRight",
	}

	local professionheaders = {
		"PrimaryProfession1",
		"PrimaryProfession2",
		"SecondaryProfession1",
		"SecondaryProfession2",
		"SecondaryProfession3",
		"SecondaryProfession4",
	}

	for _, header in pairs(professionheaders) do
		_G[header.."Missing"]:SetTextColor(1, 1, 0)
		_G[header].missingText:SetTextColor(0, 0, 0)
	end

	for _, button in pairs(professionbuttons) do
		button = _G[button]
		button:StripTextures()
		button:SetTemplate("Transparent", true)
		button.iconTexture:SetTexCoord(unpack(K.TexCoords))
		button.iconTexture:SetAllPoints()

		if button == _G[professionbuttons[2]] then
			button:SetPoint("TOPLEFT", _G[professionbuttons[1]], "BOTTOMLEFT", 0, -4)
		elseif button == _G[professionbuttons[4]] then
			button:SetPoint("TOPLEFT", _G[professionbuttons[3]], "BOTTOMLEFT", 0, -4)
		end
	end
end

tinsert(K.SkinFuncs["KkthnxUI"], LoadSkin)