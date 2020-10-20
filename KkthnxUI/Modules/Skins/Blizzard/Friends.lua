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

	local friendsBNetFrame = FriendsFrameBattlenetFrame
	local broadcastButton = friendsBNetFrame.BroadcastButton

	friendsBNetFrame:GetRegions():Hide()
	local bg = CreateFrame("Frame", nil, friendsBNetFrame)
	bg:SetFrameLevel(friendsBNetFrame:GetFrameLevel())
	bg:SetPoint("TOPLEFT", 4, -4)
	bg:SetPoint("BOTTOMRIGHT", -4, 5)
	bg:CreateBorder()
	bg.KKUI_Background:SetVertexColor(0, 0.6, 1, 0.25)

	broadcastButton:SetSize(20, 20)
	broadcastButton:SkinButton(nil, true)

	local newBroadcastButton = broadcastButton:CreateTexture(nil, "ARTWORK")
	newBroadcastButton:SetAllPoints()
	newBroadcastButton:SetTexture("Interface\\FriendsFrame\\BroadcastIcon")

	local function BroadcastButton_SetTexture(self)
		self.BroadcastButton:SetNormalTexture("")
		self.BroadcastButton:SetPushedTexture("")
	end
	hooksecurefunc(friendsBNetFrame.BroadcastFrame, "ShowFrame", BroadcastButton_SetTexture)
	hooksecurefunc(friendsBNetFrame.BroadcastFrame, "HideFrame", BroadcastButton_SetTexture)
end

table_insert(Module.NewSkin["KkthnxUI"], SkinFriendsFrame)