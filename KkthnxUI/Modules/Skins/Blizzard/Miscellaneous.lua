local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local table_insert = _G.table.insert

local function SkinMiscStuff()
	if K.CheckAddOnState("Skinner") or K.CheckAddOnState("Aurora") then
		return
	end

	do
		_G.GhostFrameMiddle:SetAlpha(0)
		_G.GhostFrameRight:SetAlpha(0)
		_G.GhostFrameLeft:SetAlpha(0)
		_G.GhostFrame:StripTextures(true)
		_G.GhostFrame:SkinButton()
		_G.GhostFrame:ClearAllPoints()
		_G.GhostFrame:SetPoint("TOP", UIParent, "TOP", 0, -40)
		_G.GhostFrameContentsFrameText:SetPoint("TOPLEFT", 53, 0)
		_G.GhostFrameContentsFrameIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		_G.GhostFrameContentsFrameIcon:SetPoint("RIGHT", _G.GhostFrameContentsFrameText, "LEFT", -12, 0)

		local iconBorderFrame = CreateFrame("Frame", nil, _G.GhostFrameContentsFrameIcon:GetParent())
		iconBorderFrame:SetAllPoints(_G.GhostFrameContentsFrameIcon)
		_G.GhostFrameContentsFrameIcon:SetSize(37, 38)
		_G.GhostFrameContentsFrameIcon:SetParent(iconBorderFrame)
		iconBorderFrame:CreateBorder()
		iconBorderFrame:CreateInnerShadow()
	end
end

local function SkinTestCraftingUI()
	local rankFrame = TradeSkillFrame.RankFrame
	rankFrame:SetStatusBarTexture(C["Media"].Texture)
	rankFrame.SetStatusBarColor = K.Noop
	rankFrame:GetStatusBarTexture():SetGradient("VERTICAL", 0.1, 0.3, 0.9, 0.2, 0.4, 1)
	rankFrame.RankText:FontTemplate(nil, 11)
	K.CreateBorder(rankFrame)
	rankFrame.BorderMid:Hide()
	rankFrame.BorderLeft:Hide()
	rankFrame.BorderRight:Hide()

	hooksecurefunc(TradeSkillFrame.DetailsFrame, "RefreshDisplay", function()
		local ResultIcon = TradeSkillFrame.DetailsFrame.Contents.ResultIcon
		ResultIcon:StyleButton()
		if ResultIcon:GetNormalTexture() then
			ResultIcon:GetNormalTexture():SetTexCoord(unpack(K.TexCoords))
			ResultIcon:GetNormalTexture():SetInside()
		end

		ResultIcon:CreateBorder()
		ResultIcon.IconBorder:SetTexture()
		ResultIcon.ResultBorder:SetTexture()

		for i = 1, #TradeSkillFrame.DetailsFrame.Contents.Reagents do
			local Button = TradeSkillFrame.DetailsFrame.Contents.Reagents[i]
			local Icon = Button.Icon
			local Count = Button.Count

			Icon:SetTexCoord(unpack(K.TexCoords))
			Icon:SetDrawLayer("OVERLAY")
			if not Icon.backdrop then
				Icon.backdrop = CreateFrame("Frame", nil, Button)
				Icon.backdrop:SetFrameLevel(Button:GetFrameLevel() - 1)
				Icon.backdrop:CreateBorder()
				Icon.backdrop:SetAllPoints(Icon)
			end

			Icon:SetParent(Icon.backdrop)
			Count:SetParent(Icon.backdrop)
			Count:SetDrawLayer("OVERLAY")

			Button.NameFrame:Kill()
		end
	end)
end

local function SkinDebugTools()
	-- EventTraceFrame
	EventTraceFrame:CreateBorder(nil, nil, nil, true)
	EventTraceFrameCloseButton:SkinCloseButton()

	EventTraceFrameScroll:SkinScrollBar()
end

table_insert(Module.NewSkin["KkthnxUI"], SkinMiscStuff)
Module.NewSkin["Blizzard_TradeSkillUI"] = SkinTestCraftingUI
Module.NewSkin["Blizzard_DebugTools"] = SkinDebugTools