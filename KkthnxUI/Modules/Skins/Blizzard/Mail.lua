local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local unpack = _G.unpack
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

local function ReskinMailAttachment()
	for i = 1, _G.ATTACHMENTS_MAX_SEND do
		local btn = _G["SendMailAttachment"..i]
		if not btn.skinned then
			btn:CreateBorder(nil, nil, nil, true)
			btn:StyleButton()
			btn.skinned = true

			hooksecurefunc(btn.IconBorder, "SetVertexColor", function(self, r, g, b)
				self:GetParent():SetBackdropBorderColor(r, g, b)
				self:SetTexture()
			end)

			hooksecurefunc(btn.IconBorder, "Hide", function(self)
				self:GetParent():SetBackdropBorderColor()
			end)
		end

		local t = btn:GetNormalTexture()
		if t then
			t:SetTexCoord(unpack(K.TexCoords))
			t:SetAllPoints()
		end
	end
end

local function ReskinMailFrame()
	for i = 1, _G.INBOXITEMS_TO_DISPLAY do
		local btn = _G["MailItem"..i.."Button"]
		btn:CreateBorder(nil, nil, nil, true)
		btn:StyleButton()

		local t = _G["MailItem"..i.."ButtonIcon"]
		t:SetTexCoord(unpack(K.TexCoords))
		t:SetAllPoints()

		local ib = _G["MailItem"..i.."ButtonIconBorder"]
		hooksecurefunc(ib, "SetVertexColor", function(s, r, g, b)
			s:GetParent():SetBackdropBorderColor(r, g, b)
			s:SetTexture()
		end)

		hooksecurefunc(ib, "Hide", function(s)
			s:GetParent():SetBackdropBorderColor()
		end)
	end

	hooksecurefunc("SendMailFrame_Update", ReskinMailAttachment)

	for i = 1, _G.ATTACHMENTS_MAX_SEND do
		local btn = _G["OpenMailAttachmentButton"..i]
		btn:CreateBorder(nil, nil, nil, true)
		btn:StyleButton()

		hooksecurefunc(btn.IconBorder, "SetVertexColor", function(s, r, g, b)
			s:GetParent():SetBackdropBorderColor(r, g, b)
			s:SetTexture()
		end)

		hooksecurefunc(btn.IconBorder, "Hide", function(s)
			s:GetParent():SetBackdropBorderColor()
		end)

		local t = _G["OpenMailAttachmentButton"..i.."IconTexture"]
		if t then
			t:SetTexCoord(unpack(K.TexCoords))
			t:SetAllPoints()
		end
	end
end

table_insert(Module.NewSkin["KkthnxUI"], ReskinMailFrame)