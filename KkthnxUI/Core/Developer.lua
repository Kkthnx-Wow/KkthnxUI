local K, C, L = select(2, ...):unpack()

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

SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end
	if arg ~= nil then FRAME = arg end -- Set the global variable frame to = whatever we are mousing over to simplify messing with frames that have no name.
	if arg ~= nil and arg:GetName() ~= nil then
		local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
		ChatFrame1:AddMessage("|cffCC0000----------------------------")
		ChatFrame1:AddMessage("Name: |cffffff00"..arg:GetName())
		if arg:GetParent() and arg:GetParent():GetName() then
			ChatFrame1:AddMessage("Parent: |cffffff00"..arg:GetParent():GetName())
		end

		ChatFrame1:AddMessage("Width: |cffffff00"..format("%.2f", arg:GetWidth()))
		ChatFrame1:AddMessage("Height: |cffffff00"..format("%.2f", arg:GetHeight()))
		ChatFrame1:AddMessage("Strata: |cffffff00"..arg:GetFrameStrata())
		ChatFrame1:AddMessage("Level: |cffffff00"..arg:GetFrameLevel())

		if xOfs then
			ChatFrame1:AddMessage("X: |cffffff00"..format("%.2f", xOfs))
		end
		if yOfs then
			ChatFrame1:AddMessage("Y: |cffffff00"..format("%.2f", yOfs))
		end
		if relativeTo and relativeTo:GetName() then
			ChatFrame1:AddMessage("Point: |cffffff00"..point.."|r anchored to "..relativeTo:GetName().."'s |cffffff00"..relativePoint)
		end
		ChatFrame1:AddMessage("|cffCC0000----------------------------|r")
	elseif arg == nil then
		ChatFrame1:AddMessage("Invalid frame name")
	else
		ChatFrame1:AddMessage("Could not find frame info")
	end
end

SLASH_FRAMELIST1 = "/framelist"
SlashCmdList["FRAMELIST"] = function(msg)
	if(not FrameStackTooltip) then
		UIParentLoadAddOn("Blizzard_DebugTools")
	end

	local isPreviouslyShown = FrameStackTooltip:IsShown()
	if(not isPreviouslyShown) then
		if(msg == tostring(true)) then
			FrameStackTooltip_Toggle(true)
		else
			FrameStackTooltip_Toggle()
		end
	end

	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	for i = 2, FrameStackTooltip:NumLines() do
		local text = _G["FrameStackTooltipTextLeft"..i]:GetText()
		if(text and text ~= "") then
			print(text)
		end
	end
	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")


	if CopyFrame then
		CopyFrame:Hide()
	end

	SlashCmdList.COPY_CHAT(ChatFrame1)
	if(not isPreviouslyShown) then
		FrameStackTooltip_Toggle()
	end
end

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