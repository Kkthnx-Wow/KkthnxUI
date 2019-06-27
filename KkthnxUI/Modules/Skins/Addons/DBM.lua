local K, C = unpack(select(2, ...))
if not (C["Skins"].DBM and K.CheckAddOnState("DBM-Core") and K.CheckAddOnState("DBM-StatusBarTimers") and K.CheckAddOnState("DBM-DefaultSkin")) then
	return
end

--local DBMFont = K.GetFont(C["UIFonts"].SkinFonts)
--local DBMTexture = K.GetTexture(C["UITextures"].SkinTextures)

local _G = _G

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc

local DBM_Skin = CreateFrame("Frame")
DBM_Skin:RegisterEvent("ADDON_LOADED")
DBM_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
DBM_Skin:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		local function SkinBars(self)
			for bar in self:GetBarIterator() do
				if not bar.injected then
					hooksecurefunc(bar, "Update", function()
						local sparkEnabled = bar.owner.options.Style ~= "BigWigs" and bar.owner.options.Spark
						if not sparkEnabled then return end
						local spark = _G[bar.frame:GetName().."BarSpark"]
						spark:SetSize(12, bar.owner.options.Height * 3/2 - 2)
						local a, b, c, d = spark:GetPoint()
						spark:SetPoint(a, b, c, d, 0)
					end)

					hooksecurefunc(bar, "ApplyStyle", function()
						local frame = bar.frame
						local tbar = _G[frame:GetName().."Bar"]
						local icon1 = _G[frame:GetName().."BarIcon1"]
						local icon2 = _G[frame:GetName().."BarIcon2"]
						local name = _G[frame:GetName().."BarName"]
						local timer = _G[frame:GetName().."BarTimer"]

						if not icon1.overlay then
							icon1.overlay = CreateFrame("Frame", "$parentIcon1Overlay", tbar)
							icon1.overlay:CreateShadow()
							icon1.overlay:SetFrameLevel(0)
							icon1.overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -4, 0)

							icon1.overlay.background = icon1.overlay:CreateTexture(nil, "BORDER")
							icon1.overlay.background:SetAllPoints()
							icon1.overlay.background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
						end

						if not icon2.overlay then
							icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", tbar)
							icon2.overlay:CreateShadow()
							icon2.overlay:SetFrameLevel(0)
							icon2.overlay:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 0)

							icon2.overlay.background = icon2.overlay:CreateTexture(nil, "BORDER")
							icon2.overlay.background:SetAllPoints()
							icon2.overlay.background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
						end

						icon1:SetTexCoord(0.1, 0.9, 0.1, 0.9)
						icon1:ClearAllPoints()
						icon1:SetAllPoints(icon1.overlay)

						icon2:SetTexCoord(0.1, 0.9, 0.1, 0.9)
						icon2:ClearAllPoints()
						icon2:SetAllPoints(icon2.overlay)

						icon1.overlay:SetSize(bar.owner.options.Height, bar.owner.options.Height)
						icon2.overlay:SetSize(bar.owner.options.Height, bar.owner.options.Height)

						tbar:SetAllPoints(frame)

						frame:CreateShadow(true)

						name:ClearAllPoints()
						name:SetWidth(165)
						name:SetHeight(8)
						name:SetJustifyH("LEFT")
						name:SetShadowColor(0, 0, 0, 0)

						timer:ClearAllPoints()
						timer:SetJustifyH("RIGHT")
						timer:SetShadowColor(0, 0, 0, 0)

						frame:SetHeight(bar.owner.options.Height)
						name:SetPoint("LEFT", frame, "LEFT", 4, 0)
						timer:SetPoint("RIGHT", frame, "RIGHT", -4, 0)

						timer:SetFont(C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)
						name:SetFont(C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)

						if bar.owner.options.IconLeft then
							icon1.overlay:Show()
						else
							icon1.overlay:Hide()
						end

						if bar.owner.options.IconRight then
							icon2.overlay:Show()
						else
							icon2.overlay:Hide()
						end

						bar.injected = true
					end)
					bar:ApplyStyle()
				end
			end
		end

		local function SkinRange(_, _, _, forceshow)
			if DBM.Options.DontShowRangeFrame and not forceshow then return end
			if DBMRangeCheck then
				DBMRangeCheck:StripTextures()
				DBMRangeCheck:CreateShadow(true)
				DBMRangeCheckRadar:StripTextures()
				DBMRangeCheckRadar:CreateShadow(true)
			end
		end

		local function SkinInfo()
			if DBM.Options.DontShowInfoFrame and (event or 0) ~= "test" then return end
			if DBMInfoFrame then
				DBMInfoFrame:StripTextures()
				DBMInfoFrame:CreateShadow(true)
			end
		end

		hooksecurefunc(DBT, "CreateBar", SkinBars)
		hooksecurefunc(DBM.RangeCheck, "Show", SkinRange)
		hooksecurefunc(DBM.InfoFrame, "Show", SkinInfo)
	end
end)