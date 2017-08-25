local C = registerClassAuto();

function C:ctor()
end

function C:awake(itemPtr)
	self.itemPtr = itemPtr;
end

function C:attacked(attackDataPtr)
end

function C:suffered(attackDataPtr)
end

function C:update()
end

function C:equipment(count)
	if count == 1 then
		self.entityPtr = CItem.getEntityPtr(self.itemPtr);
	end
end

function C:discharge(count)
end

function C:changeCount()
end

function C:appendCount(count)
end

function C:collectSync(bytesPtr)
end

function C:executeSync(bytesPtr)
end

function C:_addExp(add)
	local itemPtr = self.itemPtr;

	local maxLv = CItem.getMaxLevel(itemPtr);
	local lv = CItem.getLevel(itemPtr);

	if lv >= maxLv then return; end

	local oldLv = lv;

	local maxExp = CItem.getMaxEXP(itemPtr);
	local exp = CItem.getEXP(itemPtr);
	exp = exp + add;

	while exp >= maxExp do
		lv = lv + 1;
		exp = exp - maxExp;

		maxExp = self:_getMaxEXP(lv);

		if lv >= maxLv then
			exp = 0;
			break;
		end
	end

	CItem.setEXP(itemPtr, exp);
	if oldLv ~= lv then
		CItem.setLevel(itemPtr, lv);
		CItem.setMaxEXP(itemPtr, maxExp);

		self:_sendLevelUp(self.entityPtr, lv);
	end
end

function C:_sendLevelUp(entityPtr, lv)
	if CChapterScene.isNetwork() then
		CProtocol.sendCptActorItemSync(self.itemPtr,
		function(baPtr)
			CByteArray.writeUInt8(baPtr, lv);
		end);
	end
end