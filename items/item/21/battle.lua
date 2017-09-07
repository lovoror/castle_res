local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.valid = false;
end

function C:suffering(attackDataPtr)
	local rst = 0;
	
	self.valid = false;

	if CEntity.isHost(self.entityPtr) and CItem.getCount(self.itemPtr) > 0 then
		if CAttackData.getType(attackDataPtr) == CBattleNumberType.HP then
			local value = CAttackData.getValue(attackDataPtr);
			if value < 0 and -value >= CEntity.getHP(self.entityPtr) then
				rst = CCollisionResult.DAMAGE_INVALID;
				self.valid = true;
			end
		end
	end

	return rst;
end

function C:suffered(attackDataPtr)
	if self.valid then
		self.valid = false;
		self:_use(true);

		if CChapterScene.isNetwork() then
			CProtocol.sendCptActorItemSync(self.itemPtr, nil,
			function(baPtr)
				CByteArray.writeUInt8(baPtr, 0);
			end);
		end
	end
end

function C:executeSync(bytesPtr)
	self:_use(false);
end

function C:_use(isChange)
	self.time = CChapterScene.getLogicTime();
	CItem.setCount(self.itemPtr, CItem.getCount(self.itemPtr) - 1);

	local entityPtr = self.entityPtr;

	if isChange then
		local attPtr = CEntity.getBattleAttributePtr(entityPtr);
		CEntity.setHP(entityPtr, CBattleAttribute.getFinalHP(attPtr));
		CEntity.setMP(entityPtr, CBattleAttribute.getFinalMP(attPtr));

		if CChapterScene.isNetwork() then
			CProtocol.sendCptChangedHPMP(entityPtr, 0, 0);
		end
	end
end
