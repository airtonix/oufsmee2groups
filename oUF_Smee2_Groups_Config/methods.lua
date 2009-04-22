local layoutName = 'oUF_Smee2_Groups'
local addon = _G[layoutName]
local configAddonName = layoutName..'_Config'
local configAddon = _G[configAddonName]
local tinsert = table.insert
local db = addon.db.profile
GlobalObject = {}

function configAddon:concatLeaves(branch)
	local picture = ""
		for index,value in pairs(branch) do
			picture = picture .. "["..index.."] - "..tostring(value).."\n"
		end
	return picture
end

-- GET--
function configAddon:GetOption(info)
	local object = info['arg'] 
	local parent = info[#info-1]
	local setting = info[#info]
	local output 
	
	self:Debug("\n GetOption : "..self:concatLeaves(info))
	return output
end
-- SET--
function configAddon:SetOption(info,value)
	local object = info['arg']
	local parent = info[#info-1]
	local setting = info[#info]
	local output 
	
	self:Debug("\n SetOption : "..self:concatLeaves(info))
end


-- VALIDATE--
function configAddon:CheckUnitFrameOption(info)
	return false
end						

