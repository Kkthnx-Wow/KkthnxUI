--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins DeadlyBossMods (DBM) bars, icons, and frames.
-- - Design: Hooks into DBM create/style functions and enforces custom bar/icon styling.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")
local TT = K:GetModule("Tooltip")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local select = _G.select

local string_find = _G.string.find
local string_gsub = _G.string.gsub
local string_match = _G.string.match

-- local DBT = _G.DBT
-- local DBM = _G.DBM
-- local DBMInfoFrame = _G.DBMInfoFrame
-- local DBMRangeCheck = _G.DBMRangeCheck
-- local DBMRangeCheckRadar = _G.DBMRangeCheckRadar
-- local DBM_AllSavedOptions = _G.DBM_AllSavedOptions
-- local DBT_AllPersistentOptions = _G.DBT_AllPersistentOptions
-- local RaidNotice_AddMessage = _G.RaidNotice_AddMessage

local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded

-- REASON: Constants for skinning.
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
		bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
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
		texture:SetTexture(K.GetTexture(C["General"].Texture))
	end

	name:ClearAllPoints()
	name:SetPoint("LEFT", frame, "LEFT", 2, 8)
	name:SetPoint("RIGHT", frame, "LEFT", tbar:GetWidth() * 0.85, 8)
	name:SetFontObject(K.UIFontOutline)
	name:SetFont(select(1, name:GetFont()), 13, "OUTLINE")
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)
	name:SetShadowColor(0, 0, 0, 0)

	timer:ClearAllPoints()
	timer:SetPoint("RIGHT", frame, "RIGHT", -2, 8)
	timer:SetFontObject(K.UIFontOutline)
	timer:SetFont(select(1, timer:GetFont()), 13, "OUTLINE")
	timer:SetJustifyH("RIGHT")
	timer:SetShadowColor(0, 0, 0, 0)
end

-- REASON: Main entry point for DBM skinning.
function Module:ReskinDeadlyBossMods()
	-- REASON: Skin DBM notice messages.
	local RaidNotice_AddMessage_ = RaidNotice_AddMessage
	_G.RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
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

	if not C_AddOns_IsAddOnLoaded("DBM-Core") then
		return
	end

	if not C["Skins"].DeadlyBossMods then
		return
	end

	hooksecurefunc(_G.DBT, "CreateBar", function(self)
		for bar in self:GetBarIterator() do
			if not bar.injected then
				hooksecurefunc(bar, "Update", HideDBMSpark)
				hooksecurefunc(bar, "ApplyStyle", ApplyDBMStyle)
				bar:ApplyStyle()

				bar.injected = true
			end
		end
	end)

	hooksecurefunc(_G.DBM.RangeCheck, "Show", function()
		if _G.DBMRangeCheckRadar and not _G.DBMRangeCheckRadar.styled then
			TT.ReskinTooltip(_G.DBMRangeCheckRadar)
			_G.DBMRangeCheckRadar.styled = true
		end

		if _G.DBMRangeCheck and not _G.DBMRangeCheck.styled then
			TT.ReskinTooltip(_G.DBMRangeCheck)
			_G.DBMRangeCheck.styled = true
		end
	end)

	if _G.DBM.InfoFrame then
		_G.DBM.InfoFrame:Show(5, "test")
		_G.DBM.InfoFrame:Hide()
		_G.DBMInfoFrame:HookScript("OnShow", TT.ReskinTooltip)
	end

	-- REASON: Force recommended settings for DBM.
	if not _G.DBM_AllSavedOptions["Default"] then
		_G.DBM_AllSavedOptions["Default"] = {}
	end
	_G.DBM_AllSavedOptions["Default"]["BlockVersionUpdateNotice"] = true
	_G.DBM_AllSavedOptions["Default"]["EventSoundVictory"] = "None"
	if C_AddOns_IsAddOnLoaded("DBM-VPYike") then
		_G.DBM_AllSavedOptions["Default"]["CountdownVoice"] = "VP:Yike"
		_G.DBM_AllSavedOptions["Default"]["ChosenVoicePack"] = "Yike"
	end

	if not _G.DBT_AllPersistentOptions["Default"] then
		_G.DBT_AllPersistentOptions["Default"] = {}
	end
	_G.DBT_AllPersistentOptions["Default"]["DBM"].BarYOffset = 10
	_G.DBT_AllPersistentOptions["Default"]["DBM"].HugeBarYOffset = 10
	_G.DBT_AllPersistentOptions["Default"]["DBM"].ExpandUpwards = true
	_G.DBT_AllPersistentOptions["Default"]["DBM"].ExpandUpwardsLarge = true
end
