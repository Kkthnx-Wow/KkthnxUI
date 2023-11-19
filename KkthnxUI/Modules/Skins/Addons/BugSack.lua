local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

-- local C_AddOns.IsAddOnLoaded = C_AddOns.IsAddOnLoaded
-- local hooksecurefunc = hooksecurefunc

function Module:ReskinBugSack()
	-- if not C_AddOns.IsAddOnLoaded("BugSack") then
	-- 	return
	-- end

	-- hooksecurefunc(BugSack, "OpenSack", function()
	-- 	if BugSackFrame.IsSkinned then
	-- 		return
	-- 	end

	-- 	BugSackFrame:StripTextures()
	-- 	BugSackFrame:CreateBorder()
	-- 	BugSackTabAll:StripTextures()
	-- 	BugSackTabAll:CreateBorder(nil, nil, nil, nil, -10, nil, nil, nil, nil, 6)
	-- 	BugSackTabAll:SetPoint("TOPLEFT", BugSackFrame, "BOTTOMLEFT", 0, 1)
	-- 	BugSackTabSession:StripTextures()
	-- 	BugSackTabSession:CreateBorder(il, nil, nil, nil, -10, nil, nil, nil, nil, 6)
	-- 	BugSackTabLast:StripTextures()
	-- 	BugSackTabLast:CreateBorder(il, nil, nil, nil, -10, nil, nil, nil, nil, 6)

	-- 	BugSackNextButton:SkinButton()
	-- 	BugSackSendButton:SkinButton()
	-- 	BugSackSendButton:SetPoint("LEFT", BugSackPrevButton, "RIGHT", 6, 0)
	-- 	BugSackSendButton:SetPoint("RIGHT", BugSackNextButton, "LEFT", -6, 0)
	-- 	BugSackPrevButton:SkinButton()
	-- 	BugSackScrollScrollBar:SkinScrollBar()

	-- 	for _, child in pairs({ BugSackFrame:GetChildren() }) do
	-- 		if child:IsObjectType("Button") and child:GetScript("OnClick") == BugSack.CloseSack then
	-- 			child:SkinCloseButton()
	-- 		end
	-- 	end

	-- 	BugSackFrame.IsSkinned = true
	-- end)
end
