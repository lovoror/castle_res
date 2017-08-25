local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.G = 800.0;
end

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.entityPtr = entityPtr;
	self.ownerPtr = CEntity.getOwnerPtr(entityPtr);

	self.curDis = 0.0;
	self.step = 0;
	self.v0 = 500.0;
	self.subY = nil;
	self.tickOk = false;
end

function C:tick(time)
	local entityPtr = self.entityPtr;

	if not self.tickOk then
		self.tickOk = self:isBehaviorControllerInit(entityPtr);
		if self.tickOk then
			local ptr = CBulletBehaviorController.create();
			CBulletBehaviorController.setPosition(ptr, 0, x, y, false);
			CBulletBehaviorController.setFollowOwner(ptr, true);
			CBulletBehaviorController.setDoneOwnerDie(ptr, true);
			
			local id = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr)).."/Effect";
			CBullet.createBullet(id, self.entityPtr, ptr, nil, 0, CChapterScene.getEffectMiddleLayerPtr());
		end
	end
	if not self.tickOk then return; end

	local ownerPtr = self.ownerPtr;

	if self.subY == nil then
		self.dir = CEntity.getDirection(entityPtr);
		local ownerX, ownerY = CEntity.getPosition(ownerPtr);
		local selfX, selfY = CEntity.getPosition(entityPtr);
		self.subY = selfY - ownerY;
	end

	if self.step == 0 then
		if time > 0.0 then
			local vt = self.G * time;
			local s = (self.v0  - vt * 0.5) * time;
			if s < 0.0 then s = 0.0; end
			self.v0 = self.v0 - vt;
			s = s / time;

			if self.dir == CDirectionEnum.LEFT then
				CEntity.appendInstantVelocity(entityPtr, -s, 0.0);
			else
				CEntity.appendInstantVelocity(entityPtr, s, 0.0);
			end

			local isHit = s <= 0.0;
			if not isHit then
				local x, y = CEntity.getHitBlockVector(entityPtr);
				isHit = x ~= 0.0;
			end
			if not isHit then
				local posX, posY = CEntity.getPosition(entityPtr);
				isHit = CTileMap.collisionPoint(CChapterScene.getTileMapPtr(), posX, posY, true);
			end
			if isHit then
				self.step = 1;
				self.v0 = 0.0;
				local actionPtr = self.actionPtr;
				CEntity.setBodyShapeEnabled(entityPtr, false);
				CEntity.resetAttackCollisionNumber(entityPtr);
			end
		end
	else
		local vt = self.G * time;
		local s = (self.v0 + vt  * 0.5) * time;
		self.v0 = self.v0 + vt;
		local d = s;
		if time ~= 0.0 then s = s / time; end

		local ownerX, ownerY = CEntity.getPosition(ownerPtr);
		local selfX, selfY = CEntity.getPosition(entityPtr);
		ownerY = ownerY + self.subY;
		local x = ownerX - selfX;
		local y = ownerY - selfY;
		local a = math.atan(y, x);
		CEntity.appendInstantVelocity(entityPtr, math.cos(a) * s, math.sin(a) * s);

		if d * d >= x * x + y * y then
			self.step = 2;
			CEntity.setDie(self.entityPtr);
		end
	end
end

function C:dispose()
	return true;
end
