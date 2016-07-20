local K, C, L, _ = select(2, ...):unpack()
if C.Skins.DBM ~= true then return end

local _G = _G
local format = string.format
local find = string.find
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local forcebosshealthclasscolor = false
local croprwicons = true
local rwiconsize = 12
local backdrop = {
	bgFile = C.Media.Texture,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local DBMSkin = CreateFrame("Frame")
DBMSkin:RegisterEvent("PLAYER_LOGIN")
DBMSkin:SetScript("OnEvent", function(self, event, addon)
	if IsAddOnLoaded("DBM-Core") then
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

						if (icon1.overlay) then
							icon1.overlay = _G[icon1.overlay:GetName()]
						else
							icon1.overlay = CreateFrame("Frame", "$parentIcon1Overlay", tbar)
							icon1.overlay:SetWidth(23)
							icon1.overlay:SetHeight(23)
							icon1.overlay:SetFrameStrata("BACKGROUND")
							icon1.overlay:SetPoint("BOTTOMRIGHT", tbar, "BOTTOMLEFT", -5, -2)
							icon1.overlay:CreateBackdrop(2)
						end

						if (icon2.overlay) then
							icon2.overlay = _G[icon2.overlay:GetName()]
						else
							icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", tbar)
							icon2.overlay:SetWidth(23)
							icon2.overlay:SetHeight(23)
							icon2.overlay:SetFrameStrata("BACKGROUND")
							icon2.overlay:SetPoint("BOTTOMLEFT", tbar, "BOTTOMRIGHT", 5, -2)
							icon2.overlay:CreateBackdrop(2)
						end

						if bar.color then
							tbar:SetStatusBarColor(0.1, 0.1, 0.1)
							tbar:SetBackdrop(backdrop)
							tbar:SetBackdropColor(0.1, 0.1, 0.1, 0.15)
						else
							tbar:SetStatusBarColor(0.1, 0.1, 0.1)
							tbar:SetBackdrop(backdrop)
							tbar:SetBackdropColor(0.1, 0.1, 0.1, 0.15)
						end

						if bar.enlarged then frame:SetWidth(bar.owner.options.HugeWidth) else frame:SetWidth(bar.owner.options.Width) end
						if bar.enlarged then tbar:SetWidth(bar.owner.options.HugeWidth) else tbar:SetWidth(bar.owner.options.Width) end

						frame:SetScale(1)
						if not frame.styled then
							frame:SetHeight(23)
							frame:CreateBackdrop(2)
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
							name:SetWidth(180)
							name:SetHeight(8)
							name:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
							name:SetJustifyH("LEFT")
							name.SetFont = K.Noop
							name.styled = true
						end

						if not timer.styled then
							timer:ClearAllPoints()
							timer:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
							timer:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
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
				end
			end
		end

		local SkinBossTitle = function()
			local anchor = DBMBossHealthDropdown:GetParent()
			if not anchor.styled then
				local header = {anchor:GetRegions()}
				if header[1]:IsObjectType("FontString") then
					header[1]:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
					header[1]:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
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

				if (count == 1) then
					local _, anch, _ , _, _ = bar:GetPoint()
					bar:ClearAllPoints()
					bar:SetPoint("TOP", anch, "BOTTOM", 0, -3)
				else
					bar:ClearAllPoints()
					bar:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -3)
				end

				if not bar.styled then
					bar:SetScale(1)
					bar:SetHeight(19)
					bar:CreateBackdrop(2)
					background:SetNormalTexture(nil)
					bar.styled = true
				end

				if not progress.styled then
					progress:SetStatusBarTexture(C.Media.Texture)
					progress:SetBackdrop(backdrop)
					progress:SetBackdropColor(r,g,b,1)
					if forcebosshealthclasscolor then
						local tslu = 0
						progress:SetStatusBarColor(r,g,b,1)
						progress:HookScript("OnUpdate", function(self, elapsed)
							tslu = tslu+ elapsed
							if tslu > 0.025 then
								self:SetStatusBarColor(r,g,b,1)
								tslu = 0
							end
						end)
					end
					progress.styled = true
				end
				progress:ClearAllPoints()
				progress:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
				progress:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)

				if not name.styled then
					name:ClearAllPoints()
					name:SetPoint("LEFT", bar, "LEFT", 4, 0)
					name:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
					name:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
					name:SetJustifyH("LEFT")
					name.styled = true
				end

				if not timer.styled then
					timer:ClearAllPoints()
					timer:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
					timer:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
					timer:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
					timer:SetJustifyH("RIGHT")
					timer.styled = true
				end
				count = count + 1
			end
		end

		hooksecurefunc(DBT, "CreateBar", SkinBars)
		hooksecurefunc(DBM.BossHealth, "Show", SkinBossTitle)
		hooksecurefunc(DBM.BossHealth, "AddBoss", SkinBoss)
		hooksecurefunc(DBM.BossHealth, "UpdateSettings", SkinBoss)

		local firstRange = true
		hooksecurefunc(DBM.RangeCheck, "Show", function()
			if firstRange then
				DBMRangeCheck:SetBackdrop(nil)
				local bd = CreateFrame("Frame", nil, DBMRangeCheckRadar)
				bd:SetPoint("TOPLEFT")
				bd:SetPoint("BOTTOMRIGHT")
				bd:SetFrameLevel(0)
				bd:SetFrameStrata(DBMRangeCheckRadar:GetFrameStrata())
				bd:SetBackdropColor(.05,.05,.05, .9)
				bd:SetBackdrop(backdrop)
				bd:SetBackdropColor(.08,.08,.08, .9)

				firstRange = false
			end
		end)

		if croprwicons then
			local replace = string.gsub
			local old = RaidNotice_AddMessage
			RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
				if textString:find(" |T") then
					textString=replace(textString,"(:12:12)",":"..rwiconsize..":"..rwiconsize..":0:0:64:64:5:59:5:59")
				end
				return old(noticeFrame, textString, colorInfo)
			end
		end
	end
end)

-- DBM settings(by ALZA and help from Affli)
function K.UploadDBM()
	if IsAddOnLoaded("DBM-Core") then
		DBM_UseDualProfile = false
		DBM_SavedOptions.enabled = true
		DBM_SavedOptions.ShowMinimapButton = C.Skins.MinimapButtons and true or false
		DBM_SavedOptions.WarningIconLeft = false
		DBM_SavedOptions.WarningIconRight = false
		DBM_SavedOptions.WarningColors = {
			{["b"] = K.Color.b, ["g"] = K.Color.g, ["r"] = K.Color.r,},
			{["b"] = K.Color.b, ["g"] = K.Color.g, ["r"] = K.Color.r,},
			{["b"] = K.Color.b, ["g"] = K.Color.g, ["r"] = K.Color.r,},
			{["b"] = K.Color.b, ["g"] = K.Color.g, ["r"] = K.Color.r,},
		}
		DBM_SavedOptions.HealthFrameGrowUp = false
		DBM_SavedOptions.HealthFrameWidth = 218
		DBM_SavedOptions.HPFrameX = 100
		DBM_SavedOptions.HPFramePoint = "LEFT"
		DBM_SavedOptions.RangeFrameX = 244
		DBM_SavedOptions.RangeFramePoint = "LEFT"
		DBM_SavedOptions.ShowSpecialWarnings = true
		DBM_SavedOptions.SpecialWarningFont = C.Media.Font
		DBM_SavedOptions.SpecialWarningFontSize = 50
		DBM_SavedOptions.SpecialWarningX = 0
		DBM_SavedOptions.SpecialWarningY = 75

		DBT_SavedOptions["DBM"].StartColorR = K.Color.r
		DBT_SavedOptions["DBM"].StartColorG = K.Color.g
		DBT_SavedOptions["DBM"].StartColorB = K.Color.b
		DBT_SavedOptions["DBM"].EndColorR = K.Color.r
		DBT_SavedOptions["DBM"].EndColorG = K.Color.g
		DBT_SavedOptions["DBM"].EndColorB = K.Color.b
		DBT_SavedOptions["DBM"].Scale = 1
		DBT_SavedOptions["DBM"].HugeScale = 1
		DBT_SavedOptions["DBM"].BarXOffset = 0
		DBT_SavedOptions["DBM"].BarYOffset = 10
		DBT_SavedOptions["DBM"].Font = C.Media.Font
		DBT_SavedOptions["DBM"].FontSize = C.Media.Font_Size
		DBT_SavedOptions["DBM"].Width = 189
		DBT_SavedOptions["DBM"].TimerX = -468.500244140625
		DBT_SavedOptions["DBM"].TimerPoint = "CENTER"
		DBT_SavedOptions["DBM"].FillUpBars = true
		DBT_SavedOptions["DBM"].IconLeft = true
		DBT_SavedOptions["DBM"].ExpandUpwards = true
		DBT_SavedOptions["DBM"].Texture = C.Media.Texture
		DBT_SavedOptions["DBM"].IconRight = false
		DBT_SavedOptions["DBM"].HugeBarXOffset = 0
		DBT_SavedOptions["DBM"].HugeBarsEnabled = false
		DBT_SavedOptions["DBM"].HugeWidth = 189
		DBT_SavedOptions["DBM"].HugeTimerX = 6
		DBT_SavedOptions["DBM"].HugeTimerPoint = "CENTER"
		DBT_SavedOptions["DBM"].HugeBarYOffset = 10

		if C.ActionBar.BottomBars == 1 then
			DBM_SavedOptions.HPFrameY = 126
			DBM_SavedOptions.RangeFrameY = 101
			DBT_SavedOptions["DBM"].TimerY = 139
			DBT_SavedOptions["DBM"].HugeTimerY = -136
		elseif C.ActionBar.BottomBars == 2 then
			DBM_SavedOptions.HPFrameY = 154
			DBM_SavedOptions.RangeFrameY = 129
			DBT_SavedOptions["DBM"].TimerY = 167
			DBT_SavedOptions["DBM"].HugeTimerY = -108
		elseif C.ActionBar.BottomBars == 3 then
			DBM_SavedOptions.HPFrameY = 182
			DBM_SavedOptions.RangeFrameY = 157
			DBT_SavedOptions["DBM"].TimerY = 195
			DBT_SavedOptions["DBM"].HugeTimerY = -80
		end
		DBM_SavedOptions.InstalledBars = C.ActionBar.BottomBars
	end
end

StaticPopupDialogs.SETTINGS_DBM = {
	text = L_POPUP_SETTINGS_DBM,
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

	if IsAddOnLoaded("DBM-Core") then
		if DBM_SavedOptions.InstalledBars ~= C.ActionBar.BottomBars  then
			StaticPopup_Show("SETTINGS_DBM")
		end
	end
end)