--DynamicAnimationSpeedRun
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(actionPtr);
	
	self.standardVelocity = nil;
	local dataPtr = CGameAction.getActionDataPtr(actionPtr);
	local value = CGameActionData.getSharedData(dataPtr, "standardVelocity");
	if value ~= "" then
		self.standardVelocity = tonumber(value);
	end
end

function C:tick(time)
	if self.standardVelocity ~= nil then
		local spd = CEntity.getSPD(self.entityPtr);
		local sx, sy = CEntity.getScale(self.entityPtr);
		if sy ~= 0.0 then
			spd = spd / sy;
		end

		local speed = spd / self.standardVelocity;
		
		CGameAnimate.setSpeed(self.animatePtr, speed);
	end
end

function C:dispose()
	return true;
end