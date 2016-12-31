local K, C, L = unpack(select(2, ...))

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SLASH_DTSLASH1, Lib_EasyMenu

local DataTexts = K.DataTexts

local MenuFrame = CreateFrame("Frame", "DataTextToggleDropDown", UIParent, "Lib_UIDropDownMenuTemplate")
local Anchors = DataTexts.Anchors
local Menu = DataTexts.Menu
local Active = false
local CurrentFrame

DataTexts.Toggle = function(self, object)
	CurrentFrame:SetData(object)
end

DataTexts.Remove = function()
	CurrentFrame:RemoveData()
end

local function OnMouseDown(self)
	CurrentFrame = self

	Lib_EasyMenu(Menu, MenuFrame, "cursor", 0, 0, "MENU", 2)
end

function DataTexts:ToggleDataPositions()
	if Active then
		for i = 1, self.NumAnchors do
			local Frame = Anchors[i]

			Frame:EnableMouse(false)
			Frame.Tex:SetColorTexture(0.2, 1, 0.2, 0)
		end

		Active = false
	else
		for i = 1, self.NumAnchors do
			local Frame = Anchors[i]

			Frame:EnableMouse(true)
			Frame.Tex:SetColorTexture(0.2, 1, 0.2, 0.2)
			Frame:SetScript("OnMouseDown", OnMouseDown)
		end

		Active = true
	end
end

-- Add a remove button
tinsert(Menu, {text = "|cffFF0000"..REMOVE.."|r", notCheckable = true, func = DataTexts.Remove})
tinsert(Menu, {text = "", notCheckable = true})

-- Command to toggle, resetgold and reset all DT.
-- We need to check for details here because it uses '/dt' for all of its commands.
-- We format out slash command like so '/datatext reset' or '/datatext toggole' and so on.
SlashCmdList.DATATEXT = function(msg)
	local DataText = K.DataTexts

	if msg == "reset" then
		DataText:Reset() ReloadUI()
	elseif msg == "resetgold" then
		DataText:ResetGold() ReloadUI()
	elseif msg == "toggle" then
		DataText:ToggleDataPositions()
	end
end

if not K.CheckAddOn("Details") then
	SLASH_DATATEXT1 = "/dt"
end
SLASH_DATATEXT2 = "/datatext"