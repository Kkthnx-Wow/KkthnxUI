local K, C, L = unpack(select(2, ...))
if C["Skins"].DBM ~= true or not (K.CheckAddOnState("DBM-Core") and K.CheckAddOnState("DBM-StatusBarTimers")) then return end

local DBMFont = K.GetFont(C["Skins"].Font)
local DBMTexture = K.GetTexture(C["Skins"].Texture)

local _G = _G

local hooksecurefunc = hooksecurefunc

local DBM_Skin = CreateFrame("Frame")
DBM_Skin:RegisterEvent("ADDON_LOADED")
DBM_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
DBM_Skin:SetScript("OnEvent", function(self, event, addon)
	if event == "PLAYER_ENTERING_WORLD" then
		local croprwicons = true
		local BarHeight
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
							icon1.overlay:CreateShadow(1)
							icon1.overlay:SetBackdrop(K.BorderBackdrop)
							icon1.overlay:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
							icon1.overlay:SetFrameLevel(0)
							icon1.overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -(0 and 0 or 0), 0)
						end

						if not icon2.overlay then
							icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", tbar)
							icon2.overlay:CreateShadow(1)
							icon2.overlay:SetBackdrop(K.BorderBackdrop)
							icon2.overlay:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
							icon2.overlay:SetFrameLevel(0)
							icon2.overlay:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", (0 and 0 or 0), 0)
						end

						icon1:SetTexCoord(0.1, 0.9, 0.1, 0.9)
						icon1:ClearAllPoints()
						icon1:SetAllPoints(icon1.overlay)

						icon2:SetTexCoord(0.1, 0.9, 0.1, 0.9)
						icon2:ClearAllPoints()
						icon2:SetAllPoints(icon2.overlay)

						icon1.overlay:SetSize(bar.owner.options.Height, bar.owner.options.Height)
						icon2.overlay:SetSize(bar.owner.options.Height, bar.owner.options.Height)
						BarHeight = bar.owner.options.Height
						tbar:SetAllPoints(frame)

						frame:CreateShadow(1)
						frame:SetBackdrop(K.BorderBackdrop)
						frame:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

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

						if bar.owner.options.IconLeft then icon1.overlay:Show() else icon1.overlay:Hide() end
						if bar.owner.options.IconRight then icon2.overlay:Show() else icon2.overlay:Hide() end

						bar.injected = true
					end)
					bar:ApplyStyle()
				end
			end
		end

		local function SkinRange(self, range, filter, forceshow, redCircleNumPlayers)
			if DBM.Options.DontShowRangeFrame and not forceshow then return end
			if DBMRangeCheck then
				DBMRangeCheck:CreateShadow()
				DBMRangeCheckRadar:CreateShadow()
			end
		end

		local function SkinInfo(self, maxLines, event, ...)
			if DBM.Options.DontShowInfoFrame and (event or 0) ~= "test" then return end
			if DBMInfoFrame then
				DBMInfoFrame:CreateShadow()
				DBMInfoFrame.Shadow:SetAllPoints()
			end
		end

		hooksecurefunc(DBT, "CreateBar", SkinBars)
		hooksecurefunc(DBM.RangeCheck, "Show", SkinRange)
		hooksecurefunc(DBM.InfoFrame, "Show", SkinInfo)

		if croprwicons then
			local RaidNotice_AddMessage_ = RaidNotice_AddMessage
			RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo, displayTime)
				if textString:find("|T") then
					textString = gsub(textString,"(:12:12)",":18:18:0:0:64:64:5:59:5:59")
				end
				return RaidNotice_AddMessage_(noticeFrame, textString, colorInfo, displayTime)
			end
		end
	end
end)