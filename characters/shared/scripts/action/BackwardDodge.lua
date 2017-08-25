--shared BackwardDodge
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.VELOCITY = 400.0;
	self.UNLOCK_DIS = 100.0;
	self.MAX_DIS = 200.0;
	self.UNLOCK_TIME = self.UNLOCK_DIS / self.VELOCITY;
end

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.entityPtr = entityPtr;

	self.dir = CEntity.getDirection(entityPtr);
	self.curDis = 0.0;

	self.isLoopAction = CGameAction.isLoop(self.actionPtr);
	self.curTime = 0.0;

	if not self.isLoopAction then
		local value = CGameActionData.getSharedData(CGameAction.getActionDataPtr(self.actionPtr), "unlockTime");
		if not (value == "") then
			self.UNLOCK_TIME = tonumber(value);
		end
	end
end

function C:tick(time)
	if time > 0.0 then
		self.curTime = self.curTime + time;

		if self.isLoopAction then
			local entityPtr = self.entityPtr;

			local x = self.VELOCITY * time;
			self.curDis = self.curDis + x;
			
			if self.dir == CDirectionEnum.LEFT then
				CEntity.appendInstantVelocity(entityPtr, self.VELOCITY, 0);
			else
				CEntity.appendInstantVelocity(entityPtr, -self.VELOCITY, 0);
			end
		end
	end
end

function C:isDone(result)
	if self.isLoopAction then
		if self.curDis >= self.MAX_DIS then
			return true, true;
		else
			return false, false;
		end
	else
		return false, false;
	end
end

function C:isCancel(tag, itemPtr)
	if tag == CGameAction.ACTION_JUMP then
		return true;
	end

	if (self.curDis >= self.UNLOCK_DIS) or (self.curTime >= self.UNLOCK_TIME) then
		if tag == CGameAction.ACTION_RUN then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

function C:dispose()
	return true;
end
