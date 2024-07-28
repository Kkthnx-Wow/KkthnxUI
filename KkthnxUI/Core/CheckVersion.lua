local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("VersionCheck")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

local string_format = string.format
local string_gsub = string.gsub
local string_split = string.split
local tonumber = tonumber

local Ambiguate = Ambiguate
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local GetTime = GetTime
local IsInGroup = IsInGroup
local IsInGuild = IsInGuild

local lastVCTime, isVCInit = 0
local tn = tonumber

local function HandleVersonTag(version)
	local major, minor = strsplit(".", version)
	major, minor = tn(major), tn(minor)
	if K.LibBase64:CV(major) then
		major, minor = 0, 0
		if K.isDeveloper and author then
			print("Moron: " .. author)
		end
	end
	return major, minor
end

function Module:VersionCheck_Compare(new, old, author)
	local new1, new2 = HandleVersonTag(new, author)
	local old1, old2 = HandleVersonTag(old)
	if new1 > old1 or (new1 == old1 and new2 > old2) then
		return "IsNew"
	elseif new1 < old1 or (new1 == old1 and new2 < old2) then
		return "IsOld"
	end
end

function Module:CreateUpdateNoticeFrame()
	local frame = CreateFrame("Frame", "KKUI_UpdateNotice", UIParent)
	frame:SetSize(420, 150)
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:CreateBorder()

	frame.Texture = frame:CreateTexture(nil, "OVERLAY")
	frame.Texture:SetTexture("Interface\\HELPFRAME\\HelpIcon-ReportAbuse")
	frame.Texture:SetPoint("TOP", frame, "TOP", 0, 8)

	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	frame.Text:SetWidth(400)
	frame.Text:SetFontObject(K.UIFont)
	frame.Text:SetFont(select(1, frame.Text:GetFont()), 15, select(3, frame.Text:GetFont()))
	frame.Text:SetPoint("CENTER", frame, "CENTER")

	frame.EditBox = CreateFrame("EditBox", nil, frame)
	frame.EditBox:SetPoint("BOTTOM", frame, "BOTTOM", 0, 8)
	frame.EditBox:SetWidth(330)
	frame.EditBox:SetHeight(19)
	frame.EditBox:SetMultiLine(false)
	frame.EditBox:SetAutoFocus(false)
	frame.EditBox:SetFontObject(K.UIFont)
	frame.EditBox:CreateBorder()

	frame.EditBox.Text = frame.EditBox:CreateFontString(nil, "OVERLAY")
	frame.EditBox.Text:SetFontObject(K.UIFont)
	frame.EditBox.Text:SetPoint("BOTTOM", frame.EditBox, "TOP", 0, 2)

	frame.OkayButton = CreateFrame("Button", nil, frame)
	frame.OkayButton:SetPoint("TOP", frame, "BOTTOM", 0, -6)
	frame.OkayButton:SetSize(420, 24)
	frame.OkayButton:SkinButton()
	frame.OkayButton:SetScript("OnClick", function()
		if frame:IsShown() then
			frame:Hide()
		end
	end)

	frame.OkayButton.Text = frame.OkayButton:CreateFontString(nil, "ARTWORK")
	frame.OkayButton.Text:SetFontObject(K.UIFont)
	frame.OkayButton.Text:SetFont(select(1, frame.OkayButton.Text:GetFont()), 13, select(3, frame.OkayButton.Text:GetFont()))
	frame.OkayButton.Text:SetText("I am going to update right now")
	frame.OkayButton.Text:SetTextColor(0, 1, 0)
	frame.OkayButton.Text:SetPoint("CENTER", frame.OkayButton, "CENTER", 0, 0)
	K.AddTooltip(frame.OkayButton, "ANCHOR_BOTTOM", K.SystemColor .. "Obviously |cff669dffKkthnx|r is trusting you to go update and not complain about a missing feature or a bug because you are out of date |CFFFF0000<3|r")

	return frame
end

function Module:VersionCheck_Create(text)
	if not C["General"].VersionCheck then
		return
	end

	-- HelpTip:Show(ChatFrame1, {
	-- 	text = text,
	-- 	buttonStyle = HelpTip.ButtonStyle.Okay,
	-- 	targetPoint = HelpTip.Point.TopEdgeCenter,
	-- 	offsetY = 10,
	-- })

	local frame = Module:CreateUpdateNoticeFrame()
	frame.Text:SetText(text)
	frame:Show()
end

function Module:VersionCheck_Init()
	if not isVCInit then
		local status = Module:VersionCheck_Compare(KkthnxUIDB.DetectVersion, K.Version)
		if status == "IsNew" then
			local release = gsub(KkthnxUIDB.DetectVersion, "(%d+)$", "0")
			Module:VersionCheck_Create(format("|cff669dffKkthnxUI|r is out of date, the latest release is |cff70C0F5%s|r", release))
		elseif status == "IsOld" then
			KkthnxUIDB.DetectVersion = K.Version
		end

		isVCInit = true
	end
end

function Module:VersionCheck_Send(channel)
	if GetTime() - lastVCTime >= 10 then
		C_ChatInfo_SendAddonMessage("KKUIVersionCheck", KkthnxUIDB.DetectVersion, channel)
		lastVCTime = GetTime()
	end
end

function Module:VersionCheck_Update(...)
	local prefix, msg, distType, author = ...
	if prefix ~= "KKUIVersionCheck" then
		return
	end
	if Ambiguate(author, "none") == K.Name then
		return
	end

	local status = Module:VersionCheck_Compare(msg, KkthnxUIDB.DetectVersion, author)
	if status == "IsNew" then
		KkthnxUIDB.DetectVersion = msg
	elseif status == "IsOld" then
		Module:VersionCheck_Send(distType)
	end

	Module:VersionCheck_Init()
end

function Module:VersionCheck_UpdateGroup()
	if not IsInGroup() then
		return
	end
	Module:VersionCheck_Send(IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
end

function Module:OnEnable()
	Module:VersionCheck_Init()
	C_ChatInfo_RegisterAddonMessagePrefix("KKUIVersionCheck")
	K:RegisterEvent("CHAT_MSG_ADDON", Module.VersionCheck_Update)

	if IsInGuild() then
		C_ChatInfo_SendAddonMessage("KKUIVersionCheck", K.Version, "GUILD")
		lastVCTime = GetTime()
	end
	Module:VersionCheck_UpdateGroup()
	K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.VersionCheck_UpdateGroup)
end
