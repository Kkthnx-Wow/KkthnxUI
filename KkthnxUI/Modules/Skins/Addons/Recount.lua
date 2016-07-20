local K, C, L, _ = select(2, ...):unpack()
if C.Skins.Recount ~= true or not IsAddOnLoaded("Recount") then return end

local _G = _G
local pairs = pairs
local CreateFrame = CreateFrame

--	Recount skin
local Recount = _G.Recount

local function SkinFrame(frame)
	frame.bgMain = CreateFrame("Frame", nil, frame)
	frame.bgMain:CreateBackdrop(3)
	if frame == Recount.MainWindow then
		frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -12)
		frame.Title:SetFont(C.Media.Font, C.Media.Font_Size)
		frame.Title:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
		frame.Title:SetShadowColor(0, 0, 0, 0)
		frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -8)
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

-- Override bar textures
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
		v.LeftText:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))

		v.RightText:SetFont(C.Media.Font, C.Media.Font_Size)
		v.RightText:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
	end
end
Recount.SetBarTextures = Recount.UpdateBarTextures

-- Fix bar textures as they're created
Recount.SetupBar_ = Recount.SetupBar
Recount.SetupBar = function(self, bar)
	self:SetupBar_(bar)
	bar.StatusBar:SetStatusBarTexture(C.Media.Texture)
end

-- Skin frames when they're created
Recount.CreateFrame_ = Recount.CreateFrame
Recount.CreateFrame = function(self, Name, Title, Height, Width, ShowFunc, HideFunc)
	local frame = self:CreateFrame_(Name, Title, Height, Width, ShowFunc, HideFunc)
	SkinFrame(frame)
	return frame
end

-- Skin existing frames
if Recount.MainWindow then SkinFrame(Recount.MainWindow) end
if Recount.ConfigWindow then SkinFrame(Recount.ConfigWindow) end
if Recount.GraphWindow then SkinFrame(Recount.GraphWindow) end
if Recount.DetailWindow then SkinFrame(Recount.DetailWindow) end
if Recount.ResetFrame then SkinFrame(Recount.ResetFrame) end
if _G["Recount_Realtime_!RAID_DAMAGE"] then SkinFrame(_G["Recount_Realtime_!RAID_DAMAGE"].Window) end
if _G["Recount_Realtime_!RAID_HEALING"] then SkinFrame(_G["Recount_Realtime_!RAID_HEALING"].Window) end
if _G["Recount_Realtime_!RAID_HEALINGTAKEN"] then SkinFrame(_G["Recount_Realtime_!RAID_HEALINGTAKEN"].Window) end
if _G["Recount_Realtime_!RAID_DAMAGETAKEN"] then SkinFrame(_G["Recount_Realtime_!RAID_DAMAGETAKEN"].Window) end
if _G["Recount_Realtime_Bandwidth Available_AVAILABLE_BANDWIDTH"] then SkinFrame(_G["Recount_Realtime_Bandwidth Available_AVAILABLE_BANDWIDTH"].Window) end
if _G["Recount_Realtime_FPS_FPS"] then SkinFrame(_G["Recount_Realtime_FPS_FPS"].Window) end
if _G["Recount_Realtime_Latency_LAG"] then SkinFrame(_G["Recount_Realtime_Latency_LAG"].Window) end
if _G["Recount_Realtime_Downstream Traffic_DOWN_TRAFFIC"] then SkinFrame(_G["Recount_Realtime_Downstream Traffic_DOWN_TRAFFIC"].Window) end
if _G["Recount_Realtime_Upstream Traffic_UP_TRAFFIC"] then SkinFrame(_G["Recount_Realtime_Upstream Traffic_UP_TRAFFIC"].Window) end

-- Update Textures
Recount:UpdateBarTextures()
Recount.MainWindow.ConfigButton:HookScript("OnClick", function(self) Recount:UpdateBarTextures() end)

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

RecountDB["profiles"][K.Name.." - "..K.Realm]["Locked"] = true
RecountDB["profiles"][K.Name.." - "..K.Realm]["Scaling"] = 1
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["RowHeight"] = 15
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["RowSpacing"] = 1
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["ShowScrollbar"] = false
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["HideTotalBar"] = true
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["Position"]["x"] = 469.00
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["Position"]["y"] = -460.00
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["Position"]["w"] = 230.00
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["Position"]["h"] = 120.00
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindow"]["BarText"]["NumFormat"] = 3
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindowWidth"] = 230.00
RecountDB["profiles"][K.Name.." - "..K.Realm]["MainWindowHeight"] = 120.00
RecountDB["profiles"][K.Name.." - "..K.Realm]["ClampToScreen"] = true
RecountDB["profiles"][K.Name.." - "..K.Realm]["Font"] = "KkUI Normal"