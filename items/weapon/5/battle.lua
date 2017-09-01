local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.SHOOTING_TIME = MAGIC_WEAPON_SHOOTING_TIME;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.enabled = false;
	self.shot = false;
	self.time = 0;
end

function C:getSkillTag()
	return CGameAction.ACTION_SKILL..MAGIC_WEAPON_ACTION_INDEX;
end

function C:useCondition()
	return true;
end

function C:use()
	self.enabled = true;
	self.shot = false;
	self.time = 0.0;

	local count = CItem.getCurrentTotalCount(self.itemPtr);
	if count > 7 then count = 7; end
	self.lv = math.floor(math.random() * count);
end

function C:collectSync(bytesPtr)
	CByteArray.writeUInt8(bytesPtr, self.lv);
end

function C:executeSync(bytesPtr)
	self.lv = CByteArray.readUInt8(bytesPtr);
end

function C:preBattle(time)
	if self.enabled then
		if not self.shot then
			self.time = self.time + time;
			local t = self.time - self.SHOOTING_TIME;
			if t >= 0 then
				self.shot = true;

				local itemPtr = self.itemPtr;

				local ptr = CBulletBehaviorController.create();
				--CBulletBehaviorController.setInitActionTag(ptr, CGameAction.ACTION_SKILL..tostring(self.lv));
				CBulletBehaviorController.setStartTime(ptr, t);
				--CBulletBehaviorController.setAlphaDodgeWhenDone(ptr, 0.2);
				--CBulletBehaviorController.setAttackDisabledWithAlpha(ptr, 0.1);
				CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
				CBulletBehaviorController.setDoneLessVelocity(ptr, 0.0);
				--CBulletBehaviorController.setAlphaDodge(ptr, 0.6);
				CBulletBehaviorController.setDoneTime(ptr, 0.8);
				CBulletBehaviorController.setDoneHitBlock(ptr, true, false);
				CBulletBehaviorController.setDoneHitCount(ptr, 1);
				CBulletBehaviorController.setVelocity(ptr, 240.0);
				CBulletBehaviorController.setAcceleration(ptr, true, -200.0, true, 0.0, false, 0.0);
				CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
				CBulletBehaviorController.setFixedMoveableDirection(ptr, true);

				CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.0);
				CBulletBehaviorController.setMATFactor(ptr, self.lv * 0.5, 0.3 + self.lv * 0.05);

				local sdPtr = CSharedData.create();
				CSharedData.setData(sdPtr, "number", self.lv);

				local bulletPtr = CBullet.createBullet(CItem.getRes(itemPtr), CItem.getEntityPtr(itemPtr), ptr, itemPtr, 0, nil, sdPtr);

				CSharedData.free(sdPtr);
			end
		end
	end
end

function C:actionEnd()
	self.enabled = false;
end