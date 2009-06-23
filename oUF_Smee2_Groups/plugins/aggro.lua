--------------------------------------------------------------------------------
-- oUF_Banzai
--
-- Colors oUF health bars red when the unit has aggro.
-- Disabled for target, targettarget and targettargettarget.
--
-- If you wish to exclude your frame from being colored, set 'ignoreBanzai' to
-- any non-nil value.
-- i.e.:
--   self.ignoreBanzai = true
-- 
-- If you want to handle the banzai status yourself instead of having the health
-- bar colored red, you can set the 'Banzai' property on your frames to point to
-- a function.
-- i.e.:
--   self.Banzai = function(self, unit, aggro)
--     -- aggro == 1 or 0
--   end
--
--------------------------------------------------------------------------------

local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]

local banzai = LibStub("LibBanzai-2.0")

local ignoredUnits = {
	target = true,
	targettarget = true,
	targettargettarget = true,
}

local function applyBanzai(frame, event, unit, bar)
	if not ignoredUnits[unit] and banzai:GetUnitAggroByUnitId(unit) then
		bar:SetStatusBarColor(1, 0, 0)
	end
end

local function hook(frame)
	if frame.ignoreBanzai or frame.Banzai then return end
	local o = frame.PostUpdateHealth
	frame.PostUpdateHealth = function(...)
		if o then o(...) end
		applyBanzai(...)
	end
end
for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

banzai:RegisterCallback(function(aggro, name, ...)
	for i = 1, select("#", ...) do
		local u = select(i, ...)
		local f = oUF.units[u]
		if f and not ignoredUnits[u] and not f.ignoreBanzai then
			if f.Banzai then
				f:Banzai(u, aggro)
			else
				if aggro == 1 then
					f.Health:SetStatusBarColor(1, 0, 0)
				else
					f:UNIT_MAXHEALTH("OnBanzaiUpdate", f.unit)
				end
			end
		end
	end
end)

