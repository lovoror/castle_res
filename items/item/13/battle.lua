local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.MP = 999;
	self.CD = 1.0;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.time = -self.CD;
end

function C:getSkillTag()
	return "*";
end

function C:useCondition()
	return CEntity.isHost(self.entityPtr) and (CChapterScene.getLogicTime() - self.time >= self.CD) and CItem.getCount(self.itemPtr) > 0;
end

function C:use()
	self:_use(true);
end

function C:collectSync(bytesPtr)
	CByteArray.writeUInt8(bytesPtr, 0);
end

function C:executeSync(bytesPtr)
	self:_use(false);
end

function C:_use(isChange)
	self.time = CChapterScene.getLogicTime();
	CItem.setCount(self.itemPtr, CItem.getCount(self.itemPtr) - 1);

	local entityPtr = self.entityPtr;

	if isChange then
		CEntity.setMP(entityPtr, CEntity.getMP(entityPtr) + self.MP);
		
		if CChapterScene.isNetwork() then
			CProtocol.sendCptChangedHPMP(entityPtr, 0, self.MP);
		end
	end

	showChangedHPMPEffect(entityPtr, 0, self.MP);
end
