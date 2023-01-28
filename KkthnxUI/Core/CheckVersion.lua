local K, C = unpack(KkthnxUI)
local Module = K:NewModule("VersionCheck")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

local string_format = string.format
local string_gsub = string.gsub
local string_split = string.split

local Ambiguate = Ambiguate
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local GetTime = GetTime
local IsInGroup = IsInGroup
local IsInGuild = IsInGuild

local lastVCTime = 0
local isVCInit
local tn = tonumber

local function HandleVersionTag(version)
	local major, minor = string.split(".", version)
	major, minor = tonumber(major), tonumber(minor)

	if K.LibBase64:CV(major) then
		major, minor = 0, 0

		if K.isDeveloper and author then
			print("Moron: " .. author)
		end
	end

	return major, minor
end

function Module:VersionCheck_Compare(new, old, author)
	local new1, new2 = HandleVersionTag(new, author)
	local old1, old2 = HandleVersionTag(old)
	if new1 > old1 or (new1 == old1 and new2 > old2) then
		return "IsNew"
	elseif new1 < old1 or (new1 == old1 and new2 < old2) then
		return "IsOld"
	end
end

function Module:VersionCheck_Create(text)
	if not C["General"].VersionCheck then
		return
	end

	local UIUpdateNotice = CreateFrame("Frame", "KKUI_UpdateNotice", UIParent)
	UIUpdateNotice:SetSize(420, 150)
	UIUpdateNotice:SetPoint("CENTER", UIParent, "CENTER")
	UIUpdateNotice:CreateBorder()

	UIUpdateNotice.Texture = UIUpdateNotice:CreateTexture(nil, "OVERLAY")
	UIUpdateNotice.Texture:SetTexture("Interface\\HELPFRAME\\HelpIcon-ReportAbuse")
	UIUpdateNotice.Texture:SetPoint("TOP", UIUpdateNotice, "TOP", 0, 8)

	UIUpdateNotice.Text = UIUpdateNotice:CreateFontString(nil, "OVERLAY")
	UIUpdateNotice.Text:SetWidth(400)
	UIUpdateNotice.Text:SetFontObject(K.UIFont)
	UIUpdateNotice.Text:SetText(text)
	UIUpdateNotice.Text:SetFont(select(1, UIUpdateNotice.Text:GetFont()), 15, select(3, UIUpdateNotice.Text:GetFont()))
	UIUpdateNotice.Text:SetPoint("CENTER", UIUpdateNotice, "CENTER")

	UIUpdateNotice.EditBox = CreateFrame("EditBox", nil, UIUpdateNotice)
	UIUpdateNotice.EditBox:SetPoint("BOTTOM", UIUpdateNotice, "BOTTOM", 0, 8)
	UIUpdateNotice.EditBox:SetText("https://www.curseforge.com/wow/addons/kkthnxui")
	UIUpdateNotice.EditBox:SetWidth(330)
	UIUpdateNotice.EditBox:SetHeight(19)
	UIUpdateNotice.EditBox:SetMultiLine(false)
	UIUpdateNotice.EditBox:SetAutoFocus(false)
	UIUpdateNotice.EditBox:SetFontObject(K.UIFont)
	UIUpdateNotice.EditBox:CreateBorder()

	UIUpdateNotice.EditBox.Text = UIUpdateNotice.EditBox:CreateFontString(nil, "OVERLAY")
	UIUpdateNotice.EditBox.Text:SetFontObject(K.UIFont)
	UIUpdateNotice.EditBox.Text:SetText(K.SystemColor .. "Download Latest Release|r")
	UIUpdateNotice.EditBox.Text:SetPoint("BOTTOM", UIUpdateNotice.EditBox, "TOP", 0, 2)

	UIUpdateNotice.OkayButton = CreateFrame("Button", nil, UIUpdateNotice)
	UIUpdateNotice.OkayButton:SetPoint("TOP", UIUpdateNotice, "BOTTOM", 0, -6)
	UIUpdateNotice.OkayButton:RegisterForClicks("AnyUp")
	UIUpdateNotice.OkayButton:SetSize(420, 24)
	UIUpdateNotice.OkayButton:SkinButton()
	UIUpdateNotice.OkayButton:SetScript("OnClick", function()
		if UIUpdateNotice:IsShown() then
			UIUpdateNotice:Hide()
		end
	end)

	UIUpdateNotice.OkayButton.Text = UIUpdateNotice.OkayButton:CreateFontString(nil, "ARTWORK")
	UIUpdateNotice.OkayButton.Text:SetFontObject(K.UIFont)
	UIUpdateNotice.OkayButton.Text:SetFont(select(1, UIUpdateNotice.OkayButton.Text:GetFont()), 13, select(3, UIUpdateNotice.OkayButton.Text:GetFont()))
	UIUpdateNotice.OkayButton.Text:SetText("I am going to update right now")
	UIUpdateNotice.OkayButton.Text:SetTextColor(0, 1, 0)
	UIUpdateNotice.OkayButton.Text:SetPoint("CENTER", UIUpdateNotice.OkayButton, "CENTER", 0, 0)
	K.AddTooltip(UIUpdateNotice.OkayButton, "ANCHOR_BOTTOM", K.SystemColor .. "Obviously |cff669dffKkthnx|r is trusting you to go update and not complain about a missing feature or a bug because you are out of date |CFFFF0000<3|r")

	return UIUpdateNotice
end

function Module:VersionCheck_Init()
	if not isVCInit then
		local status = Module:VersionCheck_Compare(KkthnxUIDB.DetectVersion, K.Version)
		if status == "IsNew" then
			local release = string_gsub(KkthnxUIDB.DetectVersion, "(%d+)$", "0")
			Module:VersionCheck_Create(string_format("|cff669dffKkthnxUI|r is out of date, the latest release is |cff70C0F5%s|r", release))
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

	Module:VersionCheck_Send(K.CheckChat())
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
