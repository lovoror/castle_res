local C = registerClass(AI_PACKAGE, AI_TRIGGER_HELPER, nil);

function C:ctor()
	self:setID(0);
end

function C:setID(id)
	self.id = id;
	self.generatorPtr = nil;
end

function C:doTrigger(name, value)
	if self.id ~= 0 then
		local ptr = self:_getGeneratorPtr();
		if not CisNullptr(ptr) then
			CEntityGenerator.doTrigger(ptr, name, value);
		end
	end
end

function C:_getGeneratorPtr()
	if self.generatorPtr == nil then
		self.generatorPtr = CChapterScene.getEntityGeneratorPtr(self.id);
	end
	return self.generatorPtr;
end



local C = registerClass(AI_PACKAGE, AI_BIND_TARGET, nil);

function C:ctor()
	self:setID(0);
end

function C:setID(id)
	self.id = id;
	self.generatorPtr = nil;
end

function C:getTargetPtr()
	if self.id ~= 0 then
		local ptr = self:_getGeneratorPtr();
		if CisNullptr(ptr) then
			return nil;
		else
			return CEntityGenerator.getEntityPtr(ptr, 0);
		end
	end
end

function C:_getGeneratorPtr()
	if self.generatorPtr == nil then
		self.generatorPtr = CChapterScene.getEntityGeneratorPtr(self.id);
	end
	return self.generatorPtr;
end



--AIBase
local C = registerClass(AI_PACKAGE, AI_SKILL, nil);

function C:ctor(selfCD, publicCD, CDGroup)
	self.runningCD = 0.0;
	self.selfCD = selfCD;
	self.publicCD = publicCD;
	self.CDGroup = CDGroup;
end



local C = registerClass(AI_PACKAGE, AI_SKILL_MANAGER, nil);

function C:ctor()
	self.skills = {};
end

function C:tick(time)
	for K, V in pairs(self.skills) do
		if V.runningCD > 0.0 then
			V.runningCD =  V.runningCD - time;
		end
	end

end

function C:setSkill(name,  selfCD, publicCD, runningCD, CDGroup)
	if publicCD == nil then publicCD = 0.0; end
	if runningCD == nil then runningCD = 0.0; end
	if CDGroup == nil then CDGroup = -1; end

	local skill = self.skills[name];
	if skill == nil then
		skill = newClass(AI_PACKAGE, AI_SKILL, selfCD, publicCD, CDGroup);
		self.skills[name] = skill;
	end
	skill.runningCD = runningCD;
end

function C:getCurrentCD(name)
	local skill = self.skills[name];

	if skill == nil then
		return 0.0;
	else
		return skill.runningCD;
	end
end

function C:runSkill(name)
	local skill = self.skills[name];
	if skill == nil then return; end

	if skill.runningCD < skill.selfCD then skill.runningCD = skill.selfCD; end

	local cd = skill.publicCD;
	if cd > 0.0 then
		local group = skill.CDGroup;
		if group >= 0 then
			for K, V in pairs(self.skills) do
				if V.CDGroup == group and V.runningCD < cd then
					V.runningCD =  cd;
				end
			end
		end
	end
end

function C:tryRunSkill(name)
	if self:getCurrentCD(name) <= 0.0 then
		self:runSkill(name);
		return true;
	else
		return false;
	end
end



local C = registerClassAuto();

function C:ctor()
	self.CPtrs = {};
end

--====================================

function C:editorAwake(comPtr)
	self.editorComponentPtr = comPtr;
end

function C:editorDeserialized()
end

function C:editorDefaultData()
	return "";
end

function C:editorPublish()
	CChapterEditorComponentBehavior.setPublishDataFromSource(self.editorComponentPtr);
end

function C:editorDispose()
end

function C:editorWidgetCreate(widgetPtr)
	self.editorWidgetPtr = widgetPtr;
	return "";
end

function C:editorWidgetRefresh()
end

function C:editorClean(resultPtr)
end

function C:editorWidgetDispose()
end

--=====================================

function C:awake(executorPtr)
	self.executorPtr = executorPtr;
	self.entityPtr = CAIExecutor.getEntityPtr(executorPtr);

	self.isHost = true;
	if CChapterScene.isNetwork() then
		self.isHost = CEntity.isHost(self.entityPtr);
	end

	self.numCPtrs = 0;
end

function C:start()
end

function C:createCPtrs(clazz)
	self.numCPtrs = self.numCPtrs + 1;
	local ptr = clazz.create(self.numCPtrs);
	self.CPtrs[self.numCPtrs] = ptr;
	CAIExecutor.registerObject(self.executorPtr, ptr);
	return ptr;
end

function C:trigger(name, value)
end

function C:destroy()
	for i = 1, self.numCPtrs do
		local ptr = self.CPtrs[i];
		if ptr ~= nil then
			CAIObject.setDelete(ptr);
			self.CPtrs[i] = nil;
		end
	end
	self.numCPtrs = 0;

	return true;
end

function C:tick(time)
	local executorPtr = self.executorPtr;

	if self.unctrlCondPtr ~= nil and CAIExecutor.runCondition(executorPtr, self.unctrlCondPtr) then
		--if self.isHost then
			CAIExecutor.clearTask(executorPtr);
		--end
		return;
	end

	if self.isHost then
		if self.searchTargetsTaskPtr ~= nil then CAIExecutor.runOnceTask(executorPtr, self.searchTargetsTaskPtr); end

		while (not CAIExecutor.runTask(executorPtr, time)) do
			self:_tick(time);
			if (not CAIExecutor.hasTask(executorPtr)) then
				break;
			end
		end
	else
		CAIExecutor.runTask(executorPtr, time);
	end
end

function C:_tick(time)
end

function C:tileMapTicked(time)
end

function C:ticked(time)
end

function C:attacking(attackDataPtr)
	return 0;
end

function C:suffering(attackDataPtr)
	return 0;
end

function C:attacked(attackDataPtr)
end

function C:suffered(attackDataPtr)
end

function C:damage(attackDataPtr)
	return false;
end

function C:injured(attackDataPtr)
	return false;
end

function C:collectSync(bytesPtr)
end

function C:executeSync(bytesPtr)
end

function C:trigger(name, value)
end

function C:actionStart()
end

function C:actionEnd()
end



--AIClassic
local C = registerClass(AI_PACKAGE, AI_CLASSIC, getClass(AI_PACKAGE, AI_BASE));

function C:ctor()
	self.skillManager = newClass(AI_PACKAGE, AI_SKILL_MANAGER);

	self.skills = {};
end

function C:awake(executorPtr)
	super.awake(self, executorPtr);

	self.unctrlCondPtr = self:createCPtrs(CAIUncontrollableCondition);
	self.searchTargetsTaskPtr = self:createCPtrs(CAISearchTargetsTask);

	self:_setChangeDirTask();

	self.actionBehaviorPtr = self:createCPtrs(CAIWeightedGroupTask);

	self:_createSkills();
end

function C:_setChangeDirTask()
	self.dirCondPtr = self:createCPtrs(CAIDirectionCondition);
	CAIDirectionCondition.setRange(self.dirCondPtr, 5.0);
	self.standCondPtr = self:createCPtrs(CAIPhysicsStateCondition);
	CAIPhysicsStateCondition.setState(self.standCondPtr, CPhysicsState.STAND);

	local groupTaskPtr = self:createCPtrs(CAISequenceGroupTask);

	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.25, 0.25);
	CAIGroupTaskBase.addTask(groupTaskPtr, emptyTaskPtr);

	local dirTaskPtr = self:createCPtrs(CAIDirectionTask);
	CAIDirectionTask.setMode(dirTaskPtr, CAIDirectionTask.ORIENTATION_TARGET);
	CAIGroupTaskBase.addTask(groupTaskPtr, dirTaskPtr);

	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.25, 0.25);
	CAIGroupTaskBase.addTask(groupTaskPtr, emptyTaskPtr);

	self.dirTaskPtr = groupTaskPtr;
end

function C:_createSkills()
end

function C:_createSkill(index, selfCD, publicCD, runningCD, rangeCondPtr, skillTaskPtr, trackTaskPtr, CDGroup)
	self.skillManager:setSkill(index, selfCD, publicCD, runningCD, CDGroup);

	local data = self.skills[index];
	if data == nil then
		data = {};
		self.skills[index] = data;
	end

	local idx = tostring(index);
	local CDCondPtr = self:createCPtrs(CAICustomCondition);
	CAICustomCondition.setHandler(CDCondPtr, "_skillCDCondHandler");

	if skillTaskPtr ~= nil then
		local condGroupPtr = self:createCPtrs(CAIConditionGroup);
		CAIConditionGroup.add(condGroupPtr, CDCondPtr);
		if rangeCondPtr ~= nil then CAIConditionGroup.add(condGroupPtr, rangeCondPtr); end
		local condPtr, once = CAITaskBase.getConditionPtr(skillTaskPtr);
		CAIConditionGroup.add(condGroupPtr, condPtr);

		CAITaskBase.setCondition(skillTaskPtr, condGroupPtr, true);
		CAITaskBase.setEndHandler(skillTaskPtr, "_runSkillCD");

		CAIGroupTaskBase.addTask(self.actionBehaviorPtr, skillTaskPtr);
	 end

	if trackTaskPtr ~= nil then
		local condGroupPtr = self:createCPtrs(CAIConditionGroup);
		CAIConditionGroup.add(condGroupPtr, CDCondPtr);
		if  self.dirCondPtr ~= nil then CAIConditionGroup.add(condGroupPtr, self.dirCondPtr); end
		CAITaskBase.setCondition(trackTaskPtr, condGroupPtr, true);

		 CAIGroupTaskBase.addTask(self.actionBehaviorPtr, trackTaskPtr);
	end

	data.CDCondPtr = CDCondPtr;
	data.rangeCondPtr = rangeCondPtr;
	data.skillTaskPtr = skillTaskPtr;
	data.trackTaskPtr = trackTaskPtr;
end

function C:_setSkill(index, skillTask, condGroup)
end

function C:_setTrack()
end

function C:_skillCDCondHandler(ptr)
	local idx = -1;

	for K, V in pairs(self.skills) do
		if ptr == V.CDCondPtr then
			idx = K;
			break;
		end
	end

	return self.skillManager:getCurrentCD(idx) <= 0.0;
end

function C:_runSkillCD(ptr)
	local idx = -1;

	for K, V in pairs(self.skills) do
		if ptr == V.skillTaskPtr then
			idx = K;
			break;
		end
	end

	self.skillManager:runSkill(idx);
end

function C:tick(time)
	self:_skillManagerTick(time);

	super.tick(self, time);
end

function C:_skillManagerTick(time)
	self.skillManager:tick(time);
end

function C:_tick(time)
	if self.first == nil then
		self.first = true;
		return;
	end

	local executorPtr = self.executorPtr;

	if CAIExecutor.getNumTargets(executorPtr) > 0 and (self.standCondPtr == nil or CAIExecutor.runCondition(executorPtr, self.standCondPtr)) then
		if self.dirCondPtr == nil or CAIExecutor.runCondition(executorPtr, self.dirCondPtr) then
			CAIExecutor.setTask(executorPtr, self.actionBehaviorPtr);
		elseif self.dirTaskPtr ~= nil then
			CAIExecutor.setTask(executorPtr, self.dirTaskPtr);
		end
	end
end


--TreasureChestAIBase
local C = registerClass(AI_PACKAGE, AI_TREASURE_CHEST_BASE, getClass(AI_PACKAGE, AI_BASE));

function C:ctor()
    self.TRIGGER_OPENED_ALL = "TC_opened_all";
end

function C:awake(executorPtr)
	super.awake(self, executorPtr);

    local record = self.record;
    record.total = record.total + 1;

	self.isAttacked = false;
	self.isTriggered = false;
end

function C:attacking(attackDataPtr)
	if not self.isAttacked then
		local sufferPtr = CAttackData.getSufferPtr(attackDataPtr);

		local selfPtr = CPlayer.getSelfPtr();
		if selfPtr ~= sufferPtr then return CCollisionResult.FAILED; end
		
		local bcPtr = CEntity.getBehaviorControllerPtr(sufferPtr);
		if CisNullptr(bcPtr) then return CCollisionResult.FAILED; end
		if not CBehaviorController.isFuncPress(bcPtr) then return CCollisionResult.FAILED; end

		self.isAttacked = true;
		
		self:_open();

        local entityPtr = self.entityPtr;
		local id = CChapterScene.getLootItemID(CEntity.getCharacterID(entityPtr), CLootItemFiltrationType.SELF_PLAYER, false);
		if id > 0 then
			CItemManager.acquireItem(selfPtr, id, 1, false);

			if CChapterScene.isNetwork() then
				CProtocol.sendCptActorBehaviorSync(entityPtr,
				function(baPtr)
					CByteArray.writeUInt8(baPtr, 1);
					CByteArray.writeInt64(baPtr, CEntity.getUUID(selfPtr));
					CByteArray.writeUInt16(baPtr, id);
				end);
			end
		end

		self:_checkChapterSuccess();
	end

	return CCollisionResult.FAILED;
end

function C:executeSync(bytesPtr)
	local entityPtr = self.entityPtr;

	local state = CByteArray.readUInt8(bytesPtr);

	if state == 1 then
		if not self.isAttacked then
			self.isAttacked = true;

			self:_open();

			local id = CChapterScene.getLootItemID(CEntity.getCharacterID(entityPtr), CLootItemFiltrationType.SELF_PLAYER, false);
			if id > 0 then
				local selfPtr = CPlayer.getSelfPtr();

				CItemManager.acquireItem(selfPtr, id, 1, false);

				CProtocol.sendCptActorBehaviorSync(entityPtr,
				function(baPtr)
					CByteArray.writeUInt8(baPtr, 0);
					CByteArray.writeInt64(baPtr, CEntity.getUUID(selfPtr));
					CByteArray.writeUInt16(baPtr, id);
				end);
			end

			self:_checkChapterSuccess();
		end
	end

	local uuid = CByteArray.readInt64(bytesPtr);
	local id = CByteArray.readUInt16(bytesPtr);
	local targetPtr = CChapterScene.getEntityPtrFromUUID(uuid);
	if not CisNullptr(targetPtr) then
		CItemManager.acquireItem(targetPtr, id, 1, false);
	end
end

function C:tick(time)
	if not self.isTriggered then
		local record = self.record;
		if record.opened == record.total then
			self.isTriggered = true;
			CEntityTrigger.sendTrigger(self.entityPtr, self.TRIGGER_OPENED_ALL, "");
		end
	end
end

function C:dispose()
    local record = self.record;
	record.total = record.total - 1;
	record.opened = record.opened - 1;

	return true;
end

function C:_setRecord(record)
    self.record = record;
end

function C:_open()
	CGameActionController.requestAction(CEntity.getActionControllerPtr(self.entityPtr), CGameAction.ACTION_SKILL.."0", true, true);

    local record = self.record;
	record.opened = record.opened + 1;
end

function C:_checkChapterSuccess()
end
