--WrenchSwitch:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.TRIGGER_SWITCH_ON = "Switch_on";
	self.TRIGGER_SWITCH_OFF = "Switch_off";

	self.MAX_ANGLE = 30.0;
	self.TIME = 1.0;
	self.STATE_OFF = -2;
	self.STATE_TO_ON = -1;
	self.STATE_ON = 2;
	self.STATE_TO_OFF = 1;
	self.V = self.MAX_ANGLE * 2.0 / self.TIME;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	self.generatorPtr = nil;

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	self.entityPtr = CGameAction.getEntityPtr(actionPtr);

	self.id = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr));

	local wrenchPtr = CGameSprite.createWithSpriteFrameName(self.id .."/wrench");
	CGameNode.setAnchorPoint(wrenchPtr, 0.5, 0.0);
	CGameNode.setPosition(wrenchPtr, 0.0, 0.0);
	CGameNode.addChild(self.disPtr, wrenchPtr);
	self.wrenchPtr = wrenchPtr;

	local gearPtr = CGameSprite.createWithSpriteFrameName(self.id .."/gear");
	CGameNode.setAnchorPoint(gearPtr, 0.5, 0.0);
	CGameNode.setPosition(gearPtr, 0.0, 0.0);
	CGameNode.addChild(self.disPtr, gearPtr);

	CGameNode.setRotation(wrenchPtr, -self.MAX_ANGLE);

	local w, h = CGameNode.getContentSize(gearPtr);
	self.collW = w;
	local w, h = CGameNode.getContentSize(wrenchPtr);
	self.collH = h;

	self.state = self.STATE_OFF;
	self.triggerState = self.STATE_TO_ON;
	self.logicTime = 0.0;

	self.init = false;

	self:_init();

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);
end

function C:_init()
	if self.init then return; end
	self.init = true;
end

function C:tick(time)
	local playStartSnd = false;
	local playEndSnd = false;

	if self.state == self.STATE_TO_ON then
		local r = CGameNode.getRotation(self.wrenchPtr);
		if r == -self.MAX_ANGLE then
			playStartSnd = true;
		end
		r = r + self.V * time;
		if r >= self.MAX_ANGLE then
			r = self.MAX_ANGLE;
			self.state = self.STATE_ON;
			playEndSnd = true;
		end

		CGameNode.setRotation(self.wrenchPtr, r);
	elseif self.state == self.STATE_TO_OFF  then
		local r = CGameNode.getRotation(self.wrenchPtr);
		if r == self.MAX_ANGLE then
			playStartSnd = true;
		end
		r = r - self.V * time;
		if r <= -self.MAX_ANGLE then
			r = -self.MAX_ANGLE;
			self.state = self.STATE_OFF;
			playEndSnd = true;
		end

		CGameNode.setRotation(self.wrenchPtr, r);
	end

	if playStartSnd then
		local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "start"), true);
		local x, y = CEntity.getPosition(self.entityPtr);
		CAudioManager.set3DAttributes(chPtr, x, y);
		CAudioManager.setPaused(chPtr, false);
	end

	if playEndSnd then
		local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "end"), true);
		local x, y = CEntity.getPosition(self.entityPtr);
		CAudioManager.set3DAttributes(chPtr, x, y);
		CAudioManager.setPaused(chPtr, false);
	end

	if self.state == self.STATE_TO_ON or self.state == self.STATE_ON then
		if self.triggerState ~= self.STATE_TO_OFF  then
			self.triggerState = self.STATE_TO_OFF;

			CEntityTrigger.sendTrigger(self.entityPtr, self.TRIGGER_SWITCH_ON, "1");
		end
	elseif self.state == self.STATE_TO_OFF or self.state == self.STATE_OFF then
		if self.triggerState ~= self.STATE_TO_ON then
			self.triggerState = self.STATE_TO_ON;
			
			CEntityTrigger.sendTrigger(self.entityPtr, self.TRIGGER_SWITCH_OFF, "0");
		end
	end
end

function C:attacking(attackDataPtr)
	local selfPtr = CPlayer.getSelfPtr();
	local sufferPtr = CAttackData.getSufferPtr(attackDataPtr);
	
	if selfPtr ~= sufferPtr then return CCollisionResult.FAILED; end

	local bcPtr = CEntity.getBehaviorControllerPtr(sufferPtr);
	if CisNullptr(bcPtr) then return CCollisionResult.FAILED; end
	if not CBehaviorController.isFuncPress(bcPtr) then return CCollisionResult.FAILED; end

	self.logicTime = CChapterScene.getLogicTime();

	if self.state == self.STATE_OFF then
		self.state = self.STATE_TO_ON;
	elseif self.state == self.STATE_ON then
		self.state = self.STATE_TO_OFF ;
	end

	if CChapterScene.isNetwork() then
		CProtocol.sendCptActorActionSync(self.actionPtr,
		function(baPtr)
			CByteArray.writeFloat(baPtr, self.logicTime);
			CByteArray.writeBool(baPtr, self.state == self.STATE_TO_ON or self.state == self.STATE_ON);
		end);
	end

	return CCollisionResult.FAILED;
end

function C:executeSync(bytesPtr)
	local logicTime = CByteArray.readFloat(bytesPtr);
	if self.logicTime < logicTime then
		self.logicTime = logicTime;

		local isOn = CByteArray.readBool(bytesPtr);
		if isOn then
			if self.state == self.STATE_OFF or self.state == self.STATE_TO_OFF then
				self.state = self.STATE_TO_ON;
			end
		else
			if self.state == self.STATE_ON or self.state == self.STATE_TO_ON then
				self.state = self.STATE_TO_OFF;
			end
		end
	end
end

function C:updateColliders()
	CGameAction.setCollider(self.actionPtr, 0, 0, self.collH * 0.5, 0, 1, 1, 0, self.collW, self.collH, 0);

	return true, true;
end

function C:finish()
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end
