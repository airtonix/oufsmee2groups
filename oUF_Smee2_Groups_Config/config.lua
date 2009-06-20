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
	local db = self.addon.db.profile
	local options ={
		["raid"] = {
			name = "Raid", desc = "Raid Frames Setup",
			type = 'group',
			get = "GetOption", set = "SetOption",
			args = { 
					["lock"] = {
						name = "Lock Frame Positions",desc = "Toggles on/off Frame Lock, allowing you to drag the frames around.",
						type = 'toggle', order = 1,
					},
					["scale"] = {
						type = "range", order = 2,
						name = "Frame Scale", desc = "Global frame scale.",
						min = 0.1,	max = 2.0, step = 0.01,
					},
					
					["group"] =  {
						name = "Groups", desc = "Raid Units Setup",
						type = 'group',
						args = { 
						},
					},
					["unit"] =  {
						name = "Units", desc = "Raid Units Setup",
						type = 'group',
						args = { },
					}			
			},
		},	
	}

	tableExtend(options.raid.args.unit.args,config:SetupUnitOptions(db.frames.raid))
	
	tableExtend(options.raid.args.group.args,
		config:SetupGroupOptions(
			db.frames.raid,
			self.addon.groupMap.raid,
			self.addon.units.raid.group,
			config.RaidFramesToAnchorTo
		)
	)
	
	tableExtend(self.options.args,options)
end

function config:SetupPartyOptions()

	local db = self.addon.db.profile
	local options ={
		["party"] = {
			name = "Party", desc = "Party Frames Setup",
			type = 'group',
			get = "GetOption", set = "SetOption",
			args = { 
				["lock"] = {
					name = "Lock Frame Positions",desc = "Toggles on/off Frame Lock, allowing you to drag the frames around.",
					type = 'toggle', order = 1,
				},
				["scale"] = {
					type = "range", order = 2,
					name = "Frame Scale", desc = "Global frame scale.",
					min = 0.1,	max = 2.0, step = 0.01,
				},
				["group"] =  {
					name = "Group", desc = "Party Group Setup",
					type = 'group',
					args = { },
				},
				["unit"] =  {
					name = "Units", desc = "Party Units Setup",
					type = 'group',
					args = { },
				}			
			},
		},	
	}

	tableExtend(options.party.args.unit.args,config:SetupUnitOptions(db.frames.party))
	
	tableExtend(
		options.party.args.group.args,
		config:SetupGroupOptions(
			db.frames.party,
			self.addon.groupMap.party,
			({
				players = self.addon.units.party.group.players,
--				pets = self.addon.units.party.group.pets,
--				targets = self.addon.units.party.group.targets,
			}),
			config.PartyFramesToAnchorTo
		 )
	)
	
	tableExtend(self.options.args,options)
end

function config:SetupGroupOptions(groupDb,groupMap,groupObjects,frameAnchorObjects)
	local output = {}
	local group
	
	for index,label in ipairs(groupMap)do
		group = groupObjects[label]
		tableExtend(output,{
			[label] = {
				type = "group",
				name = label,
				order = index,
				disabled ='CheckGroupOption',
				get = "GetGroupOption", set = "SetGroupOption",
				args={
					["headerGroupName"] = {
						type		= "header",
						name	= label,
						order	= 1,
					},		
					["enabled"] = {
						name	= "Enabled",
						desc		= "Makes the group visible",
						type		= 'toggle',
						order	= 2,
						arg		= group,
					},
					["headerGroupPosition"] = {
						type		= "header",
						name	= "Position",
						order	= 3,
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
						order	= 6,
					},
					["anchorToPoint"] = {
						type		= "select",
						name	= "To edge...",
						desc		= "Which edge to attach To",
						values	= config.frameAnchorPoints,
						arg		= group,
						order	= 7,					
					},
					["anchorFromPoint"] = {
						type = "select",
						name = "From edge...", desc = "Which edge to attach from.",
						values = config.frameAnchorPoints,						
						arg = group,
						order = 8,
					},
					["anchorTo"] = {
						type = "select",
						name = "Anchor To Frame...",
						desc = "Which object to anchor to.",
						values = frameAnchorObjects,
						arg = group,
						order=9,					
					},
					["headerGroupUnits"] = {
						type		= "header",
						name	= "Units",
						order	= 20,
					},	
					["columnSpacing"] = {
						type		= "range",
						name	= "Column Spacing", desc = "Set spacing between each unit in this group.",
						min		= -20, max = 20, step = .2,
						arg		= group,
						order	= 21,
					},
					["unitsPerColumn"] = {
						type		= "range",
						name	= "Units per Column", desc = "Number of Units per Column in this group.",
						min		= 1, max = 40, step = 1,
						arg		= group,
						order	= 22,
					},
					["maxColumns"] = {
						type		= "range",
						name	= "Maximum Columns", desc = "Maximum Number of Columns in this group.",
						min		= 1, max = 8, step = 1,
						arg		= group,
						order	= 23,
					},
					["maxColumns"] = {
						type		= "range",
						name	= "Maximum Columns", desc = "Maximum Number of Columns in this group.",
						min		= 1, max = 8, step = 1,
						arg		= group,
						order	= 23,
					},
					
				}
			}
		})
		
		if(group and group.groupType and group.groupType == "party")then
			tableExtend(output[label].args,{
					["showInRaid"] = {
						name	= "Show in Raid",
						desc		= "Makes the group visible while in a raid.",
						type		= 'toggle',
						order	= 1,
						arg		= group,
					},
				
			})
		end
	end

	
	return output
end

function config:SetupUnitOptions(groupDb)
	local db = self.addon.db.profile
	local output = {
		["FontObjects"] =  {
			name = "Texts", desc = "Text Elements",
			type = 'group',
			args = {},
		},
		["textures"] =  {
			name = "Textures", desc = "Text Elements",
			type = 'group',
			args = {
				["statusbar"] = {
					type = "select",
					name = "Statusbar",
					dialogControl = 'LSM30_Statusbar',					disabled = not self.addon.SharedMediaActive,	 				desc = "Texture to use on the bars.",
					values = AceGUIWidgetLSMlists.statusbar,
					order=26,
				},
			},
		},
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
			name = "Spacing", desc = "Set the spacing between units (does not apply to spacing between groups).",
			min = 1, max = 32, step = 1,
			order=44,
		},
		["growth"] = {
			type = "select",
			name = "Growth Direction",
			desc = "Each singular frame wil stack on the previous frames edge described here.",
			values=self.frameAnchorPoints,
			order=46,
		},
	}

	local label
	for index,object in pairs(groupDb.unit.FontObjects)do
		label = tostring(index);
		tableExtend(output.FontObjects.args,{
			[label] = {
				type = "group",
				name = tostring(index),
				disabled ='CheckGroupOption',
				get = "GetFontOption", set = "SetFontOption",
				args = {
					["header"..label] = {
						type = "header",
						name = "FontObject : "..label,
						order=1,
					},
					["name"] = {
						type = "select",
						name = "Fontface",
						dialogControl = 'LSM30_Font',						disabled = not config.addon.SharedMediaActive,		 				desc = "Fontface to use on the bars.",
						values = AceGUIWidgetLSMlists.font,
						order=16,
					},						
					["outline"] = {
						type = "select",
						name = "Outline", desc = "font options, typically outline types",
						values = config.fontOutlineTypes,	
						order = 17,
					},
					["size"] = {
						name = "Font Size",desc = "Change the font size, note this is affected by your ui-scale in video settings.",
						type = "range", min = 1,max = 48.0, step = 0.1, 
						order = 18,
					},
				
				},
			}			
		})
	end

	return output 
end
