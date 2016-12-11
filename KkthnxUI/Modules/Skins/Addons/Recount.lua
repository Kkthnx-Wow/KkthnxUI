local K, C, L = unpack(select(2, ...))
if C.Skins.Recount ~= true or not K.CheckAddOn("Recount") then return end

local Recount = _G.Recount

local function SkinFrame(frame)
	frame.bgMain = CreateFrame("Frame", nil, frame)
	if frame == Recount.MainWindow then
		frame.bgMain:CreateBackdrop(3)
		frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -15)
		frame.Title:SetFont(C.Media.Font, C.Media.Font_Size)
		frame.Title:SetShadowColor(0, 0, 0, 0)
		frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -11)
	end
	frame.bgMain:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
	frame.bgMain:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	frame.bgMain:SetPoint("TOP", frame, "TOP", 0, -7)
	frame.bgMain:SetFrameLevel(frame:GetFrameLevel())
	frame:SetBackdrop(nil)
end

local function SkinButton(frame, text)
	if frame.SetNormalTexture then frame:SetNormalTexture("") end
	if frame.SetHighlightTexture then frame:SetHighlightTexture("") end
	if frame.SetPushedTexture then frame:SetPushedTexture("") end

	if not frame.text then
		frame:FontString("text", C.Media.Font, C.Media.Font_Size)
		frame.text:SetPoint("CENTER")
		frame.text:SetText(text)
	end

	frame:HookScript("OnEnter", function(self) self.text:SetTextColor(K.Color.r, K.Color.g, K.Color.b) end)
	frame:HookScript("OnLeave", function(self) self.text:SetTextColor(1, 1, 1) end)
end

-- OVERRIDE BAR TEXTURES
Recount.UpdateBarTextures = function(self)
	for k, v in pairs(Recount.MainWindow.Rows) do
		v.StatusBar:SetStatusBarTexture(C.Media.Texture)
		v.StatusBar:GetStatusBarTexture():SetHorizTile(false)
		v.StatusBar:GetStatusBarTexture():SetVertTile(false)

		v.background = v.StatusBar:CreateTexture("$parentBackground", "BACKGROUND")
		v.background:SetAllPoints(v.StatusBar)
		v.background:SetTexture(C.Media.Texture)
		v.background:SetVertexColor(0.15, 0.15, 0.15, 0.75)

		v.LeftText:ClearAllPoints()
		v.LeftText:SetPoint("LEFT", v.StatusBar, "LEFT", 2, 0)
		v.LeftText:SetFont(C.Media.Font, C.Media.Font_Size)
		v.LeftText:SetShadowOffset(K.Mult,-K.Mult) -- Temp

		v.RightText:SetFont(C.Media.Font, C.Media.Font_Size)
		v.RightText:SetShadowOffset(K.Mult,-K.Mult) -- Temp
	end
end
Recount.SetBarTextures = Recount.UpdateBarTextures

-- FIX BAR TEXTURES AS THEY'RE CREATED
Recount.SetupBar_ = Recount.SetupBar
Recount.SetupBar = function(self, bar)
	self:SetupBar_(bar)
	bar.StatusBar:SetStatusBarTexture(C.Media.Texture)
end

-- SKIN FRAMES WHEN THEY'RE CREATED
Recount.CreateFrame_ = Recount.CreateFrame
Recount.CreateFrame = function(self, Name, Title, Height, Width, ShowFunc, HideFunc)
	local frame = self:CreateFrame_(Name, Title, Height, Width, ShowFunc, HideFunc)
	SkinFrame(frame)
	return frame
end

-- Skin existing frames
if Recount.MainWindow then SkinFrame(Recount.MainWindow) end

-- Update Textures
Recount:UpdateBarTextures()
Recount.MainWindow.ConfigButton:HookScript("OnClick", function(self) Recount:UpdateBarTextures() end)

-- Reskin Dropdown
Recount.MainWindow.FileButton:HookScript("OnClick", function(self) if LibDropdownFrame0 then LibDropdownFrame0:SetTemplate("Transparent") end end)

-- Reskin Buttons
SkinButton(Recount.MainWindow.CloseButton, "X")
SkinButton(Recount.MainWindow.RightButton, ">")
SkinButton(Recount.MainWindow.LeftButton, "<")
SkinButton(Recount.MainWindow.ResetButton, "R")
SkinButton(Recount.MainWindow.FileButton, "F")
SkinButton(Recount.MainWindow.ConfigButton, "C")
SkinButton(Recount.MainWindow.ReportButton, "S")

-- Force some default profile options
if not RecountDB then RecountDB = {} end
if not RecountDB["profiles"] then RecountDB["profiles"] = {} end
if not RecountDB["profiles"][K.Name.." - "..GetRealmName()] then RecountDB["profiles"][K.Name.." - "..K.Realm] = {} end
if not RecountDB["profiles"][K.Name.." - "..GetRealmName()]["MainWindow"] then RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"] = {} end

RecountDB["profiles"][K.Name.." - "..K.Realm]["Locked"] = false
RecountDB["profiles"][K.Name.." - "..K.Realm]["Scaling"] = 1
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["RowHeight"] = 12
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["RowSpacing"] = 1
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["ShowScrollbar"] = false
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["HideTotalBar"] = true
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["Position"]["x"] = 284
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["Position"]["y"] = -281
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["Position"]["w"] = 221
--RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["Position"]["h"] = 158
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["BarText"]["NumFormat"] = 3
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindowWidth"] = 221
--RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindowHeight"] = 158
RecountDB["profiles"][K.Name.." - "..K.Realm]["ClampToScreen"] = true
RecountDB["profiles"][K.Name.." - "..K.Realm]["Font"] = "KkthnxUI_Normal"