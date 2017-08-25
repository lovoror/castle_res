--Gargoyle Skill1
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.SHOOTING_TIME = 0.33;

	self.CLAMP_MAX_ANGLE = -10;
	self.CLAMP_MIN_ANGLE = -60;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(actionPtr);
	self.shot = false;

	self.shotAngle = -45.0;

	if (not CChapterScene.isNetwork()) or CEntity.isHost(entityPtr) then
		local tx = CEntity.getSharedData(entityPtr, "targetX");
		if tx ~= "" then
			tx = tonumber(tx);
			local ty = tonumber(CEntity.getSharedData(entityPtr, "targetY"));

			local px, py, sx, sy = CGameAction.getLabelTRS(actionPtr, 0, false);

			if CEntity.getDirection(entityPtr) == CDirectionEnum.LEFT then
				tx = px + px - tx;
			end

			local dx = tx - px;
			local dy = ty - py;
			self.shotAngle = math.deg(math.atan(dy, dx));
		end

		if self.shotAngle > self.CLAMP_MAX_ANGLE then
			self.shotAngle = self.CLAMP_MAX_ANGLE;
		elseif self.shotAngle < self.CLAMP_MIN_ANGLE then
			self.shotAngle = self.CLAMP_MIN_ANGLE;
		end
	end
end

function C:collectSync(bytesPtr)
	CByteArray.writeFloat(bytesPtr, self.shotAngle);
end

function C:executeSync(bytesPtr)
	self.shotAngle = CByteArray.readFloat(bytesPtr);
end

function C:tick(time)
	if (not self.shot) then
		local t = CGameAnimate.getElapsed(self.animatePtr) - self.SHOOTING_TIME;
		if t >= 0.0 then
			self.shot = true;

			local entityPtr = self.entityPtr;
			local name = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/1";

			local ptr = CBulletBehaviorController.create();
			CBulletBehaviorController.setStartTime(ptr, t);
			CBulletBehaviorController.setMotionEnabledAction(ptr, CGameAction.ACTION_SKILL.."0");
			CBulletBehaviorController.setFollowOwner(ptr, false);
			CBulletBehaviorController.setDoneHitBlock(ptr, true, true);
			CBulletBehaviorController.setDoneOverstepWorld(ptr, true);
			CBulletBehaviorController.setVelocity(ptr, 600.0);
			CBulletBehaviorController.setAngle(ptr, self.shotAngle, false);
			CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
			CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
			CBulletBehaviorController.setDynamicRotate(ptr, -360.0);

			CBulletBehaviorController.setATKFactor(ptr, 0.0, 2.0);
			CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.0);

			CBullet.createBullet(name, entityPtr, ptr);
		end
	end
end

function C:dispose()
	return true;
end
