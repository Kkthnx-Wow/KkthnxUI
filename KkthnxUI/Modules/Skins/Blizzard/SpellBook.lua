local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local table_insert = table.insert

local function LoadSpellBookSkin()
	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G["SpellButton" .. i]
		local slot = _G["SpellButton" .. i .. "SlotFrame"]
		local icon = _G["SpellButton" .. i .. "IconTexture"]

		K.CreateBorder(button)
		button.EmptySlot:SetTexture("")
		button.UnlearnedFrame:SetTexture("")
		button.SpellHighlightTexture:SetInside(button, -6, -6) -- not on action bar
		slot:SetTexture("") -- swirly thing
		icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)

		button:HookScript("OnDisable", function(self)
			self:SetAlpha(0)
		end)

		button:HookScript("OnEnable", function(self)
			self:SetAlpha(1)
		end)
	end
end

table_insert(Module.SkinFuncs["KkthnxUI"], LoadSpellBookSkin)