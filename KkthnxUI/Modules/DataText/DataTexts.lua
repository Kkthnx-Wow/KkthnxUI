local K, C, L = select(2, ...):unpack()

local DataTexts = CreateFrame("Frame")

local pairs = pairs
local unpack = unpack
local CreateFrame = CreateFrame
local strlower = strlower
local tinsert = table.insert
local hooksecurefunc = hooksecurefunc

DataTexts.NumAnchors = 7
DataTexts.Font = C.Media.Font
DataTexts.Size = C.Media.Font_Size
DataTexts.Flags = C.Media.Font_Style
DataTexts.Texts = {}
DataTexts.Anchors = {}
DataTexts.Menu = {}

-- set valuecolor and namecolor
DataTexts.NameColor = K.RGBToHex(K.Color.r, K.Color.g, K.Color.b)
DataTexts.ValueColor = K.RGBToHex(1, 1, 1)

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

function EventFrame:PLAYER_LOGIN()
	K.DataTexts_Init()
end

function DataTexts:AddToMenu(name, data)
	if (self.Texts[name]) then
		return
	end

	self.Texts[name] = data
	tinsert(self.Menu, {text = name, notCheckable = true, func = self.Toggle, arg1 = data})
end

local function RemoveData(self)
	if (self.Data) then
		self.Data.Position = 0
		self.Data:Disable()
	end

	self.Data = nil
end

local function SetData(self, object)
	if (self.Data) then
		RemoveData(self)
	end

	self.Data = object
	self.Data:Enable()
	self.Data.Text:SetPoint("RIGHT", self, 0, 0)
	self.Data.Text:SetPoint("LEFT", self, 0, 0)
	self.Data.Text:SetPoint("TOP", self, 0, 0)
	self.Data.Text:SetPoint("BOTTOM", self, 0, 1)
	self.Data.Position = self.Num
	self.Data:SetAllPoints(self.Data.Text)
end

-- Here we def the ancors for all dts
function DataTexts:CreateAnchors()

	local KkthnxUIDataTextBottomBar = KkthnxUIDataTextBottomBar
	local KkthnxUIDataTextSplitBarLeft = KkthnxUIDataTextSplitBarLeft
	local KkthnxUIDataTextSplitBarRight = KkthnxUIDataTextSplitBarRight

	self.NumAnchors = self.NumAnchors

	for i = 1, self.NumAnchors do
		local Frame = CreateFrame("Button", "DataTextsAnchor" .. i, UIParent)
		Frame:SetFrameLevel(KkthnxUIMinimapStats:GetFrameLevel() + 1)
		Frame:SetFrameStrata("HIGH")
		Frame:EnableMouse(false)
		Frame.SetData = SetData
		Frame.RemoveData = RemoveData
		Frame.Num = i

		Frame.Tex = Frame:CreateTexture()
		Frame.Tex:SetAllPoints()
		Frame.Tex:SetTexture(0.2, 1, 0.2, 0)

		self.Anchors[i] = Frame

		if (i == 1 or i == 2 or i == 3 or i == 4) and C.DataText.BottomBar then
			Frame:SetSize((KkthnxUIDataTextBottomBar:GetWidth() / 4) - 1, KkthnxUIDataTextBottomBar:GetHeight() - 2)

			if (i == 1) then
				Frame:SetPoint("LEFT", KkthnxUIDataTextBottomBar, 1, 0)
			else
				Frame:SetPoint("LEFT", self.Anchors[i - 1], "RIGHT", 1, 0)
			end
		elseif (i == 5) and C.DataText.System then
			Frame:SetSize(KkthnxUIMinimapStats:GetWidth() - 1, KkthnxUIMinimapStats:GetHeight() - 2)
			Frame:SetPoint("LEFT", KkthnxUIMinimapStats, 1, 0)
		elseif (i == 6) and C.ActionBar.SplitBars and C.DataText.BottomBar then
			Frame:SetSize(KkthnxUIDataTextSplitBarLeft:GetWidth() - 1, KkthnxUIDataTextSplitBarLeft:GetHeight() - 2)
			Frame:SetPoint("LEFT", KkthnxUIDataTextSplitBarLeft, 1, 0)
		elseif (i == 7) and C.ActionBar.SplitBars and C.DataText.BottomBar then
			Frame:SetSize(KkthnxUIDataTextSplitBarRight:GetWidth() - 1, KkthnxUIDataTextSplitBarRight:GetHeight() - 2)
			Frame:SetPoint("LEFT", KkthnxUIDataTextSplitBarRight, 1, 0)
		end
	end
end

-- Here we set the tooltips for all dts
local function GetTooltipAnchor(self)

	local Position = self.Position
	local From
	local Anchor = "ANCHOR_TOPLEFT"
	local X = 0
	local Y = K.Scale(5)

	if (Position == 1) then
		Anchor = "ANCHOR_LEFT"
		From = KkthnxUIDataTextBottomBar
		Y = K.Scale(0)
	elseif (Position == 2) then
		Anchor = "ANCHOR_LEFT"
		From = KkthnxUIDataTextBottomBar
		Y = K.Scale(0)
	elseif (Position == 3) then
		Anchor = "ANCHOR_RIGHT"
		From = KkthnxUIDataTextBottomBar
		Y = K.Scale(0)
	elseif (Position == 4) then
		Anchor = "ANCHOR_RIGHT"
		From = KkthnxUIDataTextBottomBar
		Y = K.Scale(0)
	elseif (Position == 5) then
		Anchor = "ANCHOR_BOTTOMLEFT"
		From = KkthnxUIMinimapStats
		Y = K.Scale(-5)
	elseif (Position == 6) and C.ActionBar.SplitBars then
		Anchor = "ANCHOR_LEFT"
		From = KkthnxUIDataTextSplitBarLeft
		Y = K.Scale(0)
	elseif (Position == 7) and C.ActionBar.SplitBars then
		Anchor = "ANCHOR_RIGHT"
		From = KkthnxUIDataTextSplitBarRight
		Y = K.Scale(0)
	end

	return From, Anchor, X, Y
end

function DataTexts:GetDataText(name)
	return self.Texts[name]
end

local function OnEnable(self)
	if (not self.FontUpdated) then
		self.Text:SetFont(DataTexts.Font, DataTexts.Size, DataTexts.Flags)
		self.FontUpdated = true
	end

	self:Show()
	self.Enabled = true
end

local function OnDisable(self)
	self:Hide()
	self.Enabled = false
end

function DataTexts:Register(name, enable, disable, update)
	local Data = CreateFrame("Frame", nil, UIParent)
	Data:EnableMouse(true)
	Data:SetFrameStrata("BACKGROUND")
	Data:SetFrameLevel(3)
	Data.Enabled = false
	Data.GetTooltipAnchor = GetTooltipAnchor
	Data.Enable = enable or function() end
	Data.Disable = disable or function() end
	Data.Update = update or function() end

	hooksecurefunc(Data, "Enable", OnEnable)
	hooksecurefunc(Data, "Disable", OnDisable)

	self:AddToMenu(name, Data)
end

function DataTexts:ForceUpdate()
	for _, data in pairs(self.Texts) do
		if data.Enabled then
			data:Update(1)
		end
	end
end

function DataTexts:ResetGold()
	local Realm = GetRealmName()
	local Name = UnitName("player")

	KkthnxUIData.Gold = {}
	KkthnxUIData.Gold[Realm] = {}
	KkthnxUIData.Gold[Realm][Name] = GetMoney()
end

function DataTexts:Save()
	if (not KkthnxUIDataPerChar) then
		KkthnxUIDataPerChar = {}
	end

	local Data = KkthnxUIDataPerChar

	if (not Data.Texts) then
		Data.Texts = {}
	end

	for Name, DataText in pairs(self.Texts) do
		if (DataText.Position) then
			Data.Texts[Name] = {DataText.Enabled, DataText.Position}
		end
	end
end

-- Here default the datatext on first start --> name are from datatext files at the end
function DataTexts:AddDefaults()
	KkthnxUIDataPerChar.Texts = {}

	KkthnxUIDataPerChar.Texts[GUILD] = {true, 1}
	KkthnxUIDataPerChar.Texts[FRIENDS] = {true, 2}
	KkthnxUIDataPerChar.Texts[DURABILITY] = {true, 3}
	KkthnxUIDataPerChar.Texts["Gold"] = {true, 4}
	KkthnxUIDataPerChar.Texts["FPS&MS"] = {true, 5}
	if C.ActionBar.SplitBars then
		KkthnxUIDataPerChar.Texts["Talents"] = {true, 6}
		KkthnxUIDataPerChar.Texts[CURRENCY] = {true, 7}
	end

end

function DataTexts:Reset()
	KkthnxUIDataPerChar.Texts = {}

	for i = 1, self.NumAnchors do
		RemoveData(self.Anchors[i])
	end

	for _, Data in pairs(self.Texts) do
		if (Data.Enabled) then
			Data:Disable()
		end
	end

	self:AddDefaults()

	if (KkthnxUIDataPerChar and KkthnxUIDataPerChar.Texts) then
		for name, info in pairs(KkthnxUIDataPerChar.Texts) do
			local Enabled, Num = unpack(info)

			if (Enabled and (Num and Num > 0)) then
				local Object = self:GetDataText(name)

				if (Object) then
					Object:Enable()
					self.Anchors[Num]:SetData(Object)
				else
					K.Print("Red", "DataText " .. name .. " not found. Removing from cache.")
					KkthnxUIDataPerChar.Texts[name] = {false, 0}
				end
			end
		end
	end
end

function DataTexts:Load()
	self:CreateAnchors()

	if (not KkthnxUIDataPerChar) then
		KkthnxUIDataPerChar = {}
	end

	if (not KkthnxUIDataPerChar.Texts) then
		self:AddDefaults()
	end

	if (KkthnxUIDataPerChar and KkthnxUIDataPerChar.Texts) then
		for name, info in pairs(KkthnxUIDataPerChar.Texts) do
			local Enabled, Num = unpack(info)

			if (Enabled and (Num and Num > 0)) then
				local Object = self:GetDataText(name)

				if (Object) then
					Object:Enable()
					self.Anchors[Num]:SetData(Object)
				else
					K.Print("Red", "DataText " .. name .. " not found. Removing from cache.")
					KkthnxUIDataPerChar.Texts[name] = {false, 0}
				end
			end
		end
	end
end

DataTexts:RegisterEvent("PLAYER_LOGOUT")
DataTexts:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

K.DataTexts_Init = function()
	DataTexts:Load()
end

function DataTexts:PLAYER_LOGOUT()
	self:Save()
end

K.DataTexts = DataTexts
