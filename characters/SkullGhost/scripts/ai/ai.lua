--SkullGhost
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:_createSkills()
	CAIExecutor.setGuardRange(self.executorPtr, -500.0, -500.0, 500.0, 500.0);

	CAISearchTargetsTask.setBlockEnabled(self.searchTargetsTaskPtr, false);

	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	CAIMoveTask.setFree(trackTaskPtr, true);
	CAIMoveTask.setTargetOffset(trackTaskPtr, 0.0, 0.0);

	self:_createSkill(0, 0, 0, 0, rangeCondPtr, trackTaskPtr, nil);
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
