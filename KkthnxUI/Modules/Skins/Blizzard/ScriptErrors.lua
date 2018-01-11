local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("ScriptErrors", "AceHook-3.0")

local _G = _G

local UIParent = UIParent
local IsAddOnLoaded = IsAddOnLoaded
local LoadAddOn = LoadAddOn

function Module:OnInitialize()
	local ScriptErrorsFrame = _G["ScriptErrorsFrame"]
	ScriptErrorsFrame:SetParent(UIParent)
	ScriptErrorsFrame:SetTemplate("Transparent")
	ScriptErrorsFrame.ScrollFrame.Text:FontTemplate(nil, 13)
	ScriptErrorsFrame.ScrollFrame:CreateBackdrop("Default")
	ScriptErrorsFrame.ScrollFrame:SetFrameLevel(ScriptErrorsFrame.ScrollFrame:GetFrameLevel() + 2)
	EventTraceFrame:SetTemplate("Transparent")

	local texs = {
		"TopLeft",
		"TopRight",
		"Top",
		"BottomLeft",
		"BottomRight",
		"Bottom",
		"Left",
		"Right",
		"TitleBG",
		"DialogBG",
	}

	for i = 1, #texs do
		_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end

	FrameStackTooltip:HookScript("OnShow", function(self)
		if not self.template then
			self:SetTemplate("Transparent")
		end
	end)

	EventTraceTooltip:HookScript("OnShow", function(self)
		if not self.template then
			self:SetTemplate("Transparent")
		end
	end)
end