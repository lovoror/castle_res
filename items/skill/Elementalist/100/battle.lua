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
	self.collectSyncCount = 0;
	self.actPtr = CEntity.getCurrentActionPtr(self.entityPtr);
	self.animatePtr = CGameAction.getAnimatePtr(self.actPtr);
end

function C:collectSync(bytesPtr)
	local isShot = self.shot and self.collectSyncCount > 0;
	CByteArray.writeBool(bytesPtr, isShot);
	if self.shot then
		self.collectSyncCount = self.collectSyncCount - 1;
	end
end

function C:executeSync(bytesPtr)
	if CByteArray.readBool(bytesPtr) then
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

			local canShot = true;
			if CChapterScene.isNetwork() then
				if CEntity.isHost(entityPtr) then
					self.collectSyncCount = 1
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
	--CBulletBehaviorController.setDoneTime(ptr, 10.5);
	CBulletBehaviorController.setDoneHitCount(ptr, 1);
	CBulletBehaviorController.setDoneHitBlock(ptr, true, true);
	CBulletBehaviorController.setDoneOverstepWorld(ptr, true);
	CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
	CBulletBehaviorController.setAcceleration(ptr, true, 600.0, false, 0.0, true, 1800.0);
	CBulletBehaviorController.setVelocity(ptr, 0.0);
	CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
	CBulletBehaviorController.setFixedMoveableDirection(ptr, true);
	CBulletBehaviorController.setMotionEnabledAction(ptr, CGameAction.ACTION_SKILL.."0");
	--CBulletBehaviorController.setAngle(ptr, 30, true);

	local lv = CItem.getLevel(itemPtr) ;
	CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.0);

	local baPtr = CEntity.getBattleAttributePtr(entityPtr);
	local mat = CBattleAttribute.getFinalMAT(baPtr);
	local s = 1.0 + (lv - 1.0) * 0.1;
	CBulletBehaviorController.setMATFactor(ptr, lv * 1.0, s * 0.5);
	CBulletBehaviorController.setIceDamageFactor(ptr, lv * 1.0 + mat * s * 0.5, 1.0);
	CBulletBehaviorController.setScale(ptr, 0.8 + (lv - 1) * 0.08);

	CBullet.createBullet(CItem.getRes(itemPtr), entityPtr, ptr, itemPtr);
end

function C:actionEnd()
	self.enabled = false;
end
