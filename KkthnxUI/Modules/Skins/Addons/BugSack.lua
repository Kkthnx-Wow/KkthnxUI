local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local hooksecurefunc = _G.hooksecurefunc

function Module:ReskinBugSack()
	if not K.CheckAddOnState("BugSack") then
		return
	end

	hooksecurefunc(BugSack, "OpenSack", function()
		if BugSackFrame.IsSkinned then
			return
		end

		BugSackFrame:CreateBorder(nil, nil, nil, true)
		BugSackTabAll:CreateBorder(nil, 10, 6, true)
		BugSackTabAll:SetPoint("TOPLEFT", BugSackFrame, "BOTTOMLEFT", 0, 1)
		BugSackTabSession:CreateBorder(nil, 10, 6, true)
		BugSackTabLast:CreateBorder(nil, 10, 6, true)
		BugSackNextButton:SkinButton()
		BugSackSendButton:SkinButton()
		BugSackSendButton:SetPoint("LEFT", BugSackPrevButton, "RIGHT", 6, 0)
		BugSackSendButton:SetPoint("RIGHT", BugSackNextButton, "LEFT", -6, 0)
		BugSackPrevButton:SkinButton()
		BugSackScrollScrollBar:SkinScrollBar()

		for _, child in pairs({BugSackFrame:GetChildren()}) do
			if (child:IsObjectType("Button") and child:GetScript('OnClick') == BugSack.CloseSack) then
				child:SkinCloseButton()
			end
		end

		BugSackFrame.IsSkinned = true
	end)
end