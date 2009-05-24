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
        elseif(c >= m) then --full health , show the name
            o = n:utf8sub(1,4)
        elseif(UnitCanAttack("player", u)) then  --enemy, show the health percentage
            o = math.floor(c/m*100+0.5).."%"
        else --otherwise, show the missing health
            o = "-"..string.numberize(m - c)
        end
    end
    return o
end
oUF.TagEvents["[raidhp]"] = "UNIT_HEALTH UNIT_MAXHEALTH PLAYER_FLAGS_CHANGED"

 
