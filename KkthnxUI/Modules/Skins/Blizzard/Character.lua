local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local table_insert = _G.table.insert

local CharacterHandsSlot = _G.CharacterHandsSlot
local CharacterHeadSlot = _G.CharacterHeadSlot
local CharacterMainHandSlot = _G.CharacterMainHandSlot
local CharacterModelFrame = _G.CharacterModelFrame
local CharacterSecondaryHandSlot = _G.CharacterSecondaryHandSlot
local CharacterStatsPane = _G.CharacterStatsPane
local HideUIPanel = _G.HideUIPanel
local hooksecurefunc = _G.hooksecurefunc
local unpack = _G.unpack

local function UpdateAzeriteItem(self)
	if not self.styled then
		self.styled = true

		self.AzeriteTexture:SetAlpha(0)
		self.RankFrame.Texture:SetTexture()
		self.RankFrame.Label:FontTemplate(nil, nil, "OUTLINE")
		self.RankFrame.Label:ClearAllPoints()
		self.RankFrame.Label:SetPoint("TOPLEFT", self, 2, -1)
		self.RankFrame.Label:SetTextColor(1, 0.5, 0)
	end
end

local function UpdateAzeriteEmpoweredItem(self)
	self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
	self.AzeriteTexture:SetAllPoints()
	self.AzeriteTexture:SetTexCoord(unpack(K.TexCoords))
	self.AzeriteTexture:SetDrawLayer("BORDER", 1)
end

local function FixSidebarTabCoords()
	for i = 1, #_G.PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i]

		if tab and not tab.Backdrop then
			tab:CreateBackdrop()
			tab.Backdrop:SetBackdropBorderColor(255/255, 215/255, 0/255)
			tab.Icon:SetAllPoints()
			tab.Highlight:SetTexture("Interface\\Buttons\\UI-Button-Outline")
			tab.Highlight:SetTexCoord(0.16, 0.86, 0.16, 0.86)
			tab.Highlight:SetBlendMode("ADD")
			tab.Highlight:SetPoint("TOPLEFT", tab, "TOPLEFT", -3, 3)
			tab.Highlight:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", 4, -4)

			-- Check for DejaCharacterStats. Lets hide the Texture if the AddOn is loaded.
			if _G.IsAddOnLoaded("DejaCharacterStats") then
				tab.Hider:SetTexture()
			else
				tab.Hider:SetColorTexture(0.0, 0.0, 0.0, 0.8)
			end
			tab.Hider:SetAllPoints(tab.Backdrop)
			tab.TabBg:Kill()

			if i == 1 then
				for x = 1, tab:GetNumRegions() do
					local region = select(x, tab:GetRegions())
					region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
					hooksecurefunc(region, "SetTexCoord", function(self, x1)
						if x1 ~= 0.16001 then
							self:SetTexCoord(0.16001, 0.86, 0.16, 0.86)
						end
					end)
				end
			end
		end
	end
end

local function UpdateFactionSkins()
	for i = 1, _G.NUM_FACTIONS_DISPLAYED, 1 do
		local statusbar = _G["ReputationBar"..i.."ReputationBar"]
		if statusbar then
			statusbar:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
		end
	end
end

local function StatsPane(which)
	CharacterStatsPane[which]:StripTextures()
	CharacterStatsPane[which].Title:SetFontObject(K.GetFont(C["UIFonts"].SkinFonts))
	CharacterStatsPane[which].Title:SetFont(select(1, CharacterStatsPane[which].Title:GetFont()), 14, select(3, CharacterStatsPane[which].Title:GetFont()))
	CharacterStatsPane[which].Title:SetTextColor(255/255, 255/255, 255/255)

	local headerBar = CharacterStatsPane[which]:CreateTexture(nil, "ARTWORK")
	headerBar:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	headerBar:SetTexCoord(0, 0.6640625, 0, 0.3125)
	headerBar:SetVertexColor(255/255, 204/255, 0/255)
	headerBar:SetPoint("CENTER", CharacterStatsPane[which])
	headerBar:SetSize(232, 30)
end

local function ReskinCharacterFrame()
	if CharacterFrame:IsShown() then
		HideUIPanel(CharacterFrame)
	end

	-- Strip Textures
	_G.CharacterModelFrame:StripTextures()

	for _, corner in pairs({"TopLeft", "TopRight", "BotLeft", "BotRight"}) do
		local CharacterModelFrameBackground_Textures = _G["CharacterModelFrameBackground"..corner]
		if CharacterModelFrameBackground_Textures then
			CharacterModelFrameBackground_Textures:Kill()
		end
	end

	for _, slot in pairs({_G.PaperDollItemsFrame:GetChildren()}) do
		if slot:IsObjectType("Button") or slot:IsObjectType("ItemButton") then
			slot:CreateBorder(nil, nil, nil, true)
			slot:CreateInnerShadow()
			slot:StyleButton(slot)
			slot.icon:SetTexCoord(unpack(K.TexCoords))
			slot:SetSize(36, 36)

			hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
			hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)

			if slot.popoutButton:GetPoint() == "TOP" then
				slot.popoutButton:SetPoint("TOP", slot, "BOTTOM", 0, 2)
			else
				slot.popoutButton:SetPoint("LEFT", slot, "RIGHT", -2, 0)
			end

			slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
			slot.IconBorder:SetAlpha(0)

			hooksecurefunc(slot.IconBorder, "SetVertexColor", function(_, r, g, b)
				slot:SetBackdropBorderColor(r, g, b)
			end)

			hooksecurefunc(slot.IconBorder, "Hide", function()
				slot:SetBackdropBorderColor()
			end)
		end
	end

	CharacterHeadSlot:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 6, -6)
	CharacterHandsSlot:SetPoint("TOPRIGHT", CharacterFrame.Inset, "TOPRIGHT", -6, -6)
	CharacterMainHandSlot:SetPoint("BOTTOMLEFT", CharacterFrame.Inset, "BOTTOMLEFT", 176, 5)
	CharacterSecondaryHandSlot:ClearAllPoints()
	CharacterSecondaryHandSlot:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -176, 5)

	CharacterModelFrame:SetSize(0, 0)
	CharacterModelFrame:ClearAllPoints()
	CharacterModelFrame:SetPoint("TOPLEFT", CharacterFrame.Inset, 0, 0)
	CharacterModelFrame:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, 0, 20)
	CharacterModelFrame:SetCamDistanceScale(1.1)

	hooksecurefunc("CharacterFrame_Expand", function()
		CharacterFrame:SetSize(640, 431) -- 540 + 100, 424 + 7
		CharacterFrame.Inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 432, 4)

		CharacterFrame.Inset.Bg:SetTexture("Interface\\DressUpFrame\\DressingRoom" .. K.Class)
		CharacterFrame.Inset.Bg:SetTexCoord(1 / 512, 479 / 512, 46 / 512, 455 / 512)
		CharacterFrame.Inset.Bg:SetHorizTile(false)
		CharacterFrame.Inset.Bg:SetVertTile(false)
	end)

	hooksecurefunc("CharacterFrame_Collapse", function()
		CharacterFrame:SetHeight(424)
		CharacterFrame.Inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 332, 4)

		CharacterFrame.Inset.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", "REPEAT", "REPEAT")
		CharacterFrame.Inset.Bg:SetTexCoord(0, 1, 0, 1)
		CharacterFrame.Inset.Bg:SetHorizTile(true)
		CharacterFrame.Inset.Bg:SetVertTile(true)
	end)

	_G.CharacterLevelText:FontTemplate()
	_G.CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)

	CharacterStatsPane.ClassBackground:ClearAllPoints()
	CharacterStatsPane.ClassBackground:SetHeight(CharacterStatsPane.ClassBackground:GetHeight() + 6)
	CharacterStatsPane.ClassBackground:SetParent(CharacterFrameInsetRight)
	CharacterStatsPane.ClassBackground:SetPoint("CENTER")

	if not IsAddOnLoaded("DejaCharacterStats") then
		StatsPane("EnhancementsCategory")
		StatsPane("ItemLevelCategory")
		StatsPane("AttributesCategory")
	end

	-- Buttons used to toggle between equipment manager, titles, and character stats
	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", FixSidebarTabCoords)

	-- Reskin Reputation Statusbars
	hooksecurefunc("ExpandFactionHeader", UpdateFactionSkins)
	hooksecurefunc("CollapseFactionHeader", UpdateFactionSkins)
	hooksecurefunc("ReputationFrame_Update", UpdateFactionSkins)
end

table_insert(Module.NewSkin["KkthnxUI"], ReskinCharacterFrame)