local K, C, L = unpack(select(2, ...))
local SE = K:NewModule("ScriptErrors", "AceHook-3.0")

-- Lua API
local _G = _G

-- Wow API
local UIParent = _G.UIParent
local IsAddOnLoaded = _G.IsAddOnLoaded
local LoadAddOn = _G.LoadAddOn

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: EventTraceTooltip, ScriptErrorsFrame, ScriptErrorsFrameScrollFrameText, EventTraceFrame, FrameStackTooltip

function SE:OnEnable()
	--if enable ~= true or debug ~= true then return end
	local noscalemult = K.Mult * GetCVar('uiScale')

	ScriptErrorsFrame:SetParent(UIParent)
	ScriptErrorsFrame:SetTemplate('Transparent')
	if K.WoWBuild >= 24015 then
		ScriptErrorsFrame.ScrollFrame.Text:FontTemplate(nil, 13)
		ScriptErrorsFrame.ScrollFrame:CreateBackdrop('Default')
		ScriptErrorsFrame.ScrollFrame:SetFrameLevel(ScriptErrorsFrame.ScrollFrame:GetFrameLevel() + 2)
	end
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

	for i=1, #texs do
		_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end

	FrameStackTooltip:HookScript("OnShow", function(self)
		local noscalemult = K.Mult * GetCVar('uiScale')
		self:SetTemplate("Transparent")
	end)

	EventTraceTooltip:HookScript("OnShow", function(self)
		self:SetTemplate("Transparent")
	end)
end
