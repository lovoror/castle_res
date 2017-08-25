--LionPillar Skill0
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.SHOOTING_TIME = 0.133;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(actionPtr);
	self.shot = false;
end

function C:tick(time)
	if (not self.shot) then
		local t = CGameAnimate.getElapsed(self.animatePtr) - self.SHOOTING_TIME;
		if t >= 0.0 then
			self.shot = true;

			local entityPtr = self.entityPtr;
			local name = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/1";

			local ptr = self:_createBullet(t);
			CBullet.createBullet(name, entityPtr, ptr);
		end
	end
end

function C:dispose()
	return true;
end

function C:_createBullet(time)
	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
	CBulletBehaviorController.setStartTime(ptr, time);
	CBulletBehaviorController.setFollowOwner(ptr, false);
	CBulletBehaviorController.setDoneHitCount(ptr, 1);
	CBulletBehaviorController.setDoneHitBlock(ptr, true, false);
	CBulletBehaviorController.setDoneOverstepWorld(ptr, true);
	CBulletBehaviorController.setVelocity(ptr, 400.0);
	CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
	--CBulletBehaviorController.setFixedMoveableDirection(ptr, true);

	CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.5);
	CBulletBehaviorController.setMATFactor(ptr, 0.0, 1.5);
	CBulletBehaviorController.setFireDamageFactor(ptr, 2.0, 1.0);

	return ptr;
end
