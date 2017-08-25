--Gerald skill battle 100
local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.WAIT_TIME = 0.5;
	self.CONSUME_MP_PRE_SECOND = 4.0;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.isOn = false;
	self.frontBulletPtr = nil;
	self.backBulletPtr = nil;
end

function C:discharge(count)
	if count <= 0 and self.isOn then
		self.isOn = false;
		self:_setOff();
	end
end

function C:getSkillTag()
	return "*";
end

function C:useCondition()
	return CEntity.isHost(self.entityPtr) and CEntity.getMP(self.entityPtr) >= CItem.getConsumeMP(self.itemPtr);
end

function C:use()
	if CEntity.isHost(self.entityPtr) then
		if self.isOn then
			self.isOn = false;

			self:_setOff();
		else
			self.isOn = true;

			self:_setOn();
		end
	end
end

function C:collectSync(bytesPtr)
	CByteArray.writeBool(baPtr, self.isOn);
end

function C:executeSync(bytesPtr)
	local isOn = CByteArray.readBool(bytesPtr);
	if self.isOn ~= isOn then
		self.isOn = isOn;

		if self.isOn then
			self:_setOn();
		else
			self:_setOff();
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
				self.isOn = false;
				self:_setOff();

				if CChapterScene.isNetwork() then
					CEntity.executeCollectSync(self.entityPtr);
				end
			end
		end
	end
end

function C:_setOn()
	CEntity.appendMP(self.entityPtr, -CItem.getConsumeMP(self.itemPtr));

	local lv = CItem.getLevel(self.itemPtr);

	self.defFlatAdd = 4.0 + (lv - 1) * 1.0;
	self.defPercentageAdd = 0.1 + (lv - 1) * 0.05;

	self.curWaitTime = 0.0;

	local attPtr = CEntity.getBattleAttributePtr(self.entityPtr);
	CBattleAttribute.setFlatDEF(attPtr, CBattleAttribute.getFlatDEF(attPtr) + self.defFlatAdd);
	CBattleAttribute.setPercentageDEF(attPtr, CBattleAttribute.getPercentageDEF(attPtr) + self.defPercentageAdd);

	local sdPtr = CSharedData.create();
	CSharedData.setSharedData(sdPtr, "num", tostring(3 + math.floor((lv - 1) / 4)));
	--CSharedData.setSharedData(sdPtr, "num", "1");

	CSharedData.setSharedData(sdPtr, "front", "true");
	self.frontBulletPtr = CBullet.createBullet(CItem.getRes(self.itemPtr), self.entityPtr, self:_createBehaviorController(), self.itemPtr, 0, CChapterScene.getEffectAnterior1LayerPtr(), sdPtr);

	CSharedData.setSharedData(sdPtr, "front", "false");
	self.backBulletPtr = CBullet.createBullet(CItem.getRes(self.itemPtr), self.entityPtr, self:_createBehaviorController(), self.itemPtr, 0, CChapterScene.getEffectPosteriorLayerPtr(), sdPtr);

	CSharedData.free(sdPtr);
end

function C:_createBehaviorController()
	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setFollowOwner(ptr, true);
	CBulletBehaviorController.setBindSpineBone(ptr, "bone_program");
	CBulletBehaviorController.setDirection(ptr, CDirectionEnum.RIGHT);

	return ptr;
end

function C:_setOff()
	local attPtr = CEntity.getBattleAttributePtr(self.entityPtr);
	CBattleAttribute.setFlatDEF(attPtr, CBattleAttribute.getFlatDEF(attPtr) - self.defFlatAdd);
	CBattleAttribute.setPercentageDEF(attPtr, CBattleAttribute.getPercentageDEF(attPtr) - self.defPercentageAdd);

	if self.frontBulletPtr ~= nil then
		CEntity.setDie(self.frontBulletPtr);
		self.frontBulletPtr = nil;
	end
	if self.backBulletPtr ~= nil then
		CEntity.setDie(self.backBulletPtr);
		self.backBulletPtr = nil;
	end
end