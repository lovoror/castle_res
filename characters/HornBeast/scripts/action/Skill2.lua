--HornBeast Skill2
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.SHOOTING_START_TIME = 1.13;
	self.SHOOTING_END_TIME = 1.466;
	self.SHOOTING_START_ANGLE = -80.0;
	self.SHOOTING_END_ANGLE = -20.0;
	self.SHOOTING_MAX_NUM = 5;
	self.SHOOTING_PER_TIME = (self.SHOOTING_END_TIME - self.SHOOTING_START_TIME) / (self.SHOOTING_MAX_NUM - 1);
	self.SHOOTING_PER_ANGLE = (self.SHOOTING_END_ANGLE - self.SHOOTING_START_ANGLE) / (self.SHOOTING_MAX_NUM - 1);
	self.SHOOTING_OFFSET = 100.0;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(actionPtr);
	self.numShoted = 0;

	if CChapterScene.isNetwork() and Entity.isHost(entityPtr) then
		self.clientID = CGamePlatform.getChapterUserID();
		self.allocUUID = CChapterScene.allocateClientUUID(self.SHOOTING_MAX_NUM);
	end

	self.bulletName = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/2";
end

function C:collectSync(bytesPtr)
	CByteArray.writeUInt32(bytesPtr, self.clientID);
	CByteArray.writeUInt32(bytesPtr, self.allocUUID);
end

function C:executeSync(bytesPtr)
	self.clientID = CByteArray.readUInt32(bytesPtr);
	self.allocUUID = CByteArray.readUInt32(bytesPtr);
end

function C:tick(time)
	if self.numShoted < self.SHOOTING_MAX_NUM then
		local curTime = CGameAnimate.getElapsed(self.animatePtr);

		local nextTime = self.SHOOTING_START_TIME + self.numShoted * self.SHOOTING_PER_TIME;
		while curTime >= nextTime do
			local uuid = 0;
			if CChapterScene.isNetwork() then
				uuid = CChapterScene.generateClientUUID(self.clientID, self.allocUUID + self.numShoted);
			end

			self:_shot(self.bulletName, self.entityPtr, curTime - nextTime, self.SHOOTING_START_ANGLE + self.numShoted * self.SHOOTING_PER_ANGLE, uuid);

			self.numShoted = self.numShoted + 1;
			if self.numShoted >= self.SHOOTING_MAX_NUM then
				break;
			else
				nextTime = self.SHOOTING_START_TIME + self.numShoted * self.SHOOTING_PER_TIME;
			end
		end
	end
end

function C:dispose()
	return true;
end

function C:_shot(name, entityPtr, time, angle, uuid)
	local a = math.rad(angle);
	local sx, sy = CEntity.getScale(self.entityPtr);
	local offset = self.SHOOTING_OFFSET * sx;

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setStartTime(ptr, time);
	CBulletBehaviorController.setFollowOwner(ptr, false);
	CBulletBehaviorController.setDoneOverstepWorld(ptr, true);
	CBulletBehaviorController.setDoneTime(ptr, 15.0);
	CBulletBehaviorController.setDoneHitCount(ptr, 1);
	CBulletBehaviorController.setDoneOwnerDie(ptr, true);
	CBulletBehaviorController.setVelocity(ptr, 400.0);
	CBulletBehaviorController.setAngle(ptr, angle, false);
	CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
	CBulletBehaviorController.setPosition(ptr, 0, offset * math.cos(a), offset * math.sin(a));
	CBulletBehaviorController.setBounce(ptr, true);

	CBulletBehaviorController.setHPFactor(ptr, 1.0, 0.0);
	CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.0);
	CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.5);

	local baPtr = CEntity.getBattleAttributePtr(entityPtr);
	local mat = CBattleAttribute.getFinalMAT(baPtr);
	CBulletBehaviorController.setElectricityDamageFactor(ptr, mat * 0.5, 1.0);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(name, "start"));
	CBulletBehaviorController.setStartSound(ptr, scPtr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(name, "bounce"));
	CBulletBehaviorController.setBounceSound(ptr, scPtr);

	CBullet.createBullet(name, entityPtr, ptr, nil, uuid);
end
