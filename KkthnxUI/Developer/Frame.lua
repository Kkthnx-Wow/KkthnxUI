local K = unpack(select(2, ...))

local _G = _G
local print, tostring, select = print, tostring, select

local GetMouseFocus = _G.GetMouseFocus

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
]]

SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end

	if arg ~= nil then --Set the global variable FRAME to = whatever we are mousing over to simplify messing with frames that have no name.
		FRAME = arg
	end

	if not _G.TableAttributeDisplay then
		UIParentLoadAddOn("Blizzard_DebugTools")
	end

	if _G.TableAttributeDisplay then
		_G.TableAttributeDisplay:InspectTable(arg)
		_G.TableAttributeDisplay:Show()
	end
end

SLASH_FRAMELIST1 = "/framelist"
SlashCmdList["FRAMELIST"] = function(msg)
	if (not FrameStackTooltip) then
		UIParentLoadAddOn("Blizzard_DebugTools")
	end

	local isPreviouslyShown = FrameStackTooltip:IsShown()
	if (not isPreviouslyShown) then
		if(msg == tostring(true)) then
			_G.FrameStackTooltip_Toggle(true)
		else
			_G.FrameStackTooltip_Toggle()
		end
	end

	print("|cffCC0000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|r")
	for i = 2, FrameStackTooltip:NumLines() do
		local text = _G["FrameStackTooltipTextLeft"..i]:GetText()
		if (text and text ~= "") then
			-- print(text)
			local r, g, b = _G["FrameStackTooltipTextLeft"..i]:GetTextColor()
			text = string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, text)
			print(text)
		end
	end
	print("|cffCC0000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|r")

	if (CopyChatFrame:IsShown()) then
		CopyChatFrame:Hide()
	end

	K:GetModule("CopyChat"):CopyText(ChatFrame1)
	if (not isPreviouslyShown) then
		FrameStackTooltip_Toggle()
	end
end

local function TextureList(frame)
	frame = _G[frame] or FRAME
	--[[for key, obj in pairs(frame) do
		if type(obj) == "table" and obj.IsObjectType and obj:IsObjectType('Texture') then
			print(key, obj:GetTexture())
		end
	end]]

	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if (region:IsObjectType('Texture')) then
			print(region:GetTexture(), region:GetName(), region:GetDrawLayer())
		end
	end
end

SLASH_TEXLIST1 = "/texlist"
SlashCmdList["TEXLIST"] = TextureList

local function GetPoint(frame)
	if frame ~= "" then
		frame = _G[frame]
	else
		frame = GetMouseFocus()
	end

	local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
	local frameName = frame.GetName and frame:GetName() or "nil"
	local relativeToName = relativeTo.GetName and relativeTo:GetName() or "nil"

	print(frameName, point, relativeToName, relativePoint, xOffset, yOffset)
end

SLASH_GETPOINT1 = "/getpoint"
SlashCmdList["GETPOINT"] = GetPoint

local function GetKids()
    local kids = {GetMouseFocus():GetChildren()}
    for _, child in ipairs(kids) do
        DEFAULT_CHAT_FRAME:AddMessage(child:GetName())
    end
end
SlashCmdList["GETKIDS"] = GetKids
_G.SLASH_GETKIDS1 = "/getkids"

-- get the frame name
SlashCmdList["FRAMENAME"] = function()
	print(GetMouseFocus():GetName())
end
SLASH_FRAMENAME1 = "/gn"

-- Get the focus of the mouse
SlashCmdList["GETPARENT"] = function()
	print(GetMouseFocus():GetParent():GetName())
end
SLASH_GETPARENT1 = "/gp"

-- Frame stack on cyrillic
SlashCmdList["FSTACK"] = function()
	SlashCmdList.FRAMESTACK(0)
end
_G.SLASH_FSTACK1 = "/fs"

-- Inform us of the patch info we play on.
SlashCmdList["WOWVERSION"] = function()
	K.Print("Patch:", K.WowPatch..", ".. "Build:", K.WowBuild..", ".. "Released:", K.WowRelease..", ".. "Interface:", K.TocVersion)
end
_G.SLASH_WOWVERSION1 = "/patch"
_G.SLASH_WOWVERSION2 = "/version"