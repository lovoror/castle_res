--Zombie
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:_createSkills()
	CAIExecutor.setGuardRange(self.executorPtr, -500.0, -400.0, 600.0, 500.0);

	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -10, -100, 50, 280);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, "skill0", false, false);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 1);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	--CAIMoveTask.setTime(trackTaskPtr, 0.5, 0);
	CAIMoveTask.ignoreWidth(trackTaskPtr, true, false);
	CAIMoveTask.setClearance(trackTaskPtr, 50);

	CAITaskBase.setWeight(trackTaskPtr, 0.5);
	self:_createSkill(0, 5, 0, 0, rangeCondPtr, attackGroupTaskPtr, trackTaskPtr);

	self:_setRndSndCurDelay();
end

function C:tick(time)
	super.tick(self, time);

	local tagPtr = CEntity.getCurrentActionTagPtr(self.entityPtr);
	if CGameActionTag.hasTagByString(tagPtr, CGameAction.ACTION_IDLE, true) or CGameActionTag.hasTagByString(tagPtr, CGameAction.ACTION_RUN, true) then
		self.rndSndCurTime = self.rndSndCurTime + time;
		
		if self.rndSndCurTime >= self.rndSndCurDelay then
			self:_setRndSndCurDelay();
			
			CEntity.playSelfSound(self.entityPtr, "rnd", 1.0, true);
		end
	end
end

function C:_setRndSndCurDelay()
	self.rndSndCurDelay = 6.0 + math.random() * 5.0;
	self.rndSndCurTime = 0.0;
end