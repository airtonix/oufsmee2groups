local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]


local _G = getfenv(0)
local _,playerClass = UnitClass("player")
local tinsert = table.insert
local layoutName = "oUF_Smee2_Groups"
local addon_Settings = oUF_Smee2_Groups_Settings
local configName = layoutName.."_Config"

_G[layoutName] = LibStub("AceAddon-3.0"):NewAddon(layoutName, "AceConsole-3.0", "AceEvent-3.0")
local addon = _G[layoutName];
	addon.GlobalObject = {}
	addon.build = {}
	addon.build.version, addon.build.build, addon.build.date, addon.build.tocversion = GetBuildInfo()
	addon.PlayerTargetsList = {}

----------------------------
-- Debug
function addon:Debug(msg)
	if self.db.profile.enabledDebugMessages then
		self:Print(SELECTED_CHAT_FRAME,"|cFFFFFF00Debug : |r"..msg)
	end
end
function addon:ToggleDebug()
	self.db.profile.enabledDebugMessages=not self.db.profile.enabledDebugMessages
	self:Print(SELECTED_CHAT_FRAME,"Debug messages : "..(self.db.profile.enabledDebugMessages and "ON" or "OFF"))
end
function addon:SaveObjectForDebug(label,obj)
	self.GlobalObject[#self.GlobalObject+1] = {label,obj}
end

----------------------------
-- tools
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

local function round(num, idp)
    if idp and idp>0 then
        local mult = 10^idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
math.round = round

local function Hex(r, g, b)
   if type(r) == "table" then
      if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
   end
   return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

local function getPercent(total,index,dec) return round(index / total,dec) end

local function CompressTable(input,modifierFunction)
   local keys = {}
   for value,key in pairs(input)do
      key = key or 0
      if not keys[key] then keys[key] = {} end
      table.insert(keys[key], modifierFunction~=nil and modifierFunction(value) or value)
   end
   return keys
end

local function SortTableByKey(input,midIndexSearch)
   local output = {}
   local index = 1   
   local users 
   local midIndex = false
   for key,data in pairs(input)do
      midIndex = ((midIndex==false) and table.concat(data,","):gmatch(midIndexSearch)()) and index or midIndex
      output[index] = {
         key = key,
         data = data
      }      
      index = index + 1
   end   
   table.sort(output,function(a,b) return tonumber(a.key) > tonumber(b.key) end)
   return output,midIndex
end


----------------------------
-- LibDataBroker & Minimap Icon
local ldb =  LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(layoutName, {
	label = "|cFF006699oUF|r_|cFFFF3300Smee|r_Groups",
	type = "launcher",
	icon = "Interface\\Icons\\INV_Letter_06",
})
ldb.OnClick =  function(self, button)
	if addon.db.profile.enabled then
		if button == "RightButton" then			-- RIGHT CLICK
				if IsAltKeyDown() then
					if IsControlKeyDown() then		-- alt + ctrl
					elseif IsShiftKeyDown() then	-- alt + shift
					else												-- alt
					end				
				elseif IsShiftKeyDown()  then
					if IsControlKeyDown() then		-- shift + ctrl
					else												-- shift
					end				
				elseif IsControlKeyDown() then	-- ctrl
				else 												-- no modifier
					addon:ToggleDebug()
				end
		elseif button == "LeftButton" then		-- LEFT CLICK
				if IsAltKeyDown() then
					if IsControlKeyDown() then		-- alt + ctrl
					elseif IsShiftKeyDown() then	-- alt + shift
					else												-- alt
					end				
				elseif IsShiftKeyDown()  then
					if IsControlKeyDown() then		-- shift + ctrl
					else												-- only shift
						addon:ToggleFrameLock(nil,not addon.db.profile.frames.raid..locked)
					end				
				elseif IsControlKeyDown() then	--
				else 												-- no modifier
					addon:OpenConfig()
				end
		end
	else																-- Addon Not Enabled
		--addon:ToggleActive(true)
	end
end
ldb.OnTooltipShow = function(tt)
	tt:AddLine(layoutName)
	tt:AddLine(".: |cffffffffKeyBinds|r")
	tt:AddDoubleLine("   |cffccffccLeft Click|r", "Open Config")
	tt:AddDoubleLine("   |cff66ff66Shift|r + |cffccffccLeft Click|r", "Unlock Raid Frames")
	tt:AddDoubleLine("   |cffccffccRight Click|r", "Toggle Debug Messages")	
	tt:AddLine(" ")
	
	tt:AddDoubleLine(".: |cffffffffDebugging |r","|cff"..(addon.db.profile.enabledDebugMessages and "00ff00en" or "ff0000dis").."abled|r")
	tt:AddLine(" ")
	
	tt:AddLine(".: |cfffffffflibHealComm|r")
	local data,search =addon.hcomm:GetRaidOrPartyVersions(),UnitName("player")
	local versions,midIndex = SortTableByKey(CompressTable(data,function(u) 	return Hex( unpack({oUF.colors.class[select(2, UnitClass(u))]}) )..u.."|r" end),search)
	addon.HealCommVersions = {
		versions = versions,
		midIndex = midIndex
	}
	local higherColours = {1,1,1, 0,1,0, 0,1,0}    
	local sameColours = {0,1,0}
	local lowerColours = {0,1,0, 1,0,0, 1,0,0}
	local colour
	local isAbove = true
	local isBelow = false
	local state
	local isPlayer
	local percent = 0
	local count = #versions 
	local users,line = {},{}
	local cols,rows = 1,1
	local temp
	for index,data in pairs(versions)do
		if index == midIndex then 
			count = #versions - (midIndex-1)
			colour = sameColours
			isAbove, isBelow = false, true
			weightedIndex = 1
		elseif isAbove then
			colour = {oUF.ColorGradient( percent, unpack(higherColours))}
			weightedIndex = index
			count = midIndex-1
		elseif isBelow then
			colour = {oUF.ColorGradient( percent, unpack(lowerColours))}
			weightedIndex = weightedIndex + 1
		end
		percent = getPercent(count,weightedIndex,2)
   		
		if data.key == 0 then
			colour = {1,0,0}
			data.key = "Not Installed"
		end

		tt:AddLine("   [ "..Hex(unpack(colour))..data.key .."|r ]|n     ".. table.concat(data.data,", ").."|n ",nil,nil,nil,1)

		addon:Debug( "[ i:"..index.." wi: ".. weightedIndex.." c: "..  count .."] ["..table.concat(colour,",").."] " .. percent .. "   [ "..Hex(unpack(colour))..data.key .."|r ]" ..  table.concat(data.data,", ")  )
	end
end
function addon:ToggleFrameLock(obj,value)	
	if value == false then	
		print(SELECTED_CHAT_FRAME,"unlocking")
		obj:SetBackdropColor(.2,1,.2,.5)
		obj:EnableMouse(true);
		obj:SetMovable(true);
		obj:RegisterForDrag("LeftButton");
		obj:SetUserPlaced(true)
		--TODO : Expand borders so it is easier to grab the raidframe
		obj:SetWidth(obj:GetWidth()+10)
		--
		obj:SetScript("OnDragStart", function()
			if(value == false)then
				this.isMoving = true;
				this:StartMoving()
			end
		end);
		obj:SetScript("OnDragStop", function() 
			if(this.isMoving == true)then
				this:StopMovingOrSizing()
			end
				local from, obj, to,x,y = this:GetPoint();
				this.db.anchorFromPoint = from;
				this.db.anchorTo = obj or 'UIParent';
				this.db.anchorToPoint = to;
				this.db.anchorX = x;
				this.db.anchorY = y;
		end);
	else
		print(SELECTED_CHAT_FRAME,"locking")
		obj:SetUserPlaced(false)
		obj:SetMovable(false);
		obj:RegisterForDrag("");
		obj:SetBackdropColor(unpack(addon.db.profile.colors.backdropColors))
		obj:SetWidth(obj:GetWidth()-10)
	end

end

local function Hex(r, g, b)
	if type(r) == "table" then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end
addon.Hex = Hex

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)
	if(unit == "party" or unit == "partypet" or self.id == nil) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

local function updateBanzai(self, unit, aggro)
	if self.unit ~= unit then return end
	if aggro == 1 then self.BanzaiIndicator:Show()
	else self.BanzaiIndicator:Hide() end
end
-- Threat Function
function UpdateThreat(self, event, unit)
	local unitTarget = (unit =='player' and "target" or unit.."target")
	local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation(unit, unitTarget);
	if not(rawthreatpct == nil) then 
		self.Threat:SetText( Hex(GetThreatStatusColor(status)) .. string.format("%.0f", rawthreatpct ) .. "|r" )
	else
		self.Threat:SetText('')
	end
end

local updateHealth = function(self, event, unit, bar, min, max)
  if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
	self.Health.bg:SetVertexColor(0.3, 0.3, 0.3)
  else
	self.Health.bg:SetVertexColor(addon:GetClassColor(unit))
	if(self.RessurectionIndicator)then self.RessurectionIndicator:Hide() end
  end
  
end

function combatFeedbackText(self)
	self.CombatFeedbackText = self.Health:CreateFontString(nil, "OVERLAY")
	self.CombatFeedbackText:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.CombatFeedbackText:SetFont(font, fontsize, "OUTLINE")
	self.CombatFeedbackText.maxAlpha = .8
end

local function updatebanzai(self, unit, aggro)
	if self.unit ~= unit then return end
	if aggro == 1 then
		self.BanzaiIndicator:Show()
	else
		self.BanzaiIndicator:Hide()
	end
end

function addon:makeFontObject(frame,name,data)
	local db = addon.db.profile	
	local parent = frame.elements and frame.elements[data.anchorTo] or frame
	
	-- make our font object, parenting it to the supplied anchor point.
	local fontObject = parent:CreateFontString(nil, "OVERLAY")
			  fontObject:SetJustifyH(data.justifyH)
			  fontObject:SetJustifyV(data.justifyV)
			  fontObject:SetPoint(data.anchorFromPoint, parent,data.anchorToPoint, data.anchorX, data.anchorY)

			  self:SaveObjectForDebug("makeFontObject("..name..")",data)
			  fontObject:SetFont(addon.LSM:Fetch(addon.LSM.MediaType.FONT, data.font.name),data.font.size,data.font.outline) 


	-- if the parent frame is the unitframe and therefore has an UpdateTag function, use it.			
	if(frame.Tag~=nil and data.tag~=nil)then
		fontObject.tag = data.tag
		frame:Tag(fontObject, data.tag)
	end
	
	-- store the fontobject in the parent frames fontobject table.
	if(frame.FontObjects)then
		frame.FontObjects[name] = {
				name = data.desc,
				object = fontObject
		}
	end
	
	return fontObject
end

function addon:UpdateFontObjects(obj)
	local db = self.db.profile.frames[obj.groupType].unit.FontObjects

	for index,font in pairs(obj.FontObjects)do
		if(font.object:GetObjectType() == "FontString" and db[index]~=nil)then
			self:SaveObjectForDebug("UpdateFontObjects("..obj.unit..")", db[index])
			font.object:SetFont(addon.LSM:Fetch(addon.LSM.MediaType.FONT, db[index].font.name),db[index].font.size,db[index].font.outline) 
		end
	end
	
end


local oUF = Smee2Groups_oUFEmbed
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

-- Style
local func = function(self, unit)
	self.menu = menu
	self:EnableMouse(true)
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")
	self:SetAttribute('initial-height', height)
	self:SetAttribute('initial-width', width)

	self.elements={
		["parent"] = self
	}

	self.FontObjects = {}
	self.Indicators = {}	

	local db = addon.db.profile

	self.groupType = self:GetParent().groupType
	self.groupTypeName = self:GetParent().groupName
	
--	addon:Debug(self:GetParent():GetName() .. "[ "..tostring(self.groupType) .. " : " .. self.groupTypeName .." ]")
	local fontDb
	local groupDb = db.frames[self.groupType]
	
	self.db = groupDb.unit -- (self.groupTypeName =="unit" and groupDb["unit"] or groupDb.group[self.groupTypeName])

	self.textures = {
		background = db.textures.backgrounds[self.db.textures.background],
		statusbar = addon.LSM:Fetch('statusbar',self.db.textures.statusbar),
		border = db.textures.borders[self.db.textures.border],
	}

	self:SetBackdrop(self.textures.background)
	self:SetBackdropColor( unpack(db.colors.backdropColors) )	
	
	
	self:SetAttribute('initial-height', self.db.height)
	self:SetAttribute('initial-width', self.db.width)

--==========--
--	HEALTH	--
--==========--
	self.Health = CreateFrame("StatusBar", nil, self) -- CreateFrame"StatusBar"
	self.Health:SetHeight( self.db.height)
	self.Health:SetStatusBarTexture(self.textures.statusbar)
	self.Health:SetOrientation("VERTICAL")

	self.Health:SetStatusBarColor(0, 0, 0)
	self.Health:SetAlpha(.5)
	self.Health.frequentUpdates = true

	self.Health:SetParent(self)
	self.Health:SetPoint"TOPLEFT"
	self.Health:SetPoint"BOTTOMRIGHT"

	self.Health.bg = self:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints(self.Health)
	local hpbg = self.db.bars.health.bgColor
	self.Health.bg:SetTexture(hpbg[1],hpbg[2],hpbg[3],hpbg[4])

	for index, data in pairs(self.db.FontObjects) do
		addon:makeFontObject(self,index,data)
	end
	
	self.OverrideUpdateHealth = updateHealth
--==========--
--	ICONS	--
--==========--
--Master Loot Icon
	local iconAnchor = self.FontObjects.health.object
	local iconOffset  = self.db.FontObjects.health.font.size/2
	self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY")
	self.MasterLooter:SetPoint("CENTER", iconAnchor,"CENTER", 8, iconOffset)
	self.MasterLooter:SetHeight(8)
	self.MasterLooter:SetWidth(8)

--Leader Icon
	self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
	self.Leader:SetPoint("CENTER", iconAnchor,"CENTER", 0, iconOffset)
	self.Leader:SetHeight(8)
	self.Leader:SetWidth(8)
--Raid Assist
    self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
    self.Assistant:SetPoint("CENTER", iconAnchor,"CENTER", 0, iconOffset)
    self.Assistant:SetHeight(8)
    self.Assistant:SetWidth(8)
	
    self.MainTank = self.Health:CreateTexture(nil, "OVERLAY")
    self.MainTank:SetPoint("CENTER", iconAnchor,"CENTER", -8, iconOffset)
    self.MainTank:SetHeight(8)
    self.MainTank:SetWidth(8)
	
    self.MainAssist = self.Health:CreateTexture(nil, "OVERLAY")
    self.MainAssist:SetPoint("CENTER", iconAnchor,"CENTER", -8, iconOffset)
    self.MainAssist:SetHeight(8)
    self.MainAssist:SetWidth(8)
	
-- Raid Icon
	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("TOP", self, 0, 0)
	self.RaidIcon:SetHeight(8)
	self.RaidIcon:SetWidth(8)
	self.RaidIcon:Hide()
	
-- ReadyCheck Icon
	self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	self.ReadyCheck:SetPoint("TOPRIGHT", self, 0, 8)
	self.ReadyCheck:SetHeight(10)
	self.ReadyCheck:SetWidth(10)
	
--	self.Threat =  makeFontObject(self,'threat','Threat')
--	self.PostUpdateThreat = UpdateThreat			

	self.AuraIndicator = true	

	---Aggro Indicator
	self.Banzai = updateBanzai
	self.BanzaiIndicator = self.Health:CreateTexture(nil, "BORDER")
	self.BanzaiIndicator:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.BanzaiIndicator:SetHeight(8)
	self.BanzaiIndicator:SetWidth(self.db.width - 6)
	self.BanzaiIndicator:SetTexture(1, .25, .25,.8)
	self.BanzaiIndicator:Hide()

	---Aggro Indicator
	self.RessurectionIndicator = self.Health:CreateTexture(nil, "BORDER")
	self.RessurectionIndicator:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, 0)
	self.RessurectionIndicator:SetHeight(8)
	self.RessurectionIndicator:SetWidth(self.db.width - 6)
	self.RessurectionIndicator:SetTexture(0, .25, 1,.8)
	self.RessurectionIndicator:Hide()

-- DebuffHightlight
	self.DebuffHighlightBackdrop = self.db.Decurse.Backdrop
--	self.DebuffHighlightUseTexture = self.db.Decurse.Icon
	self.DebuffHighlightAlpha = self.db.Decurse.BackDropAlpha
	self.DebuffHighlightFilter = self.db.Decurse.Filter

--	local dbh = self.Health:CreateTexture(nil, "OVERLAY")
--			 dbh:SetWidth(16)
--			 dbh:SetHeight(16)
--			 dbh:SetPoint("CENTER", self, "CENTER")
--	self.DebuffHighlight = dbh

	self.Decurse = {
		Backdrop = self.DebuffHighlightBackdrop,
--		Icon = self.DebuffHighlight
	}



	if(not unit) then
		self.SpellRange = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = .4
	end
	return self
end

function addon:GetClassColor(unit)
	local _,unitClass = UnitClass(unit)
	return unpack(self.db.profile.colors.class[unitClass or "WARRIOR"])
end

function addon:OpenConfig()
	if(not IsAddOnLoaded(configName)) then
		LoadAddOn(configName)
	end

	local aceCfg = LibStub("AceConfigDialog-3.0")
	if(aceCfg.OpenFrames[configName])then
		aceCfg:Close(configName)
	else
		InterfaceOptionsFrame:Hide()
		aceCfg:SetDefaultSize(configName, 600, 650)
		aceCfg:Open(configName)
	end
end

function addon:ImportSharedMedia()
	if(self.LSM) then self.SharedMediaActive = true else return end
	local db = self.db.profile

	if(db.textures)then
		if(db.textures.borders)then
			for name,path in pairs(self.db.profile.textures.statusbars)do
				self.LSM:Register(self.LSM.MediaType.STATUSBAR, name, path)
			end
		end
	
		if(db.textures.borders)then
			for name,path in pairs(self.db.profile.textures.borders)do
				self.LSM:Register(self.LSM.MediaType.BORDER, name, path)
			end
		end
	end
	
	if(db.fonts)then
		for name,data in pairs(db.fonts)do
			self.LSM:Register(self.LSM.MediaType.FONT, name, data.name)
		end
	end
end

function addon:GetGroupFilterString()
	local output,first = "",true
	local dbGroups = self.db.profile.frames.raid.group.filterGroups
	for index,enabled in pairs(dbGroups) do
		if enabled then 	output = output .. (first and "" or ", ") .. index end
		first = false
	end
	return output
end

function addon:Roster()
	local roster = {}
	local raid_groups = self.units.raid.group
	local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML
	for group = 1, 8 do roster[group] = {} end
	for raidIndex = 1, GetNumRaidMembers() do
		name, rank, groupId, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(raidIndex);
		table.insert(roster[groupId],oUF.units["raid"..raidIndex])
		--raid_groups[groupId]
	end
	return roster
end

function addon:toggleGroupLayout()
	local zoneName = GetRealZoneText()
	local db = self.db.profile.frames
	if(InCombatLockdown()) then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		local groups = self.units.raid.group
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:OriginalUpdateRaidFrame()
		self:updatePartyFrame()
	end
end

function addon:updatePartyFrame()
	if( GetNumPartyMembers() > 0 )then --there is party members to show
		if(GetNumRaidMembers() > 0)then 
			if not self.db.profile.frames.party.group.players.showInRaid then
				self.units.party.group.players:Hide()
			else
				self.units.party.group.players:Show()
			end
		else
			self:Debug("Showing party frames")
			for index,frame in pairs(self.units.raid.group)do frame:Hide() end
			self.units.party.group.players:Show()
		end
	else
		self.units.party.group.players:Hide()
	end
end

function addon:CollapseGroups(roster)
	local isEmpty,tempPoints,frame,msg,data
	local raidGroup = self.units.raid.group
	local raidGroupDb = self.db.profile.frames.raid.group
	for index,name in ipairs(self.groupMap.raid) do
		frame = raidGroup[name]
		data = tempPoints and tempPoints or raidGroupDb[name]
		
		frame:SetPoint(data.anchorFromPoint,
				self.units.raid.group[data.anchorTo] or self.units.raid,
				data.anchorToPoint, data.anchorX, data.anchorY)

		if( #roster[index] == 0 )then
			--empty
			tempPoints = data						
		else
			--not empty
			tempPoints = nil
		end
		
	end
	self:Debug("Groups Collapsed")
	
end

function addon:updateRaidFrame(padding,margin)
	local padding = padding or 5
	local margin = margin or 10
	local db = self.db.profile.frames.raid
	local raidFrame = self.units.raid
	local roster = self:Roster()
	self:CollapseGroups(roster)

	if(GetNumRaidMembers() > 0) then
		self:Debug("Showing raid frames")		
		for index,group in pairs(self.units.raid.group)	do
			group:Show()
		end
		raidFrame:Show()
	else
		self:Debug("Hiding raid frames")
		for index,group in pairs(self.units.raid.group)	do
			group:Hide()
		end
		raidFrame:Hide()
		return
	end
	
	raidFrame:SetPoint(
		db.anchorFromPoint,
		UIParent,
		db.anchorToPoint,
		db.anchorX,
		db.anchorY)

	local left,bottom,width,height = 0,0,0,0
	local frameLeft,frameRight,frameTop,frameBottom
	  width = db.unit.width
	  height = db.unit.height
	  spacing = db.unit.spacing

	for unit,frame in pairs(oUF.units)do
	   if( unit:gmatch("raid")() == "raid" and UnitName(unit)~=nil )then  
		  left,  bottom = frame:GetRect()
		  left = left or 0
		  bottom = bottom or 0

		  if(frameLeft==nil or left < frameLeft)then
		     frameLeft = math.floor(left)
		  end
		  if(frameBottom==nil or bottom < frameBottom )then
		     frameBottom = math.floor(bottom)
		  end
		  
		  if(frameTop==nil or bottom+height > frameTop )then
		     frameTop = math.floor(bottom+height+spacing)
		  end
		  
		  if(frameRight==nil or left+width > frameRight)then
		     frameRight = math.floor(left+width+spacing)
		  end
		  self:Debug(table.concat({unit, frameLeft,frameBottom,frameRight - frameLeft, frameTop - frameBottom},", "))
	   end       
	end

	raidFrame:SetWidth( frameRight - frameLeft + padding )
	raidFrame:SetHeight( frameTop - frameBottom + padding )

	raidFrame:Show()

end

function addon:OriginalUpdateRaidFrame(padding,margin)
	local padding = padding or 5
	local margin = margin or 10
	
	local raidFrame = self.units.raid
	if(GetNumRaidMembers() > 0) then
		self:Debug("Showing raid frames")			
		for index,frame in pairs(raidFrame.group)do frame:Show() end
		raidFrame:Show()
	else
		self:Debug("Hiding raid frames")
		for index,frame in pairs(raidFrame.group)do frame:Hide() end
		raidFrame:Hide()
		return
	end

	local db = self.db.profile.frames.raid
	
	raidFrame:SetPoint(
		db.anchorFromPoint,
		UIParent,
		db.anchorToPoint,
		db.anchorX,
		db.anchorY)
		
	local roster = self:Roster()
	local largestGroup=1
	local largestNumberOfPartyMembers = 1
	local lastGroupWithPeople = false 
	local firstGroupWithPeople = false
	local bottomPoint, topPoint = {},{}
	local numberOfGroupsWithPeople = 0
	local group,tempPoint,data
	local emptyGroups = 0
	local groupName
	
	for groupNumber,Population in ipairs(roster) do
		-- determine the first and last group. for height
		groupName = self.groupMap.raid[groupNumber]
		group = self.units.raid.group[groupName]
		data = db.group[groupName]
		group:SetPoint(data.anchorFromPoint,
				self.units.raid.group[data.anchorTo] or self.units.raid,
				data.anchorToPoint, data.anchorX, data.anchorY)
				
		if(group~=nil)then
			if #Population > 0 then
				numberOfGroupsWithPeople = (numberOfGroupsWithPeople + 1)
				if not firstGroupWithPeople then
					firstGroupWithPeople = groupNumber
				end
				lastGroupWithPeople = groupNumber
				if #Population >= largestNumberOfPartyMembers then
					self:Debug("Found larger group : ".. groupNumber .." :".. #Population)
					--determine the group with the largest amount of players for width
						largestGroup = groupNumber
						largestNumberOfPartyMembers = #Population
				end
				if(tempPoint~=nil)then
					group:SetPoint(unpack(tempPoint))
					tempPoint = nil
				end
			else
				emptyGroups = emptyGroups + 1
				tempPoint = tempPoint and tempPoint or {group:GetPoint()}				
			end	
		end			
	end

	self:Debug("group with greatest population : "..largestGroup)
	self:Debug("first group with people : "..firstGroupWithPeople)
	self:Debug("last group with people : "..lastGroupWithPeople)
	self:Debug("number of groups with people : "..numberOfGroupsWithPeople)
	self:Debug("number of empty groups : "..emptyGroups)
	
	local top = db.unit.height * lastGroupWithPeople
	local bottom = 0
	local left = 0
	local right = 0
	local _,_,_,margin = self.units.raid.group[self.groupMap.raid[firstGroupWithPeople]]:GetPoint()
	local height = 0
	for i=1,numberOfGroupsWithPeople do 
		height = height + (db.unit.height + db.group[self.groupMap.raid[i]].anchorY)
	end
	height = height + db.group.One.anchorY
	
	raidFrame:SetHeight(height)
	raidFrame:SetWidth((db.unit.width + db.unit.spacing) * largestNumberOfPartyMembers + margin)
	raidFrame:Show()
	
end

function addon:GetUnitFrameByID(unitId)
	local found
	for index,frame in pairs(oUF.objects) do 
		if not found and frame and frame.unit==unitId then found = frame end
	end
	return frame
end

function addon:UNIT_SPELLCAST_SUCCEEDED(event,...)
	local unitId, spellName, spellRank = ...
	local ressurection = self.db.profile.ressurectionIdicator
	local frame
	if ressurection[spellName]~=nil then
		self:Debug(event,unitId, spellName)
		frame = addon:GetUnitFrameByID(unitId)
		if frame~=nil then frame.RessurectionIndicator:Show() end
	end	
end


----------------------------
-- INIT
function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(layoutName.."DB",addon_Settings)
	self.LSM = LibStub("LibSharedMedia-3.0")
	self.hcomm=LibStub:GetLibrary("LibHealComm-3.0")
		
	self.enabledDebugMessages = addon.db.profile.enabledDebugMessages
	self.units = {}
	self.Layout = layout

	self:RegisterChatCommand("oufsmeegroups", "OpenConfig")
	self:RegisterChatCommand("rl", function() ReloadUI() end)
	self:RegisterChatCommand("rgfx", function() RestartGx() end)
	self:ImportSharedMedia()

end

----------------------------
-- EVENTS
function addon:PLAYER_REGEN_ENABLED()
	self:Debug("PLAYER_REGEN_ENABLED")
	self:toggleGroupLayout()
end
function addon:ZONE_CHANGED()
	self:Debug("ZONE_CHANGED")
	self:toggleGroupLayout()
end
function addon:PARTY_LEADER_CHANGED()
	self:Debug("PARTY_LEADER_CHANGED")
	self:toggleGroupLayout()
end
function addon:PARTY_MEMBERS_CHANGED()
	self:Debug("PARTY_MEMBERS_CHANGED")
	self:toggleGroupLayout()
end
function addon:PLAYER_LOGIN()
	self:Debug("PLAYER_LOGIN")
	self:toggleGroupLayout()
end
function addon:RAID_ROSTER_UPDATE()
	self:Debug("RAID_ROSTER_UPDATE")
	self:toggleGroupLayout()
end

----------------------------
-- STARTUP
function addon:OnEnable()
    -- Called when the addon is enabled
    self.units = {}
	local db = self.db.profile
	if not db.enabled then
		self:Debug("Disabling")
		self:Disable()
		return
	end	
	self.enabledDebugMessages = false
	self.groupMap = {
		raid		= {
			[1]	= "One",
			[2]	= "Two",
			[3]	= "Three",
			[4]	= "Four",
			[5]	= "Five",
			[6]	= "Six",
			[7]	= "Seven",
			[8]	= "Eight",
		},
		party	= {
			[1]	= "players",
			[2]	= "pets",
			[3]	= "targets",
		}
	}
	
    oUF:RegisterStyle("group", func)
    oUF:SetActiveStyle"group"
    oUF.indicatorFont = oUF.indicatorFont or db.indicatorFont   
	local raidSettings = db.frames.raid
	raidSettings.locked = true
	local raidFrame = CreateFrame('Frame', 'oufraid', UIParent)
				raidFrame:SetBackdrop(db.textures.backgrounds.default)
				raidFrame:SetBackdropColor(unpack(db.colors.backdropColors))
			 	raidFrame:EnableMouse(true)
				raidFrame.db = db.frames.raid
--				raidFrame:SetStrata("HIGH")
	self.units.raid = raidFrame
	self.units.raid.group = {}

	local data
	for index,name in ipairs(self.groupMap.raid) do
		data = raidSettings.group[name]
		if(data.visible) then 
			local group = oUF:Spawn('header', 'oufraid_'..name)
			group:SetManyAttributes(
			"template",				"oUF_Smee2_Groups_Raid",			"groupFilter",				data.groupFilter,
			"showRaid",					true,
			"showPlayer", 			true,
			"yOffSet",					raidSettings.unit.spacing,
			"xOffSet", 					raidSettings.unit.spacing,
			"point", 						raidSettings.unit.anchorFromPoint,
			"initial-height",  		raidSettings.unit.height,
			"initial-width", 			raidSettings.unit.width,
			"showPlayer", 			true)
			group.groupType = 'raid'
			group.groupName = name
			self.units.raid.group[name] = group
			group:SetPoint(data.anchorFromPoint,
					self.units.raid.group[data.anchorTo] or self.units.raid,
					data.anchorToPoint, data.anchorX, data.anchorY)
			group:SetFrameLevel(0)
			group:SetParent(raidFrame)
		end
	end
	raidFrame:SetFrameLevel(1)
	raidFrame:SetPoint(
		raidSettings.anchorFromPoint,
		UIParent,
		raidSettings.anchorToPoint,
		raidSettings.anchorX,
		raidSettings.anchorY)
	raidFrame:SetScale(raidSettings.scale)

  	local partySettings = db.frames.party
  	partySettings.locked = true
  	self.units.party = {}
    self.units.party.group = {}
    self.units.party.group.players = oUF:Spawn("header", "oufparty")
	self.units.party.group.players:SetPoint(
			partySettings.group.players.anchorFromPoint,
			UIParent,
    		partySettings.group.players.anchorToPoint,
    		partySettings.group.players.anchorX,
    		partySettings.group.players.anchorY)
	self.units.party.group.players:SetManyAttributes(
		"template",		"oUF_Smee2_Groups_Party",
		"showRaid",			false,
		"showParty", 		true,
		"showPlayer", 	true,
		"yOffSet",			partySettings.unit.spacing,
		"xOffSet", 			partySettings.unit.spacing,		
	    "point",				partySettings.unit.anchorFromPoint,
	    "initial-height", 	partySettings.unit.height,
	    "initial-width", 	partySettings.unit.width)
    self.units.party.group.players.groupType = 'party'
    self.units.party.group.players.groupName = 'unit'
	self:toggleGroupLayout()

	self:RegisterEvent('ZONE_CHANGED')
	self:RegisterEvent('PARTY_LEADER_CHANGED')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('RAID_ROSTER_UPDATE')
	self:RegisterEvent('PLAYER_LOGIN')
	--self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	
	self.units.party.group.pets = {
		childFrames = function()
		    local objects = {}
		    local isParty,isPet,name

		    for index,frame in pairs(oUF.objects)do
		        name = tostring(frame:GetName()):lower()
		        isParty = name:gmatch("party")()
		        isPet = name:gmatch("pet")()
		        if( isParty and isPet )then 
		            self:Debug(name)
		            objects[name] = frame 
		        end
		    end

		    return objects
		end,
		groupType	=	'party',
		groupName	=	'unit',
	}
	
	self.units.party.group.targets = {
		childFrames = function()
			local objects = {}
			local isParty,isTarget,name

			for index,frame in pairs(oUF.objects)do
			    name = tostring(frame:GetName()):lower()
			    isParty = name:gmatch("party")()
			    isTarget = name:gmatch("target")()
			    if( isParty and isTarget )then 
			        objects[name] = frame 
			    end
			end

			return objects
		end,
		groupType	=	'party',
		groupName	=	'unit',
	}	

	----------------
	--	MAINTANKS	--
	----------------
	--[[
	local maintankSettings = db.frames.maintank
	maintankSettings.locked = true
	local maintank = oUF:Spawn('header', 'oufmaintank')
			maintank:SetManyAttributes('showRaid', true, 'groupFilter', 'MAINTANK', 'yOffset', -5)
		--	maintank:SetPoint('TOPLEFT', self.units.raid, 'TOPRIGHT',10, 0)
			maintank:SetPoint(
				maintankSettings.group.anchorFromPoint,
				self.units[maintankSettings.group.anchorTo] or UIParent,
	    		maintankSettings.group.anchorToPoint,
	    		maintankSettings.group.anchorX,
	    		maintankSettings.group.anchorY)
	    		
			maintank.groupType = 'maintank'
			maintank.groupName = 'group'
			self.units.maintank = maintank
			maintank:Show()

	local mainassistSettings = db.frames.mainassist

	local mainassist = oUF:Spawn('header', 'oufmainassist')
			mainassist:SetManyAttributes('showRaid', true, 'groupFilter', 'MAINASSIST', 'yOffset', -5)
			mainassist:SetPoint('TOPRIGHT', self.units.raid, 'TOPLEFT',-10, 0)
			mainassist.groupType = 'mainassist'
			mainassist.groupName = 'group'
			self.units.mainassist = mainassist
			mainassist:Show()


	---------------------
	--	PlayerTargets	--
	---------------------
	self.units.playerTargets = oUF:Spawn('header','oUF_PlayerTargets',"oUF_Smee2_Groups_PlayerTarget")
	self.units.playerTargets.list={}
	self.units.playerTargets:SetPoint('TOPLEFT',UIParent,'TOPLEFT',10,-40)
	self.units.playerTargets:SetManyAttributes(
		'nameList', strjoin(",", unpack(self.units.playerTargets.list)),
--		"template", "oUF_Smee2_Groups_PlayerTarget",
		"yOffset", 3,
		"xOffSet", 3,
		"unitsPerColumn",1,
		"maxColumns",8,
		"columnSpacing",1,
		"point", "left",
		"showParty", true,
		"showPlayer", true,
		"showSolo",true,
		"showRaid",true	)
	self.units.playerTargets:Show()

	self.units.playerTargets.addTarget=function(unit)
		local unitName = (unit and UnitName(unit)) or UnitName("target")
		if unitName then
			local tuid = (unit and UnitGUID(unit)) or UnitGUID("target")
			local inList = self.units.playerTargets.list[tuid]
			if inList then 
				addon:Print(SELECTED_CHAT_FRAME,"|cFFFFFF00"..unitName.." ["..tuid.."] is already in the playertarget list.")
				return
			end
			self.units.playerTargets:SetAttribute("nameList",self.units.playerTargets.InsertTarget(tuid,unitName,nil))
			addon:Print(SELECTED_CHAT_FRAME,"|cFFFFFF00[".. unitName .."] Inserted")		
		else
			addon:Print(SELECTED_CHAT_FRAME,"|cFFFFFF00Please select a target or supply a valid raid/party member.")
		end
	end
	
	self.units.playerTargets.InsertTarget = function(guid,name,realm)
		addon:Print(SELECTED_CHAT_FRAME,guid,name,realm)
		local first,output = true,""		
		self.units.playerTargets.list[guid] = {
			['name'] = name,
			['realm'] = realm,
		}
		for guid,data in pairs(self.units.playerTargets.list)do
			output = output .. (first and "" or ",") .. data.name
		end
		return output
	end
	
	self.units.playerTargets.clearList=function(unit)
		self.units.playerTargets.list = {}
		self.units.playerTargets.list:SetAttribute("nameList", "")
		addon:Print(SELECTED_CHAT_FRAME,"|cFFFFFF00Cleared")
	end

--]]
	self.MinimapIcon = LibStub("LibDBIcon-1.0")
	self.MinimapIcon:Register(layoutName, ldb, db.minimapicon)


end

function addon:OnDisable()
    -- Called when the addon is disabled
	db = self.db.profile
	if db.enabled then
		db.enabled = false
		return
	end
    self:Debug("Disabled")
end
