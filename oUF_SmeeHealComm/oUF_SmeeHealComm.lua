--==============================================================================
--
-- oUF_HealComm
--
-- Uses data from LibHealComm-3.0 to add incoming heal estimate bars onto units 
-- health bars.
--
-- * currently won't update the frame if max HP is unknown (ie, restricted to 
--   players/pets in your group that are in range), hides the bar for these
-- * can define frame.ignoreHealComm in layout to not have the bars appear on 
--   that frame
--
--=============================================================================
local printf = function(msg,error)
	print("|c"..(error and "FFFF6600" or "FF00FF00").."oUF_HealComm : |r"..msg or "")
end

if not oUF then return end

local oUF_HealComm = {}

local healcomm = LibStub("LibHealComm-3.0")

local playerName = UnitName("player")
local playerIsCasting = false
local playerHeals = 0
local playerTarget = ""
oUF.debug=false
local layoutName = "SmeeHealComm"
local layoutPath = "Interface\\Addons\\oUF_"..layoutName
local mediaPath = layoutPath.."\\media\\"
local font, fontSize = mediaPath.."font.ttf", 11		-- The font and fontSize

local function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

local  numberize = function(val)
	if(val >= 1e3) then
        return ("%.1fk"):format(val / 1e3)
	elseif (val >= 1e6) then
		return ("%.1fm"):format(val / 1e6)
	else
		return round(val,1)
	end
end

local function Hex(r, g, b)
	if type(r) == "table" then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end


--set texture and color here
local color = {
    r = 0,
    g = 1,
    b = 0,
    a = .25,
}

--update a specific bar
local updateHealCommBar = function(frame, unit)
	if not unit or unit == nil then return end
    local curHP = UnitHealth(unit)
    local maxHP = UnitHealthMax(unit)
    local percHP = curHP / maxHP
    local incHeals = select(2, healcomm:UnitIncomingHealGet(unit, GetTime())) or 0
    local healCommBar = frame.HealCommBar
	local _,parentBar,_,_,_ = healCommBar:GetPoint()

    --add player's own heals if casting on this unit
    if playerIsCasting then
        for i = 1, select("#", playerTarget) do
            local target = select(i, playerTarget)
            if target == unit then
                incHeals = incHeals + playerHeals
            end
        end
    end
    local percInc = incHeals / maxHP

    --hide if unknown max hp or no heals inc
    if maxHP == 100 or incHeals == 0 then
        frame.HealCommBar:Hide()
        return
    else
        frame.HealCommBar:Show()
    end
	
    local h,w = parentBar:GetHeight(),frame:GetWidth()-2
    healCommBar:ClearAllPoints()
    healCommBar:SetFrameStrata("DIALOG")
    
    if(parentBar:GetOrientation() == "VERTICAL")then
		healCommBar:SetHeight(percInc * h)
		healCommBar:SetWidth(w)
		healCommBar:SetPoint("BOTTOM", parentBar, "BOTTOM", 0, h * percHP)
	else
		healCommBar:SetWidth(percInc * w)
		healCommBar:SetHeight(h)
		healCommBar:SetPoint("LEFT", parentBar, "LEFT", w * percHP,0)
	end
	if(healCommBar.Amount)then
		healCommBar.Amount:SetText(numberize(incHeals))
	end

end

local getClassColour = function(unit)
	local _,unitClass = UnitClass(unit)
	return unpack(self.db.profile.colors.class[unitClass or "WARRIOR"])
end

local drawHealLine = function(state,startf, endf)
	--printf(state.." | Healer : "..startf.unit..", Target : "..endf.unit)

	if(state == "start" or state == "update")then
		local ses = startf.Health:GetScale()
		local ees = endf.Health:GetScale()
		
		local sx = startf.Health:GetLeft() + (startf.Health:GetWidth() / 2) -- * ses
		local sy = (startf.Health:GetBottom() + startf.Health:GetTop()) / 2 -- * ses
		local ex = endf.Health:GetLeft() * ees + (endf.Health:GetWidth() / 2)
		local ey = (endf.Health:GetBottom() + endf.Health:GetTop()) / 2 * ees
		
		local dx,dy = ex - sx, ey - sy
		local cx,cy = (sx + ex) / 2, (sy + ey) / 2
		if (dx < 0) then
			dx,dy = -dx,-dy
		end
		local length = sqrt(dx^2 + dy^2)
		
		
		if length <= 0 then return end

		local s,c = -dy / length, dx / length
		local sc = s * c
		local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy;
		
		if (dy >= 0) then
			Bwid = ((length * c) - (32 * s)) * (32/60)
			Bhgt = ((32 * c) - (length * s)) * (32/60)
			BLx, BLy, BRy = (32 / length) * sc, s^2, (length / 32) * sc
			BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx
			TRy = BRx
		else
			Bwid = ((length * c) + (32 * s)) * (32/60)
			Bhgt = ((32 * c) + (length * s)) * (32/60)
			BLx, BLy, BRx = s * s, -(length / 32) * sc, 1 + (32 / length) * sc
			BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy
			TRx = TLy
		end
		local r,g,b


		--printf(table.concat({TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy}, ", "))
		local line = startf.line
		local _,unitClass = UnitClass(startf.unit)
		local color = oUF.colors.class[unitClass]
		line:SetVertexColor(color[1], color[2], color[3], 0.8)
		--line:SetVertexColor(1,1,1, 0.6)
		line:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy)
		line:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", cx + Bwid, cy + Bhgt)
		line:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", cx - Bwid, cy - Bhgt)
		line:Show()
	else
		startf.line:Hide()
	end
end

local function getFrame(playerName)
	local output = nil
    for frame,object in pairs(oUF.units) do
        local name, server = UnitName(frame)
        if server then name = strjoin("-",name,server) end
        if playerName == name and not object.ignoreHealComm then
        	output = object;
        	break;
        end
    end
    return output
end

--used by library callbacks, arguments should be list of units to update
local updateHealCommBars = function(state,healerName, ...)
	local name, unit
	local source = getFrame(healerName)

	for i = 1, select("#", ...) do
		unit = select(i, ...)
		target = getFrame(unit)
		if(target)then
            drawHealLine(state,source,target)
            updateHealCommBar(target,unit)
        end
	end
	
end


local function hook(frame)
	if frame.ignoreHealComm then return end

	local parentBar = frame.Health
    --create heal bar here and set initial values
	local hcb = CreateFrame"StatusBar"
    if(parentBar:GetOrientation() =="VERTICAL")then
		hcb:SetWidth(parentBar:GetWidth()) -- same height as health bar
		hcb:SetHeight(4) --no initial width
		hcb:SetStatusBarTexture(parentBar:GetStatusBarTexture():GetTexture())
		hcb:SetStatusBarColor(color.r, color.g, color.b, color.a)
		hcb:SetParent(frame)
		hcb:SetPoint("BOTTOMLEFT", parentBar, "TOPLEFT",0,0) --attach to immediate right of health bar to start
		hcb:Hide() --hide it for now
	else
		hcb:SetHeight(parentBar:GetHeight()) -- same height as health bar
		hcb:SetWidth(4) --no initial width
		hcb:SetStatusBarTexture(parentBar:GetStatusBarTexture():GetTexture())
		hcb:SetStatusBarColor(color.r, color.g, color.b, color.a)
		hcb:SetParent(frame)
		hcb:SetPoint("LEFT", parentBar, "RIGHT",0,0) --attach to immediate right of health bar to start
		hcb:Hide() --hide it for now
	end

	if(frame.FontObjects and frame.FontObjects.health and frame.FontObjects.object)then
		fontName, fontHeight, fontFlags = frame.FontObjects.health.object:GetFont()
	else
		fontName, fontHeight, fontFlags = font, fontSize, "outline"
	end
	
	hcb.Amount = hcb:CreateFontString(nil, "OVERLAY")
	hcb.Amount:SetFont(fontName, fontHeight, fontFlags)
	hcb.Amount:SetPoint('CENTER',hcb, 0, 0)
	hcb.Amount:SetTextColor(1,1,1,.5)
	hcb.Amount:SetJustifyH("CENTER")
	
	if(frame.FontObjects ~= nil) then 
		frame.FontObjects["incomingHeals"] = {
			name = "Incoming Heals",
			object = hcb.Amount
		}
	end
	
	frame.HealCommBar = hcb

	frame.line = frame.Health:CreateTexture(nil, "OVERLAY")
	frame.line:SetTexture("Interface\\Addons\\oUF_SmeeHealComm\\media\\Line")
	
	local o = frame.PostUpdateHealth
	frame.PostUpdateHealth = function(...)
		if o then o(...) end
        local name, server = UnitName(frame.unit)
        if server then name = strjoin("-",name,server) end
        updateHealCommBar(frame, name) --update the bar when unit's health is updated
	end
end

--hook into all existing frames
for i, frame in ipairs(oUF.objects) do hook(frame) end

--hook into new frames as they're created
oUF:RegisterInitCallback(hook)

--set up LibHealComm callbacks
function oUF_HealComm:HealComm_DirectHealStart(event, healerName, healSize, endTime, ...)
	if healerName == playerName then
		playerIsCasting = true
		playerTarget = ... 
		playerHeals = healSize
	end
    updateHealCommBars("start",healerName,...)
end

function oUF_HealComm:HealComm_DirectHealUpdate(event, healerName, healSize, endTime, ...)
    updateHealCommBars("update",healerName,...)
end

function oUF_HealComm:HealComm_DirectHealStop(event, healerName, healSize, succeeded, ...)
    if healerName == playerName then
        playerIsCasting = false
    end
    updateHealCommBars("stop",healerName,...)
end

function oUF_HealComm:HealComm_HealModifierUpdate(event, unit, targetName, healModifier)
    updateHealCommBars("update",nil,unit)
end

healcomm.RegisterCallback(oUF_HealComm, "HealComm_DirectHealStart")
healcomm.RegisterCallback(oUF_HealComm, "HealComm_DirectHealUpdate")
healcomm.RegisterCallback(oUF_HealComm, "HealComm_DirectHealStop")
healcomm.RegisterCallback(oUF_HealComm, "HealComm_HealModifierUpdate")
