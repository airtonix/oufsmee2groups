oUF_Smee2_Groups_Settings = {
	profile = {
		minimapicon = {
			hide = false,
			minimapPos = 225,
		},
		enabledDebugMessages = false,
		enabled = true,
		colors = {
			class = {
				["DEATHKNIGHT"] = { 0.77, 0.12, 0.23 },
				["DRUID"] = { 1.0 , 0.49, 0.04 },
				["HUNTER"] = { 0.67, 0.83, 0.45 },
				["MAGE"] = { 0.41, 0.8 , 0.94 },
				["PALADIN"] = { 0.96, 0.55, 0.73 },
				["PRIEST"] = { 1.0 , 1.0 , 1.0 },
				["ROGUE"] = { 1.0 , 0.96, 0.41 },
				["SHAMAN"] = { 0,0.86,0.73 },
				["WARLOCK"] = { 0.58, 0.51, 0.7 },
				["WARRIOR"] = { 0.78, 0.61, 0.43 },
			},
			backdropColors = {0,0,0,1},
			castbars = {
				bgColor = {1,1,1,1},
				StatusBarColor = {1,1,1,1},
				BackdropColor = {.2,.2,0,1},
				Backdrop = {
					bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
					insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
				},
				safezoneColor = {1, .2, .2, .5}
			},
			runes={
				[1] = {0.77, 0.12, 0.23},
				[2] = {0.3, 0.8, 0.1},
				[3] = {0, 0.4, 0.7},
				[4] = {0.2, 0.2, 0.2},
			},
		},
		classification = {
			worldboss = '%s |cffD7BEA5Boss|r',
			rareelite = '%s |cff%02x%02x%02x%s|r|cffD7BEA5+ R|r',
			elite = '%s |cff%02x%02x%02x%s|r|cffD7BEA5+|r',
			rare = '%s |cff%02x%02x%02x%s|r |cffD7BEA5R|r',
			normal = '%s |cff%02x%02x%02x%s|r',
			trivial = '%s |cff%02x%02x%02x%s|r',
		},
		textures = {
			backgrounds = {
				default = {
					bgFile = "Interface\\BUTTONS\\WHITE8x8", tile = true, tileSize = 16,
					insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
				},
			},
			statusbars = {
				groupsGradient	= "Interface\\Addons\\oUF_Smee2_Groups\\media\\statusbars\\gradient",
			},
			borders = {
				groupsBorder = "Interface\\Addons\\oUF_Smee2_Groups\\media\\borders\\border",
			},
		},
		auras = {
			playerScale = 1.4,
			otherScale = 1,
			timers = {
				enabled = true,
				UsingMMSS = false,
				useEnlargedFonts = true,
				values = {
					DAY = 86400,
					HOUR = 3600,
					MINUTE = 60,
					SHORT = 5
				},
				cooldownTimerStyle = {
					short = {r = 1, g = 0, b = 0, s = .98}, -- <= 5 seconds
					secs = {r = 1, g = 1, b = 0.4, s = 1}, -- < 1 minute
					mins = {r = 0.8, g = 0.8, b = 0.9, s = 1}, -- >= 1 minute
					hrs = {r = 0.8, g = 0.8, b = 0.9, s = 1}, -- >= 1 hr
					days = {r = 0.8, g = 0.8, b = 0.9, s = 1}, -- >= 1 day
				},
			},
		},
		healComm = {
			heallines = true,
			printAmount = true,
			renderType = "bar", -- 'bars' or 'text'
		},	
		ressurectionIdicator = {
			spells = {
				id = {
					["2006"]= "Resurrection",
					["2010"] ="Resurrection",
					["10880"] ="Resurrection",
					["10881"] ="Resurrection",
					["20770"] ="Resurrection",
					["25435"] ="Resurrection",
					["48171"] ="Resurrection",

					["7328"] ="Redemption",
					["10322"] ="Redemption",
					["10324"] ="Redemption",
					["20772"] ="Redemption",
					["20773"] ="Redemption",
					["48949"] ="Redemption",
					["48950"] ="Redemption",

					["50769"] ="Revive",
					["50768"] ="Revive",
					["50767"] ="Revive",
					["50766"] ="Revive",
					["50765"] ="Revive",
					["50764"] ="Revive",
					["50763"] ="Revive",

					["20484"] ="Rebirth",
					["20739"] ="Rebirth",
					["20742"] ="Rebirth",
					["20747"] ="Rebirth",
					["20748"] ="Rebirth",
					["26994"] ="Rebirth",
					["48477"] ="Rebirth",

					["2008"] ="Ancestral Spirit", 
					["20609"] ="Ancestral Spirit",
					["20610"] ="Ancestral Spirit",
					["20776"] ="Ancestral Spirit",
					["20777"] ="Ancestral Spirit",
					["25590"] ="Ancestral Spirit",
					["49277"] ="Ancestral Spirit",	
				},
				name = {
					["Ancestral Spirit"] = true, 
					["Rebirth"] = true,
					["Revive"] = true,
					["Redemption"] = true,
					["Resurrection"] = true,
					["Mind Vision"] = true,
				},
			}
		},
		frames = {
			playerTargets={},
			maintank = {
				locked = true,
				scale = 1,
				anchorFromPoint = "TOPLEFT",
				anchorTo = "UIParent",
				anchorToPoint = "TOPLEFT",
				anchorX = 10,
				anchorY = -85,
				padding = 3,
				margin = 15,
				group = {
					enabled						= true,
					anchorFromPoint		= "TOPLEFT",
					anchorTo						= "UIParent",
					anchorToPoint			= "TOPLEFT",
					anchorX						= 4,
					anchorY						= 4,
					columnAnchorPoint		= "LEFT",
					columnSpacing			= 2,
					unitsPerColumn			= 5,
					maxColumns				= 8,
					visible							= true,
					groupFilter					= 1,
				},
				unit = {
					spacing = 4,
					width = 135,
					height =25,
					anchorFromPoint = "LEFT",
					barFading = false,
					range = {
						enabled = false,
						inside = 1,
						outside = .5,
					},
					Portrait = {
						enabled = false,
						modelScale = 4.5,
					},
					FontObjects={
						health = {
							enabled = true,
							anchorToPoint = "CENTER",
							anchorTo = "Health",
							anchorFromPoint = "CENTER",
							anchorX = 0,
							anchorY = 0,
							justifyH = "CENTER",
							justifyV = "MIDDLE",
							tag = "[raidhp]",
							desc = "Name",
							font = {
								size =9,
								name = 'visitor',
								outline = '',
							}
						},
						threat = {
							enabled = true,
							anchorToPoint = "BOTTOM",
							anchorTo = "Health",
							anchorFromPoint = "BOTTOM",
							anchorX = 0,
							anchorY = 0,
							justifyH = "CENTER",
							justifyV = "BOTTOM",
							tag = "[raidthreat]",
							desc = "Threat",
							font = {
								size = 8.5,
								name = 'default',
								outline = '',
							}
						},
					},
					bars = {
						health = {
							enabled = true,
							width = 51,
							height = 51,
							colorDisconnected = true,
							colorClass = false,
							colorTapping = true,
							colorReaction = true,
							dependantOnFrameSize = true,
							classFilter = false,
							reverse = false,
							bgColor = {1,1,1,.3},
							StatusBarColor = {0.25,0.25,0.25,1},
							BackdropColor = {0,0,0,1},
							Backdrop = "default",
						},
						power = {
							enabled = false,
							width = 3,
							height = 50,
							colorDisconnected = false,
							colorClass = true,
							colorTapping = false,
							colorReaction = false,
							dependantOnFrameSize = true,
							classFilter = false,
							reverse = false,
							bgColor = {1,1,1,.3},
							StatusBarColor = {0.25,0.25,0.25,1},
							BackdropColor = {0,0,0,1},
							Backdrop = "default",
						},
					},
					Decurse = {
						Backdrop = false,
						BackDropAlpha = 1,
						Filter = false,
						Icon = true,
					},	
					disallowVehicleSwap = true,
					textures = {
						background = 'default',
						statusbar = 'groupsGradient',
						border = 'groupsBorder',
					},
				},
			},
			mainassist = {
				locked = true,
				scale = 1,
				anchorFromPoint = "TOPLEFT",
				anchorTo = "maintank",
				anchorToPoint = "BOTTOMLEFT",
				anchorX = 0,
				anchorY = -10,
				padding = 3,
				margin = 15,
				group = {
					enabled						= true,
					anchorFromPoint		= "TOPLEFT",
					anchorTo						= "maintank",
					anchorToPoint			= "BOTTOMLEFT",
					anchorX						= 4,
					anchorY						= 4,
					columnAnchorPoint		= "LEFT",
					columnSpacing			= 2,
					unitsPerColumn			= 5,
					maxColumns				= 8,
					visible							= true,
					groupFilter					= 1,
				},
				unit = {
					spacing = 4,
					width = 135,
					height =25,
					anchorFromPoint = "LEFT",
					barFading = false,
					range = {
						enabled = false,
						inside = 1,
						outside = .5,
					},
					Portrait = {
						enabled = false,
						modelScale = 4.5,
					},
					FontObjects={
						health = {
							enabled = true,
							anchorToPoint = "CENTER",
							anchorTo = "Health",
							anchorFromPoint = "CENTER",
							anchorX = 0,
							anchorY = 0,
							justifyH = "CENTER",
							justifyV = "MIDDLE",
							tag = "[raidhp]",
							desc = "Name",
							font = {
								size =9,
								name = 'visitor',
								outline = '',
							}
						},
						threat = {
							enabled = true,
							anchorToPoint = "BOTTOM",
							anchorTo = "Health",
							anchorFromPoint = "BOTTOM",
							anchorX = 0,
							anchorY = 0,
							justifyH = "CENTER",
							justifyV = "BOTTOM",
							tag = "[raidthreat]",
							desc = "Threat",
							font = {
								size = 8.5,
								name = 'default',
								outline = '',
							}
						},
					},
					bars = {
						health = {
							enabled = true,
							width = 51,
							height = 51,
							colorDisconnected = true,
							colorClass = false,
							colorTapping = true,
							colorReaction = true,
							dependantOnFrameSize = true,
							classFilter = false,
							reverse = false,
							bgColor = {1,1,1,.3},
							StatusBarColor = {0.25,0.25,0.25,1},
							BackdropColor = {0,0,0,1},
							Backdrop = "default",
						},
						power = {
							enabled = false,
							width = 3,
							height = 50,
							colorDisconnected = false,
							colorClass = true,
							colorTapping = false,
							colorReaction = false,
							dependantOnFrameSize = true,
							classFilter = false,
							reverse = false,
							bgColor = {1,1,1,.3},
							StatusBarColor = {0.25,0.25,0.25,1},
							BackdropColor = {0,0,0,1},
							Backdrop = "default",
						},
					},
					Decurse = {
						Backdrop = false,
						BackDropAlpha = 1,
						Filter = false,
						Icon = true,
					},	
					disallowVehicleSwap = true,
					textures = {
						background = 'default',
						statusbar = 'groupsGradient',
						border = 'groupsBorder',
					},
				},
			},
			raid = {
				locked = true,
				scale = 1,
				anchorFromPoint = "BOTTOM",
				anchorTo = "UIParent",
				anchorToPoint = "BOTTOM",
				anchorX = 0,
				anchorY = 310,
				padding = 3,
				margin = 15,
				group = {
					["One"] = {
						enabled						= true,
						anchorFromPoint		= "BOTTOMLEFT",
						anchorTo						= "parent",
						anchorToPoint			= "BOTTOMLEFT",
						anchorX						= 4,
						anchorY						= 4,
						columnAnchorPoint		= "LEFT",
						columnSpacing			= 2,
						unitsPerColumn			= 5,
						maxColumns				= 8,
						visible							= true,
						groupFilter					= 1,
					},
					["Two"] = {
						enabled						= true,
						anchorFromPoint		= "BOTTOMLEFT",
						anchorTo						= "One",
						anchorToPoint			= "TOPLEFT",
						anchorX						= 0,
						anchorY						= 2,
						columnAnchorPoint		= "LEFT",
						columnSpacing			= 2,
						unitsPerColumn			= 5,
						maxColumns				= 8,
						visible							= true,
						groupFilter					= 2,
					},
					["Three"] = {
						enabled						= true,
						anchorFromPoint		= "BOTTOMLEFT",
						anchorTo						= "Two",
						anchorToPoint			= "TOPLEFT",
						anchorX						= 0,
						anchorY						= 2,
						columnAnchorPoint		= "LEFT",
						unitsPerColumn			= 5,
						maxColumns				= 8,
						visible							= true,						
						groupFilter					= 3,
					},
					["Four"] = {
						enabled						= true,
						anchorFromPoint		= "BOTTOMLEFT",
						anchorTo						= "Three",
						anchorToPoint			= "TOPLEFT",
						anchorX						= 0,
						anchorY						= 2,
						columnAnchorPoint		= "LEFT",
						columnSpacing			= 2,
						unitsPerColumn			= 5,
						maxColumns				= 8,
						visible							= true,
						groupFilter					= 4,
					},
					["Five"] = {
						enabled						= true,
						anchorFromPoint		= "BOTTOMLEFT",
						anchorTo						= "Four",
						anchorToPoint			= "TOPLEFT",
						anchorX						= 0,
						anchorY						= 2,
						columnAnchorPoint		= "LEFT",
						columnSpacing			= 2,
						unitsPerColumn			= 5,
						maxColumns				= 8,
						visible							= true,
						groupFilter					= 5,
					},
					["Six"] = {
						enabled						= true,
						anchorFromPoint		= "BOTTOMLEFT",
						anchorTo						= "Five",
						anchorToPoint			= "TOPLEFT",
						anchorX						= 0,
						anchorY						= 2,
						columnAnchorPoint		= "LEFT",
						columnSpacing			= 2,
						unitsPerColumn			= 5,
						maxColumns				= 8,
						visible							= true,
						groupFilter					= 6,
					},
					["Seven"] = {
						enabled						= true,
						anchorFromPoint		= "BOTTOMLEFT",
						anchorTo						= "Six",
						anchorToPoint			= "TOPLEFT",
						anchorX						= 0,
						anchorY						= 2,
						columnAnchorPoint		= "LEFT",
						columnSpacing			= 2,
						unitsPerColumn			= 5,
						maxColumns				= 8,
						visible							= true,
						groupFilter					= 7,
					},
					["Eight"] = {
						enabled						= true,
						anchorFromPoint		= "BOTTOMLEFT",
						anchorTo						= "Seven",
						anchorToPoint			= "TOPLEFT",
						anchorX						= 0,
						anchorY						= 2,
						columnAnchorPoint		= "LEFT",
						columnSpacing			= 2,
						unitsPerColumn			= 5,
						maxColumns				= 8,
						visible							= true,
						groupFilter					= 8,
					},
				},
				unit = {
					spacing = 4,
					width = 35,
					height =25,
					anchorFromPoint = "LEFT",
					barFading = false,
					range = {
						enabled = false,
						inside = 1,
						outside = .5,
					},
					Portrait = {
						enabled = false,
						modelScale = 4.5,
					},
					FontObjects={
						health = {
							enabled = true,
							anchorToPoint = "CENTER",
							anchorTo = "Health",
							anchorFromPoint = "CENTER",
							anchorX = 0,
							anchorY = 0,
							justifyH = "CENTER",
							justifyV = "MIDDLE",
							tag = "[raidhp]",
							desc = "Name",
							font = {
								size =9,
								name = 'visitor',
								outline = '',
							}
						},
						threat = {
							enabled = true,
							anchorToPoint = "BOTTOM",
							anchorTo = "Health",
							anchorFromPoint = "BOTTOM",
							anchorX = 0,
							anchorY = 0,
							justifyH = "CENTER",
							justifyV = "BOTTOM",
							tag = "[raidthreat]",
							desc = "Threat",
							font = {
								size = 8.5,
								name = 'default',
								outline = '',
							}
						},
					},
					bars = {
						health = {
							enabled = true,
							width = 51,
							height = 51,
							colorDisconnected = true,
							colorClass = false,
							colorTapping = true,
							colorReaction = true,
							dependantOnFrameSize = true,
							classFilter = false,
							reverse = false,
							bgColor = {1,1,1,.3},
							StatusBarColor = {0.25,0.25,0.25,1},
							BackdropColor = {0,0,0,1},
							Backdrop = "default",
						},
						power = {
							enabled = false,
							width = 3,
							height = 50,
							colorDisconnected = false,
							colorClass = true,
							colorTapping = false,
							colorReaction = false,
							dependantOnFrameSize = true,
							classFilter = false,
							reverse = false,
							bgColor = {1,1,1,.3},
							StatusBarColor = {0.25,0.25,0.25,1},
							BackdropColor = {0,0,0,1},
							Backdrop = "default",
						},
					},
					Decurse = {
						Backdrop = false,
						BackDropAlpha = 1,
						Filter = false,
						Icon = true,
					},	
					disallowVehicleSwap = true,
					textures = {
						background = 'default',
						statusbar = 'groupsGradient',
						border = 'groupsBorder',
					},
				},
			},
			
			party = {
					group = {
						players = {
							enabled					= true,
							locked					= true,
							showInRaid 				= true,
							anchorFromPoint		 	= "BOTTOM",
							anchorTo 				= "UIParent",
							anchorToPoint 			= "BOTTOM",
							anchorX 				= 0,
							anchorY 				= 230,
							columnAnchorPoint		= "TOP",
							columnSpacing			= 2,
							unitsPerColumn			= 5,
							maxColumns				= 8,
							columnSpacing			= 3,					
						},
						targets	= {},
						pets = {},
					},
					unit = {
						spacing = 3,
						width = 35,
						height =35,
						anchorFromPoint = "LEFT",
						scale = 1,
						barFading = false,
						range = {
							enabled = false,
							inside = 1,
							outside = .5,
						},
						Portrait = {
							enabled = false,
							modelScale = 4.5,
						},
						FontObjects={
							health = {
								enabled = true,
								anchorToPoint = "CENTER",
								anchorTo = "Health",
								anchorFromPoint = "CENTER",
								anchorX = 0,
								anchorY = 0,
								justifyH = "CENTER",
								justifyV = "MIDDLE",
								tag = "[raidhp]",
								desc = "Name",
								font = {
									size = 8.5,
									name = 'default',
									outline = '',
								}
							},
							threat = {
								enabled = true,
								anchorToPoint = "BOTTOM",
								anchorTo = "Health",
								anchorFromPoint = "BOTTOM",
								anchorX = 0,
								anchorY = 0,
								justifyH = "CENTER",
								justifyV = "BOTTOM",
								tag = "[raidthreat]",
								desc = "Threat",
								font = {
									size = 8.5,
									name = 'default',
									outline = '',
								}
							},
						},
						bars = {
							health = {
								enabled = true,
								width = 51,
								height = 51,
								colorDisconnected = true,
								colorClass = true,
								colorReaction = true,
								dependantOnFrameSize = true,
								classFilter = false,
								reverse = false,
								bgColor = {1,1,1,.3},
								StatusBarColor = {0.25,0.25,0.25,1},
								BackdropColor = {0,0,0,1},
								Backdrop = "default",
							},
							power = {
								enabled = false,
								width = 3,
								height = 50,
								colorDisconnected = false,
								colorClass = true,
								colorTapping = false,
								colorReaction = false,
								dependantOnFrameSize = true,
								classFilter = false,
								reverse = false,
								bgColor = {1,1,1,.3},
								StatusBarColor = {0.25,0.25,0.25,1},
								BackdropColor = {0,0,0,1},
								Backdrop = "default",
							},
						},
						Decurse = {
							Backdrop = true,
							BackDropAlpha = 1,
							Filter = true,
							Icon = false,
						},		
						disallowVehicleSwap = true,
						textures = {
							background = 'default',
							statusbar = 'groupsGradient',
							border = 'groupsBorder',
						},
					},
					target = {
						yOffSet = 3,
						xOffSet = 3,
						width = 35,
						height =35,
						anchorFromPoint = "LEFT",
						scale = 1,
						barFading = false,
						range = {
							enabled = false,
							inside = 1,
							outside = .5,
						},
						Portrait = {
							enabled = false,
							modelScale = 4.5,
						},
						FontObjects={
							health = {
								enabled = true,
								anchorToPoint = "CENTER",
								anchorTo = "Health",
								anchorFromPoint = "CENTER",
								anchorX = 0,
								anchorY = 0,
								justifyH = "CENTER",
								justifyV = "MIDDLE",
								tag = "[raidhp]",
								desc = "Name",
								font = {
									size = 8.5,
									name = 'default',
									outline = '',
								}
							},
							threat = {
								enabled = true,
								anchorToPoint = "BOTTOM",
								anchorTo = "Health",
								anchorFromPoint = "BOTTOM",
								anchorX = 0,
								anchorY = 0,
								justifyH = "CENTER",
								justifyV = "BOTTOM",
								tag = "[threat]",
								desc = "Threat",
								font = {
									size = 8.5,
									name = 'default',
									outline = '',
								}
							},
						},
						bars = {
							health = {
								enabled = true,
								width = 51,
								height = 51,
								colorDisconnected = true,
								colorClass = true,
								colorReaction = true,
								dependantOnFrameSize = true,
								classFilter = false,
								reverse = false,
								bgColor = {1,1,1,.3},
								StatusBarColor = {0.25,0.25,0.25,1},
								BackdropColor = {0,0,0,1},
								Backdrop = "default",
							},
							power = {
								enabled = false,
								width = 3,
								height = 50,
								colorDisconnected = false,
								colorClass = true,
								colorTapping = false,
								colorReaction = false,
								dependantOnFrameSize = true,
								classFilter = false,
								reverse = false,
								bgColor = {1,1,1,.3},
								StatusBarColor = {0.25,0.25,0.25,1},
								BackdropColor = {0,0,0,1},
								Backdrop = "default",
							},
						},
						Decurse = {
							Backdrop = true,
							BackDropAlpha = 1,
							Filter = false,
							Icon = true,
						},					
						disallowVehicleSwap = true,
					},
					pet = {
						yOffSet = 3,
						xOffSet = 3,
						width = 35,
						height =35,
						anchorFromPoint = "LEFT",
						scale = 1,
						barFading = false,
						range = {
							enabled = false,
							inside = 1,
							outside = .5,
						},
						Portrait = {
							enabled = false,
							modelScale = 4.5,
						},
						FontObjects={
							health = {
								enabled = true,
								anchorToPoint = "CENTER",
								anchorTo = "Health",
								anchorFromPoint = "CENTER",
								anchorX = 0,
								anchorY = 0,
								justifyH = "CENTER",
								justifyV = "MIDDLE",
								tag = "[raidhp]",
								desc = "Name",
								font = {
									size = 8.5,
									name = 'default',
									outline = '',
								}
							},
							threat = {
								enabled = true,
								anchorToPoint = "BOTTOM",
								anchorTo = "Health",
								anchorFromPoint = "BOTTOM",
								anchorX = 0,
								anchorY = 0,
								justifyH = "CENTER",
								justifyV = "BOTTOM",
								tag = "[threat]",
								desc = "Threat",
								font = {
									size = 8.5,
									name = 'default',
									outline = '',
								}
							},
						},
						bars = {
							health = {
								enabled = true,
								width = 51,
								height = 51,
								colorDisconnected = true,
								colorClass = true,
								colorReaction = true,
								dependantOnFrameSize = true,
								classFilter = false,
								reverse = false,
								bgColor = {1,1,1,.3},
								StatusBarColor = {0.25,0.25,0.25,1},
								BackdropColor = {0,0,0,1},
								Backdrop = "default",
							},
							power = {
								enabled = false,
								width = 3,
								height = 50,
								colorDisconnected = false,
								colorClass = true,
								colorTapping = false,
								colorReaction = false,
								dependantOnFrameSize = true,
								classFilter = false,
								reverse = false,
								bgColor = {1,1,1,.3},
								StatusBarColor = {0.25,0.25,0.25,1},
								BackdropColor = {0,0,0,1},
								Backdrop = "default",
							},
						},
						Decurse = {
							Backdrop = true,
							BackDropAlpha = 1,
							Filter = false,
							Icon = true,
						},					
						disallowVehicleSwap = true,
					},
				},
			
		}
	}
}
