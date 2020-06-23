local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

local function SkinStatusBar(bar)
	bar:StripTextures()
	bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
	bar:SetStatusBarColor(4/255, 179/255, 30/255)
	bar:CreateBorder()

	local StatusBarName = bar:GetName()
	if _G[StatusBarName.."Title"] then
		_G[StatusBarName.."Title"]:SetPoint("LEFT", 4, 0)
	end

	if _G[StatusBarName.."Label"] then
		_G[StatusBarName.."Label"]:SetPoint("LEFT", 4, 0)
	end

	if _G[StatusBarName.."Text"] then
		_G[StatusBarName.."Text"]:SetPoint("RIGHT", -4, 0)
	end
end

local function SkinMiscStuff()
	-- reskin popup buttons
	for i = 1, 4 do
		local StaticPopup = _G["StaticPopup"..i]
		StaticPopup:HookScript("OnShow", function() -- UpdateRecapButton is created OnShow
			if StaticPopup.UpdateRecapButton and (not StaticPopup.UpdateRecapButtonHooked) then
				StaticPopup.UpdateRecapButtonHooked = true -- we should only hook this once
				-- hooksecurefunc(_G["StaticPopup"..i], "UpdateRecapButton", S.UpdateRecapButton)
			end
		end)
		StaticPopup:CreateBorder(nil, nil, nil, true)

		for j = 1, 4 do
			local button = StaticPopup["button"..j]
			button:SkinButton()

			button.Flash:Hide()

			button:CreateShadow()
			button.Shadow:SetAlpha(0)
			button.Shadow:SetBackdropBorderColor(1, 1, 1)

			local anim1, anim2 = button.PulseAnim:GetAnimations()
			anim1:SetTarget(button.Shadow)
			anim2:SetTarget(button.Shadow)
		end

		_G["StaticPopup"..i.."EditBox"]:SetFrameLevel(_G["StaticPopup"..i.."EditBox"]:GetFrameLevel() + 1)
		Module:SkinEditBox(_G["StaticPopup"..i.."EditBox"])
		Module:SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		Module:SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		Module:SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])
		_G["StaticPopup"..i.."EditBox"].Backdrop:SetPoint("TOPLEFT", 0, -6)
		_G["StaticPopup"..i.."EditBox"].Backdrop:SetPoint("BOTTOMRIGHT", 0, 6)
		_G["StaticPopup"..i.."ItemFrameNameFrame"]:Kill()
		_G["StaticPopup"..i.."ItemFrame"]:CreateBorder()
		_G["StaticPopup"..i.."ItemFrame"]:StyleButton()
		_G["StaticPopup"..i.."ItemFrame"].IconBorder:SetAlpha(0)
		_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(unpack(K.TexCoords))
		_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetAllPoints()

		local normTex = _G["StaticPopup"..i.."ItemFrame"]:GetNormalTexture()
		if normTex then
			normTex:SetTexture()
			hooksecurefunc(normTex, "SetTexture", function(s, tex)
				if tex ~= nil then
					s:SetTexture()
				end
			end)
		end

		-- Quality IconBorder
		hooksecurefunc(_G["StaticPopup"..i.."ItemFrame"].IconBorder, "SetVertexColor", function(s, r, g, b)
			s:GetParent():SetBackdropBorderColor(r, g, b)
			s:SetTexture()
		end)

		hooksecurefunc(_G["StaticPopup"..i.."ItemFrame"].IconBorder, "Hide", function(s)
			s:GetParent():SetBackdropBorderColor()
		end)
	end

	do
		_G.GhostFrameMiddle:SetAlpha(0)
		_G.GhostFrameRight:SetAlpha(0)
		_G.GhostFrameLeft:SetAlpha(0)
		_G.GhostFrame:StripTextures(true)
		_G.GhostFrame:SkinButton()
		_G.GhostFrame:ClearAllPoints()
		_G.GhostFrame:SetPoint("TOP", _G.UIParent, "TOP", 0, -90)
		_G.GhostFrameContentsFrameText:SetPoint("TOPLEFT", 53, 0)
		_G.GhostFrameContentsFrameIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		_G.GhostFrameContentsFrameIcon:SetPoint("RIGHT", _G.GhostFrameContentsFrameText, "LEFT", -12, 0)

		local iconBorderFrame = _G.CreateFrame("Frame", nil, _G.GhostFrameContentsFrameIcon:GetParent())
		iconBorderFrame:SetAllPoints(_G.GhostFrameContentsFrameIcon)

		_G.GhostFrameContentsFrameIcon:SetSize(37, 38)
		_G.GhostFrameContentsFrameIcon:SetParent(iconBorderFrame)

		iconBorderFrame:CreateBorder()
		iconBorderFrame:CreateInnerShadow()
	end
end

local function SkinDebugTools()
	if not IsAddOnLoaded("Blizzard_DebugTools") then
		return
	end

	-- EventTraceFrame
	EventTraceFrame:CreateBorder(nil, nil, nil, true)
	EventTraceFrameCloseButton:SkinCloseButton()
end

local function SkinAchievementBars()
	if not IsAddOnLoaded("Blizzard_AchievementUI") then
		return
	end

	SkinStatusBar(_G.AchievementFrameSummaryCategoriesStatusBar)
	SkinStatusBar(_G.AchievementFrameComparisonSummaryPlayerStatusBar)
	SkinStatusBar(_G.AchievementFrameComparisonSummaryFriendStatusBar)

	for i = 1, 12 do
		local frame = _G["AchievementFrameSummaryCategoriesCategory"..i]
		local button = _G["AchievementFrameSummaryCategoriesCategory"..i.."Button"]
		local highlight = _G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]

		SkinStatusBar(frame)
		button:StripTextures()
		highlight:StripTextures()

		_G[highlight:GetName().."Middle"]:SetColorTexture(1, 1, 1, 0.3)
		_G[highlight:GetName().."Middle"]:SetAllPoints(frame)
	end
end

table_insert(Module.NewSkin["KkthnxUI"], SkinMiscStuff)
Module.NewSkin["Blizzard_DebugTools"] = SkinDebugTools
Module.NewSkin["Blizzard_AchievementUI"] = SkinAchievementBars