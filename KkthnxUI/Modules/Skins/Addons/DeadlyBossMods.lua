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
	local function reskinBarIcon(icon, bar)
		if icon.styled then
			return
		end

		icon:SetSize(buttonsize, buttonsize)
		icon.SetSize = K.Noop
		icon:ClearAllPoints()
		icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -5, 0)

		local bg = CreateFrame("Frame", nil, bar)
		bg:SetAllPoints(icon)
		bg:CreateBorder()

		bg.icon = bg:CreateTexture(nil, "BACKGROUND")
		bg.icon:SetAllPoints()
		bg.icon:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
		bg.icon:SetTexCoord(unpack(K.TexCoords))

		icon.styled = true
	end

	local function SkinBars(self)
		for bar in self:GetBarIterator() do
			if not bar.styeld then
				local frame = bar.frame
				local tbar = _G[frame:GetName().."Bar"]
				local spark = _G[frame:GetName().."BarSpark"]
				local texture = _G[frame:GetName().."BarTexture"]
				local icon1 = _G[frame:GetName().."BarIcon1"]
				local icon2 = _G[frame:GetName().."BarIcon2"]
				local name = _G[frame:GetName().."BarName"]
				local timer = _G[frame:GetName().."BarTimer"]

				if bar.color then
					tbar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
				else
					tbar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
				end

				if bar.enlarged then
					frame:SetWidth(bar.owner.options.HugeWidth)
					tbar:SetWidth(bar.owner.options.HugeWidth)
				else
					frame:SetWidth(bar.owner.options.Width)
					tbar:SetWidth(bar.owner.options.Width)
				end

				if not frame.styled then
					frame:SetScale(1)
					frame.SetScale = K.Noop
					frame:SetHeight(buttonsize / 2)
					frame.SetHeight = K.Noop
					frame.styled = true
				end

				if not spark.killed then
					spark:SetAlpha(0)
					spark:SetTexture(nil)
					spark.killed = true
				end

				reskinBarIcon(icon1, tbar)
				reskinBarIcon(icon2, tbar)

				if not tbar.styled then
					tbar:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
					tbar:SetPoint("TOPLEFT", frame, "TOPLEFT")
					tbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
					tbar.SetPoint = K.Noop
					tbar:CreateBorder()

					tbar.Spark = tbar:CreateTexture(nil, "OVERLAY")
					tbar.Spark:SetTexture(C["Media"].Textures.Spark16Texture)
					tbar.Spark:SetBlendMode("ADD")
					tbar.Spark:SetAlpha(.8)
					tbar.Spark:SetPoint("TOPLEFT", tbar:GetStatusBarTexture(), "TOPRIGHT", -16, 0)
					tbar.Spark:SetPoint("BOTTOMRIGHT", tbar:GetStatusBarTexture(), "BOTTOMRIGHT", 16, -0)

					tbar.styled = true
				end

				if not texture.styled then
					texture:SetTexture(C["Media"].Texture)
					texture.SetTexture = K.Noop
					texture.styled = true
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

				tbar:SetAlpha(1)
				frame:SetAlpha(1)
				frame:Show()
				bar:Update(0)

				bar.styeld = true
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