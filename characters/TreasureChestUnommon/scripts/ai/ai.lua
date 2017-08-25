--TreasureChestUnommon
local C = registerClassAuto(getClass(AI_PACKAGE, AI_TREASURE_CHEST_BASE));

TreasureChestUnommonRecord = {};
TreasureChestUnommonRecord.total = 0;
TreasureChestUnommonRecord.opened = 0;

function C:awake(executorPtr)
	self:_setRecord(TreasureChestUnommonRecord);

	super.awake(self, executorPtr);
end