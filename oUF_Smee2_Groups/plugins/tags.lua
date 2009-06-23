local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]

local numberize = function(val)
	if(type(val)~="number")then return end
    if(val >= 1e3) then
        return ("%.1fk"):format(val / 1e3)
    elseif (val >= 1e6) then
        return ("%.1fm"):format(val / 1e6)
    else
        return val
    end
end
string.numberize =  numberize

local function NeedsIndicators(unit)
    return ( not UnitIsGhost(unit) or not UnitIsDead(unit) or UnitIsConnected(unit))
end

oUF.Tags["[missinghp]"] = function(u) m=UnitHealthMax(u) - UnitHealth(u); return m>0 and m.. " | " or "" end
oUF.TagEvents["[missinghp]"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags["[missingpp]"] = function(u) m=UnitPowerMax(u) - UnitPower(u); return m>0 and m.. " | " or "" end
oUF.TagEvents["[missingpp]"] = "UNIT_HEALTH UNIT_MAXHEALTH"
 
 
oUF.Tags["[shortName]"] = function(u)
	return string.sub(UnitName(u),1,4) or ''
end
oUF.TagEvents["[shortName]"] = "UNIT_NAME_UPDATE"
 
oUF.Tags["[name]"] = function(u)
    if not UnitIsConnected(u) then
	return "D/C"
    elseif UnitIsAFK(u) then
	return "AFK"
    elseif UnitIsGhost(u) then
	return "GHOST"
    elseif UnitIsDead(u) then
	return "DEAD"
    else
	return UnitName(u)
    end
end
oUF.TagEvents["[name]"] = "UNIT_NAME_UPDATE PLAYER_FLAGS_CHANGED"
 
oUF.Tags["[raidhp]"] = function(u)
    o = ""
    if not(u == nil) then
        local c, m, n= UnitHealth(u), UnitHealthMax(u), UnitName(u)
        if UnitIsDead(u) then
            o = "DEAD"
        elseif not UnitIsConnected(u) then
            o = "D/C"
        elseif UnitIsAFK(u) then
            o = "AFK"
        elseif UnitIsGhost(u) then
            o = "GHOST"
        elseif(c >= m) then
            o = n:utf8sub(1,4)
        elseif(UnitCanAttack("player", u)) then
            o = math.floor(c/m*100+0.5).."%"
        else
            o = "-"..numberize(m - c)
        end
    end
    return o
end
oUF.TagEvents["[raidhp]"] = "UNIT_HEALTH UNIT_MAXHEALTH PLAYER_FLAGS_CHANGED"
 
----------
-- TAGS --
----------
 
oUF.Tags["[targethp]"] = function(u)
  o = ""
  if not(u == nil) then
    local c, m = UnitHealth(u), UnitHealthMax(u)
    local hpp = math.floor(c/m*100+0.5).."%"
    local ms = m-c
    if UnitIsGhost(u) then
      o = "Ghost"
    elseif(UnitIsDead(u)) then
      o = "DEAD"
    elseif not UnitIsConnected(u) then
      o = "D/C"
    elseif(c == m)then
      o = numberize(c)
    else
      o = (ms > 0 and numberize(ms) .. " | " or "") ..hpp
    end
  end
  return o
end
oUF.TagEvents["[targethp]"] = "UNIT_HEALTH UNIT_MAXHEALTH"
  
 
oUF.Tags["[spellreflect]"] = function(u) if not NeedsIndicators(u)then return end; local c = select(4, UnitAura(u, "Spell Reflection")); return c and "|cffFF00FF*|r" or "" end
oUF.TagEvents["[spellreflect]"] = "UNIT_AURA"


oUF.Tags["[twilighttorment]"] = function(u) if not NeedsIndicators(u)then return end; local c = select(4, UnitAura(u, "Twilight Torment")); return c and "|cffFF00FFTT|r" or "" end
oUF.TagEvents["[twilighttorment]"] = "UNIT_AURA"
oUF.Tags["[hymnofhope]"] = function(u) if not NeedsIndicators(u)then return end; local c = UnitAura(u, "Hymn of Hope"); return c and "|cff6AB8EC'|r" or "" end
oUF.TagEvents["[hymnofhope]"] = "UNIT_AURA"
 
 
oUF.Tags["[pom]"] = function(u)
  if not NeedsIndicators(u)then return end;
  local _,_,_,c = UnitAura(u, "Prayer of Mending");
  return (c and "|cffffff00·|r" or "");
end
oUF.TagEvents["[pom]"] = "UNIT_AURA"
 
oUF.Tags["[grace]"] = function(u)
  local _,_,_,c = UnitAura(u, "Grace");
  if(not NeedsIndicators(u))then return end
  return  c and "|cff006699"..string.rep("·",c).."|r" or ""
end
oUF.TagEvents["[grace]"] = "UNIT_AURA"
 
oUF.Tags["[inspiration]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Inspiration") and "|cffCCCCCC·|r" or "" end
oUF.TagEvents["[inspiration]"] = "UNIT_AURA"
 
oUF.Tags["[painsupress]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Pain Suppression") and "|cff33FF33+|r" or "" end
oUF.TagEvents["[painsupress]"] = "UNIT_AURA"
 
oUF.Tags["[powerinfusion]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Power Infusion") and "|cff33FF33+|r" or "" end
oUF.TagEvents["[powerinfusion]"] = "UNIT_AURA"
 
oUF.Tags["[guardspirit]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Guardian Spirit") and "|cff33FF33+|r" or "" end
oUF.TagEvents["[guardspirit]"] = "UNIT_AURA"
 
oUF.Tags["[gotn]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Gift of the Naaru") and "|cff0099FF·|r" or "" end
oUF.TagEvents["[gotn]"] = "UNIT_AURA"
 
oUF.Tags["[rnw]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Renew") and "|cff33FF33·|r" or "" end
oUF.TagEvents["[rnw]"] = "UNIT_AURA"
 
oUF.Tags["[aegis]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Divine Aegis") and "|cffff0000·|r" or "" end
oUF.TagEvents["[aegis]"] = "UNIT_AURA"
 
oUF.Tags["[pws]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Power Word: Shield") and "|cffFFFFFF·|r" or "" end
oUF.TagEvents["[pws]"] = "UNIT_AURA"
 
oUF.Tags["[ws]"] = function(u) if not NeedsIndicators(u)then return end; return UnitDebuff(u, "Weakened Soul") and "|cff33FF33·|r" or "" end
oUF.TagEvents["[ws]"] = "UNIT_AURA"
 
oUF.Tags["[shad]"] = function(u) if not NeedsIndicators(u)then return end; return (UnitAura(u, "Prayer of Shadow Protection") or UnitAura(u, "Shadow Protection")) and "" or "|cff9900FF·|r" end
oUF.TagEvents["[shad]"] = "UNIT_AURA"
 
oUF.Tags["[fort]"] = function(u) if not NeedsIndicators(u)then return end; return (UnitAura(u, "Prayer of Fortitude") or UnitAura(u, "Power Word: Fortitude")) and "" or "|cff00A1DE·|r" end
oUF.TagEvents["[fort]"] = "UNIT_AURA"
 
oUF.Tags["[spirit]"] = function(u) if not NeedsIndicators(u)then return end; return (UnitAura(u, "Prayer of Spirit") or UnitAura(u, "Divine Spirit")) and "" or "|cff2F6373·|r" end
oUF.TagEvents["[spirit]"] = "UNIT_AURA"
 
oUF.Tags["[fear]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Fear Ward") and "|cffCA21FF'|r" or "" end
oUF.TagEvents["[fear]"] = "UNIT_AURA"
 
oUF.Tags["[lb]"] = function(u) if not NeedsIndicators(u)then return end; local c = select(4, UnitAura(u, "Lifebloom")) return c and "|cffffff00·|r" or "" end
oUF.TagEvents["[lb]"] = "UNIT_AURA"
 
oUF.Tags["[rejuv]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Rejuvenation") and "|cff00FEBF·|r" or "" end
oUF.TagEvents["[rejuv]"] = "UNIT_AURA"
 
oUF.Tags["[regrow]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Regrowth") and "|cff00FF10·|r" or "" end
oUF.TagEvents["[regrow]"] = "UNIT_AURA"
 
oUF.Tags["[flour]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Flourish") and "|cff33FF33·|r" or "" end
oUF.TagEvents["[flour]"] = "UNIT_AURA"
 
oUF.Tags["[tree]"] = function(u) if not NeedsIndicators(u)then return end; return UnitAura(u, "Tree of Life") and "|cff33FF33·|r" or "" end
oUF.TagEvents["[tree]"] = "UNIT_AURA"
 
oUF.Tags["[gotw]"] = function(u) if not NeedsIndicators(u)then return end; return ( UnitAura(u, "Gift of the Wild") or UnitAura(u, "Mark of the Wild") ) and "" or "|cff33FF33·|r" end
oUF.TagEvents["[gotw]"] = "UNIT_AURA"
 
oUF.Tags['[raidtargeticon]'] = function(u) if(not UnitExists(u)) then return '' end local i = GetRaidTargetIndex(u..'target'); return i and ICON_LIST[i]..'22|t' or '' end
oUF.TagEvents['[raidtargeticon]'] = 'UNIT_TARGET RAID_TARGET_UPDATE'
 
oUF.Tags['[raidtargetname]'] = function(u) if(not UnitExists(u)) then return '' end return UnitName(u..'target') and '- '..UnitName(u..'target') or '' end
oUF.TagEvents['[raidtargetname]'] = 'UNIT_TARGET UNIT_NAME_UPDATE'
 
 
