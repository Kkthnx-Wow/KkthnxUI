local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = table.insert

local IsAddOnLoaded = _G.IsAddOnLoaded

local function SkinScriptErrors()
	FrameStackTooltip:HookScript("OnShow", function(self)
		if not self.isSkinned then
			self:StripTextures()

			self.Backgrounds = self:CreateTexture(nil, "BACKGROUND", -2)
			self.Backgrounds:SetAllPoints()
			self.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			K.CreateBorder(self)

			self.IsSkinned = true
		end
	end)

	EventTraceTooltip:HookScript("OnShow", function(self)
		if not self.isSkinned then
			self:StripTextures()

			self.Backgrounds = self:CreateTexture(nil, "BACKGROUND", -2)
			self.Backgrounds:SetAllPoints()
			self.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			K.CreateBorder(self)

			self.IsSkinned = true
		else
			self:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
			self.Backgrounds:SetBackdropColor(C["Media"].BackdropColor[1],C["Media"].BackdropColor[2],C["Media"].BackdropColor[3],C["Media"].BackdropColor[4])
		end
	end)

	if not EventTraceFrame.isSkinned then
		EventTraceFrame:StripTextures()

		EventTraceFrame.Backgrounds = EventTraceFrame:CreateTexture(nil, "BACKGROUND", -2)
		EventTraceFrame.Backgrounds:SetAllPoints()
		EventTraceFrame.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		K.CreateBorder(EventTraceFrame)

		EventTraceFrame.IsSkinned = true
	end
end

if IsAddOnLoaded("Blizzard_DebugTools") then
	table_insert(Module.SkinFuncs["KkthnxUI"], SkinScriptErrors)
else
	Module.SkinFuncs["Blizzard_DebugTools"] = SkinScriptErrors
end