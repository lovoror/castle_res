local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.SHOOTING_TIME = CESTUS_SHOOTING_TIME;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.enabled = false;
	self.shot = false;
	self.time = 0;
end

function C:getSkillTag()
	return CGameAction.ACTION_SKILL..CESTUS_ACTION_INDEX;
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
				CBulletBehaviorController.setPosition(ptr, 0);
				CBulletBehaviorController.setFollowOwner(ptr, true);
				CBulletBehaviorController.setDoneTime(ptr, 1.0);
				CBulletBehaviorController.setDoneAction(ptr, true);

				CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.4);
				CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.0);
				CBulletBehaviorController.setStrikeDamageFactor(ptr, 0.0, 1.0);

				CBullet.createBullet(CItem.getRes(itemPtr), CItem.getEntityPtr(itemPtr), ptr, itemPtr);
			end
		end
	end
end

function C:actionEnd()
	self.enabled = false;
end