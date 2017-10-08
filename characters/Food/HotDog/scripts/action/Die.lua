local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_FOOD_DIE_BASE));

function C:_eat(targetPtr)
	self:_add(targetPtr, 40, CBattleNumberType.HP);

	super._eat(self, targetPtr);
end
