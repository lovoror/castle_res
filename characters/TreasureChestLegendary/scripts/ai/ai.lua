--TreasureChestLegendary
local C = registerClassAuto(getClass(AI_PACKAGE, AI_TREASURE_CHEST_BASE));

TreasureChestLegendaryRecord = {};
TreasureChestLegendaryRecord.total = 0;
TreasureChestLegendaryRecord.opened = 0;

function C:ctor()
	self.KEY_CHAPTER_CLEAR = "clear";
end

function C:awake(executorPtr)
	self:_setRecord(TreasureChestLegendaryRecord);

	super.awake(self, executorPtr);
end

function C:_checkChapterSuccess()
	local entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);
	if CEntity.isHost(entityPtr) then
		if CEntity.getSharedData(entityPtr, self.KEY_CHAPTER_CLEAR) == "1" then
			CChapterScene.setFinish(true);
		end
	end
end
