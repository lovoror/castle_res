local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.G = 1000.0;
end

function C:suffering(attackDataPtr)
	if CAttackData.getValue(attackDataPtr) <= 0 and CAttackData.getType(attackDataPtr) == CBattleNumberType.HP then
		self:_setDie(CAttackData.getAttackerPtr(attackDataPtr));
	end

	return CCollisionResult.DAMAGE_INVALID;
end

function C:attacking(attackDataPtr)
	self:_setDie(CAttackData.getSufferPtr(attackDataPtr));

	return CCollisionResult.DAMAGE_INVALID;
end

function C:_setDie(targetPtr)
	Clog("wefwegewgwe");
	CEntity.setDie(self.entityPtr);

	if CChapterScene.isNetwork() then
		if CEntity.setHost(self.entityPtr) or CEntity.isHost(targetPtr) then
			CProtocol.sendCptEntityDied(self.entityPtr);
		end
	end
end

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(self.actionPtr);

	self.step = 0;
	self.v0 = 500.0;
	self.maxWaitTime = 1.0;
	if not CisNullptr(itemPtr) then
		self.maxWaitTime = self.maxWaitTime + CItem.getLevel(itemPtr) * 0.25;
	end
	self.tickOk = false;
	self.curWaitTime = 0.0;

	local resHead = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/"

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setFollowOwner(ptr, true);
	CBulletBehaviorController.setDoneOwnerActionChanged(ptr, true);

	CBullet.createBullet(resHead.."Lighting", entityPtr, ptr, nil, 0, CChapterScene.getDynamicLightingLayerPtr());

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setFollowOwner(ptr, true);
	CBulletBehaviorController.setDoneOwnerActionChanged(ptr, true);

	CBullet.createBullet(resHead.."Distortion", entityPtr, ptr, nil, 0, CChapterScene.getDistortionLayerPtr());
end

function C:tick(time)
	local entityPtr = self.entityPtr;

	if not self.tickOk then
		self.tickOk = self:isBehaviorControllerInit(entityPtr);
		if self.tickOk then
			local ptr = CBulletBehaviorController.create();
			CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0, false);
			CBulletBehaviorController.setFollowOwner(ptr, true);
			CBulletBehaviorController.setDoneOwnerDie(ptr, true);
			CBulletBehaviorController.setDoneOwnerActionChanged(ptr, true);

			local id = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr)).."/ShootEffect";
			CBullet.createBullet(id, self.entityPtr, ptr, nil, 0, CChapterScene.getEffectMiddleLayerPtr());
		end
	end
	if not self.tickOk then return; end

	local x, y = CEntity.getHitBlockVector(entityPtr);
	local isHit = x ~= 0.0;
	if not isHit then
		local posX, posY = CEntity.getPosition(entityPtr);
		isHit = CTileMap.collisionPoint(CChapterScene.getTileMapPtr(), posX, posY, true);
	end

	if isHit then
		self.step = 2;
		CEntity.setDie(self.entityPtr);
	end

	if self.step == 0 then
		if time > 0.0 then
			local vt = self.G * time;
			local s = (self.v0  - vt * 0.5) * time;
			if s < 0.0 then s = 0.0; end
			self.v0 = self.v0 - vt;
			s = s / time;

			if CEntity.getDirection(entityPtr) == CDirection.LEFT then
				CEntity.appendInstantVelocity(entityPtr, -s, 0.0);
			else
				CEntity.appendInstantVelocity(entityPtr, s, 0.0);
			end

			if s <= 0.0 then
				self.curWaitTime = 0.0;
				self.step = 1;
				self.v0 = 0.0;
			end
		end
	elseif self.step == 1 then
		self.curWaitTime = self.curWaitTime + time;

		local ratio = self.curWaitTime / self.maxWaitTime;
		if ratio > 1.0 then ratio = 1.0; end
		ratio = 1.0 - ratio * 0.5;
		CGameAnimate.setColor(self.animatePtr, 1.0, ratio, ratio);

		if self.curWaitTime >= self.maxWaitTime then
			self.step = 2;
			CEntity.setDie(self.entityPtr);
		end
	end
end

function C:dispose()
	return true;
end
