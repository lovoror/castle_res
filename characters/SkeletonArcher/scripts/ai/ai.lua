--SkeletonArcher
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:ctor()
	self.KEY_GUARDING_AREA_SCALE = "ga";
	self.KEY_NOT_MOVE = "nm";
end

function C:_createSkills()
	local entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);

	local rangeScale = 1.0;
	local value = CEntity.getSharedData(entityPtr, self.KEY_GUARDING_AREA_SCALE);
	if value ~= "" then
		rangeScale = tonumber(value);
	end

	CAIExecutor.setGuardRange(self.executorPtr, -1000.0 * rangeScale, -1000.0 * rangeScale, 1000.0 * rangeScale, 1000.0 * rangeScale);

	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -30.0 * rangeScale, -600.0 * rangeScale, 800.0 * rangeScale, 600.0 * rangeScale);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, "skill0", false, false);
	CAITaskBase.setStartHandler(skillTaskPtr, "_atkStartHandler");
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.1, 0.5);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	local canMove = CEntity.getSharedData(entityPtr, self.KEY_NOT_MOVE) ~= "1";

	local trackTaskPtr = nil;
	if canMove then
		trackTaskPtr = self:createCPtrs(CAIMoveTask);
		--CAIMoveTask.setTime(trackTaskPtr, 0.5, 0);
		CAIMoveTask.ignoreWidth(trackTaskPtr, true, false);
		CAIMoveTask.setClearance(trackTaskPtr, 450.0 * rangeScale);
		CAITaskBase.setWeight(trackTaskPtr, 0.5);
	end

	self:_createSkill(0, 2.5, 0.0, 1.5, rangeCondPtr, attackGroupTaskPtr, trackTaskPtr);


	if canMove then
		local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
		CAITargetInAABBoxCondition.setAABB(rangeCondPtr, -150.0 * rangeScale, -100.0 * rangeScale, 300.0 * rangeScale, 200.0 * rangeScale);

		local escapeGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
		local trackTaskPtr = self:createCPtrs(CAIMoveTask);
		CAIMoveTask.setTime(trackTaskPtr, 0.8, 0.2);
		CAIMoveTask.setEscape(trackTaskPtr, true);
		CAIMoveTask.setOrientation(trackTaskPtr, CAIMoveTask.ORIENTATION_KEEP);
		CAIMoveTask.setBackMoveSpeedScale(trackTaskPtr, 0.5);
		CAIMoveTask.setBackReverseAnimation(trackTaskPtr, true);
		CAIGroupTaskBase.addTask(escapeGroupTaskPtr, trackTaskPtr);
		local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
		CAIEmptyTask.setTime(emptyTaskPtr, 1.0, 0.5);
		CAIGroupTaskBase.addTask(escapeGroupTaskPtr, emptyTaskPtr);

		CAITaskBase.setWeight(escapeGroupTaskPtr, 0.2);
		self:_createSkill(1, 0.0, 0.0, 0.0, rangeCondPtr, escapeGroupTaskPtr, nil);
	end
end

function C:_atkStartHandler(taskPtr)
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
