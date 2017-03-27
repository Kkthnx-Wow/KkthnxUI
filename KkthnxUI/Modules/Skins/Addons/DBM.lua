local K, C, L = unpack(select(2, ...))
if C.Skins.DBM ~= true or not (K.CheckAddOn("DBM-Core") and K.CheckAddOn("DBM-StatusBarTimers")) then return end

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
							icon1.overlay:SetFrameLevel(0)
							icon1.overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -(2 and 2 or 3), 0)
						end

						if not icon2.overlay then
							icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", tbar)
							icon2.overlay:CreateShadow(1)
							icon2.overlay:SetFrameLevel(0)
							icon2.overlay:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", (2 and 2 or 3), 0)
						end

						icon1:SetTexCoord(0.1, 0.9, 0.1, 0.9)
						icon1:ClearAllPoints()
						icon1:SetInside(icon1.overlay)

						icon2:SetTexCoord(0.1, 0.9, 0.1, 0.9)
						icon2:ClearAllPoints()
						icon2:SetInside(icon2.overlay)

						icon1.overlay:SetSize(bar.owner.options.Height, bar.owner.options.Height)
						icon2.overlay:SetSize(bar.owner.options.Height, bar.owner.options.Height)
						BarHeight = bar.owner.options.Height
						tbar:SetInside(frame)

						frame:CreateShadow(1)

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

						timer:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
						name:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)

						if bar.owner.options.IconLeft then icon1.overlay:Show() else icon1.overlay:Hide() end
						if bar.owner.options.IconRight then icon2.overlay:Show() else icon2.overlay:Hide() end

						bar.injected = true
					end)
					bar:ApplyStyle()
				end
			end
		end

		local SkinBoss = function()
			local count = 1
			while (_G[format("DBM_BossHealth_Bar_%d", count)]) do
				local bar = _G[format("DBM_BossHealth_Bar_%d", count)]
				local barname = bar:GetName()
				local background = _G[barname.."BarBorder"]
				local progress = _G[barname.."Bar"]
				local name = _G[barname.."BarName"]
				local timer = _G[barname.."BarTimer"]
				local pointa, anchor, pointb, _, _ = bar:GetPoint()

				if not pointa then return end
				bar:ClearAllPoints()

				bar:CreateShadow(1)

				background:SetNormalTexture(nil)

				progress:SetStatusBarTexture(C.Media.Texture)
				progress:ClearAllPoints()
				progress:SetInside(bar)

				name:ClearAllPoints()
				name:SetJustifyH("LEFT")
				name:SetShadowColor(0, 0, 0, 0)

				timer:ClearAllPoints()
				timer:SetJustifyH("RIGHT")
				timer:SetShadowColor(0, 0, 0, 0)

				local MainOffset, BarOffset
				bar:SetHeight(BarHeight or 22)
				name:SetPoint("LEFT", bar, "LEFT", 4, 0)
				timer:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
				MainOffset = 8
				BarOffset = 4

				local header = {bar:GetParent():GetRegions()}
				if header and header[1]:IsObjectType("FontString") then
					header[1]:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
					header[1]:SetTextColor(1, 1, 1)
					header[1]:SetShadowColor(0, 0, 0, 0)
				end

				name:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
				timer:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)

				if DBM.Options.HealthFrameGrowUp then
					bar:SetPoint(pointa, anchor, pointb, 0, count == 1 and MainOffset or BarOffset)
				else
					bar:SetPoint(pointa, anchor, pointb, 0, -(count == 1 and MainOffset or BarOffset))
				end

				count = count + 1
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
		hooksecurefunc(DBM.BossHealth, "Show", SkinBoss)
		hooksecurefunc(DBM.BossHealth, "AddBoss", SkinBoss)
		hooksecurefunc(DBM.BossHealth, "UpdateSettings", SkinBoss)
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