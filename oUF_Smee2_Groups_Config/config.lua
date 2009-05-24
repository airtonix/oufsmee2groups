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
		["raid"] = {
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
					["group"] =  {
						name = "Groups", desc = "Raid Units Setup",
						type = 'group',
						get = 'GetUnitOption', set = 'SetUnitOption',
						args = { 
						},
					},
					["unit"] =  {
						name = "Units", desc = "Raid Units Setup",
						type = 'group',
						get = 'GetUnitOption', set = 'SetUnitOption',
						args = { 
							["headerSize"] = {
								type = "header",
								name = "Size",
								order=10,
							},
							["height"] = {
								type = "range",
								name = "Height", desc = "Set the height.",
								min = 1, max = 200, step = 1,
								order=11,
							},
							["width"] = {
								type = "range",
								name = "Width", desc = "Set the width.",
								min = 1, max = 600, step = 1,
								order=11,
							},
							
							["headerRangeFading"] = {
								type = "header",
								name = "RangeFading",
								order=30,
							},
							["Range"] = {
								type = "toggle",
								name = "Enabled", desc = "Fading this frame based on your proximity to the unit.",
								order=31,
							},
							["inRangeAlpha"] = {
								type = "range",
								name = "In range opacity", desc = "Set the opacity level of the frame for when this unit is within your range.",
								min = 0, max = 1,
								step = 0.05,
								order=32,
							},
							["outsideRangeAlpha"] = {
								type = "range",
								name = "Out of range opacity", desc = "Set the opacity level of the frame for when this unit is out of your range.",
								min = 0, max = 1, step = 0.05,
								order=33,
							},
							
							["spacing"] = {
								type = "range",
								name = "Width", desc = "Set the width.",
								min = 1, max = 32, step = 1,
								order=44,
							},
							["growth"] = {
								type = "select",
								name = "Growth Direction",
								desc = "Each singular frame wil stack on the previous frames edge described here.",
								values=config.frameAnchorPoints,
								order=46,
							},
						},
					}			
			},
		},	
	}

	for index,group in pairs(self.addon.units.raid.group)do
		tableExtend(options.raid.args.group.args,{
			[tostring(index)] = {
				type = "group",
				name = tostring(index),
				disabled ='CheckGroupOption',
				get = "GetGroupOption", set = "SetGroupOption",
				args={
					["headerGroupName"] = {
						type		= "header",
						name	= tostring(index),
						order	= 1,
					},		
					["enabled"] = {
						name	= "Enabled",
						desc		= "Makes the group visible",
						type		= 'toggle',
						order	= 1,
						arg		= group,
					},
					["anchorX"] = {
						type		= "range",
						name	= "Horizontal Position", desc = "Set the horizontal position.",
						min		= -400, max = 400, step = 1,
						arg		= group,
						order	= 5,
					},
					["anchorY"] = {
						type		= "range",
						name	= "Vertical Position", desc = "Set the vertical position.",
						min		= -400, max = 400, step = 1,
						arg		= group,
						order	= 5,
					},
					["anchorToPoint"] = {
						type		= "select",
						name	= "To edge...",
						desc		= "Which edge to attach To",
						values	= config.frameAnchorPoints,
						arg		= group,
						order	= 6,					
					},
					["anchorFromPoint"] = {
						type = "select",
						name = "From edge...", desc = "Which edge to attach from.",
						values = config.frameAnchorPoints,						
						arg = group,
						order = 7,
					},
					["anchorTo"] = {
						type = "select",
						name = "Anchor To Frame...",
						desc = "Which object to anchor to.",
						values=config.RaidFramesToAnchorTo,
						arg = group,
						order=27,					
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


