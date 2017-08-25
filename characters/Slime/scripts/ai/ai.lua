--Slime
local C = registerClassAuto(getClass(AI_PACKAGE, AI_BASE));

function C:ctor()
	self.STEP_INIT = -1;
	self.STEP_WAIT = 0;
	self.STEP_MOVE = 1;
	self.STEP_WAIT2 = 2;
	self.STEP_MOVE2 = 3;

	self.KEY_TURN_BACK_DISTANCE = "dis";

	self.DEFAULT_TURN_BACK_DISTANCE = 1000;
end

function C:awake(executorPtr)
	super.awake(self, executorPtr);

	self.entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);

	self.unctrlCondPtr = self:createCPtrs(CAIUncontrollableCondition);

	self.standCondPtr = self:createCPtrs(CAIPhysicsStateCondition);
	CAIPhysicsStateCondition.setState(self.standCondPtr, CPhysicsStateEnum.STAND);

	local waitTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(waitTaskPtr, 0.5, 0.5);
	self.waitTaskPtr = waitTaskPtr;

	local moveTaskPtr = self:createCPtrs(CAIMoveTask);
	self.moveTaskPtr = moveTaskPtr;

	self.step = self.STEP_INIT;
	self.startX = 0.0;
	self.dir = CEntity.getDirection(self.entityPtr);
	self.distance = self.DEFAULT_TURN_BACK_DISTANCE;

	local value = CEntity.getSharedData(self.entityPtr, self.KEY_TURN_BACK_DISTANCE);
	if value ~= "" then
		self.distance = tonumber(value);
	end

	self.maxX = CBaseTileMap.getMaxWidth(CChapterScene.getTileMapPtr());
end

function C:tick(time)
	local executorPtr = self.executorPtr;
	local entityPtr = self.entityPtr;

	if CAIExecutor.runCondition(executorPtr, self.unctrlCondPtr) or (not CAIExecutor.runCondition(executorPtr, self.standCondPtr)) then
		--CAIExecutor.clearTask(executorPtr);
		return;
	end

	if CEntity.isHost(entityPtr) then
		if CAIExecutor.hasTask(executorPtr) then
			local result = CAIExecutor.runTask(executorPtr, time);

			if self.step == self.STEP_MOVE or self.step == self.STEP_MOVE2 then
				if time ~= 0.0 and result then
					local hx, hy = CEntity.getHitBlockVector(entityPtr);
					local px, py = CEntity.getPosition(entityPtr);
					local isBreak = false;

					if self.step == self.STEP_MOVE then
						if self.dir == CDirectionEnum.LEFT then
							isBreak = hx < 0.0 or px <= 0.0;
						else
							isBreak = hx > 0.0 or px >= self.maxX;
						end
					else
						if self.dir == CDirectionEnum.RIGHT then
							isBreak = hx < 0.0 or px <= 0.0;
						else
							isBreak = hx > 0.0 or px >= self.maxX;
						end
					end

					if isBreak then
						CAIExecutor.clearTask(executorPtr);
					end
				end
			end
		else
			local nextTaskPtr = nil;
			if self.step == self.STEP_INIT then
				self.step = self.STEP_WAIT;

				nextTaskPtr = self.waitTaskPtr;
			elseif self.step == self.STEP_WAIT then
				self.step = self.STEP_MOVE;

				nextTaskPtr = self.moveTaskPtr;
				local x, y = CEntity.getPosition(entityPtr);
				self.startX = x;
				--CAIMoveTask.setBackReverseAnimation(elf.moveTaskPtr, false);

				if self.dir == CDirectionEnum.LEFT then
					CAIMoveTask.setMoveTo(self.moveTaskPtr, true, x - self.distance, y);
				else
					CAIMoveTask.setMoveTo(self.moveTaskPtr, true, x + self.distance, y);
				end
			elseif self.step == self.STEP_MOVE then
				self.step =self.STEP_WAIT2;

				nextTaskPtr = self.waitTaskPtr;
			elseif self.step == self.STEP_WAIT2 then
				self.step = self.STEP_MOVE2;

				nextTaskPtr = self.moveTaskPtr;
				local x, y = CEntity.getPosition(entityPtr);
				self.startX = x;
				--CAIMoveTask.setBackReverseAnimation(elf.moveTaskPtr, true);

				if self.dir == CDirectionEnum.LEFT then
					CAIMoveTask.setMoveTo(self.moveTaskPtr, true, x + self.distance, y);
				else
					CAIMoveTask.setMoveTo(self.moveTaskPtr, true, x - self.distance, y);
				end
			elseif self.step == self.STEP_MOVE2 then
				self.step = self.STEP_INIT;
			end

			if nextTaskPtr ~= nil then
				CAIExecutor.setTask(executorPtr, nextTaskPtr);
			end
		end
	else
		CAIExecutor.runTask(executorPtr, time);
	end
end
