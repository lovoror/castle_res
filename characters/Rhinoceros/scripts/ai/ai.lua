--LanceWarrior
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:_setChangeDirTask()
end

function C:_createSkills()
	CAIExecutor.setGuardRange(self.executorPtr, -500.0, -500.0, 1000.0, 500.0);

	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, 0.0, -100.0, 450.0, 460.0);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, CGameAction.ACTION_SKILL.."0", false, false);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 1.0);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(0, 5.0, 2.0, 0.0, rangeCondPtr, attackGroupTaskPtr, nil);



	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, 0.0, -100.0, 450.0, 460.0);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, CGameAction.ACTION_SKILL.."1", false, false);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 1.0);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(1, 5.0, 2.0, 0.0, rangeCondPtr, attackGroupTaskPtr, nil);
end
