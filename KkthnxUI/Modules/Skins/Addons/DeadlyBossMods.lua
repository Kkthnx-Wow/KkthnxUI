local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")
local TT = K:GetModule("Tooltip")

local _G = _G
local string_find = _G.string.find
local string_gsub = _G.string.gsub
local string_match = _G.string.match
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local IsAddOnLoaded = _G.IsAddOnLoaded
local hooksecurefunc = _G.hooksecurefunc

function Module:ReskinDeadlyBossMods()
	-- Default notice message
	local RaidNotice_AddMessage_ = RaidNotice_AddMessage
	RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
		if string_find(textString, "|T") then
			if string_match(textString, ":(%d+):(%d+)") then
				local size1, size2 = string_match(textString, ":(%d+):(%d+)")
				size1, size2 = size1 + 3, size2 + 3
				textString = string_gsub(textString,":(%d+):(%d+)",":"..size1..":"..size2..":0:0:64:64:5:59:5:59")
			elseif string_match(textString, ":(%d+)|t") then
				local size = string_match(textString, ":(%d+)|t")
				size = size + 3
				textString = string_gsub(textString,":(%d+)|t",":"..size..":"..size..":0:0:64:64:5:59:5:59|t")
			end
		end

		return RaidNotice_AddMessage_(noticeFrame, textString, colorInfo)
	end

	if not IsAddOnLoaded("DBM-Core") then
		return
	end

	if not C["Skins"].DeadlyBossMods then
		return
	end

	local buttonsize = 24
	local function SkinBars(self)
		for bar in self:GetBarIterator() do
			if not bar.injected then
				local frame = bar.frame
				local tbar = _G[frame:GetName().."Bar"]
				local spark = _G[frame:GetName().."BarSpark"]
				local texture = _G[frame:GetName().."BarTexture"]
				local icon1 = _G[frame:GetName().."BarIcon1"]
				local icon2 = _G[frame:GetName().."BarIcon2"]
				local name = _G[frame:GetName().."BarName"]
				local timer = _G[frame:GetName().."BarTimer"]

				if not (icon1.overlay) then
					icon1.overlay = CreateFrame("Frame", "$parentIcon1Overlay", tbar)
					icon1.overlay:SetSize(buttonsize + 2, buttonsize + 2)
					icon1.overlay:SetPoint("BOTTOMRIGHT", tbar, "BOTTOMLEFT", -buttonsize / 4, 0)

					local backdroptex = icon1.overlay:CreateTexture(nil, "BORDER")
					backdroptex:SetTexture([=[Interface\Icons\Spell_Nature_WispSplode]=])
					backdroptex:SetPoint("TOPLEFT", icon1.overlay, "TOPLEFT", 1, -1)
					backdroptex:SetPoint("BOTTOMRIGHT", icon1.overlay, "BOTTOMRIGHT", -1, 1)
					backdroptex:SetTexCoord(unpack(K.TexCoords))

					icon1.overlay:CreateBorder()
				end

				if not (icon2.overlay) then
					icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", tbar)
					icon2.overlay:SetSize(buttonsize + 2, buttonsize + 2)
					icon2.overlay:SetPoint("BOTTOMLEFT", tbar, "BOTTOMRIGHT", buttonsize / 4, 0)

					local backdroptex = icon2.overlay:CreateTexture(nil, "BORDER")
					backdroptex:SetTexture([=[Interface\Icons\Spell_Nature_WispSplode]=])
					backdroptex:SetPoint("TOPLEFT", icon2.overlay, "TOPLEFT", 1, -1)
					backdroptex:SetPoint("BOTTOMRIGHT", icon2.overlay, "BOTTOMRIGHT", -1, 1)
					backdroptex:SetTexCoord(unpack(K.TexCoords))

					icon2.overlay:CreateBorder()
				end

				if bar.color then
					tbar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
				else
					tbar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
				end

				if bar.enlarged then
					frame:SetWidth(bar.owner.options.HugeWidth)
				else
					frame:SetWidth(bar.owner.options.Width)
				end

				if bar.enlarged then
					tbar:SetWidth(bar.owner.options.HugeWidth)
				else
					tbar:SetWidth(bar.owner.options.Width)
				end

				if not frame.styled then
					frame:SetScale(1)
					frame.SetScale = K.Noop
					frame:SetHeight(buttonsize / 2)
					frame.SetHeight = K.Noop
					if not frame.bg then
						frame.bg = CreateFrame("Frame", nil, frame)
						frame.bg:SetAllPoints()
					end
					frame.bg:CreateBorder()
					frame.styled = true
				end

				if not spark.killed then
					spark:SetAlpha(0)
					spark:SetTexture(nil)
					spark.killed = true
				end

				if not icon1.styled then
					icon1:SetTexCoord(unpack(K.TexCoords))
					icon1:ClearAllPoints()
					icon1:SetPoint("TOPLEFT", icon1.overlay)
					icon1:SetPoint("BOTTOMRIGHT", icon1.overlay)
					icon1.SetSize = K.Noop
					icon1.styled = true
				end

				if not icon2.styled then
					icon2:SetTexCoord(unpack(K.TexCoords))
					icon2:ClearAllPoints()
					icon2:SetPoint("TOPLEFT", icon2.overlay)
					icon2:SetPoint("BOTTOMRIGHT", icon2.overlay)
					icon2.SetSize = K.Noop
					icon2.styled = true
				end

				if not texture.styled then
					texture:SetTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
					texture.styled = true
				end

				tbar:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
				if not tbar.styled then
					tbar:SetPoint("TOPLEFT", frame, "TOPLEFT")
					tbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
					tbar.SetPoint = K.Noop
					tbar.styled = true

					tbar.Spark = tbar:CreateTexture(nil, "OVERLAY")
					tbar.Spark:SetTexture(C["Media"].Textures.Spark16Texture)
					tbar.Spark:SetBlendMode("ADD")
					tbar.Spark:SetAlpha(.8)
					tbar.Spark:SetPoint("TOPLEFT", tbar:GetStatusBarTexture(), "TOPRIGHT", -16, 0)
					tbar.Spark:SetPoint("BOTTOMRIGHT", tbar:GetStatusBarTexture(), "BOTTOMRIGHT", 16, -0)
				end

				if not name.styled then
					name:ClearAllPoints()
					name:SetPoint("LEFT", frame, "LEFT", 2, 8)
					name:SetPoint("RIGHT", frame, "LEFT", tbar:GetWidth() * 0.85, 8)
					name.SetPoint = K.Noop
					name:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "OUTLINE")
					name.SetFont = K.Noop
					name:SetJustifyH("LEFT")
					name:SetWordWrap(false)
					name:SetShadowColor(0, 0, 0, 0)
					name.styled = true
				end

				if not timer.styled then
					timer:ClearAllPoints()
					timer:SetPoint("RIGHT", frame, "RIGHT", -2, 8)
					timer.SetPoint = K.Noop
					timer:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "OUTLINE")
					timer.SetFont = K.Noop
					timer:SetJustifyH("RIGHT")
					timer:SetShadowColor(0, 0, 0, 0)
					timer.styled = true
				end

				if bar.owner.options.IconLeft then
					icon1:Show() icon1.overlay:Show()
				else
					icon1:Hide() icon1.overlay:Hide()
				end

				if bar.owner.options.IconRight then
					icon2:Show() icon2.overlay:Show()
				else
					icon2:Hide() icon2.overlay:Hide()
				end

				tbar:SetAlpha(1)
				frame:SetAlpha(1)
				texture:SetAlpha(1)
				frame:Show()
				bar:Update(0)
				bar.injected = true
			end
		end
	end
	hooksecurefunc(DBT, "CreateBar", SkinBars)

	local function SkinRange()
		if DBMRangeCheckRadar and not DBMRangeCheckRadar.styled then
			TT.ReskinTooltip(DBMRangeCheckRadar)
			DBMRangeCheckRadar.styled = true
		end

		if DBMRangeCheck and not DBMRangeCheck.styled then
			TT.ReskinTooltip(DBMRangeCheck)
			DBMRangeCheck.styled = true
		end
	end
	hooksecurefunc(DBM.RangeCheck, "Show", SkinRange)

	if DBM.InfoFrame then
		DBM.InfoFrame:Show(5, "test")
		DBM.InfoFrame:Hide()
		DBMInfoFrame:HookScript("OnShow", TT.ReskinTooltip)
	end

	-- Force Settings
	if not DBM_AllSavedOptions["Default"] then
		DBM_AllSavedOptions["Default"] = {}
	end

	DBM_AllSavedOptions["Default"]["BlockVersionUpdateNotice"] = true
	DBM_AllSavedOptions["Default"]["EventSoundVictory"] = "None"

	if IsAddOnLoaded("DBM-VPYike") then
		DBM_AllSavedOptions["Default"]["CountdownVoice"] = "VP:Yike"
		DBM_AllSavedOptions["Default"]["ChosenVoicePack"] = "Yike"
	end

	if not DBT_AllPersistentOptions["Default"] then
		DBT_AllPersistentOptions["Default"] = {}
	end

	DBT_AllPersistentOptions["Default"]["DBM"].BarYOffset = 20
	DBT_AllPersistentOptions["Default"]["DBM"].HugeBarYOffset = 20
	DBT_AllPersistentOptions["Default"]["DBM"].ExpandUpwards = true
	DBT_AllPersistentOptions["Default"]["DBM"].ExpandUpwardsLarge = true
end