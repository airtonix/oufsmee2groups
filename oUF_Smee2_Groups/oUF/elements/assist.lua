local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]

local Update = function(self, event)
  local unit = self.unit
  if(UnitIsRaidOfficer(unit) and not UnitIsPartyLeader(unit)) then
    self.Assistant:Show()
  else
    self.Assistant:Hide()
  end
end

local Enable = function(self)
  local assistant = self.Assistant
  if(assistant) then
    --self:RegisterEvent("PARTY_LEADER_CHANGED", Update)
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", Update)

    if(assistant:IsObjectType"Texture" and not assistant:GetTexture()) then
      assistant:SetTexture[[Interface\GROUPFRAME\UI-GROUP-ASSISTANTICON]]
    end
    return true
  end
end

local Disable = function(self)
  local assistant = self.Assistant
  if(assistant) then
    --self:UnregisterEvent("PARTY_LEADER_CHANGED", Update)
    self:UnregisterEvent("PARTY_MEMBERS_CHANGED", Update)
  end
end

oUF:AddElement('Assistant', Update, Enable, Disable)

