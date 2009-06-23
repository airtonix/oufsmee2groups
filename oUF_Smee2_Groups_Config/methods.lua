local layoutName = 'oUF_Smee2_Groups'
local addon = _G[layoutName]
local configAddonName = layoutName..'_Config'
local configAddon = _G[configAddonName]
local tinsert = table.insert
local db = addon.db.profile
GlobalObject = {}
local oUF = Smee2Groups_oUFEmbed

-----------------
--  CONSTANTS --
configAddon.growthYDirections= {
	UP = "UP",
	DOWN = "DOWN",
}
configAddon.growthXDirections= {
	LEFT = "LEFT",
	RIGHT = "RIGHT",
}
configAddon.frameAnchorPoints = {
	TOPLEFT = "TOPLEFT", TOP = "TOP", TOPRIGHT = "TOPRIGHT",
	LEFT = "LEFT", CENTER = "CENTER", RIGHT = "RIGHT",
	BOTTOMLEFT = "BOTTOMLEFT", BOTTOM = "BOTTOM", BOTTOMRIGHT = "BOTTOMRIGHT"
}
configAddon.textHorizontalAlignmentPoints={
	LEFT = "LEFT", CENTER = "CENTER", RIGHT ="RIGHT"
}
configAddon.textVerticalAlignmentPoints={
	TOP = "TOP", MIDDLE = "MIDDLE", BOTTOM = "BOTTOM"
}
configAddon.fontOutlineTypes={
	NONE = "None",
	OUTLINE = "OUTLINE",
	THICKOUTLINE = "THICKOUTLINE",
	MONOCHROME = "MONOCHROME"
}

--########
-- CONFIG  ##
--########

-- Debug Exploder
-- : Explodes and joins the info table passed around in the ace3config gui
function configAddon:concatLeaves(branch)
	local picture = ""
		for index,value in pairs(branch) do
			picture = picture .. "["..index.."] - "..tostring(value).."\n"
		end
	return picture
end

-- RAID GROUPFRAME ANCHOR OBJECTS
-- : Builds and returns a valid ace3config table to be used in a select widget
function configAddon:RaidFramesToAnchorTo()
	local AnchorToFrames = {}
	for name,_ in pairs(addon.units.raid.group)do
		AnchorToFrames[tostring(name)] = "Group ["..tostring(name).."]"
	end
	AnchorToFrames['oufraid'] = 'Raid Frame Container'
	return AnchorToFrames
end

function configAddon:PartyFramesToAnchorTo()
	local fname
	local AnchorToFrames = {}
	for name,frame in pairs(oUF.objects)do
		fname = tostring(frame:GetName()):lower()
		if(fname:gmatch("party")())then
			AnchorToFrames[fname] = "["..fname.."]"
		end
	end
	return AnchorToFrames
end

function configAddon:DimensionFrames(type)
	local db = addon.db.profile.frames[type].unit
	
	for unit,frame in pairs(oUF.units)do
		if( unit:gmatch(type)()~=nil)then
			frame:SetWidth(db.width)
			frame:SetHeight(db.height)
		end
	end

	for index,group in pairs(addon.units.raid.group)do
		group:SetManyAttributes(
		 "initial-height", w,
		 "initial-width",  h,
		 "yOffSet",        db.spacing,
		 "xOffSet",        db.spacing,
		 "point",          db.anchorFromPoint)
	end
	addon:OriginalUpdateRaidFrame()
end

-------------
--  NORMAL --

-- GET--
function configAddon:GetOption(info)
	local object = info['arg'] 
	local parent = info[#info-1]
	local profile = addon.db.profile
	local setting = info[#info]
	local object,output
	
	if(info[1]=="enabledDebugMessages")then 
		output = self.addon.db.profile.enabledDebugMessages
	else
		profile = profile.frames
		output	= profile

		for i=1,#info-1 do
			if(info[i]~=nil)then
				output = output[info[i]];
			end
		end

		output = output[setting]

		GlobalObject[#GlobalObject] = output

		self:Debug("\n GetOption : "..self:concatLeaves(info))
	end
	return output
end
-- SET--
function configAddon:SetOption(info,value)
	local object = info['arg']
	local parent = info[#info-1]
	local profile = addon.db.profile.frames
	local setting = info[#info]
	local output
	local object	= addon.units --.raid.group[info[3]]

	if(info[1] == "enabledDebugMessages")then 
		self:ToggleDebug()
	else

		for i=1,#info-1 do
			if(info[i]~=nil)then
				profile	= profile[info[i]];
				object	= object[info[i]];
			end
		end

		profile[setting] = value		
	
		if info[1] == "raid" then
			if(setting == "lock") then
				addon:ToggleFrameLock(object,value) 
			elseif(setting == "height" or setting == "width" or setting == "spacing")then
				self:DimensionFrames("raid")
			elseif(setting == "scale")then 
				configAddon:ScaleObject(object,profile,value)
			end
		elseif info[1] == "party" then
		elseif info[1] == "maintank" then
		elseif info[1] == "playerTargets" then
		end

	end
	self:Debug("\n SetOption : "..self:concatLeaves(info))
end

-- VALIDATE--
function configAddon:CheckOption(info)
	return false
end						
function configAddon:CheckUnitOption(info)
	return false
end						
function configAddon:CheckGroupOption(info)
	return false
end						

------------
-- UNITS   --
-- GET--
function configAddon:GetUnitOption(info)
	local object = info['arg'] 
	local parent = info[#info-1]
	local profile = addon.db.profile.frames
	local setting = info[#info]
	local object,output
	local groupid =1

	profile = profile[info[1]].unit
	object	= addon.units[info[1]].unit
	
	output	= profile[setting]

	self:Debug("\n GetUnitOption : "..self:concatLeaves(info))
	
	return output
end
-- SET--
function configAddon:SetUnitOption(info,value)
	local object = info['arg']
	local parent = info[#info-1]
	local profile = addon.db.profile.frames
	local setting = info[#info]
	local object,output
	local groupid =1
	profile = profile[info[1]].unit
	object	= addon.units[info[1]].unit
	
	profile[setting] = value

	self:Debug("\n SetUnitOption : "..self:concatLeaves(info))
end

------------
-- UNITFONTS   --
-- GET--
function configAddon:SetFontType(unitType,profile)
--	for index,group in pairs(self.addon.units.raid.group)do

	for index,unit in pairs(oUF.units)do
		if(unit.groupType == unitType)then
			addon:UpdateFontObjects(unit,profile.name,profile.size,profile.outline)
		end
	end
	
end

function configAddon:GetFontOption(info)
	local object = info['arg'] 
	local parent = info[#info-1]
	local profile = addon.db.profile.frames
	local setting = info[#info]
	local object,output

	profile = profile[info[1]].unit.FontObjects[info[4]].font
	object	= addon.units[info[1]].unit
	
	output	= profile[setting]

	self:Debug("\n GetFontOption : "..self:concatLeaves(info))
	
	return output
end
-- SET--
function configAddon:SetFontOption(info,value)
	local object = info['arg']
	local parent = info[#info-1]
	local profile = addon.db.profile.frames
	local setting = info[#info]
	local object,output
	
	profile = profile[info[1]].unit.FontObjects[info[4]].font

	profile[setting] = value
	
	self:SetFontType(info[1], profile)
	
	self:Debug("\n SetFontOption : "..self:concatLeaves(info))
end

-------------
-- GROUPS  --

-- GET--
function configAddon:GetGroupOption(info)
	local object	= info['arg'] 
	local parent	= info[#info-1]
	local setting	= info[#info]

	local profile	= addon.db.profile.frames --[info[1]].group[info[3]]
	local object	= addon.units --.raid.group[info[3]]
	
	self:Debug("\n GetGroupOption : "..self:concatLeaves(info))

	for i=1,#info-1 do
		if(info[i]~=nil)then
			profile	= profile[info[i]];
			object	= object[info[i]];
		end
	end

	output	= profile[setting]
	
	return output
end

-- SET--
function configAddon:SetGroupOption(info,value)
	local object	= info['arg'] 
	local parent	= info[#info-1]
	local setting	= info[#info]

	local profile	= addon.db.profile.frames
	local object	= addon.units

	self:Debug("\n SetGroupOption : "..self:concatLeaves(info))

	for i=1,#info-1 do
		if(info[i]~=nil)then
			profile	= profile[info[i]];
--			object	= object[info[i]];
		end
	end
	
	profile[setting] = value
	
	if(setting == "showInRaid")then
		addon:toggleGroupLayout()
	end
	
	self.addon:updateRaidFrame()
end

--------------
-- METHODS --
function configAddon:ScaleObject(obj,db,value)
	if obj~=nil then
		obj:SetScale(db.scale)
	end
end


