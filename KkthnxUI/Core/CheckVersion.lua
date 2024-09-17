local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("VersionCheck")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

local string_format = string.format
local string_gsub = string.gsub
local string_split = string.split
local tonumber = tonumber
local CreateFrame = CreateFrame
local GetTime = GetTime
local Ambiguate = Ambiguate
local IsInGroup = IsInGroup
local IsInGuild = IsInGuild
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local print = print

local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage

local tn = tonumber
local lastVCTime, isVCInit = 0
local debugTest = false

-- Debugging function to track issues
local function DebugLog(message)
	if K.isDeveloper and debugTest then
		print("|cffFF0000[DEBUG]:|r " .. message)
	end
end

local function HandleVersonTag(version, author)
	local major, minor = string_split(".", version)
	major, minor = tn(major), tn(minor)

	if K.LibBase64:CV(major) then
		major, minor = 0, 0
		if K.isDeveloper and author then
			DebugLog("Invalid version from author: " .. author)
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
	frame:SetSize(420, 180)
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:CreateBorder()

	-- Set background texture to 'adventureguide-pane-small'
	frame.Background = frame:CreateTexture(nil, "BACKGROUND")
	frame.Background:SetAtlas("adventureguide-pane-small")
	frame.Background:SetAllPoints(frame)
	frame.Background:SetBlendMode("ADD")

	frame.Texture = frame:CreateTexture(nil, "OVERLAY")
	frame.Texture:SetTexture("Interface\\HELPFRAME\\HelpIcon-ReportAbuse")
	frame.Texture:SetPoint("TOP", frame, "TOP", 0, -4)

	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	frame.Text:SetWidth(400)
	frame.Text:SetFontObject(K.UIFont)
	frame.Text:SetFont(select(1, frame.Text:GetFont()), 15, select(3, frame.Text:GetFont()))
	frame.Text:SetPoint("TOP", frame, "TOP", 0, -70)

	-- CurseForge link
	frame.CurseLink = CreateFrame("EditBox", nil, frame)
	frame.CurseLink:SetPoint("CENTER", frame, "CENTER", 0, -40)
	frame.CurseLink:SetWidth(330)
	frame.CurseLink:SetHeight(19)
	frame.CurseLink:SetMultiLine(false)
	frame.CurseLink:SetAutoFocus(false)
	frame.CurseLink:SetFontObject(K.UIFont)
	frame.CurseLink:SetText("https://www.curseforge.com/wow/addons/kkthnxui")
	frame.CurseLink:CreateBorder()

	-- Tooltip for CurseForge link
	frame.CurseLink:SetScript("OnEnter", function()
		GameTooltip:SetOwner(frame.CurseLink, "ANCHOR_TOP")
		GameTooltip:AddLine("CurseForge Link", 1, 1, 1)
		GameTooltip:AddLine("This is the stable release version.", 0.7, 0.7, 0.7)
		GameTooltip:Show()
	end)
	frame.CurseLink:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- GitHub link
	frame.GitHubLink = CreateFrame("EditBox", nil, frame)
	frame.GitHubLink:SetPoint("CENTER", frame, "CENTER", 0, -70)
	frame.GitHubLink:SetWidth(330)
	frame.GitHubLink:SetHeight(19)
	frame.GitHubLink:SetMultiLine(false)
	frame.GitHubLink:SetAutoFocus(false)
	frame.GitHubLink:SetFontObject(K.UIFont)
	frame.GitHubLink:SetText("https://github.com/Kkthnx-Wow/KkthnxUI")
	frame.GitHubLink:CreateBorder()

	-- Tooltip for GitHub link
	frame.GitHubLink:SetScript("OnEnter", function()
		GameTooltip:SetOwner(frame.GitHubLink, "ANCHOR_TOP")
		GameTooltip:AddLine("GitHub Link", 1, 1, 1)
		GameTooltip:AddLine("This is the bleeding edge version and may contain bugs.", 0.7, 0.7, 0.7)
		GameTooltip:Show()
	end)
	frame.GitHubLink:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	frame.OkayButton = CreateFrame("Button", nil, frame)
	frame.OkayButton:SetPoint("TOP", frame, "BOTTOM", 0, -6)
	frame.OkayButton:SetSize(420, 24)
	frame.OkayButton:SkinButton()
	frame.OkayButton:SetScript("OnClick", function()
		if frame:IsShown() then
			frame:Hide()
		end
	end)

	-- Set background texture to 'GarrMissionLocation-Maw-ButtonBG'
	frame.Background = frame:CreateTexture(nil, "BACKGROUND")
	frame.Background:SetAtlas("GarrMissionLocation-Maw-ButtonBG")
	frame.Background:SetAllPoints(frame.OkayButton)
	frame.Background:SetBlendMode("ADD")

	frame.OkayButton.Text = frame.OkayButton:CreateFontString(nil, "ARTWORK")
	frame.OkayButton.Text:SetFontObject(K.UIFont)
	frame.OkayButton.Text:SetFont(select(1, frame.OkayButton.Text:GetFont()), 13, select(3, frame.OkayButton.Text:GetFont()))
	frame.OkayButton.Text:SetText("I am going to update right now")
	frame.OkayButton.Text:SetTextColor(0, 1, 0)
	frame.OkayButton.Text:SetPoint("CENTER", frame.OkayButton, "CENTER", 0, 0)
	K.AddTooltip(frame.OkayButton, "ANCHOR_BOTTOM", K.SystemColor .. "Please update to the latest version!")

	return frame
end

function Module:VersionCheck_Create(text)
	if not C["General"].VersionCheck then
		DebugLog("VersionCheck is disabled in settings.")
		return
	end

	local frame = Module:CreateUpdateNoticeFrame()
	frame.Text:SetText(text)
	frame:Show()
end

function Module:VersionCheck_Init()
	if not isVCInit then
		local status = Module:VersionCheck_Compare(KkthnxUIDB.DetectVersion, K.Version)

		if status == "IsNew" then
			local release = string_gsub(KkthnxUIDB.DetectVersion, "(%d+)$", "0")
			Module:VersionCheck_Create(string_format("|cff669dffKkthnxUI|r is out of date!|nPlease update to the latest version: |cff70C0F5%s|r.", release))
		elseif status == "IsOld" then
			KkthnxUIDB.DetectVersion = K.Version
		end

		isVCInit = true
		DebugLog("VersionCheck initialized.")
	else
		DebugLog("VersionCheck already initialized.")
	end
end

function Module:VersionCheck_Send(channel)
	if GetTime() - lastVCTime >= 10 then
		C_ChatInfo_SendAddonMessage("KKUIVersionCheck", KkthnxUIDB.DetectVersion, channel)
		lastVCTime = GetTime()
		DebugLog("VersionCheck message sent to channel: " .. channel)
	else
		DebugLog("VersionCheck message not sent due to cooldown.")
	end
end

function Module:VersionCheck_Update(prefix, msg, distType, author)
	if prefix ~= "KKUIVersionCheck" then
		return
	end

	if Ambiguate(author, "none") == K.Name then
		DebugLog("VersionCheck ignored message from self.")
		return
	end

	local status = Module:VersionCheck_Compare(msg, KkthnxUIDB.DetectVersion, author)

	if status == "IsNew" then
		KkthnxUIDB.DetectVersion = msg
		DebugLog("Detected new version: " .. msg)
	elseif status == "IsOld" then
		Module:VersionCheck_Send(distType)
		DebugLog("Detected outdated version. Sending current version to: " .. distType)
	end

	Module:VersionCheck_Init()
end

function Module:VersionCheck_UpdateGroup()
	if not IsInGroup() then
		DebugLog("Not in a group, skipping version check.")
		return
	end

	local channel = IsPartyLFG() or C_PartyInfo.IsPartyWalkIn() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"
	Module:VersionCheck_Send(channel)
end

function Module:OnEnable()
	Module:VersionCheck_Init()

	C_ChatInfo_RegisterAddonMessagePrefix("KKUIVersionCheck")
	K:RegisterEvent("CHAT_MSG_ADDON", Module.VersionCheck_Update)

	if IsInGuild() then
		C_ChatInfo_SendAddonMessage("KKUIVersionCheck", K.Version, "GUILD")
		lastVCTime = GetTime()
		DebugLog("VersionCheck message sent to guild.")
	end

	Module:VersionCheck_UpdateGroup()
	K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.VersionCheck_UpdateGroup)
end

-- Add this function to manually trigger a test of the version check frame
function Module:VersionCheck_Test()
	-- Fake version for testing purposes
	local fakeVersion = "9.9.9"

	-- Force the creation of the update notice frame with fake text
	local fakeText = string_format("|cff669dffKkthnxUI|r is out of date!|nPlease update to the latest version: |cff70C0F5%s|r.", fakeVersion)
	Module:VersionCheck_Create(fakeText)

	-- Print debug message for testing
	DebugLog("Triggered VersionCheck test with version: " .. fakeVersion)
end

-- Add a slash command to manually trigger the test during runtime
SLASH_KKUI_VERSIONCHECK1 = "/vctest"
SlashCmdList["KKUI_VERSIONCHECK"] = function()
	Module:VersionCheck_Test()
end
