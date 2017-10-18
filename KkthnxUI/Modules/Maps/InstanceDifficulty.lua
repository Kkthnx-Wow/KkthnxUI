local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("InstanceDifficulty", "AceHook-3.0", "AceEvent-3.0")
local sub = string.utf8sub
local _G = _G

local DifficultyColor = {
	["lfr"] = {r = 0.32,g = 0.91,b = 0.25},
	["normal"] = {r = 0.09,g = 0.51,b = 0.82},
	["heroic"] = {r = 0.82,g = 0.42,b = 0.16},
	["challenge"] = {r = 0.9,g = 0.89,b = 0.27},
	["mythic"] = {r = 0.9, g = 0.14,b = 0.15},
	["time"] = {r = 0.41, g = 0.80,b = 0.94}
}

local Difficulties = {
	[1] = "normal", --5ppl normal
	[2] = "heroic", --5ppl heroic
	[3] = "normal", --10ppl raid
	[4] = "normal", --25ppl raid
	[5] = "heroic", --10ppl heroic raid
	[6] = "heroic", --25ppl heroic raid
	[7] = "lfr", --25ppl LFR
	[8] = "challenge", --5ppl challenge
	[9] = "normal", --40ppl raid
	[11] = "heroic", --Heroic scenario
	[12] = "normal", --Normal scenario
	[14] = "normal", --10-30ppl normal
	[15] = "heroic", --13-30ppl heroic
	[16] = "mythic", --20ppl mythic
	[17] = "lfr", --10-30 LFR
	[23] = "mythic", --5ppl mythic
	[24] = "time", --Timewalking
}

function Module:CreateText()
	Module.frame = CreateFrame("Frame", "MiniMapDifFrame", _G["Minimap"])
	Module.frame:SetSize(50, 20)
	-- Module.frame:SetTemplate()
	Module.frame.text = Module.frame:CreateFontString(nil, "OVERLAY")
	Module.frame.text:SetPoint("LEFT", Module.frame, "LEFT")
	Module.frame.icon = Module.frame:CreateFontString(nil, "OVERLAY")
	Module.frame.icon:SetPoint("LEFT", Module.frame.text, "RIGHT", 4, 0)
	self:SetFonts()
end

function Module:SetFonts()
	Module.frame.text:SetFont(C["Media"].Font, 13, "")
	Module.frame.text:SetShadowOffset(1.25, -1.25)
	Module.frame.icon:SetFont(C["Media"].Font, 13, "")
	Module.frame.icon:SetShadowOffset(1.25, -1.25)
end

function Module:InstanceCheck()
	local isInstance, InstanseType = IsInInstance()
	local s = false
	if isInstance and InstanseType ~= "pvp" then
		if InstanseType ~= "arena" then
			s = true
		end
	end

	return s
end

function Module:GuildEmblem()
	-- table
	local char = {}
	-- check if Blizzard_GuildUI is loaded
	if _G["GuildFrameTabardEmblem"] then
		char.guildTexCoord = {_G["GuildFrameTabardEmblem"]:GetTexCoord()}
	else
		char.guildTexCoord = false
	end
	if IsInGuild() and char.guildTexCoord then
		return "|TInterface\\GuildFrame\\GuildEmblemsLG_01:24:24:-4:1:32:32:"..(char.guildTexCoord[1] * 32)..":"..(char.guildTexCoord[7] * 32)..":"..(char.guildTexCoord[2] * 32)..":"..(char.guildTexCoord[8] * 32).."|t"
	else
		return ""
	end
end

function Module:UpdateFrame()
	if IsInInstance() then
		if _G["MiniMapInstanceDifficulty"]:IsShown() then
			_G["MiniMapInstanceDifficulty"]:Hide()
		elseif not _G["MiniMapInstanceDifficulty"]:IsShown() then
			_G["MiniMapInstanceDifficulty"]:Show()
		end
	end
	Module.frame:SetPoint("TOPLEFT", _G["Minimap"], "TOPLEFT", 4, 0)
	Module:SetFonts()
	Module.frame.text:Show()
	Module.frame.icon:Show()
end

function Module:GetColor(dif)
	if dif and Difficulties[dif] then
		local color = DifficultyColor[Difficulties[dif]]
		return color.r * 255, color.g * 255, color.b * 255
	else
		return 255, 255, 255
	end
end

function Module:GenerateText(event, guild, force)
	local text
	if not Module:InstanceCheck() then
		Module.frame.text:SetText("")
		Module.frame.icon:SetText("")
	else
		local _, _, difficulty, difficultyName, _, _, _, _, instanceGroupSize = GetInstanceInfo()
		local r, g, b = Module:GetColor(difficulty)
		if (difficulty >= 3 and difficulty <= 7) or difficulty == 9 or C["Minimap"].InstanceOnlyNumber then
			text = format("|cff%02x%02x%02x%s|r", r, g, b, instanceGroupSize)
		else
			difficultyName = sub(difficultyName, 1 , 1)
			text = format(instanceGroupSize.." |cff%02x%02x%02x%s|r", r, g, b, difficultyName)
		end
		Module.frame.text:SetText(text)
		if guild or force then
			local logo = Module:GuildEmblem()
			Module.frame.icon:SetText(logo)
		end
	end
end

function Module:OnInitialize()
	if not C["Minimap"].Enable then return end
	Module.flag = nil
	self:CreateText()
	_G["MiniMapInstanceDifficulty"]:HookScript("OnShow", function(self) if C["Minimap"].Enable then self:Hide() end end)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "GenerateText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "GenerateText")
	self:RegisterEvent("GUILD_PARTY_STATE_UPDATED", "GenerateText")
	self:UpdateFrame()
	hooksecurefunc("MiniMapInstanceDifficulty_Update", Module.GenerateText)

	function Module:ForUpdateAll()
		Module:UpdateFrame()
	end
end