local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_UPDRADE_BASE));

function C:update()
	local itemPtr = self.itemPtr;

	CItem.setMaxLevel(itemPtr, 9);

	local lv = CItem.getLevel(itemPtr);
	local maxExp = self:_getMaxEXP(lv);
	CItem.setMaxEXP(itemPtr, maxExp);
end

function C:appendCount(count)
	if count > 0 then self:_addExp(count); end
end

function C:executeSync(bytesPtr)
	local lv = CByteArray.readUInt8(bytesPtr);
	local itemPtr = self.itemPtr;
	CItem.setLevel(itemPtr, lv);
	CItem.setMaxEXP(itemPtr, self:_getMaxEXP(lv));
end

function C:_getMaxEXP(lv)
	return 1;
end