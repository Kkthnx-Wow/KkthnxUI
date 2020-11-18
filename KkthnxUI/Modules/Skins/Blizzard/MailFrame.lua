
local K, C, L = unpack(ns)

tinsert(C.defaultThemes, function()
	local texL, texR, texT, texB = unpack(K.TexCoords)

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local item = _G["MailItem"..i]
		local button = _G["MailItem"..i.."Button"]
		item:StripTextures(3)
		button:StripTextures()
		button.Icon:SetTexCoord(texL, texR, texT, texB)
		button.IconBorder:SetAlpha(0)
		button:CreateBorder()
		button:StyleButton()
	end

	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["SendMailAttachment"..i]
		button:StripTextures()
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button.bg = button:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
		button:StyleButton()
	end

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = SendMailFrame.SendMailAttachments[i]
			if HasSendMailItem(i) then
				button:GetNormalTexture():SetTexCoord(texL, texR, texT, texB)
			end
		end
	end)

	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local button = _G["OpenMailAttachmentButton"..i]
		button:StripTextures()
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button.icon:SetTexCoord(texL, texR, texT, texB)
		button.bg = button:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
		button:StyleButton()
	end
end)