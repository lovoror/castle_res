--HighSkullGhost
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:_createSkills()
	CAIExecutor.setGuardRange(self.executorPtr, -800.0, -800.0, 800.0, 800.0);

	CAISearchTargetsTask.setBlockEnabled(self.searchTargetsTaskPtr, false);


	--skill0
	local rangeCondPtr = self:createCPtrs(CAITargetInCircleCondition);
	CAITargetInCircleCondition.setRadius(rangeCondPtr, 480.0);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, CGameAction.ACTION_SKILL.."0", false, false);
	CAITaskBase.setStartHandler(skillTaskPtr, "_skill0StartHandler");
	CAITaskBase.setImmediate(skillTaskPtr, true);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, CGameAction.ACTION_SKILL.."1", false, false);
	CAITaskBase.setImmediate(skillTaskPtr, true);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 1.0);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	--CAIMoveTask.setTime(trackTaskPtr, 0.5, 0);
	CAIMoveTask.ignoreWidth(trackTaskPtr, true, false);
	CAIMoveTask.setClearance(trackTaskPtr, 200.0);

	CAITaskBase.setWeight(trackTaskPtr, 0.5);
	self:_createSkill(0, 1.0, 0.0, 0.0, rangeCondPtr, attackGroupTaskPtr, trackTaskPtr);


	--skill1
	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	CAIMoveTask.setFree(trackTaskPtr, true);
	CAIMoveTask.setClearance(trackTaskPtr, 280.0);

	self:_createSkill(1, 0.0, 0.0, 0.0, nil, trackTaskPtr, nil);


	--skill2
	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -150, -100, 250, 200);

	local escapeGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	CAIMoveTask.setTime(trackTaskPtr, 0.6, 1.0);
	CAIMoveTask.setFree(trackTaskPtr, true);
	CAIMoveTask.setEscape(trackTaskPtr, true);
	CAIMoveTask.setOrientation(trackTaskPtr, CAIMoveTask.ORIENTATION_KEEP);
	CAIMoveTask.setBackMoveSpeedScale(trackTaskPtr, 0.7);
	CAIGroupTaskBase.addTask(escapeGroupTaskPtr, trackTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 0.5);
	CAIGroupTaskBase.addTask(escapeGroupTaskPtr, emptyTaskPtr);

	CAITaskBase.setWeight(escapeGroupTaskPtr, 0.3);
	self:_createSkill(2, 2.0, 0.0, 0.0, rangeCondPtr, escapeGroupTaskPtr, nil);


	--skill3
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.25, 0.8);

	self:_createSkill(3, 0.0, 0.0, 0.0, nil, emptyTaskPtr, nil);
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

function C:_tick(time)
	if self.first == nil then
		self.first = true;
		return;
	end

	local executorPtr = self.executorPtr;

	if CAIExecutor.getNumTargets(executorPtr) > 0 then
		if CAIExecutor.runCondition(executorPtr, self.dirCondPtr) then
			CAIExecutor.setTask(executorPtr, self.actionBehaviorPtr);
		else
			CAIExecutor.setTask(executorPtr, self.dirTaskPtr);
		end
	end
end
