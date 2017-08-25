--LionPillar
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:ctor()
	self.KEY_GUARDING_AREA_SCALE = "ga";
end

function C:awake(executorPtr)
	super.awake(self, executorPtr);

	local entityPtr = CAIExecutor.getEntityPtr(executorPtr);
	self.entityPtr = entityPtr;
	CEntity.setBodyStepHandler(entityPtr, CScriptBodyStepHandler.create());
end

function C:_createSkills()
	local entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);

	local rangeScale = 1.0;
	local value = CEntity.getSharedData(entityPtr, self.KEY_GUARDING_AREA_SCALE);
	if value ~= "" then
		rangeScale = tonumber(value);
	end

	CAIExecutor.setGuardRange(self.executorPtr, -500.0 * rangeScale, -500.0 * rangeScale, 1000.0 * rangeScale, 500.0 * rangeScale);

	local rangeCondPtr = self:createCPtrs(CAITargetInAABBoxCondition);
	CAITargetInAABBoxCondition.setAABB(rangeCondPtr, 0.0 * rangeScale, -100.0 * rangeScale, 500.0 * rangeScale, 280.0 * rangeScale);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, CGameAction.ACTION_SKILL.."0", false, false);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 1.0);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(0, 5.0, 2.0, 0.0, rangeCondPtr, attackGroupTaskPtr, nil);
end