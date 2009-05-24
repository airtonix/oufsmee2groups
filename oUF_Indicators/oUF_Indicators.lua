local _,playerClass = UnitClass("player")


local numberize = function(val)
    if(val >= 1e3) then
        return ("%.1fk"):format(val / 1e3)
    elseif (val >= 1e6) then
        return ("%.1fm"):format(val / 1e6)
    else
        return val
    end
end
 
function round(num, idp)
    if idp and idp>0 then
        local mult = 10^idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
	
--++++++++++++++++++++++++++--
--         BUFFS
--++++++++++++++++++++++++++--

oUF.indicators={
	fonts = {
		default = "Interface\\Addons\\oUF_Indicators\\Fonts\\visitor.ttf",
	},
	fontObjects = {
		["DEFAULT"] = {
			offsets = {x = 0, y = 0},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "CENTER",
		},
		["TOPLEFT"] = {
			offsets = {x = 0, y = 3},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "LEFT",
		},
		["TOP"] = {
			offsets = {x = 0, y = 3},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "CENTER",
		},
		["TOPRIGHT"] = {
			offsets = {x = 3, y = 3},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "RIGHT",
		},
		["LEFT"] = {
			offsets = {x = 0, y = 0},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "LEFT",
		},
		["CENTER"] = {
			offsets = {x = 0, y = 0},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "CENTER",
		},
		["RIGHT"] = {
			offsets = {x = 3, y = 0},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "RIGHT",
		},
		["BOTTOMLEFT"] = {
			offsets = {x = 0, y = -3},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "LEFT",
		},
		["BOTTOM"] = {
			offsets = {x = 0, y = -3},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "CENTER",
		},
		["BOTTOMRIGHT"] = {
			offsets = {x = 3, y = -3},
			size = 8.5,
			name = "default",
			outline = "OUTLINE",
			alignH = "RIGHT",
		},
	},
	classLayout = {
		DEATHKNIGHT = {
			["TOP"] = "",
			["TOPLEFT"] = "[tree]",
			["TOPRIGHT"] = "[gotw]",
			["BOTTOMLEFT"] = "[lb]",
			["BOTTOMRIGHT"] = "[rejuv][regrow]"
		},
		DRUID = {
			["TOP"] = "",
			["TOPLEFT"] = "[tree]",
			["TOPRIGHT"] = "[gotw]",
			["BOTTOMLEFT"] = "[lb]",
			["BOTTOMRIGHT"] = "[rejuv][regrow]"
		},
		PRIEST = {
			["TOP"] = "[painsupress][powerinfusion][guardspirit][twilighttorment]",
			["TOPLEFT"] = "[pws][ws][aegis]",
			["TOPRIGHT"] = "[spirit][shad][fort][fear][tree]",
			["BOTTOMLEFT"] = "[inspiration][grace][pom]",
			["BOTTOMRIGHT"] = "[rnw][gotn][rejuv][regrow]"
		},
		PALADIN = {
			["TOP"] = "",
			["TOPLEFT"] = "",
			["TOPRIGHT"] = "",
			["BOTTOMLEFT"] = "",
			["BOTTOMRIGHT"] = ""
		},
		SHAMAN = {
			["TOP"] = "",
			["TOPLEFT"] = "",
			["TOPRIGHT"] = "",
			["BOTTOMLEFT"] = "",
			["BOTTOMRIGHT"] = ""
		},
		WARLOCK = {
			["TOP"] = "",
			["TOPLEFT"] = "",
			["TOPRIGHT"] = "",
			["BOTTOMLEFT"] = "",
			["BOTTOMRIGHT"] = ""
		},
		MAGE = {
			["TOP"] = "",
			["TOPLEFT"] = "",
			["TOPRIGHT"] = "",
			["BOTTOMLEFT"] = "",
			["BOTTOMRIGHT"] = ""
		},
		ROGUE = {
			["TOP"] = "",
			["TOPLEFT"] = "",
			["TOPRIGHT"] = "",
			["BOTTOMLEFT"] = "",
			["BOTTOMRIGHT"] = ""
		},
		WARRIOR = {
			["TOP"] = "",
			["TOPLEFT"] = "",
			["TOPRIGHT"] = "",
			["BOTTOMLEFT"] = "",
			["BOTTOMRIGHT"] = ""
		},
	}
}

function createIndicatorGroup(object,anchor,objectAnchor,fontDB, tags)
    group = objectAnchor:CreateFontString(nil, "OVERLAY")
    group:SetFont(oUF.indicators.fonts[fontDB.name], fontDB.size, fontDB.outline)
    group:SetPoint(anchor, objectAnchor, anchor, fontDB.offsets.x, fontDB.offsets.y)
    group:SetJustifyH(fontDB.alignH)
    object:Tag(group,tags)
    group:Show()
    return group
end


function generateAuraGroups(object)
    if not object.AuraIndicator then return end
    if not oUF.indicators then return end
    if not object.FontObjects then object.FontObjects = {} end
    
    for index,tags in pairs(oUF.indicators.classLayout[playerClass])do
        local auraGroup = createIndicatorGroup(object, index, object.Health, oUF.indicators.fontObjects[index], tags)
        object.FontObjects[index] = {
        	name = "Aura Indicator Group : ".. index,
        	object = auraGroup
        }
    end
end
 
--for index, object in ipairs(oUF.objects) do  generateAuraGroups(object) end

oUF:RegisterInitCallback(generateAuraGroups)
