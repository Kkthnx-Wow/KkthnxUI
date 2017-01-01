local K, C, L = unpack(select(2, ...))
if C.Skins.DBM ~= true then return end

local backdrop = {
	bgFile = C.Media.Blank,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local DBMSkin = CreateFrame("Frame")
DBMSkin:RegisterEvent("PLAYER_LOGIN")
DBMSkin:RegisterEvent("ADDON_LOADED")
DBMSkin:SetScript("OnEvent", function(self, event, addon)
	if K.CheckAddOn("DBM-Core") then
		local function SkinBars(self)
			for bar in self:GetBarIterator() do
				if not bar.injected then
					bar.ApplyStyle = function()
						local frame = bar.frame
						local tbar = _G[frame:GetName().."Bar"]
						local spark = _G[frame:GetName().."BarSpark"]
						local texture = _G[frame:GetName().."BarTexture"]
						local icon1 = _G[frame:GetName().."BarIcon1"]
						local icon2 = _G[frame:GetName().."BarIcon2"]
						local name = _G[frame:GetName().."BarName"]
						local timer = _G[frame:GetName().."BarTimer"]

						if icon1.overlay then
							icon1.overlay = _G[icon1.overlay:GetName()]
						else
							icon1.overlay = CreateFrame("Frame", "$parentIcon1Overlay", tbar)
							icon1.overlay:SetWidth(25)
							icon1.overlay:SetHeight(25)
							icon1.overlay:SetFrameStrata("BACKGROUND")
							icon1.overlay:SetPoint("BOTTOMRIGHT", tbar, "BOTTOMLEFT", -5, -2)
							K.CreateBorder(icon1.overlay, 1)
						end

						if icon2.overlay then
							icon2.overlay = _G[icon2.overlay:GetName()]
						else
							icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", tbar)
							icon2.overlay:SetWidth(25)
							icon2.overlay:SetHeight(25)
							icon2.overlay:SetFrameStrata("BACKGROUND")
							icon2.overlay:SetPoint("BOTTOMLEFT", tbar, "BOTTOMRIGHT", 5, -2)
							K.CreateBorder(icon2.overlay, 1)
						end

						if bar.color then
							tbar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
							tbar:SetBackdrop(backdrop)
							tbar:SetBackdropColor(bar.color.r, bar.color.g, bar.color.b, 0.15)
						else
							tbar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
							tbar:SetBackdrop(backdrop)
							tbar:SetBackdropColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB, 0.15)
						end

						if bar.enlarged then frame:SetWidth(bar.owner.options.HugeWidth) else frame:SetWidth(bar.owner.options.Width) end
						if bar.enlarged then tbar:SetWidth(bar.owner.options.HugeWidth) else tbar:SetWidth(bar.owner.options.Width) end

						if not frame.styled then
							frame:SetScale(1)
							frame:SetHeight(19)
							K.CreateBorder(frame, 1)
							frame.styled = true
						end

						if not spark.killed then
							spark:SetAlpha(0)
							spark:SetTexture(nil)
							spark.killed = true
						end

						if not icon1.styled then
							icon1:SetTexCoord(0.1, 0.9, 0.1, 0.9)
							icon1:ClearAllPoints()
							icon1:SetPoint("TOPLEFT", icon1.overlay, 2, -2)
							icon1:SetPoint("BOTTOMRIGHT", icon1.overlay, -2, 2)
							icon1.styled = true
						end

						if not icon2.styled then
							icon2:SetTexCoord(0.1, 0.9, 0.1, 0.9)
							icon2:ClearAllPoints()
							icon2:SetPoint("TOPLEFT", icon2.overlay, 2, -2)
							icon2:SetPoint("BOTTOMRIGHT", icon2.overlay, -2, 2)
							icon2.styled = true
						end

						if not texture.styled then
							texture:SetTexture(C.Media.Texture)
							texture.styled = true
						end

						if not tbar.styled then
							tbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
							tbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
							tbar.styled = true
						end

						if not name.styled then
							name:ClearAllPoints()
							name:SetPoint("LEFT", frame, "LEFT", 4, 0)
							name:SetWidth(165)
							name:SetHeight(8)
							name:SetFont(C.Media.Font, C.Media.Font_Size, "")
							name:SetShadowOffset(K.Mult, -K.Mult)
							name:SetJustifyH("LEFT")
							name.SetFont = K.Noop
							name.styled = true
						end

						if not timer.styled then
							timer:ClearAllPoints()
							timer:SetPoint("RIGHT", frame, "RIGHT", -1, 0)
							timer:SetFont(C.Media.Font, C.Media.Font_Size, "")
							timer:SetShadowOffset(K.Mult, -K.Mult)
							timer:SetJustifyH("RIGHT")
							timer.SetFont = K.Noop
							timer.styled = true
						end

						if bar.owner.options.IconLeft then icon1:Show() icon1.overlay:Show() else icon1:Hide() icon1.overlay:Hide() end
						if bar.owner.options.IconRight then icon2:Show() icon2.overlay:Show() else icon2:Hide() icon2.overlay:Hide() end
						tbar:SetAlpha(1)
						frame:SetAlpha(1)
						texture:SetAlpha(1)
						frame:Show()
						bar:Update(0)
						bar.injected = true
					end
					bar:ApplyStyle()
					bar.ApplyPosition = function()
						if C.Unitframe.Enable ~= true or C.Skins.DBMMove == true then return end
						self.mainAnchor:ClearAllPoints()
						if C.Unitframe.Enable == true then
							if bar.owner.options.IconRight then
								self.mainAnchor:SetPoint("BOTTOMRIGHT", "oUF_KkthnxPlayer", "BOTTOMLEFT", -148, -20)
							else
								self.mainAnchor:SetPoint("BOTTOMRIGHT", "oUF_KkthnxPlayer", "BOTTOMLEFT", -120, -20)
							end
						else
							if bar.owner.options.IconRight then
								self.mainAnchor:SetPoint("BOTTOMRIGHT", "oUF_KkthnxPlayer", "BOTTOMLEFT", -131, -20)
							else
								self.mainAnchor:SetPoint("BOTTOMRIGHT", "oUF_KkthnxPlayer", "BOTTOMLEFT", -103, -20)
							end
						end
					end
					bar:ApplyPosition()
				end
			end
		end

		local SkinBossTitle = function()
			local anchor = DBMBossHealthDropdown:GetParent()
			if not anchor.styled then
				local header = {anchor:GetRegions()}
				if header[1]:IsObjectType("FontString") then
					header[1]:SetFont(C.Media.Font, C.Media.Font_Size, "")
					header[1]:SetShadowOffset(K.Mult, -K.Mult)
					header[1]:SetTextColor(1, 1, 1, 1)
					anchor.styled = true
				end
				header = nil
			end
			anchor = nil
		end

		local SkinBoss = function()
			local count = 1
			while (_G[format("DBM_BossHealth_Bar_%d", count)]) do
				local bar = _G[format("DBM_BossHealth_Bar_%d", count)]
				local background = _G[bar:GetName().."BarBorder"]
				local progress = _G[bar:GetName().."Bar"]
				local name = _G[bar:GetName().."BarName"]
				local timer = _G[bar:GetName().."BarTimer"]
				local prev = _G[format("DBM_BossHealth_Bar_%d", count-1)]

				if count == 1 then
					local _, anch = bar:GetPoint()
					bar:ClearAllPoints()
					if DBM_AllSavedOptions["Default"].HealthFrameGrowUp then
						bar:SetPoint("BOTTOM", anch, "TOP", 0, 3)
					else
						bar:SetPoint("TOP", anch, "BOTTOM", 0, -3)
					end
				else
					bar:ClearAllPoints()
					if DBM_AllSavedOptions["Default"].HealthFrameGrowUp then
						bar:SetPoint("BOTTOMLEFT", prev, "TOPLEFT", 0, 3)
					else
						bar:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -3)
					end
				end

				if not bar.styled then
					bar:SetScale(1)
					bar:SetHeight(19)
					K.CreateBorder(bar, 1)
					background:SetNormalTexture(nil)
					bar.styled = true
				end

				if not progress.styled then
					progress:SetStatusBarTexture(C.Media.Texture)
					progress:SetBackdrop(backdrop)
					progress:SetBackdropColor(K.Color.r, K.Color.g, K.Color.b, 0.2)
					progress.styled = true
				end
				progress:ClearAllPoints()
				progress:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
				progress:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)

				if not name.styled then
					name:ClearAllPoints()
					name:SetPoint("LEFT", bar, "LEFT", 4, 0)
					name:SetFont(C.Media.Font, C.Media.Font_Size, "")
					name:SetShadowOffset(K.Mult,-K.Mult)
					name:SetJustifyH("LEFT")
					name.styled = true
				end

				if not timer.styled then
					timer:ClearAllPoints()
					timer:SetPoint("RIGHT", bar, "RIGHT", -1, 0)
					timer:SetFont(C.Media.Font, C.Media.Font_Size, "")
					timer:SetShadowOffset(K.Mult,-K.Mult)
					timer:SetJustifyH("RIGHT")
					timer.styled = true
				end
				count = count + 1
			end
		end
		if DBM then
			hooksecurefunc(DBT, "CreateBar", SkinBars)
			hooksecurefunc(DBM.BossHealth, "Show", SkinBossTitle)
			hooksecurefunc(DBM.BossHealth, "AddBoss", SkinBoss)
			hooksecurefunc(DBM.BossHealth, "UpdateSettings", SkinBoss)

			hooksecurefunc(DBM.RangeCheck, "Show", function()
				if DBMRangeCheck then
					-- DBMRangeCheck:SetTemplate("Transparent")
				end
				if DBMRangeCheckRadar then
					-- DBMRangeCheckRadar:SetTemplate("Transparent")
				end
			end)

			hooksecurefunc(DBM.InfoFrame, "Show", function()
				-- DBMInfoFrame:SetTemplate("Transparent")
			end)
		end
		local replace = string.gsub
		local old = RaidNotice_AddMessage
		RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
			if textString:find(" |T") then
				textString = replace(textString, "(:12:12)", ":13:13:0:0:64:64:5:59:5:59")
			end
			return old(noticeFrame, textString, colorInfo)
		end
	end
end)

-- DBM settings(by ALZA and help from Affli)
function K.UploadDBM()
	if K.CheckAddOn("DBM-Core") then
		DBM_UseDualProfile = false
		DBM_AllSavedOptions["Default"].Enabled = true
		DBM_AllSavedOptions["Default"].ShowMinimapButton = C.Skins.MinimapButtons and true or false
		DBM_AllSavedOptions["Default"].WarningIconLeft = false
		DBM_AllSavedOptions["Default"].WarningIconRight = false
		DBM_AllSavedOptions["Default"].WarningColors = {
			{["b"] = K.Color.b, ["g"] = K.Color.g, ["r"] = K.Color.r,},
			{["b"] = K.Color.b, ["g"] = K.Color.g, ["r"] = K.Color.r,},
			{["b"] = K.Color.b, ["g"] = K.Color.g, ["r"] = K.Color.r,},
			{["b"] = K.Color.b, ["g"] = K.Color.g, ["r"] = K.Color.r,},
		}
		DBM_AllSavedOptions["Default"].HealthFrameGrowUp = false
		DBM_AllSavedOptions["Default"].HealthFrameWidth = 218
		DBM_AllSavedOptions["Default"].HPFrameX = 100
		DBM_AllSavedOptions["Default"].HPFramePoint = "LEFT"
		DBM_AllSavedOptions["Default"].RangeFrameX = 244
		DBM_AllSavedOptions["Default"].RangeFramePoint = "LEFT"
		DBM_AllSavedOptions["Default"].ShowSpecialWarnings = true
		DBM_AllSavedOptions["Default"].SpecialWarningFont = C.Media.Font
		DBM_AllSavedOptions["Default"].SpecialWarningFontSize = 50
		DBM_AllSavedOptions["Default"].SpecialWarningX = 0
		DBM_AllSavedOptions["Default"].SpecialWarningY = 76

		DBT_AllPersistentOptions["Default"]["DBM"].StartColorR = K.Color.r
		DBT_AllPersistentOptions["Default"]["DBM"].StartColorG = K.Color.g
		DBT_AllPersistentOptions["Default"]["DBM"].StartColorB = K.Color.b
		DBT_AllPersistentOptions["Default"]["DBM"].EndColorR = K.Color.r
		DBT_AllPersistentOptions["Default"]["DBM"].EndColorG = K.Color.g
		DBT_AllPersistentOptions["Default"]["DBM"].EndColorB = K.Color.b
		DBT_AllPersistentOptions["Default"]["DBM"].Scale = 1
		DBT_AllPersistentOptions["Default"]["DBM"].HugeScale = 1
		DBT_AllPersistentOptions["Default"]["DBM"].BarXOffset = 0
		DBT_AllPersistentOptions["Default"]["DBM"].BarYOffset = 8
		DBT_AllPersistentOptions["Default"]["DBM"].Font = C.Media.Font
		DBT_AllPersistentOptions["Default"]["DBM"].FontSize = C.Media.Font_Size
		DBT_AllPersistentOptions["Default"]["DBM"].Width = 188
		DBT_AllPersistentOptions["Default"]["DBM"].TimerX = 142
		DBT_AllPersistentOptions["Default"]["DBM"].TimerPoint = "BOTTOMLEFT"
		DBT_AllPersistentOptions["Default"]["DBM"].FillUpBars = true
		DBT_AllPersistentOptions["Default"]["DBM"].IconLeft = true
		DBT_AllPersistentOptions["Default"]["DBM"].ExpandUpwards = true
		DBT_AllPersistentOptions["Default"]["DBM"].Texture = C.Media.Texture
		DBT_AllPersistentOptions["Default"]["DBM"].IconRight = false
		DBT_AllPersistentOptions["Default"]["DBM"].HugeBarXOffset = 0
		DBT_AllPersistentOptions["Default"]["DBM"].HugeBarsEnabled = false
		DBT_AllPersistentOptions["Default"]["DBM"].HugeWidth = 188
		DBT_AllPersistentOptions["Default"]["DBM"].HugeTimerX = 8
		DBT_AllPersistentOptions["Default"]["DBM"].HugeTimerPoint = "CENTER"
		DBT_AllPersistentOptions["Default"]["DBM"].HugeBarYOffset = 8

		if C.ActionBar.BottomBars == 1 then
			DBM_AllSavedOptions["Default"].HPFrameY = 126
			DBM_AllSavedOptions["Default"].RangeFrameY = 102
			DBT_AllPersistentOptions["Default"]["DBM"].TimerY = 138
			DBT_AllPersistentOptions["Default"]["DBM"].HugeTimerY = -136
		elseif C.ActionBar.BottomBars == 2 then
			DBM_AllSavedOptions["Default"].HPFrameY = 154
			DBM_AllSavedOptions["Default"].RangeFrameY = 128
			DBT_AllPersistentOptions["Default"]["DBM"].TimerY = 166
			DBT_AllPersistentOptions["Default"]["DBM"].HugeTimerY = -108
		elseif C.ActionBar.BottomBars == 3 then
			DBM_AllSavedOptions["Default"].HPFrameY = 182
			DBM_AllSavedOptions["Default"].RangeFrameY = 156
			DBT_AllPersistentOptions["Default"]["DBM"].TimerY = 194
			DBT_AllPersistentOptions["Default"]["DBM"].HugeTimerY = -80
		end
		DBM_AllSavedOptions["Default"].InstalledBars = C.ActionBar.BottomBars
	end
end

StaticPopupDialogs.SETTINGS_DBM = {
	text = L.Popup.SettingsDBM,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() K.UploadDBM() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- On logon function
local OnLogon = CreateFrame("Frame")
OnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
OnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if K.CheckAddOn("DBM-Core") then
		if DBM_AllSavedOptions["Default"].InstalledBars ~= C.ActionBar.BottomBars then
			StaticPopup_Show("SETTINGS_DBM")
		end
	end
end)