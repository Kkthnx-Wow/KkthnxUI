local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

local function removeStyle(bar)
	bar.candyBarBackdrop:Hide()
	local height = bar:Get("bigwigs:restoreheight")
	if height then
		bar:SetHeight(height)
	end

	local tex = bar:Get("bigwigs:restoreicon")
	if tex then
		bar:SetIcon(tex)
		bar:Set("bigwigs:restoreicon", nil)
		bar.candyBarIconFrameBackdrop:Hide()
	end

	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
	bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)
	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
	bar.candyBarLabel:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)
end

local function styleBar(bar)
	local height = bar:GetHeight()
	bar:Set("bigwigs:restoreheight", height)
	bar:SetHeight(height / 2)
	bar.candyBarBackdrop:Hide()

	if not bar.styled then
		bar.candyBarBar:StripTextures()
		bar.candyBarBar:CreateBorder()

		if not bar.spark then
			bar.spark = bar.candyBarBar:CreateTexture(nil, "OVERLAY")
			bar.spark:SetTexture(C["Media"].Textures.Spark16Texture)
			bar.spark:SetHeight(height / 2)
			bar.spark:SetBlendMode("ADD")
			bar.spark:SetPoint("CENTER", bar.candyBarBar:GetStatusBarTexture(), "RIGHT", 0, 0)
			bar.spark = true
		end

		bar.styled = true
	end
	bar:SetTexture(K.GetTexture(C["General"].Texture))

	local tex = bar:GetIcon()
	if tex then
		local icon = bar.candyBarIconFrame
		bar:SetIcon(nil)
		icon:SetTexture(tex)
		icon:Show()
		if bar.iconPosition == "RIGHT" then
			icon:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", 6, 0)
		else
			icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -6, 0)
		end
		icon:SetSize(height, height)
		bar:Set("bigwigs:restoreicon", tex)
		bar.candyBarIconFrameBackdrop:Hide()

		if not icon.styled then
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			icon.border = CreateFrame("Frame", nil, bar)
			icon.border:CreateBorder()
			icon.border:SetAllPoints(icon)
			icon.border:SetFrameLevel(bar:GetFrameLevel())
			icon.styled = true
		end
	end

	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:SetPoint("LEFT", bar.candyBarBar, "LEFT", 2, 8)
	bar.candyBarLabel:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 8)
	bar.candyBarLabel:SetFontObject(K.UIFont)
	bar.candyBarLabel.SetFont = K.Noop

	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 8)
	bar.candyBarDuration:SetPoint("LEFT", bar.candyBarBar, "LEFT", 2, 8)
	bar.candyBarDuration:SetFontObject(K.UIFont)
	bar.candyBarDuration.SetFont = K.Noop
end

local styleData = {
	apiVersion = 1,
	version = 3,
	GetSpacing = function(bar)
		return bar:GetHeight() + 6
	end,
	ApplyStyle = styleBar,
	BarStopped = removeStyle,
	barHeight = 24,
	fontSizeNormal = 12,
	fontSizeEmphasized = 14,
	fontOutline = "NONE",
	GetStyleName = function()
		return "KkthnxUI"
	end,
}

function Module:RegisterBigWigs()
	if not C["Skins"].BigWigs then
		return
	end

	if not BigWigsAPI then
		return
	end

	BigWigsAPI:RegisterBarStyle("KkthnxUI", styleData)

	local pending = true
	hooksecurefunc(BigWigsAPI, "GetBarStyle", function()
		if pending then
			BigWigsAPI.GetBarStyle = function()
				return styleData
			end
			pending = nil
		end
	end)
end

function Module:ReskinBigWigs()
	if not C["Skins"].BigWigs then
		return
	end

	if BigWigsLoader then
		BigWigsLoader.RegisterMessage("KkthnxUI", "BigWigs_FrameCreated", function(_, frame, name)
			if name == "QueueTimer" and not frame.styled then
				frame:SetHeight(18)
				frame:StripTextures()

				if not frame.spark then
					frame.spark = frame:CreateTexture(nil, "OVERLAY")
					frame.spark:SetTexture(C["Media"].Textures.Spark16Texture)
					frame.spark:SetHeight(18)
					frame.spark:SetBlendMode("ADD")
					frame.spark:SetPoint("CENTER", frame:GetStatusBarTexture(), "RIGHT", 0, 0)
					frame.spark = true
				end

				frame:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
				frame:CreateBorder()

				frame.styled = true
			end
		end)
	end
end

Module:RegisterSkin("BigWigs", Module.ReskinBigWigs)
Module:RegisterSkin("BigWigs_Plugins", Module.RegisterBigWigs)
