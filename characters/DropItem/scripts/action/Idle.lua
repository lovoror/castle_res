local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.W = 76.0 * CGameCenter.HIGHT_DOWN_RATE;
	self.H = 76.0 * CGameCenter.HIGHT_DOWN_RATE;
	self.HALF_W = self.W * 0.5;
	self.HALF_H = self.H * 0.5;
end

function C:start(itemPtr)
	super.start(self, itemPtr);

	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.entityPtr = entityPtr;
	
	CEntity.setBodyShape(entityPtr, CBodyShapeTypeEnum.BOX, -self.HALF_W, 0.0, self.HALF_W, self.H, 1.0, 1.0);
	CEntity.setUpdateBodyShapeEnabled(entityPtr, false);

	self.isAttacked = false;
end

function C:attacking(attackDataPtr)
	local sufferPtr = CAttackData.getSufferPtr(attackDataPtr);
	if (not self.isAttacked) and CEntity.getType(sufferPtr) == CEntityType.PLAYER and CEntity.isHost(sufferPtr) then
		local itemID = CDropItem.getItemID(self.entityPtr);
		local itemDataPtr = CItemManager.getItemDataPtr(itemID);
		if not CisNullptr(itemDataPtr) then
			if CItemData.canUseByID(itemDataPtr, CEntity.getConfigID(sufferPtr)) then
				self.isAttacked = true;
				CItemManager.acquireItem(sufferPtr, itemID, 1, true);
				CEntity.setDie(CGameAction.getEntityPtr(self.actionPtr));
			end
		end
	end

	return CCollisionResult.FAILED;
end

function C:updateColliders()
	CGameAction.setCollider(self.actionPtr, 0, 0.0, self.HALF_H, 0.0, 1.0, 1.0, 0, self.W, self.H, 0);

	return true, true;
end

function C:dispose()
	return true;
end
