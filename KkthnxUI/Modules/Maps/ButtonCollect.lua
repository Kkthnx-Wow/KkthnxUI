local K, C, L = unpack(select(2, ...))
if C["Minimap"].Enable ~= true or C["Minimap"].CollectButtons ~= true then return end

-- Lua API
local table_insert = table.insert
local string_find = string.find

-- WoW API
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local UIParent = _G.UIParent

-- Global variables that we don"t cache, list them here for the mikk"s Find Globals script
-- GLOBALS: VendomaticButton, VendomaticButtonIcon, Minimap, BaudErrorFrameMinimapButton
-- GLOBALS: GarrisonLandingPageMinimapButton

local MinimapButtonCollectFrame
local buttons = {}

local AcceptedFrames = {
	"BagSync_MinimapButton",
	"VendomaticButtonFrame",
	-- "MiniMapMailFrame",
}

local PartialIgnores = {
	"Node",
	"Note",
	"Pin",
	"POI",
}

local ignoreButtons = {
	"GameTimeFrame",
	"HelpOpenTicketButton",
	"MiniMapVoiceChatFrame",
	"TimeManagerClockButton",
}

local GenericIgnores = {
	"Archy",
	"GatherMatePin",
	"GatherNote",
	"GuildInstance",
	"HandyNotesPin",
	"MinimMap",
	"Spy_MapNoteList_mini",
	"ZGVMarker",
	"poiMinimap",
}

local function SetMinimapButton(btn)
	if (not btn or btn.isSkinned) then return end

	local name = btn:GetName()
	if not name then return end

	if btn:IsObjectType("Button") then
		local ValidIcon = false

		if not ValidIcon then
			for i = 1, #ignoreButtons do
				if name == ignoreButtons[i] then return end
			end

			for i = 1, #GenericIgnores do
				if strsub(name, 1, strlen(GenericIgnores[i])) == GenericIgnores[i] then return end
			end

			for i = 1, #PartialIgnores do
				if strfind(name, PartialIgnores[i]) ~= nil then return end
			end
		end

		if not name == "GarrisonLandingPageMinimapButton" then
			btn:SetPushedTexture(nil)
			btn:SetHighlightTexture(nil)
			btn:SetDisabledTexture(nil)
		end
	end

	btn:SetParent("MinimapButtonCollectFrame")

	for i = 1, btn:GetNumRegions() do
		local region = select(i, btn:GetRegions())
		if region:GetObjectType() == "Texture" then
			local texture = region:GetTexture()

			if texture and (string_find(texture, "Border") or string_find(texture, "Background") or string_find(texture, "AlphaMask") or string_find(texture, "Highlight")) then
				region:SetTexture(nil)
				if name == "MiniMapTrackingButton" then
					region:SetTexture("Interface\\Minimap\\Tracking\\None")
					region:ClearAllPoints()
					region:SetAllPoints()
				end
			else
				if name == "BagSync_MinimapButton" then region:SetTexture("Interface\\AddOns\\BagSync\\media\\icon") end
				if name == "DBMMinimapButton" then region:SetTexture("Interface\\Icons\\INV_Helmet_87") end
				if name == "MiniMapMailFrame" then
					region:ClearAllPoints()
					region:SetPoint("CENTER", btn)
				end
				if not (name == "MiniMapMailFrame" or name == "SmartBuff_MiniMapButton") then
					region:ClearAllPoints()
					region:SetAllPoints()
					region:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
					btn:HookScript("OnLeave", function(self)
						region:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
					end)
				end
				region:SetDrawLayer("ARTWORK")
				region.SetPoint = function() return end
			end
		end
	end

	btn:SetFrameLevel(Minimap:GetFrameLevel() + 5)

	btn.preset = {}
	btn.preset.Width, btn.preset.Height = btn:GetSize()
	btn.preset.Point, btn.preset.relativeTo, btn.preset.relativePoint, btn.preset.xOfs, btn.preset.yOfs = btn:GetPoint()
	btn.preset.Parent = btn:GetParent()
	btn.preset.FrameStrata = btn:GetFrameStrata()
	btn.preset.FrameLevel = btn:GetFrameLevel()
	btn.preset.Scale = btn:GetScale()

	if btn:HasScript("OnDragStart") then
		btn.preset.DragStart = btn:GetScript("OnDragStart")
	end
	if btn:HasScript("OnDragEnd") then
		btn.preset.DragEnd = btn:GetScript("OnDragEnd")
	end

	if name == "SmartBuff_MiniMapButton" then
		btn:SetNormalTexture("Interface\\Icons\\Spell_Nature_Purge")
		btn:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		btn.SetNormalTexture = function() end
		btn:SetDisabledTexture("Interface\\Icons\\Spell_Nature_Purge")
		btn:GetDisabledTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		btn.SetDisabledTexture = function() end
	elseif name == "VendomaticButtonFrame" then
		VendomaticButton:StripTextures()
		VendomaticButton:SetAllPoints()
		VendomaticButtonIcon:SetTexture("Interface\\Icons\\INV_Misc_Rabbit_2")
		VendomaticButtonIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	end

	btn:SetSize(18, 18)
	btn:SetTemplate("ActionButton", true)
	if btn:GetName() ~= "BaudErrorFrameMinimapButton" then
		table_insert(buttons, btn)
	else
		btn:SetBackdropBorderColor(1, 0, 0)
	end

	btn.isSkinned = true -- We don"t want to trying to skin them back to back
end

local function GrabMinimapButtons()
	for i = 1, Minimap:GetNumChildren() do
		local object = select(i, Minimap:GetChildren())
		if object then
			if object:IsObjectType("Button") and object:GetName() then
				SetMinimapButton(object)
			end
			for _, frame in pairs(AcceptedFrames) do
				if object:IsObjectType("Frame") and object:GetName() == frame then
					SetMinimapButton(object)
				end
			end
		end
	end
end

function K:PositionButton(button)
	local line = math.ceil(Minimap:GetWidth() / 20)
	if button:IsShown() then
		button:ClearAllPoints()
		if self.prevButton == nil then
			button:SetPoint("TOP", MinimapButtonCollectFrame, "TOP", -2, 0)
			self.prevButton = button
		elseif self.prevLineButton then
			button:SetPoint("TOPRIGHT", self.prevLineButton, "TOPLEFT", -3, 0)
			self.prevLineButton = nil
		else
			button:SetPoint("TOP", self.prevButton, "BOTTOM", 0, -5)
		end
		self.positioned = self.positioned + 1
		self.prevButton = button
		if self.positioned%line == 1 and self.positioned > 1 then
			self.prevLineButton = button
		end
	end
end

function K:PositionButtonCollector(self)
	MinimapButtonCollectFrame:ClearAllPoints()
	if BaudErrorFrameMinimapButton then
		BaudErrorFrameMinimapButton:SetFrameStrata("DIALOG")
		BaudErrorFrameMinimapButton:ClearAllPoints()
		BaudErrorFrameMinimapButton:SetPoint("RIGHT", Minimap, "RIGHT", -2, 0)
		BaudErrorFrameMinimapButton.ClearAllPoints = K.Noop
		BaudErrorFrameMinimapButton.SetPoint = K.Noop
	end
	K.prevLineButton = nil
	K.prevButton = nil
	K.positioned = 0
	for i =1, #buttons do
		K:PositionButton(buttons[i])
		if not buttons[i].hooked then
			hooksecurefunc(buttons[i], "SetPoint", function(self, _, anchor)
				if anchor == Minimap or type(anchor) == "number" then
					K:PositionButtonCollector(Minimap)
				end
			end)
			buttons[i]:HookScript("OnShow", function() K:PositionButtonCollector(Minimap) end)
			buttons[i]:HookScript("OnHide", function() K:PositionButtonCollector(Minimap) end)
			buttons[i].hooked = true
		end
	end
	local line = math.ceil(Minimap:GetWidth() / 20)
	local rows = math.floor(K.positioned / line) + 1
	MinimapButtonCollectFrame:SetWidth(rows * 20 + (rows - 1) * 3)
	MinimapButtonCollectFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -4, 0)
end

function K:ButtonCollector()
	MinimapButtonCollectFrame = CreateFrame("Frame", "MinimapButtonCollectFrame", UIParent)
	if select(3, Minimap:GetPoint()):upper():find("TOP") then
		MinimapButtonCollectFrame:SetPoint("BOTTOMLEFT", Minimap, "TOPLEFT", 0, 5)
	else
		MinimapButtonCollectFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -5)
	end
	MinimapButtonCollectFrame:SetSize(23, C["Minimap"].Size)
	MinimapButtonCollectFrame:SetFrameStrata("BACKGROUND")
	MinimapButtonCollectFrame:SetFrameLevel(1)

	local MinimapButtonCollect = CreateFrame("Frame")
	MinimapButtonCollect:RegisterEvent("PLAYER_ENTERING_WORLD")
	MinimapButtonCollect:RegisterEvent("ADDON_LOADED")
	MinimapButtonCollect:SetScript("OnEvent", function(self)
		GrabMinimapButtons()
		K:PositionButtonCollector(Minimap)
	end)

	local Time = 0
	MinimapButtonCollect:SetScript("OnUpdate", function(self, elasped)
		Time = Time + elasped
		if Time > 4 then -- Give it time to catch all minimap buttons.
			GrabMinimapButtons()
			K:PositionButtonCollector(Minimap)
			self:SetScript("OnUpdate", nil)
		end
	end)
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function()
	K:ButtonCollector()
end)