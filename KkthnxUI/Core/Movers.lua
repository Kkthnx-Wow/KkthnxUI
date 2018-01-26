local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_insert = table.insert
local unpack = unpack

-- Wow API
local CreateFrame = _G.CreateFrame
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local InCombatLockdown = _G.InCombatLockdown
local pairs = _G.pairs
local print = _G.print
local UIParent = _G.UIParent

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KkthnxUIData

local Movers = CreateFrame("Frame")
local Name = UnitName("Player")
local Realm = GetRealmName()

Movers:RegisterEvent("PLAYER_ENTERING_WORLD")
Movers:RegisterEvent("PLAYER_REGEN_DISABLED")
Movers.Frames = {}
Movers.Defaults = {}

function Movers:SaveDefaults(frame, a1, p, a2, x, y)
	if not a1 then
		return
	end

	if not p then
		p = UIParent
	end

	local Data = Movers.Defaults
	local Frame = frame:GetName()

	Data[Frame] = {a1, p:GetName(), a2, x, y}
end

function Movers:RestoreDefaults(button)
	local FrameName = self.Parent:GetName()
	local Data = Movers.Defaults[FrameName]
	local SavedVariables = KkthnxUIData[Realm][Name].Movers

	if IsShiftKeyDown() and (button == "RightButton") and (Data) and not (InCombatLockdown()) then
		local Anchor1, ParentName, Anchor2, X, Y = unpack(Data)
		local Frame = _G[FrameName]
		local Parent = _G[ParentName]

		Frame:ClearAllPoints()
		Frame:SetPoint(Anchor1, Parent, Anchor2, X, Y)

		Frame.DragInfo:ClearAllPoints()
		Frame.DragInfo:SetPoint("CENTER", Frame)

		-- Delete Saved Variable
		SavedVariables[FrameName] = nil
	end
end

function Movers:RegisterFrame(frame)
	if not frame then return end

	local Anchor1, Parent, Anchor2, X, Y = frame:GetPoint()

	table_insert(self.Frames, frame)

	self:SaveDefaults(frame, Anchor1, Parent, Anchor2, X, Y)
end

function Movers:OnDragStart()
	if InCombatLockdown() then
		return K.Print(ERR_NOT_IN_COMBAT)
	end
	self.moving = true
	self:StartMoving()
end

function Movers:OnDragStop()
	if InCombatLockdown() then
		return K.Print(ERR_NOT_IN_COMBAT)
	end
	self.moving = nil
	self:StopMovingOrSizing()

	local Data = KkthnxUIData[Realm][Name].Movers
	local Anchor1, Parent, Anchor2, X, Y = self:GetPoint()
	local FrameName = self.Parent:GetName()
	local Frame = self.Parent

	Frame:ClearAllPoints()
	Frame:SetPoint(Anchor1, Parent, Anchor2, X, Y)

	if not Parent then
		Parent = UIParent
	end

	Data[FrameName] = {Anchor1, Parent:GetName(), Anchor2, X, Y}
end

function Movers:CreateDragInfo()
	self.DragInfo = CreateFrame("Button", nil, self)
	self.DragInfo:SetPoint("CENTER", self)
	self.DragInfo:SetFrameLevel(self:GetFrameLevel() + 1)
	self.DragInfo:SetWidth(self:GetWidth())
	self.DragInfo:SetHeight(self:GetHeight())
	self.DragInfo:SetMovable(true)
	self.DragInfo:SetToplevel(true)
	self.DragInfo:RegisterForDrag("LeftButton")
	self.DragInfo:SetClampedToScreen(true)
	self.DragInfo:SetTemplate("Transparent", true)
	self.DragInfo:SetBackdropColor(72/255, 133/255, 237/255, 0.6)
	self.DragInfo:Hide()
	self.DragInfo:SetScript("OnMouseUp", Movers.RestoreDefaults)

	self.DragInfo:SetScript("OnEnter", function(self)
		self:SetBackdropColor(K.Color.r, K.Color.g, K.Color.b, 0.8)
	end)

	self.DragInfo:SetScript("OnLeave", function(self)
		self:SetBackdropColor(72/255, 133/255, 237/255, 0.6)
	end)

	self.DragInfo.Name = self.DragInfo:CreateFontString(nil, "OVERLAY")
	self.DragInfo.Name:SetFont(C["Media"].Font, C["Media"].FontSize, C["Media"].FontStyle)
	self.DragInfo.Name:SetPoint("CENTER")
	self.DragInfo.Name:SetTextColor(1, 1, 1)
	self.DragInfo.Name:SetText(self:GetName())
	self.DragInfo.Name:SetWidth(self:GetWidth() - 4)

	self.DragInfo.Parent = self.DragInfo:GetParent()
end

function Movers:StartOrStopMoving()
	if InCombatLockdown() then
		return K.Print(ERR_NOT_IN_COMBAT)
	end

	if not self.IsEnabled then
		self.IsEnabled = true
	else
		self.IsEnabled = false
	end

	for i = 1, #self.Frames do
		local Frame = Movers.Frames[i]

		if self.IsEnabled then
			if not Frame.DragInfo then
				self.CreateDragInfo(Frame)
			end

			if Frame.unit then
				Frame.oldunit = Frame.unit
				Frame.unit = "player"
				Frame:SetAttribute("unit", "player")
			end

			Frame.DragInfo:SetScript("OnDragStart", self.OnDragStart)
			Frame.DragInfo:SetScript("OnDragStop", self.OnDragStop)
			Frame.DragInfo:SetParent(UIParent)
			Frame.DragInfo:Show()

			if Frame.DragInfo:GetFrameLevel() ~= 100 then
				Frame.DragInfo:SetFrameLevel(100)
			end

			if Frame.DragInfo:GetFrameStrata() ~= "HIGH" then
				Frame.DragInfo:SetFrameStrata("HIGH")
			end

			if Frame.DragInfo:GetHeight() < 12 then
				Frame.DragInfo:ClearAllPoints()
				Frame.DragInfo:SetWidth(Frame:GetWidth())
				Frame.DragInfo:SetHeight(12)
				Frame.DragInfo:SetPoint("CENTER", Frame)
			end
		else
			if Frame.unit then
				Frame.unit = Frame.oldunit
				Frame:SetAttribute("unit", Frame.unit)
			end

			if Frame.DragInfo then
				Frame.DragInfo:SetParent(Frame.DragInfo.Parent)
				Frame.DragInfo:Hide()
				Frame.DragInfo:SetScript("OnDragStart", nil)
				Frame.DragInfo:SetScript("OnDragStop", nil)

				if Frame.DragInfo.CurrentHeight then
					Frame.DragInfo:ClearAllPoints()
					Frame.DragInfo:SetPoint("CENTER", Frame)
				end
			end
		end
	end
end

function Movers:IsRegisteredFrame(frame)
	local Match = false

	for i = 1, #self.Frames do
		if self.Frames[i] == frame then
			Match = true
		end
	end

	return Match
end

Movers:SetScript("OnEvent", function(self, event)
	if (event == "PLAYER_ENTERING_WORLD") then
		if not KkthnxUIData[Realm][Name].Movers then
			KkthnxUIData[Realm][Name].Movers = {}
		end

		local Data = KkthnxUIData[Realm][Name].Movers

		for Frame, Position in pairs(Data) do
			local Frame = _G[Frame]
			local IsRegistered = self:IsRegisteredFrame(Frame)

			if Frame and IsRegistered then
				local Anchor1, Parent, Anchor2, X, Y = Frame:GetPoint()

				self:SaveDefaults(Frame, Anchor1, Parent, Anchor2, X, Y)

				Anchor1, Parent, Anchor2, X, Y = unpack(Position)

				Frame:ClearAllPoints()
				Frame:SetPoint(Anchor1, _G[Parent], Anchor2, X, Y)
			end
		end
		if (event == "PLAYER_REGEN_DISABLED") then
			if self.IsEnabled then
				self:StartOrStopMoving()
			end
		end
	end
end)

K["Movers"] = Movers