local layoutName = 'oUF_Smee2_Groups'
local addon = _G[layoutName]
local configAddonName = layoutName..'_Config'
_G[configAddonName] = LibStub("AceAddon-3.0"):NewAddon(configAddonName, "AceConsole-3.0")
local configAddon = _G[configAddonName]
configAddon.addon = addon



--======================--
--==<<	ACE3 SETUP	>>==--
--======================--
function configAddon:round(num, idp)
  if idp and idp>0 then  return math.floor(num * mult + 0.5) / (10^idp)  end
  return math.floor(num + 0.5)
end

function configAddon:numberize(val)
	if(val >= 1e3) then
		return ("%.1fk"):format(val / 1e3)
	elseif (val >= 1e6) then 
		return ("%.1fm"):format(val / 1e6)
	else
		return val
	end
end

function configAddon:Debug(msg)
	if addon.db.profile.enabledDebugMessages then
		self:Print("|cFFFFFF00Debug : |r"..tostring(msg))
	end
end

function configAddon:OnInitialize()
end

function configAddon:OnEnable()
	self:Debug("Enabling")
	self:SetupRaidOptions()
--	self:SetupTagOptions(oUF.TagsLogicStrings)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(configAddonName, self.options,layoutName)
	-- RegisterOptions("Profiles", LibStub('AceDBOptions-3.0'):GetOptionsTable(addon.db))
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(configAddonName, layoutName)
	self:Debug("Enabled")
end

function configAddon:OnDisable()
 	self:Debug("Disabling")
   -- Called when the addon is disabled
	local db = self.db.profile
	if db.enabled then
		db.enabled = false
		return
	end
    self:Debug("Disabled")
end

