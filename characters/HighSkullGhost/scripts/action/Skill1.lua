local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	local r = -math.rad(CEntity.getRotation(entityPtr));
	self.sinValue = math.sin(r);
	self.cosValue = math.cos(r);
end

function C:tick(time)
	local v = 500.0;
	local x = self.cosValue * v;
	if CEntity.getDirection(self.entityPtr) == CDirectionEnum.LEFT then
		x = -x;
	end
	CEntity.appendInstantVelocity(self.entityPtr, x, self.sinValue * v);
end

function C:dispose()
	return true;
end
