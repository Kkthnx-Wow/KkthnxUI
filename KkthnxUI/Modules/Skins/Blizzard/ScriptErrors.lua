local K, C = unpack(select(2, ...))

local _G = _G

local UIParent = UIParent
local IsAddOnLoaded = IsAddOnLoaded
local LoadAddOn = LoadAddOn

local function LoadSkin()
	local ScriptErrorsFrame = _G["ScriptErrorsFrame"]
	ScriptErrorsFrame:SetParent(UIParent)
	ScriptErrorsFrame:SetTemplate("Transparent")
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
			self:SetTemplate("Transparent", true)
		end
	end)

	EventTraceTooltip:HookScript("OnShow", function(self)
		if not self.template then
			self:SetTemplate("Transparent", true) -- ignore updates
		else
			self:SetBackdropBorderColor( C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
			self:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
		end
	end)


	EventTraceFrameCloseButton:SkinCloseButton()
end

tinsert(K.SkinFuncs["KkthnxUI"], LoadSkin)