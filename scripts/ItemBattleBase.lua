local C = registerClassAuto();

function C:ctor()
end

function C:awake(itemPtr)
	self.itemPtr = itemPtr;
	self.entityPtr = CItem.getEntityPtr(itemPtr);
end

function C:attacking(attackDataPtr)
	return 0;
end

function C:suffering(attackDataPtr)
	return 0;
end

function C:attacked(attackDataPtr)
end

function C:suffered(attackDataPtr)
end

function C:equipment(count)
end

function C:discharge(count)
end

function C:getSkillTag()
	return "";
end

function C:useCondition()
	return false;
end

function C:use()
end

function C:actionStart(actionPtr)
end

function C:tick(time)
end

function C:preBattle(time)
end

function C:collectSync(bytesPtr)
end

function C:executeSync(bytesPtr)
end

function C:actionEnd()
end
