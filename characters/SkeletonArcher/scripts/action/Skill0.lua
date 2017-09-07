--SkeletonArcher Skill0
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.SHOOTING_TIME = 1.16;
	self.ROTATE_START_TIME = 0.5;
	self.ROTATE_KEEP_TIME = 1.33;

	self.ROTATE_START_DURATION = self.ROTATE_START_TIME;
	self.ROTATE_KEEP_DURATION = self.ROTATE_KEEP_TIME - self.ROTATE_START_TIME;

	self.CLAMP_MAX_ANGLE = 45;
	self.CLAMP_MIN_ANGLE = -45;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(actionPtr);

	self.bonePtr = CGameAnimate.getBonePtr(self.animatePtr, "shangbanshen_program");
	self.arrowBonePtr = CGameAnimate.getBonePtr(self.animatePtr, "jian_program");

	self.shot = false;

	self.rotationStep = 0;
	self.rotation = 0.0;
	self.curRotationTime = 0.0;
	self.ROTATE_END_DURATION = CGameAnimate.getDuration(self.animatePtr) - self.ROTATE_KEEP_TIME;

	if (not CChapterScene.isNetwork()) or CEntity.isHost(entityPtr) then
		local tx = CEntity.getSharedData(entityPtr, "targetX");
		if tx ~= "" then
			tx = tonumber(tx);
			local ty = tonumber(CEntity.getSharedData(entityPtr, "targetY"));

			local px, py, sx, sy = CGameAction.getLabelTRS(actionPtr, 0, false);

			if CEntity.getDirection(entityPtr) == CDirection.LEFT then
				tx = px + px - tx;
			end

			local dx = tx - px;
			local dy = ty - py;
			local d = math.sqrt(dx * dx + dy * dy);
			local a = math.deg(math.atan(dy, dx));
			self.rotation = a + 0.032 * d;
		end

		if self.rotation > self.CLAMP_MAX_ANGLE then
			self.rotation = self.CLAMP_MAX_ANGLE;
		elseif self.rotation < self.CLAMP_MIN_ANGLE then
			self.rotation = self.CLAMP_MIN_ANGLE;
		end
	end
end

function C:collectSync(bytesPtr)
	CByteArray.writeFloat(bytesPtr, self.rotation);
end

function C:executeSync(bytesPtr)
	self.rotation = CByteArray.readFloat(bytesPtr);
end

function C:tick(time)
	if (not self.shot) then
		local t = CGameAnimate.getElapsed(self.animatePtr) - self.SHOOTING_TIME;
		if t >= 0.0 then
			self.shot = true;

			local entityPtr = self.entityPtr;

			local x, y = CGameSpineBone.getWorldPosition(self.arrowBonePtr);
			local ox, oy = CEntity.transformModelToCharacter(entityPtr, x, y);

			local ptr = CBulletBehaviorController.create();
			CBulletBehaviorController.setStartTime(ptr, t);
			CBulletBehaviorController.setFollowOwner(ptr, false);
			CBulletBehaviorController.setDoneHitCount(ptr, 1);
			CBulletBehaviorController.setDoneHitBlock(ptr, true, true);
			CBulletBehaviorController.setDoneOverstepWorld(ptr, true);
			CBulletBehaviorController.setPosition(ptr, -1, ox, oy);
			CBulletBehaviorController.setVelocity(ptr, 600.0);
			CBulletBehaviorController.setGravityScale(ptr, 0.2, 0.2);
			CBulletBehaviorController.setFixedMoveableDirection(ptr, true);
			CBulletBehaviorController.setDynamicAngleFromMotion(ptr, true)
			CBulletBehaviorController.setAngle(ptr, self.rotation, true);

			CBulletBehaviorController.setATKFactor(ptr, 0.0, 2.5);
			CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.0);

			CBullet.createBullet(CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/1", entityPtr, ptr);
		end
	end

	while time > 0.0 do
		time = time - self:_motion(time);
	end
end

function C:_motion(time)
	self.curRotationTime = self.curRotationTime + time;

	if self.rotationStep == 0 then
		local d = self.curRotationTime - self.ROTATE_START_DURATION;
		if d >= 0.0 then
			self.rotationStep = 1;
			time = time - d;
			self.curRotationTime = 0.0;
			CGameSpineBone.setRotation(self.bonePtr, self.rotation);
		else
			CGameSpineBone.setRotation(self.bonePtr, self.rotation * self.curRotationTime / self.ROTATE_START_DURATION);
		end
	elseif self.rotationStep == 1 then
		local d = self.curRotationTime - self.ROTATE_KEEP_DURATION;
		if d >= 0.0 then
			self.rotationStep = 2;
			time = time - d;
			self.curRotationTime = 0.0;
		end
	else
		local d = self.curRotationTime - self.ROTATE_END_DURATION;
		if d >= 0.0 then
			CGameSpineBone.setRotation(self.bonePtr, 0.0);
		else
			CGameSpineBone.setRotation(self.bonePtr, self.rotation * (1.0 - self.curRotationTime / self.ROTATE_END_DURATION));
		end
	end
	return time;
end

function C:finish()
	CGameSpineBone.setRotation(self.bonePtr, 0.0);
end

function C:dispose()
	return true;
end
