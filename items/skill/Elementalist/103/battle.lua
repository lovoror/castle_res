local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.SHOOTING_TIME = MAGIC_SHOOTING_TIME;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.enabled = false;
	self.shot = false;
	self.collectSyncCount = 0;
end

function C:getSkillTag()
	return CGameAction.ACTION_SKILL..MAGIC_ACTION_INDEX;
end

function C:useCondition()
	return CEntity.getMP(self.entityPtr) >= CItem.getConsumeMP(self.itemPtr);
end

function C:use()
	self.enabled = true;
	self.shot = false;
	self.allocUUID = 0;
	self.collectSyncCount = 0;
	self.actPtr = CEntity.getCurrentActionPtr(self.entityPtr);
	self.animatePtr = CGameAction.getAnimatePtr(self.actPtr);
end

function C:collectSync(bytesPtr)
	local isShot = self.shot and self.collectSyncCount > 0;
	CByteArray.writeBool(bytesPtr, isShot);
	if self.shot then
		self.collectSyncCount = self.collectSyncCount - 1;
		CByteArray.writeUInt32(bytesPtr, self.clientID);
		CByteArray.writeUInt32(bytesPtr, self.allocUUID);
	end
end

function C:executeSync(bytesPtr)
	if CByteArray.readBool(bytesPtr) then
		self.clientID = CByteArray.readUInt32(bytesPtr);
		self.allocUUID = CByteArray.readUInt32(bytesPtr);

		local actPtr = CEntity.getCurrentActionPtr(self.entityPtr);
		self:_shot(CGameAnimate.getElapsed(CGameAction.getAnimatePtr(actPtr)) - self.SHOOTING_TIME);
	end
end

function C:preBattle(time)
	if self.enabled and (not self.shot) then
		local t = CGameAnimate.getElapsed(self.animatePtr) - self.SHOOTING_TIME;
		if t >= 0.0 then
			self.shot = true;

			local itemPtr = self.itemPtr;
			local entityPtr = self.entityPtr;

			local itemPtr = self.itemPtr;
			local entityPtr = CItem.getEntityPtr(itemPtr);

			local canShot = true;
			if CChapterScene.isNetwork() then
				if CEntity.isHost(entityPtr) then
					self.clientID = CGamePlatform.getChapterUserID();
					self.allocUUID = CChapterScene.allocateClientUUID(1);
					self.collectSyncCount = 1;
					CEntity.executeCollectSync(entityPtr);
					self.collectSyncCount = 0;
				else
					canShot = false;
				end
			end

			if canShot then
				self:_shot(t);
			end
		end
	end
end

function C:_shot(time)
	local itemPtr = self.itemPtr;
	local entityPtr = self.entityPtr;

	CEntity.appendMP(entityPtr, -CItem.getConsumeMP(itemPtr));

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setStartTime(ptr, t);
	CBulletBehaviorController.setFollowOwner(ptr, false);
	CBulletBehaviorController.setDoneHitBlock(ptr, true, false);
	CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
	--CBulletBehaviorController.setVelocity(ptr, 240);
	CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
	CBulletBehaviorController.setFixedMoveableDirection(ptr, true);
	--CBulletBehaviorController.setAngle(ptr, 30, true);

	local lv = CItem.getLevel(itemPtr);
	CBulletBehaviorController.setHPFactor(ptr, 0.0, 0.0);

	local baPtr = CEntity.getBattleAttributePtr(entityPtr);
	local mat = CBattleAttribute.getFinalMAT(baPtr);
	local s = 0.4 + (lv - 1.0) * 0.2;
	CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.0);
	CBulletBehaviorController.setMATFactor(ptr, lv * 1.5, s * 0.5);
	CBulletBehaviorController.setFireDamageFactor(ptr, lv * 1.2 + mat * s * 0.5, 1.0);
	--CBulletBehaviorController.setDoneTime(ptr, 2 + (lv - 1) * 0.12);
	CBulletBehaviorController.setScale(ptr, 1.0 + (lv - 1.0) * 0.06);

	local uuid = 0;
	if self.allocUUID ~= 0 then
		uuid = CChapterScene.generateClientUUID(self.clientID, self.allocUUID);
		self.allocUUID = 0;
	end

	CBullet.createBullet(CItem.getRes(itemPtr), entityPtr, ptr, itemPtr, uuid);
end

function C:actionEnd()
	self.enabled = false;
end
