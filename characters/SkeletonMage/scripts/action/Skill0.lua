--SkeletonArcher Skill0
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.SHOOTING_TIME = 3.2;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(actionPtr);

	self.actionSpeed = CGameActionData.getSpeed(CGameAction.getActionDataPtr(actionPtr));

	self.shot = false;
	self.collectSyncCount = 0;
	self.allocUUID = 0;
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

		self:_shot(CGameAnimate.getElapsed(self.animatePtr) - self.SHOOTING_TIME);
	end
end

function C:tick(time)
	if (not self.shot) then
		local t = CGameAnimate.getElapsed(self.animatePtr) - self.SHOOTING_TIME * self.actionSpeed;
		if t >= 0.0 then
			self.shot = true;

			local entityPtr = self.entityPtr;

			local canShot = true;
			if CChapterScene.isNetwork() then
				if  CEntity.isHost(entityPtr) then
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
	local entityPtr = self.entityPtr;

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setStartTime(ptr, time);
	CBulletBehaviorController.setFollowOwner(ptr, true);
	CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0, false, true);
	CBulletBehaviorController.setScale(ptr, 1.1);

	CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.0);

	local baPtr = CEntity.getBattleAttributePtr(entityPtr);
	local mat = CBattleAttribute.getFinalMAT(baPtr);
	local s = 2.0;
	CBulletBehaviorController.setMATFactor(ptr, 0.0, s * 0.5);
	CBulletBehaviorController.setElectricityDamageFactor(ptr, mat * s * 0.5, 0.0);

	local uuid = 0;
	if self.allocUUID ~= 0 then
		uuid = CChapterScene.generateClientUUID(self.clientID, self.allocUUID);
		self.allocUUID = 0;
	end

	CBullet.createBullet(CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/1", entityPtr, ptr, uuid);
end

function C:dispose()
	return true;
end
