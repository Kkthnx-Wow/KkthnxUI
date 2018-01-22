local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("ChatBubbles", "AceTimer-3.0")

function Module:UpdateBubbleBorder()
    if not self.text then return end

    local r, g, b = self.text:GetTextColor()
    self:SetBackdropBorderColor(r, g, b, 1)
end

function Module:SkinBubble(frame)
    local mult = K.Mult * UIParent:GetScale()
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region:GetObjectType() == "Texture" then
            region:SetTexture(nil)
        elseif region:GetObjectType() == "FontString" then
            frame.text = region
        end
    end

    if (C["Chat"].BubbleBackdrop.Value == "Backdrop") then
		if not frame.backdrop then
			frame:SetBackdrop({bgFile = C["Media"].Blank, tileSize = 12, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, edgeSize = 12, insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}})
			frame:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
			frame:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
		else
			frame:SetBackdrop(nil)
		end

		local r, g, b = frame.text:GetTextColor()
		frame.text:SetFont(C["Media"].Font, C["Media"].FontSize)
	elseif C["Chat"].BubbleBackdrop.Value == "NoBackdrop" then
		frame:SetBackdrop(nil)
		frame.text:SetFont(C["Media"].Font, C["Media"].FontSize)
		frame.text:SetShadowOffset(1.25, 1.25)
		frame:SetClampedToScreen(false)
	end
    frame:SetClampedToScreen(false)
    frame:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
    frame:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
    Module.UpdateBubbleBorder(frame)
    frame:HookScript("OnShow", Module.UpdateBubbleBorder)
    frame.isSkinned = true
end

local function ChatBubble_OnUpdate(self, elapsed)
	if not Module.lastupdate then
		Module.lastupdate = -2 -- wait 2 seconds before hooking frames
	end
	Module.lastupdate = Module.lastupdate + elapsed
	if (Module.lastupdate < .1) then return end
	Module.lastupdate = 0
	for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
		if not chatBubble.isSkinned then
			Module:SkinBubble(chatBubble)
		end
	end
end

function Module:OnInitialize()
    local frame = CreateFrame("Frame")

    frame:SetScript("OnUpdate", ChatBubble_OnUpdate)
end