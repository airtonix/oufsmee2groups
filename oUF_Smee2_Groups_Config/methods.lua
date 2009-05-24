local layoutName = 'oUF_Smee2_Groups'
local addon = _G[layoutName]
local configAddonName = layoutName..'_Config'
local configAddon = _G[configAddonName]
local tinsert = table.insert
local db = addon.db.profile
GlobalObject = {}
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

-------------
--  NORMAL --

-- GET--
function configAddon:GetOption(info)
	local object = info['arg'] 
	local parent = info[#info-1]
	local profile = addon.db.profile.frames
	local setting = info[#info]
	local object,output

	if info[1] == "raid" then
		-- raid stuff blah
		profile = profile.raid
		output	= profile[setting]
	elseif info[1] == "party" then
	elseif info[1] == "maintank" then
	elseif info[1] == "playerTargets" then
	end
	
--	self:Debug("\n GetOption : "..self:concatLeaves(info))
	
	return output
end
-- SET--
function configAddon:SetOption(info,value)
	local object = info['arg']
	local parent = info[#info-1]
	local profile = addon.db.profile.frames
	local setting = info[#info]
	local object,output

	if info[1] == "raid" then
		object	= addon.units.raid
		profile = profile.raid
		-- raid stuff blah
		profile[setting] = value
		if(setting == "lock") then
			configAddon:ToggleFrameLock(object,profile,value) 
		elseif(setting == "scale")then 
			configAddon:ScaleObject(object,profile,value)
		end
	elseif info[1] == "party" then
	elseif info[1] == "maintank" then
	elseif info[1] == "playerTargets" then
	end

--	self:Debug("\n SetOption : "..self:concatLeaves(info))
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

--	self:Debug("\n GetOption : "..self:concatLeaves(info))
	
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

--	self:Debug("\n SetOption : "..self:concatLeaves(info))
end

-------------
-- GROUPS  --

-- GET--
function configAddon:GetGroupOption(info)
	local object	= info['arg'] 
	local parent	= info[#info-1]
	local setting	= info[#info]

	local profile	= addon.db.profile.frames
	local object	= addon.units

	self:Debug("\n GetOption : "..self:concatLeaves(info))

	for i=1,#info-1 do
		print(info[i].."- [object]type : "..type(object[info[i]]) .. "- [profile]type : "..type(profile[info[i]]))

		GlobalObject = {profile, object}
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
	local object = info['arg']
	local parent = info[#info-1]
	local profile = addon.db.profile.frames
	local setting = info[#info]
	local object,output
	local groupid =1
	profile = profile[info[1]].group[groupid]
	object	= addon.units[info[1]].group[groupid]
	
	profile[setting] = value

--	self:Debug("\n SetOption : "..self:concatLeaves(info))
end
--------------
-- METHODS --
function configAddon:ScaleObject(obj,db,value)
	if obj~=nil then
		obj:SetScale(db.scale)
	end
end

function configAddon:ToggleFrameLock(obj,db,value)	
	if value == false then	
		print("unlocking")
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
		print("locking")
		obj:SetUserPlaced(false)
		obj:SetMovable(false);
		obj:RegisterForDrag("");
		obj:SetBackdropColor(unpack(addon.db.profile.colors.backdropColors))
		obj:SetWidth(obj:GetWidth()-10)
	end

end
