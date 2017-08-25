local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.ROTATE_PER_SECOND = 400.0;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
end

function C:tick(time)
	local r = CEntity.getRotation(self.entityPtr);
	if not (r == 0.0) then
		local a = self.ROTATE_PER_SECOND * time;
		if a < math.abs(r) then
			if r < 0.0 then
				CEntity.setRotation(self.entityPtr, r + a);
			else
				CEntity.setRotation(self.entityPtr, r - a);
			end
		else
			CEntity.setRotation(self.entityPtr, 0.0);
		end
	end
end

function C:dispose()
	return true;
end
