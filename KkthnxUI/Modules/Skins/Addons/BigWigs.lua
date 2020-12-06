local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local BigWigsFont = K.GetFont(C["UIFonts"].SkinFonts)
local BigWigsTexture = K.GetTexture(C["UITextures"].SkinTextures)

function Module:ReskinBigWigs()
	if not C["Skins"].BigWigs or not IsAddOnLoaded("BigWigs") then
		return
	end

	if not BigWigs3DB then
		return
	end

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
		bar:SetTexture(BigWigsTexture)

		local bd = bar.candyBarBackdrop
		bd:CreateShadow(true)
		bd:ClearAllPoints()
		bd:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
		bd:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, -0)
		bd:Show()

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

			local iconBd = bar.candyBarIconFrameBackdrop
			iconBd:CreateShadow(true)
			iconBd:ClearAllPoints()
			iconBd:SetPoint("TOPLEFT", icon, "TOPLEFT", -0, 0)
			iconBd:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, -0)
			iconBd:Show()
		end

		bar.candyBarLabel:ClearAllPoints()
		bar.candyBarLabel:SetPoint("LEFT", bar.candyBarBar, "LEFT", 2, 8)
		bar.candyBarLabel:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 8)
		bar.candyBarLabel:SetFontObject(BigWigsFont)
		bar.candyBarLabel.SetFont = K.Noop
		bar.candyBarDuration:ClearAllPoints()
		bar.candyBarDuration:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 8)
		bar.candyBarDuration:SetPoint("LEFT", bar.candyBarBar, "LEFT", 2, 8)
		bar.candyBarDuration:SetFontObject(BigWigsFont)
		bar.candyBarDuration.SetFont = K.Noop
	end

	local function registerStyle()
		local bars = BigWigs:GetPlugin("Bars", true)
		bars:RegisterBarStyle("KkthnxUI", {
			apiVersion = 1,
			version = 2,
			GetSpacing = function(bar)
				return bar:GetHeight() + 5
			end,
			ApplyStyle = styleBar,
			BarStopped = removeStyle,
			GetStyleName = function()
				return "KkthnxUI"
			end,
		})
	end

	if IsAddOnLoaded("BigWigs_Plugins") then
		registerStyle()
	else
		local function loadStyle(event, addon)
			if addon == "BigWigs_Plugins" then
				registerStyle()
				K:UnregisterEvent(event, loadStyle)
			end
		end
		K:RegisterEvent("ADDON_LOADED", loadStyle)
	end
end