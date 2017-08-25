--SkeletonArcher Skill1
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.SHOOTING_TIME = 1.36;
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

			local px, py, sx, sy = CGameAction.getLabelTRS(self.actionPtr, 0, false);
			CChapterScene.shake(px, py, 20.0, 2000.0, 0.2 - t);

			local entityPtr = self.entityPtr;
			local name = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/1";

			local ptr = self:_createBullet(t);
			CBulletBehaviorController.setPosition(ptr, 0, 100.0, 0.0);
			CBullet.createBullet(name, entityPtr, ptr);

			local ptr = self:_createBullet(t);
			CBulletBehaviorController.setPosition(ptr, 0, -100.0, 0.0);
			CBulletBehaviorController.setReverseDirection(ptr, true);
			CBullet.createBullet(name, entityPtr, ptr);
		end
	end
end

function C:dispose()
	return true;
end

function C:_createBullet(time)
	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setStartTime(ptr, time);
	CBulletBehaviorController.setFollowOwner(ptr, false);
	CBulletBehaviorController.setDoneHitBlock(ptr, true, false);
	CBulletBehaviorController.setDoneTime(ptr, 1.5);
	CBulletBehaviorController.setAlphaDodgeWhenDone(ptr, 0.2);
	CBulletBehaviorController.setAttackDisabledWithAlpha(ptr, 0.2);
	CBulletBehaviorController.setVelocity(ptr, 400.0);
	CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
	--CBulletBehaviorController.setFixedMoveableDirection(ptr, true);

	CBulletBehaviorController.setATKFactor(ptr, 0.0, 2.0);
	CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.0);

	return ptr;
end
