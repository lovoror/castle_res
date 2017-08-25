--Banshee
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:_createSkills()
	CAIExecutor.setGuardRange(self.executorPtr, -600.0, -600.0, 600.0, 600.0);

	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -10.0, 0.0, 80.0, 100.0);

	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	CAIMoveTask.setCondition(trackTaskPtr, self.dirCondPtr, false);
	CAIMoveTask.setFree(trackTaskPtr, true);
	CAIMoveTask.setOrientation(trackTaskPtr, CAIMoveTask.ORIENTATION_KEEP);
	CAIMoveTask.setTargetOffset(trackTaskPtr, -70.0, 50.0);
	CAIMoveTask.setBackMoveSpeedScale(trackTaskPtr, 0.5);
	CAIMoveTask.setTime(trackTaskPtr, 1.0, 2.0);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	--CAIGroupTaskBase.addTask(attackGroupTaskPtr, trackTaskPtr);
	local actionTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(actionTaskPtr, CGameAction.ACTION_SKILL.."0", false, false);
	CAIActionTask.setImmediate(actionTaskPtr, true);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, actionTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 0.5);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(0, 5.0, 0.0, 0.0, rangeCondPtr, attackGroupTaskPtr, trackTaskPtr);



	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, 10.0, -600.0, 600.0, -10.0);

	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	CAIMoveTask.setCondition(trackTaskPtr, self.dirCondPtr, false);
	CAIMoveTask.setFree(trackTaskPtr, true);
	CAIMoveTask.setOrientation(trackTaskPtr, CAIMoveTask.ORIENTATION_KEEP);
	CAIMoveTask.setTargetOffset(trackTaskPtr, -300.0, 300.0);
	CAIMoveTask.setBackMoveSpeedScale(trackTaskPtr, 0.5);
	CAIMoveTask.setTime(trackTaskPtr, 1.0, 2.0);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local actionTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(actionTaskPtr, CGameAction.ACTION_SKILL.."1", false, false);
	CAITaskBase.setStartHandler(actionTaskPtr, "_skill1StartHandler");
	CAIActionTask.setImmediate(actionTaskPtr, true);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, actionTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 0.5);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(1, 8.0, 0.0, 0, rangeCondPtr, attackGroupTaskPtr, trackTaskPtr);



	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -150, -120, 250, 280);

	local escapeGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	CAIMoveTask.setTime(trackTaskPtr, 0.8, 1.0);
	CAIMoveTask.setFree(trackTaskPtr, true);
	CAIMoveTask.setEscape(trackTaskPtr, true);
	CAIMoveTask.setOrientation(trackTaskPtr, CAIMoveTask.ORIENTATION_KEEP);
	CAIMoveTask.setBackMoveSpeedScale(trackTaskPtr, 0.5);
	CAIGroupTaskBase.addTask(escapeGroupTaskPtr, trackTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 0.5);
	CAIGroupTaskBase.addTask(escapeGroupTaskPtr, emptyTaskPtr);

	CAITaskBase.setWeight(escapeGroupTaskPtr, 0.3);
	self:_createSkill(2, 0.0, 0.0, 0.0, rangeCondPtr, escapeGroupTaskPtr, nil);
end

function C:_skill1StartHandler(taskPtr)
	local targetPtr = CAIExecutor.getTargetPtr(self.executorPtr, 0);
	local entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);
	if CisNullptr(targetPtr) then
		CEntity.setSharedData(entityPtr, "targetX", "");
		CEntity.setSharedData(entityPtr, "targetY", "");
	else
		local x, y = CBattleCollider.getPosition(targetPtr);
		CEntity.setSharedData(entityPtr, "targetX", tostring(x));
		CEntity.setSharedData(entityPtr, "targetY", tostring(y));
	end
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
