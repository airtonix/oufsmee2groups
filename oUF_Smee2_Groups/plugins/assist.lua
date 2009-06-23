local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]

local UpdateAssistant = function(self, event)
  local unit = self.unit
  if((UnitInParty(unit) or UnitInRaid(unit)) and UnitIsRaidOfficer(unit) and not UnitIsPartyLeader(unit)) then
    self.Assistant:Show()
  else
    self.Assistant:Hide()
  end
end
local EnableAssistant = function(self)
  local assistant = self.Assistant
  if(assistant) then
    --self:RegisterEvent("PARTY_LEADER_CHANGED", UpdateAssistant)
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", UpdateAssistant)

    if(assistant:IsObjectType"Texture" and not assistant:GetTexture()) then
      assistant:SetTexture[[Interface\GROUPFRAME\UI-GROUP-ASSISTANTICON]]
    end
    return true
  end
end
local DisableAssistant = function(self)
  local assistant = self.Assistant
  if(assistant) then
    --self:UnregisterEvent("PARTY_LEADER_CHANGED", UpdateAssistant)
    self:UnregisterEvent("PARTY_MEMBERS_CHANGED", UpdateAssistant)
  end
end

local UpdateMainTank = function(self, event)
  local unit = self.unit
  if((UnitInParty(unit) or UnitInRaid(unit)) and GetPartyAssignment("MAINTANK", unit)) then
    self.MainTank:Show()
  else
    self.MainTank:Hide()
  end
end
local EnableMainTank = function(self)
  local maintank = self.MainTank
  if(maintank) then
    --self:RegisterEvent("PARTY_LEADER_CHANGED", UpdateMainTank)
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", UpdateMainTank)
    if(maintank:IsObjectType"Texture" and not maintank:GetTexture()) then
      maintank:SetTexture[[Interface\GroupFrame\UI-Group-MainTankIcon]]
    end
    return true
  end
end
local DisableMainTank = function(self)
  local maintank = self.MainTank
  if(maintank) then
    --self:UnregisterEvent("PARTY_LEADER_CHANGED", UpdateMainTank)
    self:UnregisterEvent("PARTY_MEMBERS_CHANGED", UpdateMainTank)
  end
end

local UpdateMainAssist = function(self, event)
  local unit = self.unit
  if((UnitInParty(unit) or UnitInRaid(unit)) and GetPartyAssignment("MAINASSIST", unit)) then
    self.MainAssist:Show()
  else
    self.MainAssist:Hide()
  end
end
local EnableMainAssist = function(self)
  local mainassist = self.MainAssist
  if(mainassist) then
    --self:RegisterEvent("PARTY_LEADER_CHANGED", UpdateMainAssist)
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", UpdateMainAssist)
    if(mainassist:IsObjectType"Texture" and not mainassist:GetTexture()) then
      mainassist:SetTexture[[Interface\GroupFrame\UI-Group-MainAssistIcon]]
    end
    return true
  end
end
local DisableMainAssist = function(self)
  local mainassist = self.MainAssist
  if(mainassist) then
    --self:UnregisterEvent("PARTY_LEADER_CHANGED", UpdateMainAssist)
    self:UnregisterEvent("PARTY_MEMBERS_CHANGED", UpdateMainAssist)
  end
end

oUF:AddElement('Assistant', UpdateAssistant, EnableAssistant, DisableAssistant)
oUF:AddElement('MainTank', UpdateMainTank, EnableMainTank, DisableMainTank)
oUF:AddElement('MainAssist', UpdateMainAssist, EnableMainAssist, DisableMainAssist)

