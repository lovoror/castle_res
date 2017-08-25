local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.CD = 0.25;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.time = -self.CD;
end

function C:getSkillTag()
	return "*";
end

function C:useCondition()
	return CEntity.isHost(self.entityPtr) and CChapterScene.getLogicTime() - self.time >= self.CD;
end

function C:use()
	self:_shot();
end

function C:collectSync(bytesPtr)
	CByteArray.writeUInt8(bytesPtr, 0);
end

function C:executeSync(bytesPtr)
	self:_shot();
end

function C:_shot()
	self.time = CChapterScene.getLogicTime();

	local itemPtr = self.itemPtr;

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
	CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
	CBulletBehaviorController.setFixedMoveableDirection(ptr, true);
	--CBulletBehaviorController.setAngle(ptr, 30, true);

	CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.0);
	CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.4);

	CBullet.createBullet(CItem.getRes(itemPtr), CItem.getEntityPtr(itemPtr), ptr, itemPtr);
end
