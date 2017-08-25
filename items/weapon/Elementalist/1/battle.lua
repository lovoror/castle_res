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
				--CBulletBehaviorController.setFollowOwner(ptr, true);
				--CBulletBehaviorController.setDoneAnimation(ptr, true);
				--CBulletBehaviorController.setDoneAction(ptr, true);
				CBulletBehaviorController.setDoneHitCount(ptr, 1);
				CBulletBehaviorController.setDoneHitBlock(ptr, true, false);
				CBulletBehaviorController.setVelocity(ptr, 550.0);
				CBulletBehaviorController.setDoneTime(ptr, 0.3);
				CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
				CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
				CBulletBehaviorController.setAlphaDodge(ptr, 0.2);
				CBulletBehaviorController.setAlphaDodgeWhenDone(ptr, 0.1);
				CBulletBehaviorController.setAttackDisabledWithAlpha(ptr, 0.1);
				CBulletBehaviorController.setFixedMoveableDirection(ptr, true);
				--CBulletBehaviorController.setAngle(ptr, 30, true);

				CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.0);
				CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.4);

				CBullet.createBullet(CItem.getRes(itemPtr), CItem.getEntityPtr(itemPtr), ptr, itemPtr);
			end
		end
	end
end