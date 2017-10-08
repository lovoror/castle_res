local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_FOOD_DIE_BASE));

function C:_eat(targetPtr)
	self:_add(targetPtr, 10, CBattleNumberType.HP);
	self:_add(targetPtr, 30, CBattleNumberType.MP);

	super._eat(self, targetPtr);
end
