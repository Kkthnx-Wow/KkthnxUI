local K, C, L = unpack(select(2, ...))
if C["Skins"].BigWigs ~= true or not K.IsAddOnEnabled("BigWigs") then return end

local _G = _G
local table_remove = table.remove

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

-- GLOBALS: BigWigs, BigWigsLoader

local BigWigsFont = K.GetFont(C["Skins"].Font)
local BigWigsTexture = K.GetTexture(C["Skins"].Texture)

local BigWigs_Skin = CreateFrame("Frame")
BigWigs_Skin:RegisterEvent("ADDON_LOADED")
BigWigs_Skin:SetScript("OnEvent", function(_, event, addon)
	if event == "PLAYER_ENTERING_WORLD" then
		if BigWigsLoader then
			BigWigsLoader.RegisterMessage("KkthnxUI", "BigWigs_FrameCreated", function(event, frame, name)
				if name == "QueueTimer" then
					frame:SetStatusBarTexture(BigWigsTexture)
					frame:ClearAllPoints()
					frame:SetPoint("TOP", "$parent", "BOTTOM", 0, -(2 and 2 or 4))
					frame:SetHeight(16)
				end
			end)
		end
	end

	if event == "ADDON_LOADED" and addon == "BigWigs_Plugins" then
		BigWigs_Skin:UnregisterEvent("ADDON_LOADED")

		local buttonsize = 19
		local FreeBackgrounds = {}

		local CreateBG = function()
			local BG = CreateFrame("Frame")
			BG:SetTemplate("Transparent", true)
			return BG
		end

		local function FreeStyle(bar)
			local bg = bar:Get("bigwigs:KkthnxUI:bg")
			if bg then
				bg:ClearAllPoints()
				bg:SetParent(UIParent)
				bg:Hide()
				FreeBackgrounds[#FreeBackgrounds + 1] = bg
			end

			local ibg = bar:Get("bigwigs:KkthnxUI:ibg")
			if ibg then
				ibg:ClearAllPoints()
				ibg:SetParent(UIParent)
				ibg:Hide()
				FreeBackgrounds[#FreeBackgrounds + 1] = ibg
			end

			bar.candyBarIconFrame:ClearAllPoints()
			bar.candyBarIconFrame.SetWidth = nil
			bar.candyBarIconFrame:SetPoint("TOPLEFT")
			bar.candyBarIconFrame:SetPoint("BOTTOMLEFT")

			bar.candyBarBar:ClearAllPoints()
			bar.candyBarBar.SetPoint = nil
			bar.candyBarBar:SetPoint("TOPRIGHT")
			bar.candyBarBar:SetPoint("BOTTOMRIGHT")
		end

		local function ApplyStyle(bar)
			bar:SetHeight(buttonsize)

			local bg
			if #FreeBackgrounds > 0 then
				bg = table_remove(FreeBackgrounds)
			else
				bg = CreateBG()
			end

			bg:SetParent(bar)
			bg:SetFrameStrata(bar:GetFrameStrata())
			bg:SetFrameLevel(bar:GetFrameLevel() + 1)
			bg:ClearAllPoints()
			bg:SetPoint("TOPLEFT", bar, "TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
			bg:SetTemplate("Transparent", true)
			bg:Show()
			bar:Set("bigwigs:KkthnxUI:bg", bg)

			if bar.candyBarIconFrame:GetTexture() then
				local ibg
				if #FreeBackgrounds > 0 then
					ibg = table_remove(FreeBackgrounds)
				else
					ibg = CreateBG()
				end
				ibg:SetParent(bar)
				ibg:SetFrameStrata(bar:GetFrameStrata())
				ibg:SetFrameLevel(bar:GetFrameLevel())
				ibg:ClearAllPoints()
				ibg:SetPoint("TOPLEFT", bar.candyBarIconFrame, "TOPLEFT")
				ibg:SetPoint("BOTTOMRIGHT", bar.candyBarIconFrame, "BOTTOMRIGHT")
				ibg:SetTemplate("Transparent", true)
				ibg:Show()
				bar:Set("bigwigs:KkthnxUI:ibg", ibg)
			end

			bar.candyBarBar:ClearAllPoints()
			bar.candyBarBar:SetAllPoints(bar)
			bar.candyBarBar.SetPoint = K.Noop
			bar.candyBarBar:SetStatusBarTexture(BigWigsTexture)

			bar.candyBarBackground:SetTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			bar.candyBarIconFrame:ClearAllPoints()
			bar.candyBarIconFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -6, 0)
			bar.candyBarIconFrame:SetSize(buttonsize, buttonsize)
			bar.candyBarIconFrame.SetWidth = K.Noop

			bar.candyBarLabel:ClearAllPoints()
			bar.candyBarLabel:SetPoint("LEFT", bar, "LEFT", 2, 0)
			bar.candyBarLabel:SetPoint("RIGHT", bar, "RIGHT", -2, 0)

			bar.candyBarDuration:ClearAllPoints()
			bar.candyBarDuration:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
			bar.candyBarDuration:SetPoint("LEFT", bar, "LEFT", 2, 0)

			bar.candyBarIconFrame:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end

		local BigWigsBars = BigWigs:GetPlugin("Bars", true)
		if BigWigsBars then
			BigWigsBars:RegisterBarStyle("KkthnxUI", {
				apiVersion = 1,
				version = 1,
				GetSpacing = function() return 4 end,
				ApplyStyle = ApplyStyle,
				BarStopped = FreeStyle,
				GetStyleName = function() return "KkthnxUI" end,
			})
		end
		BigWigsBars.defaultDB.barStyle = "KkthnxUI"
	end
end)