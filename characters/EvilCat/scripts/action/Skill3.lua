--EvilCat Skill3
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(actionPtr);

	local isJump= CGameAction.getTag(actionPtr) == CGameAction.ACTION_SKILL.."3";
	self.isJump = isJump;

	self.bonePtr = CGameAnimate.getBonePtr(self.animatePtr, "tou_progrom");
	self.arrowBonePtr = CGameAnimate.getBonePtr(self.animatePtr, "shetouzuobiao_progrom");

	self.shot = false;

	self.rotationStep = 0;
	self.rotate = 0.0;
	self.curRotateTime = 0.0;

	if isJump then
		self.SHOOTING_TIME = 0.833;
		self.ROTATE_START_TIME = 0.5;
		self.ROTATE_KEEP_TIME = 1.166;

		self.CLAMP_MAX_ANGLE = 30.0;
		self.CLAMP_MIN_ANGLE = -30.0;

		local mode = toint(CEntity.getSharedData(entityPtr, "mode"));
		local iy = tonumber(CEntity.getSharedData(entityPtr, "iy"));

		mode = (mode & 0xF) << 4;
		iy = iy * 0.5;
		CEntity.setSharedData(entityPtr, "mode", tostring(mode));
		CEntity.setSharedData(entityPtr, "iy", tostring(iy));

		CGameAction.setLinkActionName(actionPtr, CGameAction.ACTION_SKILL.."1");
	else
		self.SHOOTING_TIME = 0.833;
		self.ROTATE_START_TIME = 0.5;
		self.ROTATE_KEEP_TIME = 1.166;

		self.CLAMP_MAX_ANGLE = 10.0;
		self.CLAMP_MIN_ANGLE = -40.0;

		CGameAction.setLinkActionName(actionPtr, "");
	end

	self.ROTATE_START_DURATION = self.ROTATE_START_TIME;
	self.ROTATE_KEEP_DURATION = self.ROTATE_KEEP_TIME - self.ROTATE_START_TIME;
	self.ROTATE_END_DURATION = CGameAnimate.getDuration(self.animatePtr) - self.ROTATE_KEEP_TIME;

	local tx = tonumber(CEntity.getSharedData(entityPtr, "targetX"));
	local ty = tonumber(CEntity.getSharedData(entityPtr, "targetY"));

	local px, py, sx, sy = CGameAction.getLabelTRS(actionPtr, 0, false);
	if CEntity.getDirection(entityPtr) == CDirection.LEFT then
		tx = px + px - tx;
	end

	local dx = tx - px;
	local dy = ty - py;
	local d = math.sqrt(dx * dx + dy * dy);
	self.rotate = math.deg(math.atan(dy, dx));

	if self.rotate > self.CLAMP_MAX_ANGLE then
		self.rotate = self.CLAMP_MAX_ANGLE;
	elseif self.rotate < self.CLAMP_MIN_ANGLE then
		self.rotate = self.CLAMP_MIN_ANGLE;
	end
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
			CBulletBehaviorController.setFollowOwner(ptr, true);
			CBulletBehaviorController.setDoneHitCount(ptr, 1);
			CBulletBehaviorController.setPosition(ptr, -1, ox, oy);
			CBulletBehaviorController.setAngle(ptr, self.rotate, true);

			CBulletBehaviorController.setATKFactor(ptr, 0.0, 1.5);
			CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.0);

			CBullet.createBullet(CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/1", entityPtr, ptr);
		end
	end

	while time > 0.0 do
		time = time - self:_motion(time);
	end
end

function C:_motion(time)
	self.curRotateTime = self.curRotateTime + time;

	if self.rotationStep == 0 then
		local d = self.curRotateTime - self.ROTATE_START_DURATION;
		if d >= 0.0 then
			self.rotationStep = 1;
			time = time - d;
			self.curRotateTime = 0.0;
			CGameSpineBone.setRotation(self.bonePtr, self.rotate);
		else
			CGameSpineBone.setRotation(self.bonePtr, self.rotate * self.curRotateTime / self.ROTATE_START_DURATION);
		end
	elseif self.rotationStep == 1 then
		local d = self.curRotateTime - self.ROTATE_KEEP_DURATION;
		if d >= 0.0 then
			self.rotationStep = 2;
			time = time - d;
			self.curRotateTime = 0.0;
		end
	else
		local d = self.curRotateTime - self.ROTATE_END_DURATION;
		if d >= 0.0 then
			CGameSpineBone.setRotation(self.bonePtr, 0.0);
		else
			CGameSpineBone.setRotation(self.bonePtr, self.rotate * (1.0 - self.curRotateTime / self.ROTATE_END_DURATION));
		end
	end
	return time;
end

function C:finish()
	if self.isJump then
		CEntity.setPersistVelocity(self.entityPtr, 0.0, 0.0);
	end

	CGameSpineBone.setRotation(self.bonePtr, 0.0);
end

function C:dispose()
	return true;
end
