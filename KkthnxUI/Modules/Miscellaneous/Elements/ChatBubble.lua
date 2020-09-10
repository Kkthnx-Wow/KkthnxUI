local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local table_wipe = _G.table.wipe

local Ambiguate = _G.Ambiguate
local C_ChatBubbles_GetAllChatBubbles = _G.C_ChatBubbles.GetAllChatBubbles
local CreateFrame = _G.CreateFrame
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local GetInstanceInfo = _G.GetInstanceInfo

-- Message caches
local messageToSender = {}

local function AddChatBubbleName(chatBubble, name)
	if not name then
		return
	end

    chatBubble.Name:SetFormattedText("|c%s%s|r", RAID_CLASS_COLORS.PRIEST.colorStr, name)
end

local function UpdateBubbleBorder(self)
	if not self.text then
		return
	end

	self.KKUI_Border:SetVertexColor(self.text:GetTextColor())

    local name = self.Name and self.Name:GetText()
	if name then
		self.Name:SetText()
	end

    local text = self.text:GetText()
    if text  then
        AddChatBubbleName(self, messageToSender[text])
    end
end

local function SkinBubble(frame)
	if frame:IsForbidden() then
		return
	end

    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region:IsObjectType("Texture") then
            region:SetTexture()
		elseif region:IsObjectType("FontString") then
			region:FontTemplate(nil, 12 * 0.85, "")
			region:SetShadowOffset(K.Mult or 1, -K.Mult or 1 / 2)
            frame.text = region
        end
    end

	local name = frame:CreateFontString(nil, "BORDER")
	name:SetHeight(10)
    name:SetPoint("TOPLEFT", 5, 10)
	name:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -8, 4)
	name:FontTemplate(nil, 12 * 0.85, "")
	name:SetShadowOffset(K.Mult or 1, -K.Mult or 1 / 2)
    name:SetJustifyH("LEFT")
	frame.Name = name

    frame:CreateBorder(nil, nil, 10)

    frame:HookScript("OnShow", UpdateBubbleBorder)
    frame:SetFrameStrata("DIALOG") -- Doesn't work currently in Legion due to a bug on Blizzards end
    UpdateBubbleBorder(frame)

    frame.isSkinned = true
end

local function ChatBubble_OnEvent(_, _, msg, sender)
    messageToSender[msg] = Ambiguate(sender, "none")
end

local function ChatBubble_OnUpdate(self, elapsed)
	if not self then
		return
	end

    if not self.lastupdate then
        self.lastupdate = -2 -- wait 2 seconds before hooking frames
    end

    self.lastupdate = self.lastupdate + elapsed
	if self.lastupdate < 0.1 then
		return
	end
    self.lastupdate = 0

    for _, chatBubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
        if not chatBubble.isSkinned then
            SkinBubble(chatBubble)
        end
    end
end

local function ToggleChatBubbleScript()
    local _, instanceType = GetInstanceInfo()
    if instanceType == "none" then
        Module.BubbleFrame:SetScript("OnEvent", ChatBubble_OnEvent)
        Module.BubbleFrame:SetScript("OnUpdate", ChatBubble_OnUpdate)
    else
        Module.BubbleFrame:SetScript("OnEvent", nil)
        Module.BubbleFrame:SetScript("OnUpdate", nil)

        -- Clear caches
        table_wipe(messageToSender)
    end
end

function Module:CreateChatBubbles()
    if not C["Skins"].ChatBubbles then
        return
    end

    K:RegisterEvent("PLAYER_ENTERING_WORLD", ToggleChatBubbleScript)

    Module.BubbleFrame = CreateFrame("Frame")
    Module.BubbleFrame:RegisterEvent("CHAT_MSG_SAY")
    Module.BubbleFrame:RegisterEvent("CHAT_MSG_YELL")
    Module.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    Module.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end