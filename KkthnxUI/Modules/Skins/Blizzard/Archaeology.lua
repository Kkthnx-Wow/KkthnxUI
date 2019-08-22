local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local function ReskinArchaeologyUI()
	_G.ArcheologyDigsiteProgressBar:StripTextures()

	_G.ArcheologyDigsiteProgressBar.FillBar:SetFrameLevel(_G.ArcheologyDigsiteProgressBar:GetFrameLevel() + 1)
	_G.ArcheologyDigsiteProgressBar.FillBar:StripTextures()
	_G.ArcheologyDigsiteProgressBar.FillBar:CreateBorder()
	_G.ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(C["Media"].Texture)
	_G.ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.2, 0)

	_G.ArcheologyDigsiteProgressBar.BarTitle:FontTemplate(nil, nil, "OUTLINE")
	_G.ArcheologyDigsiteProgressBar:ClearAllPoints()
	_G.ArcheologyDigsiteProgressBar:SetPoint("TOP", _G.UIParent, "TOP", 0, -400)

	_G.UIPARENT_MANAGED_FRAME_POSITIONS.ArcheologyDigsiteProgressBar = nil
	K.Mover(_G.ArcheologyDigsiteProgressBar, "DigSiteProgressBarMover", "DigSiteProgressBarMover", {"TOP", _G.UIParent, "TOP", 0, -400})
end

Module.NewSkin["Blizzard_ArchaeologyUI"] = ReskinArchaeologyUI