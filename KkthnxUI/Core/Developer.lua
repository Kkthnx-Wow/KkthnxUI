local K, C, L = unpack(select(2, ...))

local _G = _G
local print, tostring, select = print, tostring, select
local format = format

local GetMouseFocus = GetMouseFocus
local FrameStackTooltip_Toggle = FrameStackTooltip_Toggle

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SLASH_FRAME1, SLASH_FRAMELIST1, SLASH_TEXLIST1, SLASH_FSTACK1, SLASH_WOWVERSION2
-- GLOBALS: SLASH_WOWVERSION1, FRAME, ChatFrame1, FrameStackTooltip, UIParentLoadAddOn
-- GLOBALS: CopyFrame, SlashCmdList

--[[
Command to grab frame information when mouseing over a frame

Frame Name
Width
Height
Strata
Level
X Offset
Y Offset
Point
--]]

SlashCmdList.FRAME = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end
	if arg ~= nil then FRAME = arg end
	if arg ~= nil and arg:GetName() ~= nil then
		local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
		print("|cffCC0000--------------------------------------------------------------------|r")
		print("Name: |cffFFD100"..arg:GetName().."|r")
		if arg:GetParent() and arg:GetParent():GetName() then
			print("Parent: |cffFFD100"..arg:GetParent():GetName().."|r")
		end

		print("Width: |cffFFD100"..format("%.2f", arg:GetWidth()).."|r")
		print("Height: |cffFFD100"..format("%.2f", arg:GetHeight()).."|r")
		print("Strata: |cffFFD100"..arg:GetFrameStrata().."|r")
		print("Level: |cffFFD100"..arg:GetFrameLevel().."|r")

		if relativeTo and relativeTo:GetName() then
			print('Point: |cffFFD100 "'..point..'", '..relativeTo:GetName()..', "'..relativePoint..'"'.."|r")
		end
		if xOfs then
			print("X: |cffFFD100"..format("%.2f", xOfs).."|r")
		end
		if yOfs then
			print("Y: |cffFFD100"..format("%.2f", yOfs).."|r")
		end
		print("|cffCC0000--------------------------------------------------------------------|r")
	elseif arg == nil then
		print("Invalid frame name")
	else
		print("Could not find frame info")
	end
end
SLASH_FRAME1 = "/frame"

SlashCmdList["FRAMELIST"] = function(msg)
	if not FrameStackTooltip then
		UIParentLoadAddOn("Blizzard_DebugTools")
	end

	local isPreviouslyShown = FrameStackTooltip:IsShown()
	if not isPreviouslyShown then
		if msg == tostring(true) then
			FrameStackTooltip_Toggle(true)
		else
			FrameStackTooltip_Toggle()
		end
	end

	print("|cffCC0000--------------------------------------------------------------------|r")
	for i = 2, FrameStackTooltip:NumLines() do
		local text = _G["FrameStackTooltipTextLeft"..i]:GetText()
		if text and text ~= "" then
			print("|cffFFD100"..text)
		end
	end
	print("|cffCC0000--------------------------------------------------------------------|r")

	FrameStackTooltip_Toggle()
	SlashCmdList.COPY_CHAT()
end
SLASH_FRAMELIST1 = "/framelist"

local function TextureList(frame)
	frame = _G[frame] or FRAME

	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if(region:GetObjectType() == "Texture") then
			print(region:GetTexture(), region:GetName(), region:GetDrawLayer())
		end
	end
end
SLASH_TEXLIST1 = "/texlist"
SlashCmdList["TEXLIST"] = TextureList

-- Frame stack on cyrillic
SLASH_FSTACK1 = "/fs"
SlashCmdList["FSTACK"] = function()
	SlashCmdList.FRAMESTACK(0)
end

-- Inform us of the patch info we play on.
SLASH_WOWVERSION1, SLASH_WOWVERSION2 = "/patch", "/version"
SlashCmdList["WOWVERSION"] = function()
	K.Print("Patch:", K.WoWPatch..", ".. "Build:", K.WoWBuild..", ".. "Released:", K.WoWPatchReleaseDate..", ".. "Interface:", K.TocVersion)
end