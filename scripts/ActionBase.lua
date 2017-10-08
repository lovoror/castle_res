local C = registerClassAuto();

function C:ctor()
end

function C:awake(actionPtr)
	self.actionPtr = actionPtr;
end

function C:attacking(attackDataPtr)
	return 0;
end

function C:suffering(attackDataPtr)
	return 0;
end

function C:attacked(attackDataPtr)
end

function C:suffered(attackDataPtr)
end

function C:damage(attackDataPtr)
	return false;
end

function C:injured(attackDataPtr)
	return false;
end

function C:collectSync(bytesPtr)
end

function C:executeSync(bytesPtr)
end

function C:trigger(name, value)
end

function C:start(itemPtr)
end

function C:tick(time)
end

function C:finish()
end

function C:isLock(result)
	return false, false
end

function C:isDone(result)
	return false, false;
end

--tag:string
function C:isCancel(tag, itemPtr)
	return false;
end

function C:updateColliders()
	return false, false;
end

function C:dispose()
	return false;
end

function C:isBehaviorControllerInit(entityPtr)
	local bcPtr = CEntity.getBehaviorControllerPtr(entityPtr);
	if CisNullptr(bcPtr) then
		return false;
	else
		return CBehaviorController.isCalledAddedLayer(bcPtr);
	end
end



--FoodIdleBase
local C = registerClass(ACTION_PACKAGE, ACTION_FOOD_IDLE_BASE, getClass(ACTION_PACKAGE, ACTION_BASE));

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;
	self.contentPtr = nil;
	self.animatorPtr = nil;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	self.entityPtr = CGameAction.getEntityPtr(actionPtr);

	self.id = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr));

	self:_init();

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);


	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.entityPtr = entityPtr;

	local hw = self.COLL_W * 0.5;

	CEntity.setBodyShape(entityPtr, CBodyShapeType.BOX, -hw, 0.0, hw, self.COLL_H, 1.0, 1.0);
	CEntity.setUpdateBodyShapeEnabled(entityPtr, false);

	self.isAttacked = false;
end

function C:_init()
	local contentPtr = CGameSprite.createWithSpriteFrameName(self.id.."/tex");
	CGameNode.setAnchorPoint(contentPtr, 0.5, 0.0);
	CGameNode.addChild(self.disPtr, contentPtr);

	self.animatorPtr = CDropItemAnimator.create(contentPtr);

	local sw, sh = CGameNode.getContentSize(contentPtr);
	self.COLL_W = sw;
	self.COLL_H = sh;
	self.COLL_Y = sh * 0.5;
end

function C:attacking(attackDataPtr)
	local sufferPtr = CAttackData.getSufferPtr(attackDataPtr);
	if (not self.isAttacked) and CEntity.getType(sufferPtr) == CEntityType.PLAYER and CEntity.isHost(sufferPtr) then
		self.isAttacked = true;

		if CChapterScene.isNetwork() then
			CProtocol.sendCptEntityDied(sufferPtr);
		end
		CEntity.setDie(CGameAction.getEntityPtr(self.actionPtr));
	end

	return CCollisionResult.FAILED;
end

function C:tick(time)
	CDropItemAnimator.tick(self.animatorPtr, time, CEntity.getPhysicsState(self.entityPtr) == CPhysicsState.STAND);
end

function C:updateColliders()
	CGameAction.setCollider(self.actionPtr, 0, 0.0, self.COLL_Y, 0.0, 1.0, 1.0, 0, self.COLL_W, self.COLL_H, 0);

	return true, true;
end

function C:finish()
	CDropItemAnimator.free(self.animatorPtr);
	self.animatorPtr = nil;
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	return true;
end



--FoodDieBase
local C = registerClass(ACTION_PACKAGE, ACTION_FOOD_DIE_BASE, getClass(ACTION_PACKAGE, ACTION_BASE));

function C:start(itemPtr)
	self.changedHP = 0;
	self.changedMP = 0;
end

function C:attacking(attackDataPtr)
	local sufferPtr = CAttackData.getSufferPtr(attackDataPtr);
	if CEntity.getType(sufferPtr) == CEntityType.PLAYER and CEntity.isHost(sufferPtr) then
		self:_eat(sufferPtr);
	end

	return CCollisionResult.FAILED;
end

function C:updateColliders()
	CGameAction.setCollider(self.actionPtr, 0, 0.0, 80.0, 0.0, 1.0, 1.0, 0, 160.0, 160.0, 0);

	return true, true;
end

function C:dispose()
	return true;
end

function C:_eat(targetPtr)
	showChangedHPMPEffect(targetPtr, self.changedHP, self.changedMP);

	if CChapterScene.isNetwork() then
		if self.changedHP ~= 0 or self.changedMP ~= 0 then
			CProtocol.sendCptChangedHPMP(targetPtr, self.changedHP, self.changedMP, true);
		end
	end
end

function C:_add(targetPtr, value, type)
	if value ~= 0 then
		if type == CBattleNumberType.HP then
			self.changedHP = value;
			CEntity.setHP(targetPtr, CEntity.getHP(targetPtr) + value);
		elseif type == CBattleNumberType.MP then
			self.changedMP = value;
			CEntity.setMP(targetPtr, CEntity.getMP(targetPtr) + value);
		end
	end
end
