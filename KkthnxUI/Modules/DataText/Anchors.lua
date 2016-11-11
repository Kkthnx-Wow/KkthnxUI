local K, C, L = select(2, ...):unpack()

local tinsert = tinsert

local DataTexts = K.DataTexts

local MenuFrame = CreateFrame("Frame", "DataTextToggleDropDown", UIParent, "UIDropDownMenuTemplate")
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

tinsert(Menu, {text = "", notCheckable = true})
tinsert(Menu, {text = "|cffFF0000"..REMOVE.."|r", notCheckable = true, func = DataTexts.Remove})

-- Datatext toggle
SlashCmdList.DTSLASH = function() K.DataTexts:ToggleDataPositions() end
SLASH_DTSLASH1 = "/dt"
