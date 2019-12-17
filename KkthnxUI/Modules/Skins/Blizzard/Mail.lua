local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local unpack = _G.unpack
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc
local GetInboxItemLink = _G.GetInboxItemLink
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetInboxNumItems = _G.GetInboxNumItems
local GetInboxHeaderInfo = _G.GetInboxHeaderInfo
local GetSendMailItem = _G.GetSendMailItem

local function ReskinMailFrame()
	for i = 1, _G.INBOXITEMS_TO_DISPLAY do
		local button = _G["MailItem"..i.."Button"]
		local icon = _G["MailItem"..i.."ButtonIcon"]

		button:CreateBorder(nil, nil, nil, true)
		button:StyleButton()

		icon:SetTexCoord(unpack(K.TexCoords))
		icon:SetAllPoints(button)
	end

	hooksecurefunc("InboxFrame_Update", function()
		local numItems = GetInboxNumItems()
		local index = ((_G.InboxFrame.pageNum - 1) * _G.INBOXITEMS_TO_DISPLAY) + 1

		for i = 1, _G.INBOXITEMS_TO_DISPLAY do
			local mail = _G["MailItem"..i.."Button"]
			if index <= numItems then
				local packageIcon, _, _, _, _, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(index)

				if packageIcon and not isGM then
					local ItemLink = GetInboxItemLink(index, 1)

					if ItemLink then
						local quality = select(3, GetItemInfo(ItemLink))

						if quality and quality > 1 then
							mail:SetBackdropBorderColor(GetItemQualityColor(quality))
						else
							mail:SetBackdropBorderColor()
						end
					end
				elseif isGM then
					mail:SetBackdropBorderColor(0, 0.56, 0.94)
				else
					mail:SetBackdropBorderColor()
				end
			else
				mail:SetBackdropBorderColor()
			end

			index = index + 1
		end
	end)

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, _G.ATTACHMENTS_MAX_SEND do
			local button = _G["SendMailAttachment"..i]
			local icon = button:GetNormalTexture()
			local name = GetSendMailItem(i)

			if not button.skinned then
				button:CreateBorder(nil, nil, nil, true)
				button:StyleButton(nil, true)

				button.skinned = true
			end

			if name then
				local quality = select(3, GetItemInfo(name))

				if quality and quality > 1 then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor()
				end

				icon:SetTexCoord(unpack(K.TexCoords))
				icon:SetInside()
			else
				button:SetBackdropBorderColor()
			end
		end
	end)

	for i = 1, _G.ATTACHMENTS_MAX_SEND do
		local button = _G["OpenMailAttachmentButton"..i]
		local icon = _G["OpenMailAttachmentButton"..i.."IconTexture"]
		local count = _G["OpenMailAttachmentButton"..i.."Count"]

		button:CreateBorder(nil, nil, nil, true)
		button:StyleButton()

		if icon then
			icon:SetTexCoord(unpack(K.TexCoords))
			icon:SetDrawLayer("ARTWORK")
			icon:SetAllPoints()

			count:SetDrawLayer("OVERLAY")
		end
	end

	hooksecurefunc("OpenMailFrame_UpdateButtonPositions", function()
		for i = 1, _G.ATTACHMENTS_MAX_RECEIVE do
			local ItemLink = GetInboxItemLink(_G.InboxFrame.openMailID, i)
			local button = _G["OpenMailAttachmentButton"..i]

			if ItemLink then
				local quality = select(3, GetItemInfo(ItemLink))

				if quality and quality > 1 then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor()
				end
			else
				button:SetBackdropBorderColor()
			end
		end
	end)
end

table_insert(Module.NewSkin["KkthnxUI"], ReskinMailFrame)