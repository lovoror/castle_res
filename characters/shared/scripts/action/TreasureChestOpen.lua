--TreasureChestOpen
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.SHOOTING_TIME = 0.0;
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
			local name = "shared/GenericTreasureChestOpenEffect";

			local ptr = self:_createBullet(t);
			CBullet.createBullet(name, entityPtr, ptr, nil, 0, CEntity.getLayerPtr(entityPtr));
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
	CBulletBehaviorController.setFollowOwner(ptr, true);
	CBulletBehaviorController.setDoneAnimation(ptr, true);
	CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
	--CBulletBehaviorController.setFixedMoveableDirection(ptr, true);

	return ptr;
end
