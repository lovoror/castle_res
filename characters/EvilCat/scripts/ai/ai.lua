--EvilCat
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:_createSkills()
	CAIExecutor.setGuardRange(self.executorPtr, -800.0, -600.0, 800.0, 600.0);

	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -400.0, -200.0, 800.0, 400.0);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, CGameAction.ACTION_SKILL.."0", false, false);
	CAITaskBase.setStartHandler(skillTaskPtr, "_skill0StartHandler");
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.1, 0.5);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(0, 0.0, 2.0, 0.0, rangeCondPtr, attackGroupTaskPtr, nil, 0);



	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -20.0, -150.0, 800.0, 400.0);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, CGameAction.ACTION_SKILL.."4", false, false);
	CAITaskBase.setStartHandler(skillTaskPtr, "_skill0StartHandler");
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.1, 0.5);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(1, 0.0, 2.0, 0.0, rangeCondPtr, attackGroupTaskPtr, nil, 0);



	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -20.0, -150.0, 800.0, 300.0);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, CGameAction.ACTION_SKILL.."5", false, false);
	CAITaskBase.setStartHandler(skillTaskPtr, "_skill0StartHandler");
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.1, 0.5);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(2, 0.0, 2.0, 0.0, rangeCondPtr, attackGroupTaskPtr, nil, 0);
end

function C:_skill0StartHandler(taskPtr)
	local bcPtr = CAIExecutor.getTargetPtr(self.executorPtr, 0);

	local x, y
	if CisNullptr(bcPtr) then
		x, y = CEntity.getPosition(self.entityPtr);
	else
		x, y = CBattleCollider.getPosition(bcPtr);
	end

	local entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);
	CEntity.setSharedData(entityPtr, "targetX", tostring(x));
	CEntity.setSharedData(entityPtr, "targetY", tostring(y));
end
