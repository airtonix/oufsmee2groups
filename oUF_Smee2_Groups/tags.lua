oUF.Tags["[raidhp]"] = function(u)
  local  o = ""
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
        elseif(c >= m) then --full health , show the name
            o = n:utf8sub(1,4)
        elseif(UnitCanAttack("player", u)) then  --enemy, show the health percentage
            o = math.floor(c/m*100+0.5).."%"
        else --otherwise, show the missing health
			r,g,b = oUF.ColorGradient((c/m), .9,.1,.1, .8,.8,.1, 1,1,1)
			o = string.format("|cff%02x%02x%02x -%s |r", r*255, g*255, b*255,string.numberize(m - c))             
        end
    end
    return o
end
oUF.TagEvents["[raidhp]"] = "UNIT_HEALTH UNIT_MAXHEALTH PLAYER_FLAGS_CHANGED"

oUF.Tags['[raidthreat]'] = function(u)
	if(u==nil) then return end
	local tanking, _, perc = UnitDetailedThreatSituation(u, u..'target')
	return not tanking and perc and floor(perc)
end
oUF.TagEvents['[raidthreat]'] = 'UNIT_THREAT_LIST_UPDATE  UNIT_THREAT_SITUATION_UPDATE'

