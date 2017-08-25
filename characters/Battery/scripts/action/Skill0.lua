--Battery Skill0
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.ROTATION_PER_SECOND = 45.0;

	self.CLAMP_MAX_ANGLE = math.rad(180.0);
	self.CLAMP_MIN_ANGLE = math.rad(0.0);
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	self.bonePtr = CGameAnimate.getBonePtr(CGameAction.getAnimatePtr(actionPtr), "paotong_program");

	self.rotation = tonumber(CEntity.getSharedData(entityPtr, "rotation"));
	CGameSpineBone.setRotation(self.bonePtr, self.rotation);

	self.willRotateTo = self.rotation;
	self.done = false;

	local tx = CEntity.getSharedData(entityPtr, "targetX");
	if tx ~= "" then
		tx = tonumber(tx);
		local ty = tonumber(CEntity.getSharedData(entityPtr, "targetY"));

		local x, y = CGameSpineBone.getWorldPosition(self.bonePtr);
		x, y = CEntity.transformModelToCharacter(entityPtr, x, y);
		local px, py = CEntity.transformCharacterToWorld(entityPtr, x, y);

		local entityRotation = -math.rad(CEntity.getRotation(entityPtr));

		--if CEntity.getDirection(entityPtr) == CDirectionEnum.LEFT then
			--tx = px + px - tx;
		--end

		local gx, gy = CTileMap.getGravity(CChapterScene.getTileMapPtr());

		local a = getProjectileElevation(px, py, tx, ty, CharacterBattery.VELOCITY, gy * CharacterBattery.GRAVITY_SCALE, self.CLAMP_MIN_ANGLE + entityRotation, self.CLAMP_MAX_ANGLE + entityRotation);

		if a == nil then
			self.willRotateTo = self.rotation;
		else
			a = a - entityRotation;
			local rndAngle = CEntity.getSharedData(entityPtr, "randomAngle");
			if rndAngle == nil then
				rndAngle = 0.0;
			else
				rndAngle = tonumber(rndAngle);
			end
			a = a + rndAngle;

			if a < self.CLAMP_MIN_ANGLE or a > self.CLAMP_MAX_ANGLE then
				if a < 0.0 then
					a = a + math.pi * 2.0;
				else
					a = a - math.pi * 2.0;
				end
			end

			--if CEntity.getDirection(entityPtr) == CDirectionEnum.LEFT then
			--	a = math.pi - a;
			--end

			self.willRotateTo = math.deg(a);
		end
	end

	self.startRotation = self.rotation;
	self.subRotation = self.willRotateTo - self.rotation;
	self.totalTime = math.abs(self.subRotation) / self.ROTATION_PER_SECOND;
end

function C:tick(time)
	if self.totalTime == 0.0 then
		self.done = true;
		return;
	end

	local at = CGameAction.getAccumulateElapsed(self.actionPtr);
	local r = at / self.totalTime;
	if r >= 1.0 then
		self.done = true;
		self.rotation = self.willRotateTo;
	else
		self.rotation = self.startRotation + self.subRotation * r;
	end

	CGameSpineBone.setRotation(self.bonePtr, self.rotation);
end

function C:isDone(result)
	return true, self.done;
end

function C:finish()
	CEntity.setSharedData(self.entityPtr, "rotation", tostring(self.rotation));
end

function C:dispose()
	return true;
end
