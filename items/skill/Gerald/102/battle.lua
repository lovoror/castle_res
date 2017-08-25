--Gerald skill battle 102
local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.WAIT_TIME = 0.5;
	self.CONSUME_MP_PRE_SECOND = 5.0;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.isOn = false;
end

function C:discharge(count)
	if count <= 0 then
		self:_setOff();
	end
end

function C:getSkillTag()
	return "*";
end

function C:useCondition()
	if CEntity.isHost(self.entityPtr) and CEntity.getMP(self.entityPtr) >= CItem.getConsumeMP(self.itemPtr) then
		return CEntity.getPhysicsState(self.entityPtr) ~= CPhysicsStateEnum.STAND and CEntity.getCurrentActionTag(self.entityPtr) ~= CGameAction.ACTION_HURT
	else
		return false;
	end
end

function C:use()
	if CEntity.isHost(self.entityPtr) then
		self:_setOn();
	end
end

function C:collectSync(bytesPtr)
	CByteArray.writeBool(baPtr, self.isOn);
end

function C:executeSync(bytesPtr)
	local isOn = CByteArray.readBool(bytesPtr);
	if isOn then
		self:_setOn();
	else
		self:_setOff();
	end
end

function C:tick(time)
	if self.isOn then
		if CEntity.isHost(self.entityPtr) then
			if (not CItem.isSkillButtonPressing(self.itemPtr)) or CEntity.getPhysicsState(self.entityPtr) == CPhysicsStateEnum.STAND or CEntity.getCurrentActionTag(self.entityPtr) == CGameAction.ACTION_HURT or CEntity.isDie(self.entityPtr) then
				self:_setOff();
			end
		end

		if self.isOn then
			CEntity.setInstantVelocity(self.entityPtr, 0.0, 0.0);
			CEntity.setResistanceVelocity(self.entityPtr, 0.0, 0.0);

			if CEntity.getCurrentActionTag(self.entityPtr) ~= CGameAction.ACTION_KICK then
				CEntity.setPersistVelocity(self.entityPtr, 0.0, 0.0);
			end
		end
	end
end

function C:preBattle(time)
	if self.isOn then
		local changeMP = true;
		local lastTime = time;
		if self.curWaitTime < self.WAIT_TIME then
			self.curWaitTime = self.curWaitTime + time;
			if self.curWaitTime > self.WAIT_TIME then
				lastTime = self.curWaitTime - self.WAIT_TIME;
			else
				changeMP = false;
			end
		end

		if changeMP then
			CEntity.appendMP(self.entityPtr, -self.CONSUME_MP_PRE_SECOND * lastTime);
			if CEntity.isHost(self.entityPtr) and CEntity.getMP(self.entityPtr) <= 0.0 then
				self:_setOff();
			end
		end
	end
end

function C:_setOn()
	if not self.isOn then
		self.isOn = true;

		CEntity.appendMP(self.entityPtr, -CItem.getConsumeMP(self.itemPtr));
		self.curWaitTime = 0.0;
		CEntity.setIgnoredMotion(self.entityPtr, true);
	end
end

function C:_setOff()
	if self.isOn then
		self.isOn = false;

		CEntity.setIgnoredMotion(self.entityPtr, false);

		if CEntity.isHost(self.entityPtr) and CChapterScene.isNetwork() then
			CEntity.executeCollectSync(self.entityPtr);
		end
	end
end