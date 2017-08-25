--TreasureChestEpic
local C = registerClassAuto(getClass(AI_PACKAGE, AI_TREASURE_CHEST_BASE));

TreasureChestEpicRecord = {};
TreasureChestEpicRecord.total = 0;
TreasureChestEpicRecord.opened = 0;

function C:awake(executorPtr)
	self:_setRecord(TreasureChestEpicRecord);

	super.awake(self, executorPtr);
end