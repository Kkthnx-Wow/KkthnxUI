local K, C, L = unpack(select(2, ...))
if C.Skins.Recount ~= true or not K.CheckAddOn("Recount") then return end

local _G = _G

local Recount = _G.Recount
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local hooksecurefunc = _G.hooksecurefunc

-- GLOBALS: AcceptFrame, YES, NO, LibDropdownFrame0, Recount_MainWindow_ScrollBarScrollBar, Recount_ReportWindow

local function Recount_AcceptFrame(MainText, Function)
	if not AcceptFrame then
		AcceptFrame = CreateFrame("Frame", "AcceptFrame", UIParent)
		AcceptFrame:CreateBackdrop()
		AcceptFrame:SetPoint("CENTER", UIParent, "CENTER")
		AcceptFrame:SetFrameStrata("DIALOG")
		AcceptFrame.Text = AcceptFrame:CreateFontString(nil, "OVERLAY")
		AcceptFrame.Text:SetFont(C.Media.Font, 14)
		AcceptFrame.Text:SetPoint("TOP", AcceptFrame, "TOP", 0, -10)
		AcceptFrame.Accept = CreateFrame("Button", nil, AcceptFrame, "OptionsButtonTemplate")
		AcceptFrame.Accept:SkinButton()
		AcceptFrame.Accept:SetSize(70, 22)
		AcceptFrame.Accept:SetPoint("RIGHT", AcceptFrame, "BOTTOM", -10, 20)
		AcceptFrame.Accept:SetFormattedText("|cFFFFFFFF%s|r", YES)
		AcceptFrame.Close = CreateFrame("Button", nil, AcceptFrame, "OptionsButtonTemplate")
		AcceptFrame.Close:SkinButton()
		AcceptFrame.Close:SetSize(70, 22)
		AcceptFrame.Close:SetPoint("LEFT", AcceptFrame, "BOTTOM", 10, 20)
		AcceptFrame.Close:SetScript("OnClick", function(self) self:GetParent():Hide() end)
		AcceptFrame.Close:SetFormattedText("|cFFFFFFFF%s|r", NO)
	end
	AcceptFrame.Text:SetText(MainText)
	AcceptFrame:SetSize(AcceptFrame.Text:GetStringWidth() + 100, AcceptFrame.Text:GetStringHeight() + 60)
	AcceptFrame.Accept:SetScript("OnClick", Function)
	AcceptFrame:Show()
end

local Recount_Skin = CreateFrame("Frame")
Recount_Skin:RegisterEvent("ADDON_LOADED")
Recount_Skin:SetScript("OnEvent", function(self, event, addon)
	function Recount:ShowReset()
		Recount_AcceptFrame("Reset Recount?", function(self) Recount:ResetData() self:GetParent():Hide() end)
	end

	local function SkinFrame(frame)
		frame:CreateBackdrop()
		frame.backdrop:SetAllPoints()
		frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, -6)
		frame.backdrop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 6)
		frame.backdrop:SetAlpha(0.2) -- Idk why we need this but our backdrop bugs it out.
		frame:SetBackdrop(nil)
		frame.TitleBackground = CreateFrame("Frame", nil, frame)
		frame.TitleBackground:SetPoint("TOP", frame, "TOP", 0, -8)
		frame.TitleBackground:SetScript("OnUpdate", function(self) self:SetSize(frame:GetWidth() - 4, 22) end)
		frame.TitleBackground:SetFrameLevel(frame:GetFrameLevel())
		frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -12)
	end

	local RecountFrames = {
		Recount.MainWindow,
		Recount.ConfigWindow,
		Recount.GraphWindow,
		Recount.DetailWindow,
	}

	for _, frame in pairs(RecountFrames) do
		if frame then SkinFrame(frame) end
	end

	local OtherRecountFrames = {
		"Recount_Realtime_!RAID_DAMAGE",
		"Recount_Realtime_!RAID_HEALING",
		"Recount_Realtime_!RAID_HEALINGTAKEN",
		"Recount_Realtime_!RAID_DAMAGETAKEN",
		"Recount_Realtime_Bandwidth Available_AVAILABLE_BANDWIDTH",
		"Recount_Realtime_FPS_FPS",
		"Recount_Realtime_Latency_LAG",
		"Recount_Realtime_Downstream Traffic_DOWN_TRAFFIC",
		"Recount_Realtime_Downstream Traffic_UP_TRAFFIC"
	}

	for _, frame in pairs(OtherRecountFrames) do
		if _G[frame] then
			SkinFrame(_G[frame].Window)
		end
	end

	Recount.MainWindow.FileButton:HookScript("OnClick", function(self) if LibDropdownFrame0 then LibDropdownFrame0:SetTemplate("Transparent") end end)

	hooksecurefunc(Recount, "ShowScrollbarElements", function(self, name) Recount_MainWindow_ScrollBarScrollBar:Show() end)
	hooksecurefunc(Recount, "HideScrollbarElements", function(self, name) Recount_MainWindow_ScrollBarScrollBar:Hide() end)

	if Recount.db.profile.MainWindow.ShowScrollbar == false then
		Recount:HideScrollbarElements("Recount_MainWindow_ScrollBar")
	end

	hooksecurefunc(Recount, "ShowReport", function(self)
		if Recount_ReportWindow.isSkinned then return end
		Recount_ReportWindow.isSkinned = true
		Recount_ReportWindow.Whisper:CreateBackdrop()
	end)
end)