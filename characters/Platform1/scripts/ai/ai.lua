--Platform1
local C = registerClassAuto(getClass(AI_PACKAGE, AI_BASE));

function C:ctor()
	self.STATE_IDLE = 0;
	self.STATE_READY_DROP = 1;
	self.STATE_DROP = 2;
	self.STATE_DROP_WAIT = 3;
	self.STATE_DROP_BACK = 4;

	self.IDLE_WAIT_TIME = 0.2;
	self.DROP_WAIT_TIME = 1.0;
end

function C:awake(executorPtr)
	super.awake(self, executorPtr);

	self.hasCollisions = false;

	local entityPtr = CAIExecutor.getEntityPtr(executorPtr);
	self.entityPtr = entityPtr;

	local actionControllerPtr = CEntity.getActionControllerPtr(entityPtr);
	self.actionControllerPtr = actionControllerPtr;

	CEntity.setOneWayType(entityPtr, COneWayType.UP);
	CEntity.setUpdateBodyShapeEnabled(entityPtr, false);
	CGameActionController.setActionUpdateEnabled(actionControllerPtr, false);
	self:_setBodyShape();

	self.state = self.STATE_IDLE;
	self.curTime = 0.0;
	self.curActionPtr = nil;

	local scriptRef = CAIExecutor.getScriptRef(executorPtr);

	local stepHandlerPtr = CScriptBodyStepHandler.create();
	CScriptBodyStepHandler.setCollisionTopHandler(stepHandlerPtr, scriptRef, "_collisionTopHandler");
	CEntity.setBodyStepHandler(entityPtr, stepHandlerPtr);
end

function C:tick(time)
	while time > 0.0 do
		time = time - self:_motion(time);
	end

	self.hasCollisions = false;
end

function C:_motion(time)
	if self.hasCollisions then
		if self.state == self.STATE_IDLE then
			self.state = self.STATE_READY_DROP;
			self.curTime = 0.0;
			return 0.0;
		elseif self.state == self.STATE_READY_DROP then
			self.curTime = self.curTime + time;
			local d = self.curTime - self.IDLE_WAIT_TIME;
			if d >= 0.0 then
				self.state = self.STATE_DROP;
				self.curActionPtr = CGameActionController.changeAction(self.actionControllerPtr, CGameAction.ACTION_SKILL.."0", false, true);
				self.curTime = 0.0;
				CEntity.setBodyShape(self.entityPtr, CBodyShapeType.NONE);
				return time - d;
			end
		end
	else
		if self.state == self.STATE_READY_DROP then
			self.state = self.STATE_IDLE;
		end
	end

	if self.state == self.STATE_DROP then
		self.curTime = self.curTime + time;
		local d = self.curTime - CGameAnimate.getDuration(CGameAction.getAnimatePtr(self.curActionPtr));
		if d >= 0.0 then
			self.state = self.STATE_DROP_WAIT;
			self.curActionPtr = CGameActionController.changeAction(self.actionControllerPtr, CGameAction.ACTION_SKILL.."1", false, true);
			self.curTime = 0.0;
			return time - d;
		else
			CGameAction.tick(self.curActionPtr, time);
		end
	elseif self.state == self.STATE_DROP_WAIT then
		self.curTime = self.curTime + time;
		local d = self.curTime - self.DROP_WAIT_TIME;
		if d >= 0.0 then
			self.state = self.STATE_DROP_BACK;
			self.curActionPtr = CGameActionController.changeAction(self.actionControllerPtr, CGameAction.ACTION_SKILL.."2", false, true);
			self.curTime = 0.0;
			return time - d;
		end
	elseif self.state == self.STATE_DROP_BACK then
		self.curTime = self.curTime + time;
		local d = self.curTime - CGameAnimate.getDuration(CGameAction.getAnimatePtr(self.curActionPtr));
		if d >= 0.0 then
			self.state = self.STATE_IDLE;
			self.curActionPtr = CGameActionController.changeAction(self.actionControllerPtr, CGameAction.ACTION_IDLE, false, true);
			self.curTime = 0.0;
			self:_setBodyShape();
			return time - d;
		else
			CGameAction.tick(self.curActionPtr, time);
		end
	end

	return time;
end

function C:_collisionTopHandler(entityPtr)
	self.hasCollisions = true;
end

function C:_setBodyShape()
	CEntity.setBodyShape(self.entityPtr, CBodyShapeType.BOX, -40.0, 0.0, 40.0, 40.0, 1.0, 1.0);
end
