--TreasureChestEpic
local C = registerClassAuto(getClass(AI_PACKAGE, AI_TREASURE_CHEST_BASE));

TreasureChestEpicRecord = {};
TreasureChestEpicRecord.total = 0;
TreasureChestEpicRecord.opened = 0;

function C:awake(executorPtr)
	self:_setRecord(TreasureChestEpicRecord);

	super.awake(self, executorPtr);

	local entityPtr = self.entityPtr;

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setFollowOwner(ptr, true);
	CBulletBehaviorController.setDoneOwnerActionChanged(ptr, true);
	CBullet.createBullet(CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/IdleEffect", entityPtr, ptr, nil, 0, CEntity.getLayerPtr(entityPtr));
end