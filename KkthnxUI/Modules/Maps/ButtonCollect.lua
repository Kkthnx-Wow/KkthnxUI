local K, C, L = unpack(select(2, ...))
if C.Minimap.Enable ~= true or C.Minimap.CollectButtons ~= true then return end

-- WoW Lua
local ipairs = ipairs
local tinsert = table.insert
local unpack = unpack

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: Minimap

-- COLLECT MINIMAP BUTTONS IN ONE LINE
local BlackList = {
	["QueueStatusMinimapButton"] = true,
	["MiniMapTracking"] = true,
	["MiniMapMailFrame"] = true,
	["HelpOpenTicketButton"] = true,
	["GameTimeFrame"] = true,
	["TimeManagerClockButton"] = true,
}

local buttons = {}
local button = CreateFrame("Frame", "ButtonCollectFrame", UIParent)
local line = ceil(C.Minimap.Size / 20)

local function PositionAndStyle()
	button:SetSize(20, 20)
	button:SetPoint(unpack(C.Position.MinimapButtons))
	for i = 1, #buttons do
		buttons[i]:ClearAllPoints()
		if i == 1 then
			buttons[i]:SetPoint("TOP", button, "TOP", 0, 0)
		elseif i == line then
			buttons[i]:SetPoint("TOPRIGHT", buttons[1], "TOPLEFT", -1, 0)
		else
			buttons[i]:SetPoint("TOP", buttons[i-1], "BOTTOM", 0, -1)
		end
		buttons[i].ClearAllPoints = K.Noop
		buttons[i].SetPoint = K.Noop
		if C.Minimap.FadeButtons then
			buttons[i]:SetAlpha(0)
			buttons[i]:HookScript("OnEnter", function() K.FadeIn(buttons[i]) end)
			buttons[i]:HookScript("OnLeave", function() K.FadeOut(buttons[i]) end)
		end
	end
end

local collect = CreateFrame("Frame")
collect:RegisterEvent("PLAYER_ENTERING_WORLD")
collect:SetScript("OnEvent", function(self)
	for i, child in ipairs({Minimap:GetChildren()}) do
		if not BlackList[child:GetName()] then
			if child:GetObjectType() == "Button" and child:GetNumRegions() >= 3 and child:IsShown() then
				child:SetParent(button)
				tinsert(buttons, child)
			end
		end
	end
	if #buttons == 0 then
		button:Hide()
	end
	PositionAndStyle()
end)
