local K, C = unpack(select(2, ...))

local _G = _G
local pairs = pairs
local table_insert = table.insert

local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	local professionTexture = K.GetTexture(C["UITextures"].SkinTextures)

	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G["SpellButton"..i]
		local icon = _G["SpellButton"..i.."IconTexture"]
		local slot = _G["SpellButton"..i.."SlotFrame"]
		local highlight =_G["SpellButton"..i.."Highlight"]

		button.EmptySlot:SetTexture("")
		button.UnlearnedFrame:SetTexture("")
		slot:SetTexture("")
		icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		icon:SetAllPoints()
		button:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
		button:StyleButton()

		if C["General"].ColorTextures then
			button.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			button.KKUI_Border:SetVertexColor(1, 1, 1)
		end

		if button.shine then
			button.shine:ClearAllPoints()
			button.shine:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
			button.shine:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
		end

		local NewBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
		NewBorder:SetBackdrop({edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12})
		NewBorder:SetPoint("TOPLEFT", button, -6, 6)
		NewBorder:SetPoint("BOTTOMRIGHT", button, 6, -6)
		NewBorder:SetBackdropBorderColor(1, 1, 0)
		NewBorder:Hide()

		local NewAnimation = NewBorder:CreateAnimationGroup()
		NewAnimation:SetLooping("BOUNCE")
		NewAnimation.Fader = NewAnimation:CreateAnimation("Alpha")
		NewAnimation.Fader:SetFromAlpha(0.8)
		NewAnimation.Fader:SetToAlpha(0.2)
		NewAnimation.Fader:SetDuration(1)
		NewAnimation.Fader:SetSmoothing("OUT")
		NewAnimation.Fader:Stop()

		hooksecurefunc(button.SpellHighlightTexture, "SetShown", function(_, value)
			if value == true then
				NewBorder:Show()
				NewAnimation:Play()
			end
		end)

		hooksecurefunc(button.SpellHighlightTexture, "Hide", function()
			NewBorder:Hide()
			NewAnimation:Stop()
		end)
	end

	hooksecurefunc("SpellButton_UpdateButton", function()
		for i = 1, SPELLS_PER_PAGE do
			local button = _G["SpellButton"..i]
			if button.SpellHighlightTexture then
				button.SpellHighlightTexture:SetTexture("")
			end
		end
	end)

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
	}

	local professionheaders = {
		"PrimaryProfession1",
		"PrimaryProfession2",
		"SecondaryProfession1",
		"SecondaryProfession2",
		"SecondaryProfession3",
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
		"SecondaryProfession3StatusBar",
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
end)