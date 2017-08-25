local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
	CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
	CBulletBehaviorController.setDynamicRotate(ptr, 900.0);
	CBulletBehaviorController.setDoneOwnerDie(ptr, true);
	CBulletBehaviorController.setFixedMoveableDirection(ptr, true);
	--CBulletBehaviorController.setAngle(ptr, 30, true);

	CBulletBehaviorController.setATKFactor(ptr, 0.0, 1.5);
	CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.0);

	local bulletPtr = CBullet.createBullet(CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/1", entityPtr, ptr);
	self.bulletPtr = bulletPtr;
	CEntity.entityRetain(bulletPtr);
	self.done = false;
end

function C:tick(time)
	self.done = CEntity.isDie(self.bulletPtr);
end

function C:finish()
	CEntity.entityRelease(self.bulletPtr);
end

function C:isDone(result)
	return true, self.done;
end

function C:dispose()
	return true;
end
