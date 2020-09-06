local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

local function SkinFriendsFrame()
	-- GameIcons
	for i = 1, FRIENDS_TO_DISPLAY do
		local bu = _G["FriendsListFrameScrollFrameButton"..i]
		local ic = bu.gameIcon

		bu.background:Hide()
		bu:SetHighlightTexture(C["Media"].Blank)
		bu:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)

		ic:SetSize(22, 22)
		ic:SetTexCoord(.17, .83, .17, .83)

		bu.bg = CreateFrame("Frame", nil, bu)
		bu.bg:SetAllPoints(ic)
		bu.bg:SetFrameLevel(bu:GetFrameLevel())
		bu.bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

		local travelPass = bu.travelPassButton
		travelPass:SetSize(22, 22)
		travelPass:SetPushedTexture(nil)
		travelPass:SetDisabledTexture(nil)
		travelPass:SetPoint("TOPRIGHT", -3, -6)
		travelPass:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

		local nt = travelPass:GetNormalTexture()
		nt:SetTexture("Interface\\FriendsFrame\\PlusManz-PlusManz")
		nt:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		local hl = travelPass:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints()
	end

	local function UpdateScroll()
		for i = 1, FRIENDS_TO_DISPLAY do
			local bu = _G["FriendsListFrameScrollFrameButton"..i]
			if bu.gameIcon:IsShown() then
				bu.bg:Show()
				bu.gameIcon:SetPoint("TOPRIGHT", bu.travelPassButton, "TOPLEFT", -6, 0)
			else
				bu.bg:Hide()
			end
		end
	end

	hooksecurefunc("FriendsFrame_UpdateFriends", UpdateScroll)
	hooksecurefunc(FriendsListFrameScrollFrame, "update", UpdateScroll)

	FriendsFrameBattlenetFrame:GetRegions():Hide()
	local bg = CreateFrame("Frame", nil, FriendsFrameBattlenetFrame)
	bg:SetFrameLevel(FriendsFrameBattlenetFrame:GetFrameLevel())
	bg:SetPoint("TOPLEFT", 4, -5)
	bg:SetPoint("BOTTOMRIGHT", -4, 5)
	bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	bg.KKUI_InnerShadow:SetAlpha(0.25)
	bg.KKUI_Background:SetVertexColor(0, 0.6, 1, 0.25)

	local broadcastButton = FriendsFrameBattlenetFrame.BroadcastButton
	broadcastButton:SetSize(20, 20)
	broadcastButton:SkinButton(nil, true)

	local newIcon = broadcastButton:CreateTexture(nil, "ARTWORK")
	newIcon:SetAllPoints()
	newIcon:SetTexture("Interface\\FriendsFrame\\BroadcastIcon")
end

table_insert(Module.NewSkin["KkthnxUI"], SkinFriendsFrame)