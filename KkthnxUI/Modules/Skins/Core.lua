local K, C = unpack(select(2, ...))
local Module = K:NewModule("Skins")

local _G = _G
local pairs = _G.pairs
local type = _G.type
local string_find = _G.string.find

local NO = _G.NO

Module.Blizzard_Regions = {
	"Left",
	"Middle",
	"Right",
	"Mid",
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"TopLeft",
	"TopRight",
	"BottomLeft",
	"BottomRight",
	"TopMiddle",
	"MiddleLeft",
	"MiddleRight",
	"BottomMiddle",
	"MiddleMiddle",
	"TabSpacer",
	"TabSpacer1",
	"TabSpacer2",
	"_RightSeparator",
	"_LeftSeparator",
	"Cover",
	"Border",
	"Background",
	"TopTex",
	"TopLeftTex",
	"TopRightTex",
	"LeftTex",
	"BottomTex",
	"BottomLeftTex",
	"BottomRightTex",
	"RightTex",
	"MiddleTex",
}

Module.NewSkin = {}
Module.NewSkin["KkthnxUI"] = {}
local function LoadWithSkin(event, addon)
	if K.CheckAddOnState("Skinner") or K.CheckAddOnState("Aurora") then
		if event == "ADDON_LOADED" then
			K:UnregisterEvent("ADDON_LOADED", LoadWithSkin)
		end
		return
	end

	for _addon, skinfunc in pairs(Module.NewSkin) do
		if type(skinfunc) == "function" then
			if _addon == addon then
				if skinfunc then
					skinfunc()
				end
			end
		elseif type(skinfunc) == "table" then
			if _addon == addon then
				for _, skinfunc in pairs(Module.NewSkin[_addon]) do
					if skinfunc then
						skinfunc()
					end
				end
			end
		end
	end
end
K:RegisterEvent("ADDON_LOADED", LoadWithSkin)

function Module:AcceptFrame(MainText, Function)
	if not AcceptFrame then
		AcceptFrame = CreateFrame("Frame", "AcceptFrame", UIParent)

		AcceptFrame:CreateBorder()

		AcceptFrame:SetPoint("CENTER", UIParent, "CENTER")
		AcceptFrame:SetFrameStrata("DIALOG")
		AcceptFrame.Text = AcceptFrame:CreateFontString(nil, "OVERLAY")
		AcceptFrame.Text:SetFont(C["Media"].Font, 14)
		AcceptFrame.Text:SetPoint("TOP", AcceptFrame, "TOP", 0, -10)
		AcceptFrame.Accept = CreateFrame("Button", nil, AcceptFrame, "OptionsButtonTemplate")
		AcceptFrame.Accept:SkinButton()
		AcceptFrame.Accept:SetSize(70, 24)
		AcceptFrame.Accept:SetPoint("RIGHT", AcceptFrame, "BOTTOM", -10, 20)
		AcceptFrame.Accept:SetFormattedText("|cFFFFFFFF%s|r", YES)
		AcceptFrame.Close = CreateFrame("Button", nil, AcceptFrame, "OptionsButtonTemplate")
		AcceptFrame.Close:SkinButton()
		AcceptFrame.Close:SetSize(70, 24)
		AcceptFrame.Close:SetPoint("LEFT", AcceptFrame, "BOTTOM", 10, 20)
		AcceptFrame.Close:SetScript("OnClick", function(self) self:GetParent():Hide() end)
		AcceptFrame.Close:SetFormattedText("|cFFFFFFFF%s|r", NO)
	end

	AcceptFrame.Text:SetText(MainText)
	AcceptFrame:SetSize(AcceptFrame.Text:GetStringWidth() + 100, AcceptFrame.Text:GetStringHeight() + 60)
	AcceptFrame.Accept:SetScript("OnClick", Function)
	AcceptFrame:Show()
end

function Module:SkinEditBox(frame)
	assert(frame, "doesnt exist! Tell Kkthnx!")

	if frame.Backdrop then
		return
	end

	local EditBoxName = frame.GetName and frame:GetName()
	for _, Region in pairs(Module.Blizzard_Regions) do
		if EditBoxName and _G[EditBoxName..Region] then
			_G[EditBoxName..Region]:SetAlpha(0)
		end

		if frame[Region] then
			frame[Region]:SetAlpha(0)
		end
	end

	frame:CreateBackdrop()
	frame.Backdrop:SetFrameLevel(frame:GetFrameLevel())

	if EditBoxName and (string_find(EditBoxName, "Silver") or string_find(EditBoxName, "Copper")) then
		frame.Backdrop:SetPoint("BOTTOMRIGHT", -12, -2)
	end
end

function Module:OnEnable()
	self:ReskinBigWigs()
	self:ReskinBugSack()
	self:ReskinDBM()
	self:ReskinDetails()
	self:ReskinSimulationcraft()
	self:ReskinSkada()
	self:ReskinSpy()
	self:ReskinImmersion()
	-- self:ReskinTitanPanel()
	self:ReskinWeakAuras()
	self:ReskinWorldQuestTab()
	self:ReskinBartender4()
end