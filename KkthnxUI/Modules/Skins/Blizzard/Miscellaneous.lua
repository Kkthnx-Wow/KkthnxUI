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

local function SkinDebugTools()
	-- EventTraceFrame
	EventTraceFrame:CreateBorder(nil, nil, nil, true)
	EventTraceFrameCloseButton:SkinCloseButton()
end

table_insert(Module.NewSkin["KkthnxUI"], SkinMiscStuff)
Module.NewSkin["Blizzard_DebugTools"] = SkinDebugTools