--Battery Skill1
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.SHOOTING_TIME = 1.06;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(actionPtr);

	self.bonePtr = CGameAnimate.getBonePtr(self.animatePtr, "paotong_program");
	self.shotBonePtr = CGameAnimate.getBonePtr(self.animatePtr, "paodan_program");
	self.rotation = tonumber(CEntity.getSharedData(entityPtr, "rotation"));
	CGameSpineBone.setRotation(self.bonePtr, self.rotation);

	self.shot = false;
end

function C:tick(time)
	if (not self.shot) then
		local t = CGameAnimate.getElapsed(self.animatePtr) - self.SHOOTING_TIME;
		if t >= 0.0 then
			self.shot = true;

			local entityPtr = self.entityPtr;

			local x, y = CGameSpineBone.getWorldPosition(self.shotBonePtr);
			local ox, oy = CEntity.transformModelToCharacter(entityPtr, x, y);
			local entityRotation = CEntity.getRotation(entityPtr);
			ox, oy = rotatePoint(ox, oy, -math.rad(entityRotation));

			local ptr = CBulletBehaviorController.create();
			CBulletBehaviorController.setStartTime(ptr, t);
			CBulletBehaviorController.setFollowOwner(ptr, false);
			CBulletBehaviorController.setDoneHitCount(ptr, 1);
			CBulletBehaviorController.setDoneHitBlock(ptr, true, true);
			CBulletBehaviorController.setDoneDie(ptr, true);
			CBulletBehaviorController.setDoneOverstepWorld(ptr, true);
			CBulletBehaviorController.setPosition(ptr, -1, ox, oy);
			CBulletBehaviorController.setVelocity(ptr, CharacterBattery.VELOCITY);
			CBulletBehaviorController.setGravityScale(ptr, CharacterBattery.GRAVITY_SCALE, CharacterBattery.GRAVITY_SCALE);
			CBulletBehaviorController.setFixedMoveableDirection(ptr, true);
			--CBulletBehaviorController.setDynamicAngleFromMotion(ptr, true)
			CBulletBehaviorController.setAngle(ptr, self.rotation - entityRotation, false);

			CBulletBehaviorController.setATKFactor(ptr, 0.0, 1.0);
			CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.0);

			CBullet.createBullet(CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/1", entityPtr, ptr);
		end
	end
end

function C:dispose()
	return true;
end
