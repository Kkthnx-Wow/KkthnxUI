local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

--[[ Element: Builder Spender
local FeedBackFrame = CreateFrame("Frame", nil, self.Power, "BuilderSpenderFrame")
FeedbackFrame:SetFrameLevel(self.Power:GetFrameLevel())
FeedbackFrame:SetAllPoints(self.Power)
FeedbackFrame:SetPoint("TOPLEFT", self.Power, "TOPLEFT", 0, -1)
self.Power.FeedBackFrame = FeedBackFrame

local FullPowerFrame = CreateFrame("Frame", nil, self.Power, "FullResourcePulseFrame")
FullPowerFrame:SetAllPoints(self.Power)
FullPowerFrame:SetPoint("TOPRIGHT")
self.Power.FullPowerFrame = FullPowerFrame
]]

local _, ns = ...
local oUF = ns.oUF or oUF

local function startFeedbackAnim(self, oldValue, newValue) --copied, only removed need for CVars
	if (not self.initialized) then
		return;
	end

	oldValue = Clamp(oldValue, 0, self.maxValue);
	newValue = math.max(newValue, 0);

	if ( newValue > oldValue ) then -- Gaining power
		self.updatingGain = true;
		self:SetScript("OnUpdate", BuilderSpender_OnUpdateFeedback);

		self.oldValue = oldValue;
		self.newValue = newValue;
		self.animGainStartTime = GetTime();
	elseif ( newValue < oldValue ) then -- Losing power
		local glowTexture = self.LossGlowTexture;
		local barTexture = self.BarTexture;
		local maxValue = self.maxValue;
		local leftPosition = newValue / maxValue * self:GetWidth();
		local width = (oldValue - newValue) / maxValue * self:GetWidth();
		local texMinX = newValue / maxValue;
		local texMaxX = oldValue / maxValue;

		local height = self:GetHeight();

		glowTexture:ClearAllPoints();
		glowTexture:SetPoint("TOPLEFT", leftPosition, 0);
		glowTexture:SetHeight(height);
		glowTexture:SetWidth(width);
		glowTexture:SetTexCoord(texMinX, texMaxX, 0, 1);
		glowTexture:Show();
		glowTexture:SetAlpha(0);

		barTexture:ClearAllPoints();
		barTexture:SetPoint("TOPLEFT", leftPosition, 0);
		barTexture:SetHeight(height);
		barTexture:SetWidth(width);
		barTexture:SetTexCoord(texMinX, texMaxX, 0, 1);
		barTexture:Show();
		barTexture:SetAlpha(1);

		self.updatingLoss = true;
		self:SetScript("OnUpdate", BuilderSpender_OnUpdateFeedback);
		self.animLossStartTime = GetTime();
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end
	local element = self.BuilderSpender

	if(element.PreUpdate) then element:PreUpdate(unit) end

	local currValue = UnitPower(self.unit, element.powerType)
	if ( currValue ~= element.currValue or event == "ForceUpdate" ) then
		if ( element.FeedbackFrame ) then
			-- Only show anim if change is more than 10%
			local oldValue = element.currValue or 0;
			if ( element.FeedbackFrame.maxValue ~= 0 and math.abs(currValue - oldValue) / element.FeedbackFrame.maxValue > 0.1 ) then
				startFeedbackAnim(element.FeedbackFrame, oldValue, currValue)
			end
		end
		if ( element.FullPowerFrame and element.FullPowerFrame.active ) then
			element.FullPowerFrame:StartAnimIfFull(element.currValue or 0, currValue);
		end
		element.currValue = currValue
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, min)
	end
end

local Path = function(self, ...)
	return (self.BuilderSpender.Override or Update)(self, ...)
end

local Visibility = function(self, event, unit)
	if (unit and unit ~= self.unit) then return false; end
	local element = self.BuilderSpender
	local powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
	local info = self.colors.power[powerToken]
	if (info) then
		if (element.FeedbackFrame) then
			element.FeedbackFrame:Initialize(info, self.unit, powerType)
			local atlas = self.Power.atlas or info.atlas
			if self.Power.useAtlas and atlas then
				element.FeedbackFrame.BarTexture:SetAtlas(atlas)
			else
				element.FeedbackFrame.BarTexture:SetVertexColor(self.Power:GetStatusBarColor()) --test pliz
				element.FeedbackFrame.BarTexture:SetTexture(self.Power.texture)
			end
		end
		if (element.FullPowerFrame) then
			element.FullPowerFrame:Initialize(info.fullPowerAnim)
			element.FullPowerFrame:SetMaxValue(UnitPowerMax(self.unit, powerType))
		end
	end

	if ( element.powerType ~= powerType or element.powerType ~= powerType ) then
		element.powerType = powerType;
		element.powerToken = powerToken;
		if ( element.FullPowerFrame ) then
			element.FullPowerFrame:RemoveAnims();
		end
		element.currValue = UnitPower(self.unit, powerType);
	end
end

local VisibilityPath = function(self, ...)
	return (self.BuilderSpender.OverrideVisibility or Visibility)(self, ...)
end

local ForceUpdate = function(element)
	return VisibilityPath(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self, unit)
	local element = self.BuilderSpender
	if(unit == "player" and element) then

		local feedback = element.FeedbackFrame
		local fullpower = element.FullPowerFrame

		if feedback or fullpower then
			element.__owner = self
			element.ForceUpdate = ForceUpdate

			--Update
			self:RegisterEvent("UNIT_POWER_FREQUENT", Path)

			--Initialize
			self:RegisterEvent("UNIT_DISPLAYPOWER", VisibilityPath)
			self:RegisterEvent("PLAYER_ALIVE", VisibilityPath, true)
			self:RegisterEvent("PLAYER_DEAD", VisibilityPath, true)
			self:RegisterEvent("PLAYER_UNGHOST", VisibilityPath, true)
			self:RegisterEvent("UNIT_MAXPOWER", VisibilityPath)

			return true
		end
	end
end

local Disable = function(self)
	local element = self.BuilderSpender
	if(element) then
		--Update
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)

		--Initialize
		self:UnregisterEvent("UNIT_DISPLAYPOWER", VisibilityPath)
		self:UnregisterEvent("PLAYER_ALIVE", VisibilityPath)
		self:UnregisterEvent("PLAYER_DEAD", VisibilityPath)
		self:UnregisterEvent("PLAYER_UNGHOST", VisibilityPath)
		self:UnregisterEvent("UNIT_MAXPOWER", VisibilityPath)
	end
end

oUF:AddElement("BuilderSpender", VisibilityPath, Enable, Disable)