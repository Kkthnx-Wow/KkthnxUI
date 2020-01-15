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

	-- do
	-- 	_G.FriendsTabHeaderRecruitAFriendButton:SetSize(22, 22)
	-- 	_G.FriendsTabHeaderRecruitAFriendButton:CreateBorder()
	-- 	_G.FriendsTabHeaderRecruitAFriendButton:StyleButton()
	-- 	_G.FriendsTabHeaderRecruitAFriendButton:CreateInnerShadow()
	-- 	_G.FriendsTabHeaderRecruitAFriendButtonIcon:SetDrawLayer("OVERLAY")
	-- 	_G.FriendsTabHeaderRecruitAFriendButtonIcon:SetTexCoord(_G.unpack(K.TexCoords))
	-- 	_G.FriendsTabHeaderRecruitAFriendButtonIcon:SetAllPoints()
	-- end

	do
		if not IsAddOnLoaded("ConsolePortUI_Menu") then
			-- -- reskin all esc/menu buttons
			-- for _, Button in pairs({_G.GameMenuFrame:GetChildren()}) do
			-- 	if Button.IsObjectType and Button:IsObjectType("Button") then
			-- 		Button:SkinButton()
			-- 	end
			-- end

			-- _G.GameMenuFrame:StripTextures()
			-- _G.GameMenuFrame:CreateBorder()
			-- _G.GameMenuFrameHeader:SetTexture()
			-- _G.GameMenuFrameHeader:ClearAllPoints()
			-- _G.GameMenuFrameHeader:SetPoint("TOP", _G.GameMenuFrame, 0, 7)
		end
	end
end

local function SkinDebugTools()
	-- EventTraceFrame
	_G.EventTraceFrame:CreateBorder(nil, nil, nil, true)
	_G.EventTraceFrameCloseButton:SkinCloseButton()
end

table_insert(Module.NewSkin["KkthnxUI"], SkinMiscStuff)
Module.NewSkin["Blizzard_DebugTools"] = SkinDebugTools