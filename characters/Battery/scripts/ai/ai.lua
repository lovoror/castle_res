--Battery
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:ctor()
	self.KEY_GUARDING_AREA_SCALE = "ga";
end

function C:_setChangeDirTask()
end

function C:_createSkills()
	local entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);

	local rangeScale = 1.0;
	local value = CEntity.getSharedData(entityPtr, self.KEY_GUARDING_AREA_SCALE);
	if value ~= "" then
		rangeScale = tonumber(value);
	end

	CAIExecutor.setGuardRange(self.executorPtr, -1400.0 * rangeScale, -1400.0 * rangeScale, 1400.0 * rangeScale, 1400.0 * rangeScale);

	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local skillTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(skillTaskPtr, CGameAction.ACTION_SKILL.."0", false, false);
	CAITaskBase.setStartHandler(skillTaskPtr, "_skill0StartHandler");
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, skillTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 1.0);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(0, 3.0, 0.0, 0.0, nil, attackGroupTaskPtr, nil);
end

function C:_skill0StartHandler(taskPtr)
	local bcPtr = CAIExecutor.getTargetPtr(self.executorPtr, 0);
	local x, y = CBattleCollider.getPosition(bcPtr);
	local randomAngleRange = 5.0;
	local rndAngle = math.rad(-randomAngleRange * 0.5 + math.random() * randomAngleRange);

	local entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);
	CEntity.setSharedData(entityPtr, "targetX", tostring(x));
	CEntity.setSharedData(entityPtr, "targetY", tostring(y));
	CEntity.setSharedData(entityPtr, "randomAngle", tostring(rndAngle));

	if CChapterScene.isNetwork() and CEntity.isHost(entityPtr) then
		CProtocol.sendCptActorBehaviorSync(entityPtr,
		function(baPtr)
			CByteArray.writeFloat(baPtr, x);
			CByteArray.writeFloat(baPtr, y);
			CByteArray.writeFloat(baPtr, rndAngle);
		end);
	end
end

function C:executeSync(bytesPtr)
	local x = CByteArray.readFloat(bytesPtr);
	local y = CByteArray.readFloat(bytesPtr);
	local rndAngle = CByteArray.readFloat(bytesPtr);

	local entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);
	CEntity.setSharedData(entityPtr, "targetX", tostring(x));
	CEntity.setSharedData(entityPtr, "targetY", tostring(y));
	CEntity.setSharedData(entityPtr, "randomAngle", tostring(rndAngle));

	CGameActionController.requestAction(CEntity.getActionControllerPtr(entityPtr), CGameAction.ACTION_SKILL.."0", true, true);
end
