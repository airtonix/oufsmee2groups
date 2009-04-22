local _G = getfenv(0)
local _,playerClass = UnitClass("player")
local tinsert = table.insert
local layoutName = "oUF_Smee2_Groups"
local addon_Settings = oUF_Smee2_Groups_Settings

_G[layoutName] = LibStub("AceAddon-3.0"):NewAddon(layoutName, "AceConsole-3.0", "AceEvent-3.0")
local addon = _G[layoutName];
addon.PlayerTargetsList = {}

local LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(layoutName, {
	label = "|cFF006699oUF|r_|cFFFF3300Smee|r_Groups",
	type = "launcher",
	icon = "Interface\\Icons\\Spell_Nature_StormReach",
})
function LDB.OnClick(self, button)
	if button == "RightButton" then
		addon:OpenConfig()
	else
		if addon.db.profile.enabled then
			if IsAltKeyDown() then
				if IsControlKeyDown() then
					addon:ToggleDebug()
				end
			elseif IsShiftKeyDown()  then
				--
			end
		else
			--addon:ToggleActive(true)
		end
	end
end

function LDB.OnTooltipShow(tt)
	tt:AddLine(layoutName)
	tt:AddLine("Debugging "..(addon.enabledDebugMessages and "en" or "dis").."abled.")
	tt:AddLine("--")
	tt:AddLine("Ctrl + Alt + Left Click : Toggle Debug Messages")
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

local numberize = function(val)
	if(val >= 1e3) then
        return ("%.1fk"):format(val / 1e3)
	elseif (val >= 1e6) then
		return ("%.1fm"):format(val / 1e6)
	else
		return val
	end
end

local function Hex(r, g, b)
	if type(r) == "table" then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)
	if(unit == "party" or unit == "partypet" or self.id == nil) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
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
  if(max ~= 0)then
   r,g,b = self.ColorGradient((min/max), .9,.1,.1, .8,.8,.1, 1,1,1)
  end
  bar.text:SetTextColor(r,g,b)
  if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
    bar.bg:SetVertexColor(0.3, 0.3, 0.3)
  else
    bar.bg:SetVertexColor(addon:GetClassColor(unit))
  end
end

function combatFeedbackText(self)
	self.CombatFeedbackText = self.Health:CreateFontString(nil, "OVERLAY")
	self.CombatFeedbackText:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.CombatFeedbackText:SetFont(font, fontsize, "OUTLINE")
	self.CombatFeedbackText.maxAlpha = .8
end

local function updateBanzai(self, unit, aggro)
	if self.unit ~= unit then return end
	if aggro == 1 then
		self.BanzaiIndicator:Show()
	else
		self.BanzaiIndicator:Hide()
	end
end

local function makeFontObject(self,object,desc)
	local db = addon.db.profile
	local parent = self.elements[self.db.FontObjects[object].anchorTo] or self
	
	local fontObject = parent:CreateFontString(nil, "OVERLAY")
			fontObject:SetJustifyH(self.db.FontObjects[object].justifyH)
			fontObject:SetJustifyV(self.db.FontObjects[object].justifyV)
			fontObject:SetAlpha(1)
			fontObject:SetFont(db.fonts['default'].name, db.fonts['default'].size, db.fonts['default'].outline)
			fontObject:SetPoint(self.db.FontObjects[object].anchorFromPoint, parent, 
					self.db.FontObjects[object].anchorToPoint,
					self.db.FontObjects[object].anchorX, 
					self.db.FontObjects[object].anchorY)
					
	fontObject.tag = self.db.FontObjects[object].tag
	self:Tag(fontObject, fontObject.tag)

	self.FontObjects[object] = { 
			name = desc,
			object = fontObject
		}
	return fontObject
end

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
	local  unitSuffix = (self:GetName():gmatch("_(.*)")() or 'unit'):lower()
	
	addon:Debug(self:GetParent():GetName() .. "[ "..tostring(self.groupType) .. " : " ..tostring(unitSuffix).." ]")
	
	local groupDb = db.frames[self.groupType]	
	self.db = groupDb[unitSuffix]
	
	self:SetBackdrop(db.textures.backdrop)
	self:SetBackdropColor(unpack(db.colors.backdropColors))	
	
	
	self:SetAttribute('initial-height', self.db.height)
	self:SetAttribute('initial-width', self.db.width)

--==========--
--	HEALTH	--
--==========--
	self.Health = CreateFrame("StatusBar", nil, self) -- CreateFrame"StatusBar"
	self.Health:SetHeight( self.db.height)
	self.Health:SetStatusBarTexture(db.textures.statusbar)
	self.Health:SetOrientation("VERTICAL")

	self.Health:SetStatusBarColor(0, 0, 0)
	self.Health:SetAlpha(.6)
	self.Health.frequentUpdates = true

	self.Health:SetParent(self)
	self.Health:SetPoint"TOPLEFT"
	self.Health:SetPoint"BOTTOMRIGHT"

	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(db.textures.statusbar)

--	self.Health.text = makeFontObject(self,'health','Health')
  -- Health Text
  self.Health.text = self.Health:CreateFontString(nil, "OVERLAY")
  self.Health.text:SetFont(db.fonts['default'].name, db.fonts['default'].size, db.fonts['default'].outline)
  self.Health.text:SetShadowOffset(0,-1)
  self.Health.text:SetPoint("CENTER")
  self.Health.text:SetJustifyH("CENTER")
  self.Health.text.tag = "[raidhp]"
  self:Tag(self.Health.text, self.Health.text.tag)

  if(unitSuffix ~='target' or unitSuffix~='pet') then
  	self.AFK={}
	self.AFK.object = self.Health.text
	self.AFK.Tagger=self
	self.AFK.fontFormat = "%s:%s"
	self.DC={}
	self.DC.object = self.Health.text
	self.DC.Tagger=self
	self.DC.fontFormat = "%s:%s"
  end

	self.OverrideUpdateHealth = updateHealth
--==========--
--	ICONS	--
--==========--
--Leader Icon
	self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
	self.Leader:SetPoint("TOPLEFT", self, 0, 0)
	self.Leader:SetHeight(10)
	self.Leader:SetWidth(10)

--Master Loot Icon
	self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY")
	self.MasterLooter:SetPoint("TOPLEFT", self, 8, 0)
	self.MasterLooter:SetHeight(10)
	self.MasterLooter:SetWidth(10)

-- Raid Icon
	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("TOP", self, 0, 0)
	self.RaidIcon:SetHeight(10)
	self.RaidIcon:SetWidth(10)
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
	self.BanzaiIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.BanzaiIndicator:SetPoint("TOPRIGHT", self, 0, 0)
	self.BanzaiIndicator:SetHeight(4)
	self.BanzaiIndicator:SetWidth(4)
	self.BanzaiIndicator:SetTexture(1, .25, .25)
	self.BanzaiIndicator:Hide()

-- DebuffHightlight
	if IsAddOnLoaded("oUF_DebuffHighlight") then 
		local dbh =self.Health:CreateTexture(nil, "OVERLAY")
		dbh:SetWidth(16)
		dbh:SetHeight(16)
		dbh:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 16, 4)
		self.DebuffHighlight = dbh
		self.DebuffHighlightUseTexture = true
		self.DebuffHighlightBackdrop = true
	end

	if(not unit) then
		self.SpellRange = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = .4
	end
	return self
end

function addon:Debug(msg)
	if not self.enabledDebugMessages then return end
	self:Print("|cFFFFFF00Debug : |r"..msg)
end
function addon:GetClassColor(unit)
	local _,unitClass = UnitClass(unit)
	return unpack(self.db.profile.colors.class[unitClass or "WARRIOR"])
end
function addon:OpenConfig(input)
	local configName = layoutName.."_Config"
	if(not IsAddOnLoaded(configName)) then LoadAddOn(configName) end
	InterfaceOptionsFrame:Hide()
	LibStub("AceConfigDialog-3.0"):SetDefaultSize(configName, 500, 550)
	LibStub("AceConfigDialog-3.0"):Open(configName)
end

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(layoutName.."DB",addon_Settings)
	self.enabledDebugMessages = addon.db.profile.enabledDebugMessages
	self.units = {}
	self.Layout = layout

	self:RegisterChatCommand("oufsmeegroups", "OpenConfig")
	self:RegisterChatCommand("rl", "reloadui")
	self:RegisterChatCommand("rgfx", "reloadgfx")
--	self:ImportSharedMedia()

end

function addon:ToggleDebug()
	self.enabledDebugMessages=not self.enabledDebugMessages
	self:Print("Debug messages : "..(self.enabledDebugMessages and "ON" or "OFF"))
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

function addon:SubGroups()
	local t = {}
	for i = 1, 8 do t[i] = 0 end
	for i = 1, GetNumRaidMembers() do
			local s = select(3, GetRaidRosterInfo(i))
			t[s] = t[s] + 1
	end
	return t
end

function addon:toggleGroupLayout()
	local zoneName = GetRealZoneText()
	local db = self.db.profile.frames
	if(InCombatLockdown()) then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		local groups = self.units.raid.groups
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		
		if(GetNumRaidMembers() > 0) then
			self:Debug("Showing raid frames")			
			for index,frame in pairs(groups)do frame:Show() end
			self.units.raid:Show()
			self:updateRaidFrame()
		end

		if( GetNumPartyMembers() > 0 )then --there is party members to show
			if(GetNumRaidMembers() > 0)then 
				if not self.db.profile.frames.party.group.showInRaid then
					self.units.party:Hide()
				else
					self.units.party:Show()
				end
			else
				self:Debug("Showing party frames")
				for index,frame in pairs(groups)do frame:Hide() end
				self.units.party:Show()
			end
		end
	end
end

function addon:updateRaidFrame()
 
	local db = self.db.profile.frames.raid
	local raidFrame = self.units.raid
	local roster = self:SubGroups()
	local largestGroup=1
	local largestNumberOfPartyMembers = 1
	local lastGroupWithPeople = false 
	local firstGroupWithPeople = false
	local bottomPoint, topPoint = {},{}
	local numberOfGroupsWithPeople = 0

	for groupNumber,Population in ipairs(roster) do
		-- determine the first and last group. for height
		if(_G['oufraid'..groupNumber]~=nil)then
			if Population > 0 then
				numberOfGroupsWithPeople = numberOfGroupsWithPeople + 1
				if not firstGroupWithPeople then
					firstGroupWithPeople = groupNumber
				end
				lastGroupWithPeople = groupNumber
				if Population > largestNumberOfPartyMembers then
					self:Debug("Found larger group : ".. groupNumber .." :".. Population)
					--determine the group with the largest amount of players for width
						largestGroup = groupNumber
						largestNumberOfPartyMembers = Population
				end
			end			
		end			
	end
	
	self:Debug("group with greatest population : "..largestGroup)
	self:Debug("first group with people : "..firstGroupWithPeople)
	self:Debug("last group with people : "..lastGroupWithPeople)
	self:Debug("number of groups with people : "..numberOfGroupsWithPeople)
	
	raidFrame:SetHeight((db.unit.height + db.unit.yOffSet) * lastGroupWithPeople - db.unit.yOffSet)
	raidFrame:SetWidth((db.unit.width + db.unit.xOffSet) * largestNumberOfPartyMembers)
	raidFrame:Show()
end

function addon:PLAYER_REGEN_ENABLED()
	self:Debug("PLAYER_REGEN_ENABLED")
	self:toggleGroupLayout()
end
function addon:ZONE_CHANGED()
	self:Debug("ZONE_CHANGED")
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

function addon:RAID_ROSTER_UPDATE()
	self:Debug("RAID_ROSTER_UPDATE")
	self:toggleGroupLayout()
end

function  addon:PARTY_MEMBERS_CHANGED()
	self:Debug("PARTY_MEMBERS_CHANGED")
	self:toggleGroupLayout()
end

function  addon:PARTY_LEADER_CHANGED()
	self:Debug("PARTY_LEADER_CHANGED")
	self:toggleGroupLayout()
end

function addon:OnEnable()
    -- Called when the addon is enabled
	local db = self.db.profile
	if not db.enabled then
		self:Debug("Disabling")
		self:Disable()
		return
	end	
	self.enabledDebugMessages = false
	db.frames.unlocked = false

    oUF:RegisterStyle("group", func)
    oUF:SetActiveStyle"group"
    
    oUF.indicatorFont = oUF.indicatorFont or db.indicatorFont   
	local raidSettings = db.frames.raid
	local raidFrame = CreateFrame('Frame', 'oufraid', UIParent)
				raidFrame.groups = {}
				raidFrame:SetBackdrop(db.textures.backdrop)
				raidFrame:SetBackdropColor(unpack(db.colors.backdropColors))
			 	raidFrame:EnableMouse(true)

	self.units.raid = raidFrame
	self.units.raid.groups={}
	for index,data in pairs(raidSettings.group) do
		if(data.visible) then 
			local group = oUF:Spawn('header', 'oufraid'..index)
			group:SetManyAttributes(
			"template",				"oUF_Smee2_Groups_Raid",			"groupFilter",				index,
			"showRaid",					true,
			"showPlayer", 			true,
			"yOffSet",					raidSettings.unit.yOffSet,
			"xOffSet", 					raidSettings.unit.xOffSet,
			"point", 						raidSettings.unit.anchorFromPoint,
			"initial-height",  		raidSettings.unit.height,
			"initial-width", 			raidSettings.unit.width,
			"showPlayer", 			true)
			table.insert(self.units.raid.groups, group)
			group.groupType = 'raid'
			group:SetPoint(data.anchorFromPoint,
					self.units.raid.groups[data.anchorTo] or self.units.raid,
					data.anchorToPoint,
					data.anchorX,
					data.columnSpacing)			
			self.units.raid.groups[index] = group
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


  	local partySettings = db.frames.party
    self.units.party = oUF:Spawn("header", "oufparty")
    self.units.party.groupType = 'party'
	self.units.party:SetPoint(
			partySettings.group.anchorFromPoint,
			UIParent,
    		partySettings.group.anchorToPoint,
    		partySettings.group.anchorX,
    		partySettings.group.anchorY)
	self.units.party:SetManyAttributes(
		"template",		"oUF_Smee2_Groups_Party",
		"showRaid",			false,
		"showParty", 		true,
		"showPlayer", 	true,
		"yOffSet",			partySettings.unit.yOffSet,
		"xOffSet", 			partySettings.unit.xOffSet,		
	    "point",				partySettings.unit.anchorFromPoint,
	    "initial-height", 	partySettings.unit.height,
	    "initial-width", 	partySettings.unit.width)
	self:toggleGroupLayout()
	self:RegisterEvent('ZONE_CHANGED')
	self:RegisterEvent('PARTY_LEADER_CHANGED')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('RAID_ROSTER_UPDATE')
	self:RegisterEvent('PLAYER_LOGIN')
	
--[[
	----------------
	--	MAINTANKS	--
	----------------
	local tank = oUF:Spawn('header', 'oufmaintank')
	tank:SetManyAttributes('showRaid', true, 'groupFilter', 'MAINTANK', 'yOffset', -5)
	tank:SetPoint('BOTTOM', UIParent, 'BOTTOM',180, 255)
	tank:Show()
	self.units.tank = tank
	local assist = oUF:Spawn('header', 'oufmainassist')
	assist:SetManyAttributes('showRaid', true, 'groupFilter', 'MAINASSIST', 'yOffset', -5)
	assist:SetPoint('BOTTOM', tank, 'TOP', 0, 10)
	assist:Show()
	self.units.assist = assist
	
	---------------------
	--	PlayerTargets	--
	---------------------
	self.units.playerTargets = oUF:Spawn('header','oUF_PlayerTargets',"oUF_Smee2_Groups_PlayerTarget")
	self.units.playerTargets.list={}
	self.units.playerTargets:SetPoint('TOPLEFT',UIParent,'TOPLEFT',10,-40)
	self.units.playerTargets:SetManyAttributes(
		'nameList', strjoin(",", unpack(self.units.playerTargets.list)),
		"template", "oUF_Party",
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
				print("|cFFFFFF00"..unitName.." ["..tuid.."] is already in the playertarget list.")
				return
			end
			self.units.playerTargets:SetAttribute("nameList",self.units.playerTargets.InsertTarget(tuid,unitName,nil))
			print("|cFFFFFF00[".. unitName .."] Inserted")		
		else
			print("|cFFFFFF00Please select a target or supply a valid raid/party member.")
		end
	end
	
	self.units.playerTargets.InsertTarget = function(guid,name,realm)
		print (guid,name,realm)
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
		print("|cFFFFFF00Cleared")
	end
--]]	
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
