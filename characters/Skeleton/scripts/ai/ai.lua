--Skeleton
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:_createSkills()
	CAIExecutor.setGuardRange(self.executorPtr, -550.0, -400.0, 800.0, 500.0);

	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -10, -100, 60, 320);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, "skill0", false, false);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.1, 0.5);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	--CAIMoveTask.setTime(trackTaskPtr, 0.5, 0);
	CAIMoveTask.ignoreWidth(trackTaskPtr, true, false);
	CAIMoveTask.setClearance(trackTaskPtr, 50);

	CAITaskBase.setWeight(trackTaskPtr, 0.5);
	self:_createSkill(0, 2.5, 0, 0, rangeCondPtr, attackGroupTaskPtr, trackTaskPtr);



	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -150, -100, 200, 100);

	local escapeGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	CAIMoveTask.setTime(trackTaskPtr, 0.8, 0.2);
	CAIMoveTask.setEscape(trackTaskPtr, true);
	CAIMoveTask.setOrientation(trackTaskPtr, CAIMoveTask.ORIENTATION_KEEP);
	CAIMoveTask.setBackMoveSpeedScale(trackTaskPtr, 0.5);
	CAIMoveTask.setBackReverseAnimation(trackTaskPtr, true);
	CAIGroupTaskBase.addTask(escapeGroupTaskPtr, trackTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 1, 0.5);
	CAIGroupTaskBase.addTask(escapeGroupTaskPtr, emptyTaskPtr);

	CAITaskBase.setWeight(escapeGroupTaskPtr, 0.2);
	self:_createSkill(1, 0, 0, 0, rangeCondPtr, escapeGroupTaskPtr, nil);
end
