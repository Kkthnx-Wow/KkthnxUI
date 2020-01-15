local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local pairs = _G.pairs
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local GetActionInfo = _G.GetActionInfo
local GetContainerItemID = _G.GetContainerItemID
local GetInventoryItemID = _G.GetInventoryItemID
local GetItemCooldown = _G.GetItemCooldown
local GetItemInfo = _G.GetItemInfo
local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellTexture = _G.GetSpellTexture
local GetTime = _G.GetTime
local hooksecurefunc = _G.hooksecurefunc

local PulseCooldown = CreateFrame("Frame")
local ActiveCount = 0
local MinTreshold = C["PulseCooldown"].MinTreshold
local Running = false
local CurrentTime
local GetCD
local Spells = {}
local Elapsed = 0
local Delay = 0.5

local ActiveCDs = {
	["item"] = {},
	["player"] = {},
}

local Blacklist = {
	["item"] = {
		[110560] = true, -- Garrison Hearthstone
		[140192] = true, -- Dalaran Hearthstone
		[6948] = true, -- Hearthstone
	},

	["player"] = {
		[125439] = true, -- Revive Battle Pets
	},
}

local TextureFilter = {
	[136235] = true
}

local function GetTexture(cd, id)
	local Texture

	if (cd == "item") then
		Texture = select(10, GetItemInfo(id))
	else
		Texture = GetSpellTexture(id)
	end

	if (not TextureFilter[Texture]) then
		return Texture
	end
end

local Frame = CreateFrame("Frame", nil, UIParent)
Frame:SetSize(C["PulseCooldown"].Size, C["PulseCooldown"].Size)
Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 260)
Frame:CreateBorder()
Frame:CreateInnerShadow()
Frame:SetAlpha(0)

Frame.Icon = Frame:CreateTexture(nil, "OVERLAY")
Frame.Icon:SetAllPoints()
Frame.Icon:SetTexCoord(unpack(K.TexCoords))

Frame.Anim = CreateAnimationGroup(Frame)

Frame.AnimIn = Frame.Anim:CreateAnimation("Fade")
Frame.AnimIn:SetChange(1)
Frame.AnimIn:SetDuration(0.2)
Frame.AnimIn:SetEasing("in")

Frame.AnimOut = Frame.Anim:CreateAnimation("Fade")
Frame.AnimOut:SetChange(0)
Frame.AnimOut:SetDuration(0.6)
Frame.AnimOut:SetEasing("out")

Frame.Sleep = Frame.Anim:CreateAnimation("Sleep")
Frame.Sleep:SetDuration(C["PulseCooldown"].HoldTime)
Frame.Sleep:SetScript("OnFinished", function()
	Frame.AnimOut:Play()
end)

local function PlayAnimation()
	Frame.AnimIn:Play()

	Frame.Sleep:Play()
end

local function OnUpdate(self, ela)
	Elapsed = Elapsed + ela

	if (Elapsed < Delay) then
		return
	end

	CurrentTime = GetTime()

	for CDType, Data in pairs(ActiveCDs) do
		GetCD = (CDType == "item") and GetItemCooldown or GetSpellCooldown

		for Position, ID in pairs(Data) do
			local Start, Duration = GetCD(ID)

			if (Start ~= nil) then
				local Remaining = Start + Duration - CurrentTime

				if (Remaining <= 0) then
					local Texture = GetTexture(CDType, ID)

					if Texture then
						Frame.Icon:SetTexture(Texture)
						PlayAnimation()
					end
					if C["PulseCooldown"].Sound then
						PlaySound(18192, "master") -- https://www.wowhead.com/sound=18192/fx-sonarping
					end
					table_remove(Data, Position)
					ActiveCount = ActiveCount - 1
				end
			end
		end
	end

	if (ActiveCount <= 0) then
		self:SetScript("OnUpdate", nil)
		Running = false
	end

	Elapsed = 0
end

-- UNIT_SPELLCAST_SUCCEEDED fetches casts, and then SPELL_UPDATE_COOLDOWN checks them after the GCD is done (Otherwise GetSpellCooldown detects GCD)
function Module:SPELL_UPDATE_COOLDOWN()
	for i = #Spells, 1, -1 do
		local _, Duration = GetSpellCooldown(Spells[i])

		if (Duration >= MinTreshold) then
			table_insert(ActiveCDs.player, Spells[i])
			ActiveCount = ActiveCount + 1

			if (ActiveCount > 0 and not Running) then
				PulseCooldown:SetScript("OnUpdate", OnUpdate)
				Running = true
			end
		end

		table_remove(Spells, i)
	end
end

function Module:UNIT_SPELLCAST_SUCCEEDED(unit, _, id)
	if (unit == "player") then
		if Blacklist["player"][id] then
			return
		end

		table_insert(Spells, id)
	end
end

local function StartItem(id)
	if Blacklist["item"][id] then
		return
	end

	local _, Duration = GetItemCooldown(id)
	if (Duration and Duration > MinTreshold) then
		table_insert(ActiveCDs.item, id)
		ActiveCount = ActiveCount + 1

		if (ActiveCount > 0 and not Running) then
			PulseCooldown:SetScript("OnUpdate", OnUpdate)
			Running = true
		end
	end
end

local function UseAction(slot)
	local ActionType, ItemID = GetActionInfo(slot)

	if (ActionType == "item") then
		StartItem(ItemID)
	end
end

local function UseInventoryItem(slot)
	local ItemID = GetInventoryItemID("player", slot)

	if ItemID then
		StartItem(ItemID)
	end
end

local function UseContainerItem(bag, slot)
	local ItemID = GetContainerItemID(bag, slot)

	if ItemID then
		StartItem(ItemID)
	end
end

function Module:CreatePulseCooldown()
	if C["PulseCooldown"].Enable ~= true then
		return
	end

	local Anchor = CreateFrame("Frame", "KKUIPulseCooldown", UIParent)
	Anchor:SetSize(C["PulseCooldown"].Size, C["PulseCooldown"].Size)
	Anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 260)

	Frame:SetSize(C["PulseCooldown"].Size, C["PulseCooldown"].Size)
	Frame:SetAllPoints(Anchor)

	K.Mover(Anchor, "PulseCooldown", "PulseCooldown", {"CENTER", UIParent, "CENTER", 0, 260}, C["PulseCooldown"].Size, C["PulseCooldown"].Size)

	K:RegisterEvent("SPELL_UPDATE_COOLDOWN", Module.SPELL_UPDATE_COOLDOWN)
	K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UNIT_SPELLCAST_SUCCEEDED)

	hooksecurefunc("UseAction", UseAction)
	hooksecurefunc("UseInventoryItem", UseInventoryItem)
	hooksecurefunc("UseContainerItem", UseContainerItem)
end