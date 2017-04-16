local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true and C.Raidframe.Enable ~= true then return end

-- Lua API
local _G = _G
local string_format = string.format
local table_insert = table.insert

-- Wow API
local CreateFrame = _G.CreateFrame
local DEAD = _G.DEAD
local GetSpellInfo = _G.GetSpellInfo
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPlayer = _G.UnitIsPlayer
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitSelectionColor = _G.UnitSelectionColor

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UnitFrame_OnLeave, UnitFrame_OnEnter

local _, ns = ...
local oUF = ns.oUF or oUF
local colors = K.Colors

function K.MatchUnit(unit)
  if (unit and unit:match("vehicle")) then
    return "player"
  elseif (unit and unit:match("party%d")) then
    return "party"
  elseif (unit and unit:match("arena%d")) then
    return "arena"
  elseif (unit and unit:match("boss%d")) then
    return "boss"
  elseif (unit and unit:match("partypet%d")) then
    return "pet"
  else
    return unit
  end
end

function K.MultiCheck(check, ...)
  for i = 1, select("#", ...) do
    if (check == select(i, ...)) then
      return true
    end
  end
  return false
end

local function UpdatePortraitColor(self, unit, min, max)
  if (not UnitIsConnected(unit)) then
    self.Portrait:SetVertexColor(0.5, 0.5, 0.5, 0.7)
  elseif (UnitIsDead(unit)) then
    self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 0.7)
  elseif (UnitIsGhost(unit)) then
    self.Portrait:SetVertexColor(0.3, 0.3, 0.9, 0.7)
  elseif (max == 0 or min/max * 100 < 25) then
    if (UnitIsPlayer(unit)) then
      if (unit ~= "player") then
        self.Portrait:SetVertexColor(1, 0, 0, 0.7)
      end
    end
  else
    self.Portrait:SetVertexColor(1, 1, 1, 1)
  end
end

local TEXT_PERCENT, TEXT_SHORT, TEXT_LONG, TEXT_MINMAX, TEXT_MAX, TEXT_DEF, TEXT_NONE = 0, 1, 2, 3, 4, 5, 6
local function SetValueText(self, tag, cur, max)
  -- not sure why this happens
  if (not max or max == 0) then
    max = 100
  end

  if (tag == TEXT_PERCENT) and (max < 200) then
    tag = TEXT_SHORT -- Shows energy etc. with real number
  end

  local string
  local percent = cur / max * 100

  if tag == TEXT_SHORT then
    string = string_format("%s", cur > 0 and K.ShortValue(cur) or "")
  elseif tag == TEXT_LONG then
    -- string = string_format("%s - %.1f%%", K.ShortValue(cur), cur / max * 100)
    if (percent > 99.95) then
      string = string_format('%s - 100%%', K.ShortValue(cur))
    else
      string = string_format('%s - %.1f%%', K.ShortValue(cur), percent)
    end
  elseif tag == TEXT_MINMAX then
    string = string_format("%s/%s", K.ShortValue(cur), K.ShortValue(max))
  elseif tag == TEXT_MAX then
    string = string_format("%s", K.ShortValue(max))
  elseif tag == TEXT_DEF then
    string = string_format("%s", (cur == max and "" or "-"..K.ShortValue(max - cur)))
  elseif tag == TEXT_PERCENT then
    string = string_format("%d%%", cur / max * 100)
  else
    string = ""
  end

  self:SetFormattedText("|cff%02x%02x%02x%s|r", K.Colors.white[1] * 255, K.Colors.white[2] * 255, K.Colors.white[3] * 255, string)
end

-- PostUpdateHealth
do
  local GHOST = GetSpellInfo(8326)
  if GetLocale() == "deDE" then
    GHOST = "Geist"
  end

  local HealthTagTable = {
    NUMERIC = {TEXT_MINMAX, TEXT_SHORT, TEXT_MAX},
    BOTH	= {TEXT_MINMAX, TEXT_LONG, TEXT_MAX},
    PERCENT = {TEXT_SHORT, TEXT_PERCENT, TEXT_PERCENT},
    MINIMAL = {TEXT_SHORT, TEXT_PERCENT, TEXT_NONE},
    DEFICIT = {TEXT_DEF, TEXT_DEF, TEXT_NONE},
  }

  function K.PostUpdateHealth(bar, unit, cur, max, min)
    local self = bar:GetParent()
    local uconfig = C.UnitframePlugins[self.MatchUnit]

    if (self.Portrait) then
      UpdatePortraitColor(self, unit, cur, max)
    end

    if (self.Name) and (self.Name.Bg) and (self.MatchUnit == "boss") then -- For boss frames
      self.Name.Bg:SetVertexColor(UnitSelectionColor(unit))
    end

    if (not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit)) then
      if (not UnitIsConnected(unit)) then
        local color = K.Colors.white
        if bar then
          bar:SetStatusBarColor(0.5, 0.5, 0.5)
          if bar.Value then
            bar.Value:SetText(nil)
          end
        end
        return bar.Value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, PLAYER_OFFLINE)
      elseif (UnitIsDeadOrGhost(unit)) then
        local color = K.Colors.white
        if bar then
          bar:SetValue(0)
          if bar.Value then
            bar.Value:SetText(nil)
          end
        end
        return bar.Value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, UnitIsGhost(unit) and GHOST or UnitIsDead(unit) and DEAD)
      end
    end

    if (not cur) then
      cur = UnitHealth(unit)
      max = UnitHealthMax(unit) or 1
    end

    if uconfig.HealthTag == "DISABLE" then
      bar.Value:SetText(nil)
    elseif self.isMouseOver and bar.Value then
      SetValueText(bar.Value, HealthTagTable[uconfig.HealthTag][1], cur, max)
    elseif cur < max then
      SetValueText(bar.Value, HealthTagTable[uconfig.HealthTag][2], cur, max)
    else
      SetValueText(bar.Value, HealthTagTable[uconfig.HealthTag][3], cur, max)
    end
  end
end

-- PostPower update
do
  local PowerTagTable = {
    NUMERIC	= {TEXT_MINMAX, TEXT_SHORT, TEXT_MAX},
    PERCENT	= {TEXT_SHORT, TEXT_PERCENT, TEXT_PERCENT},
    MINIMAL	= {TEXT_SHORT, TEXT_PERCENT, TEXT_NONE},
  }

  function K.PostUpdatePower(bar, unit, cur, max, min)
    local self = bar:GetParent()
    local uconfig = C.UnitframePlugins[self.MatchUnit]
    local shown = bar:IsShown()

    if max == 0 then
      if shown then
        bar:Hide()
      end
      return
    elseif not shown then
      bar:Show()
    end

    if (not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit)) then
      if not (UnitIsConnected(unit)) then
        bar:SetValue(0)
        if bar.Value then
          bar.Value:SetText(nil)
        end
      elseif (UnitIsDeadOrGhost(unit)) then
        bar:SetValue(0)
        if bar.Value then
          bar.Value:SetText(nil)
        end
        return
      end
    end

    if not bar.Value then return end

    if (not cur) then
      max = UnitPower(unit) or 1
      cur = UnitPowerMax(unit)
    end

    if uconfig.PowerTag == "DISABLE" then
      bar.Value:SetText(nil)
    elseif self.isMouseOver then
      SetValueText(bar.Value, PowerTagTable[uconfig.PowerTag][1], cur, max)
    elseif cur < max then
      SetValueText(bar.Value, PowerTagTable[uconfig.PowerTag][2], cur, max)
    else
      SetValueText(bar.Value, PowerTagTable[uconfig.PowerTag][3], cur, max)
    end
  end
end

-- Mouseover enter
function K.UnitFrame_OnEnter(self)
  if self.__owner then
    self = self.__owner
  end
  if not self:IsEnabled() then return end -- arena prep

  UnitFrame_OnEnter(self)

  self.isMouseOver = true
  if self.mouseovers then
    for _, text in pairs (self.mouseovers) do
      text:ForceUpdate()
    end
  end

  if (self.AdditionalPower and self.AdditionalPower.Value) then
    self.AdditionalPower.Value:Show()
  end
end

-- Mouseover leave
function K.UnitFrame_OnLeave(self)
  if self.__owner then
    self = self.__owner
  end
  if not self:IsEnabled() then return end -- arena prep
  UnitFrame_OnLeave(self)

  self.isMouseOver = nil
  if self.mouseovers then
    for _, text in pairs (self.mouseovers) do
      text:ForceUpdate()
    end
  end

  if (self.AdditionalPower and self.AdditionalPower.Value) then
    self.AdditionalPower.Value:Hide()
  end
end

-- Statusbar functions
function K.CreateStatusBar(bar, name)
  local statusBar = CreateFrame("StatusBar", name, bar)
  statusBar:SetStatusBarTexture(C.Media.Texture)
  statusBar:GetStatusBarTexture():SetHorizTile(false)
  statusBar:GetStatusBarTexture():SetVertTile(false)

  if statusBar.styled then return end

  statusBar.background = statusBar:CreateTexture(nil, "BACKGROUND")
  statusBar.background:SetTexture(C.Media.Blank)
  statusBar.background:SetColorTexture(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
  statusBar.background:SetAllPoints()

  statusBar.styled = true

  return statusBar
end

-- AuraWatch
local RaidBuffsPosition = {
  TOPLEFT = {6, 1},
  TOPRIGHT = {-6, 1},
  BOTTOMLEFT = {6, 1},
  BOTTOMRIGHT = {-6, 1},
  LEFT = {6, 1},
  RIGHT = {-6, 1},
  TOP = {0, 0},
  BOTTOM = {0, 0},
}

function K.CreateAuraWatchIcon(self, icon)
  if icon.icon and not icon.hideIcon then
    icon:SetBackdrop(K.TwoPixelBorder)
    icon.icon:SetPoint("TOPLEFT", icon, 1, -1)
    icon.icon:SetPoint("BOTTOMRIGHT", icon, -1, 1)
    icon.icon:SetTexCoord(.08, .92, .08, .92)
    icon.icon:SetDrawLayer("ARTWORK")

    if (icon.cd) then
      icon.cd:SetHideCountdownNumbers(true)
      icon.cd:SetReverse(true)
    end

    if icon.overlay then
      icon.overlay:SetTexture()
    end
  end
end

function K.CreateAuraWatch(self, unit)
  local auras = CreateFrame("Frame", nil, self)
  auras:SetPoint("TOPLEFT", self.Health, 2, -2)
  auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
  auras.presentAlpha = 1
  auras.missingAlpha = 0
  auras.icons = {}
  auras.PostCreateIcon = K.CreateAuraWatchIcon
  auras.strictMatching = true

  local buffs = {}

  if K.RaidBuffs["ALL"] then
    for key, value in pairs(K.RaidBuffs["ALL"]) do
      table_insert(buffs, value)
    end
  end

  if K.RaidBuffs[K.Class] then
    for key, value in pairs(K.RaidBuffs[K.Class]) do
      table_insert(buffs, value)
    end
  end

  if buffs then
    for key, spell in pairs(buffs) do
      local icon = CreateFrame("Frame", nil, auras)
      icon.spellID = spell[1]
      icon.anyUnit = spell[4]
      icon:SetWidth(6)
      icon:SetHeight(6)
      icon:SetPoint(spell[2], 0, 0)

      local tex = icon:CreateTexture(nil, "OVERLAY")
      tex:SetAllPoints(icon)
      tex:SetTexture(C.Media.Blank)
      if spell[3] then
        tex:SetVertexColor(unpack(spell[3]))
      else
        tex:SetVertexColor(0.8, 0.8, 0.8)
      end

      local count = icon:CreateFontString(nil, "OVERLAY")
      count:SetFont(C.Media.Font, 8, "THINOUTLINE")
    count:SetPoint("CENTER", unpack(RaidBuffsPosition[spell[2]]))
  icon.count = count

  auras.icons[spell[1]] = icon
end
end

self.AuraWatch = auras
end