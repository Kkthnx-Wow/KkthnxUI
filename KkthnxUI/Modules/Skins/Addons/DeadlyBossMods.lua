local K, C = unpack(KkthnxUI)
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

local buttonsize = 24

local function ReskinDBMIcon(icon, frame)
	if not icon then
		return
	end

	if not icon.styled then
		icon:SetSize(buttonsize, buttonsize)
		icon.SetSize = K.Noop

		local bg = CreateFrame("Frame", nil, frame)
		bg:SetAllPoints(icon)
		bg:CreateBorder()

		bg.icon = bg:CreateTexture(nil, "ARTWORK")
		bg.icon:SetAllPoints()
		bg.icon:SetTexture(icon:GetTexture())
		bg.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		icon.styled = true
	end

	icon:ClearAllPoints()
	icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -6, 0)
end

local function ReskinDBMBar(bar, frame)
	if not bar then
		return
	end

	if not bar.styled then
		bar:StripTextures()
		bar:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
		bar:CreateBorder()

		bar.newSpark = bar:CreateTexture(nil, "OVERLAY")
		bar.newSpark:SetTexture(C["Media"].Textures.Spark16Texture)
		bar.newSpark:SetBlendMode("ADD")
		bar.newSpark:SetAlpha(0.6)
		bar.newSpark:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT", -16, 0)
		bar.newSpark:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 16, -0)

		bar.styled = true
	end

	bar:SetAllPoints(frame)
end

local function HideDBMSpark(self)
	local spark = _G[self.frame:GetName() .. "BarSpark"]
	spark:SetAlpha(0)
	spark:SetTexture(nil)
end

local function ApplyDBMStyle(self)
	local frame = self.frame
	local frame_name = frame:GetName()
	local tbar = _G[frame_name .. "Bar"]
	local texture = _G[frame_name .. "BarTexture"]
	local icon1 = _G[frame_name .. "BarIcon1"]
	local icon2 = _G[frame_name .. "BarIcon2"]
	local name = _G[frame_name .. "BarName"]
	local timer = _G[frame_name .. "BarTimer"]

	if self.enlarged then
		frame:SetWidth(self.owner.Options.HugeWidth)
		tbar:SetWidth(self.owner.Options.HugeWidth)
	else
		frame:SetWidth(self.owner.Options.Width)
		tbar:SetWidth(self.owner.Options.Width)
	end

	frame:SetScale(1)
	frame:SetHeight(buttonsize / 2)

	ReskinDBMIcon(icon1, frame)
	ReskinDBMIcon(icon2, frame)
	ReskinDBMBar(tbar, frame)

	if texture then
		texture:SetTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
	end

	name:ClearAllPoints()
	name:SetPoint("LEFT", frame, "LEFT", 2, 8)
	name:SetPoint("RIGHT", frame, "LEFT", tbar:GetWidth() * 0.85, 8)
	name:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "OUTLINE")
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)
	name:SetShadowColor(0, 0, 0, 0)

	timer:ClearAllPoints()
	timer:SetPoint("RIGHT", frame, "RIGHT", -2, 8)
	timer:SetFont(C["Media"].Fonts.KkthnxUIFont, 12, "OUTLINE")
	timer:SetJustifyH("RIGHT")
	timer:SetShadowColor(0, 0, 0, 0)
end

function Module:ReskinDeadlyBossMods()
	-- Default notice message
	local RaidNotice_AddMessage_ = RaidNotice_AddMessage
	RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
		if string_find(textString, "|T") then
			if string_match(textString, ":(%d+):(%d+)") then
				local size1, size2 = string_match(textString, ":(%d+):(%d+)")
				size1, size2 = size1 + 3, size2 + 3
				textString = string_gsub(textString, ":(%d+):(%d+)", ":" .. size1 .. ":" .. size2 .. ":0:0:64:64:5:59:5:59")
			elseif string_match(textString, ":(%d+)|t") then
				local size = string_match(textString, ":(%d+)|t")
				size = size + 3
				textString = string_gsub(textString, ":(%d+)|t", ":" .. size .. ":" .. size .. ":0:0:64:64:5:59:5:59|t")
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

	hooksecurefunc(DBT, "CreateBar", function(self)
		for bar in self:GetBarIterator() do
			if not bar.injected then
				hooksecurefunc(bar, "Update", HideDBMSpark)
				hooksecurefunc(bar, "ApplyStyle", ApplyDBMStyle)
				bar:ApplyStyle()

				bar.injected = true
			end
		end
	end)

	hooksecurefunc(DBM.RangeCheck, "Show", function()
		if DBMRangeCheckRadar and not DBMRangeCheckRadar.styled then
			TT.ReskinTooltip(DBMRangeCheckRadar)
			DBMRangeCheckRadar.styled = true
		end

		if DBMRangeCheck and not DBMRangeCheck.styled then
			TT.ReskinTooltip(DBMRangeCheck)
			DBMRangeCheck.styled = true
		end
	end)

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
	DBT_AllPersistentOptions["Default"]["DBM"].BarYOffset = 10
	DBT_AllPersistentOptions["Default"]["DBM"].HugeBarYOffset = 10
	DBT_AllPersistentOptions["Default"]["DBM"].ExpandUpwards = true
	DBT_AllPersistentOptions["Default"]["DBM"].ExpandUpwardsLarge = true
end
