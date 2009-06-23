local parent = debugstack():match[[\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]
--[[

	Elements handled:
	 .ReadyCheck [texture]

	Shared:
	 - delayTime [value] default: 10
	 - fadeTime [value] default: 1.5

--]]


local OnFinishUpdate
do
	function OnFinishUpdate(self, elapsed)
		if(self.finish) then
			self.finish = self.finish - elapsed
			if(self.finish <= 0) then
				self.finish = nil
			end
		elseif(self.fade) then
			self.fade = self.fade - elapsed
			if(self.fade <= 0) then
				self.fade = nil
				self:SetScript('OnUpdate', nil)

				for k,v in ipairs(oUF.objects) do
					if(type(v) == 'table' and v.ReadyCheck) then
						v.ReadyCheck:Hide()
					end
				end
			else
				for k,v in ipairs(oUF.objects) do
					if(type(v) == 'table' and v.ReadyCheck) then
						v.ReadyCheck:SetAlpha(self.fade / self.offset)
					end
				end
			end
		end
	end
end

local function READY_CHECK(self, event, name)
	if(not IsRaidLeader() and not IsRaidOfficer() and not IsPartyLeader()) then return end

	local texture = self.ReadyCheck
	if(UnitName(self.unit) == name) then
		texture:SetTexture([=[Interface\RAIDFRAME\ReadyCheck-Ready]=])
	else
		texture:SetTexture([=[Interface\RAIDFRAME\ReadyCheck-Waiting]=])
	end

	texture:SetAlpha(1)
	texture:Show()
end

local function READY_CHECK_CONFIRM(self, event, index, status)
	if(self.id ~= tostring(index)) then return end

	local texture = self.ReadyCheck
	if(status and status == 1) then
		texture:SetTexture([=[Interface\RAIDFRAME\ReadyCheck-Ready]=])
	else
		texture:SetTexture([=[Interface\RAIDFRAME\ReadyCheck-NotReady]=])
	end
end

local function READY_CHECK_FINISHED(self)
	local rc = self.ReadyCheck
	rc.dummy.finish = rc.delayTime or 10
	rc.dummy.fade = rc.fadeTime or 1.5
	rc.dummy.offset = rc.fadeTime or 1.5
	rc.dummy:SetScript('OnUpdate', OnFinishUpdate)
end

local function Enable(self)
	local readycheck = self.ReadyCheck
	if(readycheck) then
		self:RegisterEvent('READY_CHECK', READY_CHECK)
		self:RegisterEvent('READY_CHECK_CONFIRM', READY_CHECK_CONFIRM)
		self:RegisterEvent('READY_CHECK_FINISHED', READY_CHECK_FINISHED)

		readycheck.dummy = CreateFrame('Frame', nil, self)

		return true
	end
end

local function Disable(self)
	if(self.ReadyCheck) then
		self:UnregisterEvent('READY_CHECK', READY_CHECK)
		self:UnregisterEvent('READY_CHECK_CONFIRM', READY_CHECK_CONFIRM)
		self:UnregisterEvent('READY_CHECK_FINISHED', READY_CHECK_FINISHED)
	end
end

oUF:AddElement('ReadyCheck', nil, Enable, Disable)
