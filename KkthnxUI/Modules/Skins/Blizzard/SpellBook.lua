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
		NewBorder:SetBackdrop({edgeFile = C["Media"].BorderGlow, edgeSize = 16})
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

		local name = self:GetName()
		local ic = _G[name.."IconTexture"]
		if ic.bg then
			ic.bg:SetShown(ic:IsShown())
		end
	end)

	-- Professions
	local professions = {"PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3"}
	for i, button in pairs(professions) do
		local bu = _G[button]

		bu.statusBar:ClearAllPoints()
		bu.statusBar:StripTextures()
		bu.statusBar:SetStatusBarTexture(professionTexture)
		bu.statusBar:SetPoint("BOTTOMLEFT", 100	, 25)
		bu.statusBar:SetHeight(20)
		bu.statusBar:SetWidth(170)
		bu.statusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .6, 0, 0, .8, 0)
		bu.statusBar.rankText:SetPoint("CENTER")
		bu.statusBar.rankText:SetFont(bu.statusBar.rankText:GetFont(), 10, "NONE")
		bu.statusBar.rankText:SetShadowOffset(1, -1)
		bu.statusBar:CreateBorder()
		if i < 3 then
		_G["PrimaryProfession"..i.."UnlearnButton"]:SetSize(15,15)
		_G["PrimaryProfession"..i.."UnlearnButton"]:ClearAllPoints()
		_G["PrimaryProfession"..i.."UnlearnButton"]:SetPoint("BOTTOMLEFT",82,52)
		--_G["PrimaryProfession"..i.."UnlearnButton"]:CreateBorder()
		end
		if i > 2 then
			_G["SecondaryProfession"..(i-2).."ProfessionName"]:SetPoint("BOTTOMLEFT", bu.statusBar, "TOPLEFT", 0, 6)
			_G["SecondaryProfession"..(i-2).."Rank"]:SetPoint("TOPLEFT", bu.statusBar, "BOTTOMLEFT", 0, -40)
			bu.statusBar:SetWidth(110)
			bu.statusBar:SetHeight(16)
			bu.statusBar:SetPoint("BOTTOMLEFT", 10, 22)
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
		icon:SetPoint("TOPLEFT", 3, -3)
		icon:SetPoint("BOTTOMRIGHT", -3, 3)
		icon:SetTexCoord(unpack(K.TexCoords))

		icon.bg = CreateFrame("Frame", nil, bu)
		icon.bg:SetAllPoints(icon)
		icon.bg:SetFrameLevel(bu:GetFrameLevel())
		icon.bg:CreateBorder()

		local check = bu:GetCheckedTexture()
		check:SetColorTexture(0, 1, 0, 0.3)
		check:SetPoint("TOPLEFT", button, 3, -3)
		check:SetPoint("BOTTOMRIGHT", button, -3, 3)

	end

	--Profession Color Table #HEX
	local Prof_Color = {
	["Tailoring"] = "995adb", --763cb5
	["Enchanting"] = "f04172",  --e32957
	["Enginering"] =  "f2b950",
	["Mining"] = "997f4e",
	["Herbalism"] = "57c959",
	["Alchemy"] = "59c2b8",
	["Inscription"] = "fcebb6",
	["Leatherworking"] = "d14e0d",
	["Skinning"] = "d93030"
	}

	for i = 1, 2 do
		local bu = _G["PrimaryProfession"..i]
		_G["PrimaryProfession"..i.."IconBorder"]:Hide()
		bu.professionName:ClearAllPoints()
		bu.professionName:SetPoint("TOPLEFT", 100, -15	)
		bu.icon:SetDesaturated(false)
		bu.icon:ClearAllPoints()
		bu.icon:SetPoint("LEFT", 10, -5)
		bu.icon:SetAlpha(0.9)
		bu.icon:SetBlendMode("BLEND")

		bu.bg1 = CreateFrame("Frame", nil, bu)
		bu.bg1:SetAllPoints(bu.icon)
		bu.bg1:SetFrameLevel(bu:GetFrameLevel() + 2)

		bu.bg = bu.bg1:CreateTexture(nil, "OVERLAY")
		bu.bg:SetPoint("TOPLEFT", bu.icon, "TOPLEFT", -13, 13)
		bu.bg:SetPoint("BOTTOMRIGHT", bu.icon, "BOTTOMRIGHT", 13, -13)
		bu.bg:SetTexture("Interface\\AuctionFrame\\AuctionHouse", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		if C["General"].ColorTextures then
			bu.bg:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			bu.bg:SetVertexColor(0.8, 0.8, 0.8)
		end
		local prof = _G["PrimaryProfession"..i.."ProfessionName"]


		 local r, g, b = tonumber(string.sub(Prof_Color[prof:GetText()], 1, 2), 16), tonumber(string.sub(Prof_Color[prof:GetText()], 3, 4), 16), tonumber(string.sub(Prof_Color[prof:GetText()], 5), 16)

		--Coloring by Profession
		bu.bg:SetVertexColor(r/255,g/255,b/255)
		_G["PrimaryProfession"..i.."StatusBar"]:SetStatusBarColor(r/255,g/255,b/255)

		bu.bg:SetTexCoord(0.555664, 0.688477, 0.689453, 0.955078)
	end
end)