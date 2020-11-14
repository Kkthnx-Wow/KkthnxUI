local K = unpack(select(2, ...))

local _G = _G
local print = _G.print
local string_find = _G.string.find
local string_format = _G.string.format
local string_split = _G.string.split
local table_wipe = _G.table.wipe
local tostring = _G.tostring

local C_ChatInfo_RegisterAddonMessagePrefix = _G.C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = _G.C_ChatInfo.SendAddonMessage
local DESCRIPTION = _G.DESCRIPTION
local EJ_GetCurrentTier = _G.EJ_GetCurrentTier
local EJ_GetEncounterInfoByIndex = _G.EJ_GetEncounterInfoByIndex
local EJ_GetInstanceInfo = _G.EJ_GetInstanceInfo
local EJ_SelectInstance = _G.EJ_SelectInstance
local EnumerateFrames = _G.EnumerateFrames
local GetInstanceInfo = _G.GetInstanceInfo
local GetSpellDescription = _G.GetSpellDescription
local GetSpellInfo = _G.GetSpellInfo
local GetSpellTexture = _G.GetSpellTexture
local IsInGuild = _G.IsInGuild
local IsInRaid = _G.IsInRaid
local MouseIsOver = _G.MouseIsOver
local NAME = _G.NAME
local SlashCmdList = _G.SlashCmdList
local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName
local UNKNOWN = _G.UNKNOWN

-- KkthnxUI DevTools:
-- /getenc, get selected encounters info
-- /getid, get instance id
-- /getnpc, get npc name and id
-- /kf, get frame names
-- /kg, show grid on WorldFrame
-- /ks, get spell name and description
-- /kt, get gametooltip names

K.Devs = {
	["Iamnsfw-Sargeras"] = true,
	["Kkthnx-Sargeras"] = true,
	["Kkthnxbye-Sargeras"] = true,
	["Kkthnxtv-Sargeras"] = true,
	["Kkthnxui-Sargeras"] = true,
	["Kkthnxx-Sargeras"] = true,
	["Littledots-Sargeras"] = true,
	["Superfreaky-Sargeras"] = true,
	["Tattoofreak-Sargeras"] = true,
	["Toxicfreak-Sargeras"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name.."-"..K.Realm]
end
K.isDeveloper = isDeveloper()

-- Commands
SlashCmdList["KKTHNXUI_ENUMTIP"] = function()
	local enumf = EnumerateFrames()
	while enumf do
		if (enumf:GetObjectType() == "GameTooltip" or string_find((enumf:GetName() or ""):lower(), "tip")) and enumf:IsVisible() and enumf:GetPoint() then
			print(enumf:GetName())
		end

		enumf = EnumerateFrames(enumf)
	end
end
_G.SLASH_KKTHNXUI_ENUMTIP1 = "/gettip"
_G.SLASH_KKTHNXUI_ENUMTIP2 = "/gettooltip"

SlashCmdList["KKTHNXUI_ENUMFRAME"] = function()
	local frame = EnumerateFrames()
	local chatModule = K:GetModule("Chat")
	while frame do
		if (frame:IsVisible() and MouseIsOver(frame)) then
			print(frame:GetName() or string_format(UNKNOWN..": [%s]", tostring(frame)))
			chatModule:ChatCopy_OnClick("LeftButton")
		end

		frame = EnumerateFrames(frame)
	end
end
_G.SLASH_KKTHNXUI_ENUMFRAME1 = "/getframe"

SlashCmdList["KKTHNXUI_DUMPSPELL"] = function(arg)
	local name = GetSpellInfo(arg)
	if not name then
		print("Please enter a spell name --> /getspell SPELLNAME")
		return
	end

	local des = GetSpellDescription(arg)
	print(K.InfoColor.."------------------------")
	print(" \124T"..GetSpellTexture(arg)..":16:16:::64:64:5:59:5:59\124t", K.InfoColor..arg)
	print(NAME, K.InfoColor..(name or "nil"))
	print(DESCRIPTION, K.InfoColor..(des or "nil"))
	print(K.InfoColor.."------------------------")
end
_G.SLASH_KKTHNXUI_DUMPSPELL1 = "/getspell"

SlashCmdList["INSTANCEID"] = function()
	local name, _, _, _, _, _, _, id = GetInstanceInfo()
	print(name, id)
end
_G.SLASH_INSTANCEID1 = "/getinstance"

SlashCmdList["KKTHNXUI_NPCID"] = function()
	local name = UnitName("target")
	local guid = UnitGUID("target")
	if name and guid then
		local npcID = K.GetNPCID(guid)
		print(name, K.InfoColor..(npcID or "nil"))
	end
end
_G.SLASH_KKTHNXUI_NPCID1 = "/getnpc"

SlashCmdList["KKTHNXUI_GETFONT"] = function(msg)
	local font = _G[msg]
	if not font then
		print(msg, "not found.")
		return
	end

	local a, b, c = font:GetFont()
	print(msg,a,b,c)
end
_G.SLASH_KKTHNXUI_GETFONT1 = "/getfont"

do
	local versionList = {}
	C_ChatInfo_RegisterAddonMessagePrefix("KKUI_VersonCheck")

	local function PrintVerCheck()
		print("------------------------")
		for name, version in pairs(versionList) do
			print(name.." "..version)
		end
	end

	local function SendVerCheck(channel)
		table_wipe(versionList)
		C_ChatInfo_SendAddonMessage("KKUI_VersonCheck", "VersionCheck", channel)
		C_Timer.After(3, PrintVerCheck)
	end

	local function VerCheckListen(_, ...)
		local prefix, msg, distType, sender = ...

		if prefix == "KKUI_VersonCheck" then
			if msg == "VersionCheck" then
				C_ChatInfo_SendAddonMessage("KKUI_VersonCheck", "MyVer-"..K.Version, distType)
			elseif string_find(msg, "MyVer") then
				local _, version = string_split("-", msg)
				versionList[sender] = version.." - "..distType
			end
		end
	end
	K:RegisterEvent("CHAT_MSG_ADDON", VerCheckListen)

	SlashCmdList["KKTHNXUI_VER_CHECK"] = function(msg)
		local channel
		if IsInRaid() then
			channel = "RAID"
		elseif IsInGuild() then
			channel = "GUILD"
		end

		if msg ~= "" then
			channel = msg
		end

		if channel then
			SendVerCheck(channel)
		end
	end

	_G.SLASH_KKTHNXUI_VER_CHECK1 = "/kkversion"
end

SlashCmdList["KKTHNXUI_GET_ENCOUNTERS"] = function()
	if not _G.EncounterJournal then
		return
	end

	local tierID = EJ_GetCurrentTier()
	local instID = _G.EncounterJournal.instanceID
	EJ_SelectInstance(instID)
	local instName = EJ_GetInstanceInfo()
	print(" ")
	print("TIER = "..tierID)
	print("INSTANCE = "..instID.." -- "..instName)
	print("BOSS")
	print(" ")

	local i = 0
	while true do
		i = i + 1
		local name, _, boss = EJ_GetEncounterInfoByIndex(i)
		if not name then
			return
		end

		print("BOSS = "..boss.." -- "..name)
	end
end
_G.SLASH_KKTHNXUI_GET_ENCOUNTERS1 = "/getencounter"

-- Inform us of the patch info we play on.
SlashCmdList["WOWVERSION"] = function()
	print(K.InfoColor.."------------------------")
	K.Print("Build: ", K.WowBuild)
	K.Print("Released: ", K.WowRelease)
	K.Print("Interface: ", K.TocVersion)
	print(K.InfoColor.."------------------------")
end
_G.SLASH_WOWVERSION1 = "/getpatch"
_G.SLASH_WOWVERSION2 = "/getbuild"
_G.SLASH_WOWVERSION3 = "/getinterface"