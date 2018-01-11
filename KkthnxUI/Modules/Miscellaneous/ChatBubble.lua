local K, C, L = unpack(select(2, ...))
local ChatBubbles = K:NewModule("ChatBubbles", "AceEvent-3.0", "AceTimer-3.0")

-- Lua Wow
local select, unpack, type = select, unpack, type
local strlower, find, format = strlower, string.find, string.format

-- WoW API
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local WorldFrame = _G.WorldFrame

function ChatBubbles:UpdateBubbleBorder()
	if not self.text then return end

	if (C["Chat"].BubbleBackdrop.Value == "Backdrop") then
		if not self.backdrop then
			self:SetBackdropBorderColor(self.text:GetTextColor())
		else
			local r, g, b = self.text:GetTextColor()
			self:SetBackdropBorderColor(r, g, b)
		end
	end
end

function ChatBubbles:SkinBubble(frame)
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

	frame:HookScript("OnShow", ChatBubbles.UpdateBubbleBorder)
	frame:SetFrameStrata("DIALOG") -- Doesn't work currently in Legion due to a bug on Blizzards end
	ChatBubbles.UpdateBubbleBorder(frame)
	frame.isBubblePowered = true
end

function ChatBubbles:IsChatBubble(frame)
	if not frame:IsForbidden() then
		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())

			if region.GetTexture and region:GetTexture() and type(region:GetTexture() == "string") then
				if find(strlower(region:GetTexture()), "chatbubble%-background") then
					return true
				end
			end
		end
	end
	return false
end

local numChildren = 0
function ChatBubbles:OnEnable()

	local frame = CreateFrame("Frame")
	frame.lastupdate = -2 -- wait 2 seconds before hooking frames

	if C["Chat"].BubbleBackdrop.Value == "Disabled" then return end

	frame:SetScript("OnUpdate", function(self, elapsed)
		self.lastupdate = self.lastupdate + elapsed
		if (self.lastupdate < .1) then return end
		self.lastupdate = 0

		local count = WorldFrame:GetNumChildren()
		if(count ~= numChildren) then
			for i = numChildren + 1, count do
				local frame = select(i, WorldFrame:GetChildren())

				if ChatBubbles:IsChatBubble(frame) then
					ChatBubbles:SkinBubble(frame)
				end
			end
			numChildren = count
		end
	end)
end