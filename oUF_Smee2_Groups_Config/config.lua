local tableExtend = function(array,table)
	for index,data in pairs(table)do
		array[index] = data
	end
end

local config = oUF_Smee2_Groups_Config

config.options = {
	name = "Global", type = 'group',
	childGroups = "select",
	handler = config,
	args = {
		["enabledDebugMessages"] = {
			name = "Enable Debug Messages in ChatFrame1",desc = "Toggles on/off output of debug messages.",
			type = 'toggle',
			get = "GetOption", set = "SetOption",
		},
	},
}

function config:SetupRaidOptions()
	local options ={
		["Raid"] = {
			name = "Raid", desc = "Raid Frames Setup",
			type = 'group',
			args = { 
					["lock"] = {
						name = "Lock Frame Positions",desc = "Toggles on/off Frame Lock, allowing you to drag the frames around.",
						type = 'toggle', order = 1,
						get = "GetOption", set = "SetOption",
					},
					["scale"] = {
						type = "range", order = 2,
						name = "Frame Scale", desc = "Global frame scale.",
						min = 0.1,	max = 2.0, step = 0.01,
						get = "GetOption", set = "SetOption",
					},
			},
		},	
	}

	for index,group in pairs(self.addon.units.raid.groups)do
		tableExtend(options.Raid.args,{
			['group'..index] = {
				type = "group",
				name = tostring(index),
				args={
					["headerGroupName"] = {
						type = "header",
						name = tostring(index),
					},		
				}
			}
		})
	end

	tableExtend(self.options.args,options)
end

function config:SetupPartyOptions()
--	tableExtend(config.options.args,{
end


