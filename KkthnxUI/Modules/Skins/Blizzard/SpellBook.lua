local K, C = unpack(select(2, ...))

local _G = _G
local pairs = _G.pairs
local string_split = _G.string.split
local string_sub = _G.string.sub
local table_insert = _G.table.insert

local BOOKTYPE_PROFESSION = _G.BOOKTYPE_PROFESSION
local GetProfessionInfo = _G.GetProfessionInfo
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
		bu.statusBar:SetPoint("BOTTOMLEFT", 100, 25)
		bu.statusBar:SetHeight(20)
		bu.statusBar:SetWidth(170)
		bu.statusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, 0.6, 0, 0, 0.8, 0)
		bu.statusBar.rankText:SetPoint("CENTER")
		bu.statusBar.rankText:SetFontObject(K.GetFont(C["UIFonts"].SkinFonts))
		bu.statusBar:CreateBorder()

		if i < 3 then
			bu.unlearn:SetSize(15,15)
			bu.unlearn:ClearAllPoints()
			bu.unlearn:SetPoint("BOTTOMLEFT",82,52)
		end

		if i > 2 then
			bu.professionName:SetPoint("BOTTOMLEFT", bu.statusBar, "TOPLEFT", 0, 6)
			bu.rank:SetPoint("TOPLEFT", bu.statusBar, "BOTTOMLEFT", 0, -46)
			bu.statusBar:SetWidth(110)

			bu.statusBar:SetHeight(18)
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

		icon.parts = icon.bg:CreateTexture(nil, "BACKGROUND")
		icon.parts:SetPoint("TOPLEFT", icon.bg, "TOPRIGHT", -12, 0)
		icon.parts:SetSize(167, 39)
		icon.parts:SetTexture("Interface\\Spellbook\\Spellbook-Parts")
		icon.parts:SetTexCoord(0.31250000, 0.96484375, 0.37109375, 0.52343750)

		icon.parts2 = icon.bg:CreateTexture(nil, "BACKGROUND")
		icon.parts2:SetPoint("TOPLEFT", icon.bg, "TOPRIGHT", -12, 0)
		icon.parts2:SetSize(167, 39)
		icon.parts2:SetTexture("Interface\\Spellbook\\Spellbook-Parts")
		icon.parts2:SetTexCoord(0.31250000, 0.96484375, 0.37109375, 0.52343750)

		local check = bu:GetCheckedTexture()
		check:SetColorTexture(0, 1, 0, 0.3)
		check:SetPoint("TOPLEFT", button, 3, -3)
		check:SetPoint("BOTTOMRIGHT", button, -3, 3)
	end

	-- Profession Color Table #HEX - right:left gradient
	local Prof_Color = {
		[164] = "969696:ff7b11", -- Blacksmithing
		[165] = "d14e0d:ff9732", -- Leatherworking
		[171] = "358fb1:34e393", -- Alchemy
		[182] = "389b3a:e3ff9f", -- Herbalism
		[186] = "8f5b33:c78250", -- Mining
		[197] = "73579f:6c81ff", -- Tailoring 197
		[202] = "f2b950:efe328", -- Engineering
		[333] = "e32e4c:f47ffa", -- Enchanting 333 bd4f4f:ff3e62
		[393] = "a24343:d93030", -- Skinning
		[755] = "2d7cff:d1fffd", -- Jewelcrafting
		[773] = "ddc092:ffce4a", -- Inscription
		default = "ffffff:ffffff"
	}

	for i = 1, 2 do
		local bu = _G["PrimaryProfession"..i]
		_G["PrimaryProfession"..i.."IconBorder"]:Hide()
		bu.professionName:ClearAllPoints()
		bu.professionName:SetPoint("TOPLEFT", 100, -15)
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
		bu.bg:SetVertexColor(1, 1, 1)
		bu.bg:SetTexCoord(0.555664, 0.688477, 0.689453, 0.955078)
	end

	hooksecurefunc("FormatProfession", function(frame, id)
		if not (id and frame and frame.icon) then
			return
		end

		if not id and frame.icon then -- Define name or id?
			if frame.bg then
				frame.bg:SetVertexColor(69/100, 42/100, 17/100)
			end
		end

		local _, _, _, _, numSpells, _, skillLine = GetProfessionInfo(id);
		if numSpells == 1 then
			frame.button1:ClearAllPoints()
			frame.button1:SetPoint("RIGHT", -110, -5)
		elseif numSpells == 2 then
			frame.button1:ClearAllPoints()
			frame.button1:SetPoint("RIGHT", -110, -22)
		end

		local gradient = Prof_Color[skillLine]
		local lhex, rhex = string_split(":", gradient)
		local lr, lg, lb = tonumber(string_sub(lhex, 1, 2), 16), tonumber(string_sub(lhex, 3, 4), 16), tonumber(string_sub(lhex, 5), 16)
		local rr, rg, rb = tonumber(string_sub(rhex, 1, 2), 16), tonumber(string_sub(rhex, 3, 4), 16), tonumber(string_sub(rhex, 5), 16)
		frame.bg:SetVertexColor(lr / 255, lg / 255, lb / 255)

		local t = frame.statusBar:GetStatusBarTexture()
		t:SetVertexColor(1, 1, 1)
		t:SetGradient("Horizontal", lr / 255, lg / 255, lb / 255, rr / 255, rg/255, rb / 255)
		frame.bg:SetGradient("VERTICAL", lr / 255, lg / 255, lb / 255, rr / 255, rg / 255, rb / 255)
	end)

	hooksecurefunc("UpdateProfessionButton", function(self)

	end)
end)