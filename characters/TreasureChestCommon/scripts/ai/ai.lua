--TreasureChestCommon
local C = registerClassAuto(getClass(AI_PACKAGE, AI_TREASURE_CHEST_BASE));

TreasureChestCommonRecord = {};
TreasureChestCommonRecord.total = 0;
TreasureChestCommonRecord.opened = 0;

function C:awake(executorPtr)
	self:_setRecord(TreasureChestCommonRecord);

	super.awake(self, executorPtr);
end