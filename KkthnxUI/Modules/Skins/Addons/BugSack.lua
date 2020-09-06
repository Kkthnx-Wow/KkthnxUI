local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local IsAddOnLoaded = _G.IsAddOnLoaded
local hooksecurefunc = _G.hooksecurefunc

function Module:ReskinBugSack()
	if not IsAddOnLoaded("BugSack") then
		return
	end

	hooksecurefunc(BugSack, "OpenSack", function()
		if BugSackFrame.IsSkinned then
			return
		end

		BugSackFrame:StripTextures()
		BugSackFrame:CreateBorder()
		BugSackTabAll:StripTextures()
		BugSackTabAll:CreateBorder(nil, nil, nil, nil, -10, nil, nil, nil, nil, nil, nil, nil, 6)
		BugSackTabAll:SetPoint("TOPLEFT", BugSackFrame, "BOTTOMLEFT", 0, 1)
		BugSackTabSession:StripTextures()
		BugSackTabSession:CreateBorder(nil, nil, nil, nil, -10, nil, nil, nil, nil, nil, nil, nil, 6)
		BugSackTabLast:StripTextures()
		BugSackTabLast:CreateBorder(nil, nil, nil, nil, -10, nil, nil, nil, nil, nil, nil, nil, 6)

		BugSackNextButton:SkinButton()
		BugSackSendButton:SkinButton()
		BugSackSendButton:SetPoint("LEFT", BugSackPrevButton, "RIGHT", 6, 0)
		BugSackSendButton:SetPoint("RIGHT", BugSackNextButton, "LEFT", -6, 0)
		BugSackPrevButton:SkinButton()
		BugSackScrollScrollBar:SkinScrollBar()

		for _, child in pairs({BugSackFrame:GetChildren()}) do
			if (child:IsObjectType("Button") and child:GetScript("OnClick") == BugSack.CloseSack) then
				child:SkinCloseButton()
			end
		end

		BugSackFrame.IsSkinned = true
	end)
end