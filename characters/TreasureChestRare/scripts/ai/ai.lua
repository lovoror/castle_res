--TreasureChestRare
local C = registerClassAuto(getClass(AI_PACKAGE, AI_TREASURE_CHEST_BASE));

TreasureChestRareRecord = {};
TreasureChestRareRecord.total = 0;
TreasureChestRareRecord.opened = 0;

function C:awake(executorPtr)
	self:_setRecord(TreasureChestRareRecord);

	super.awake(self, executorPtr);
end