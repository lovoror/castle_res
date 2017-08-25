local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_FOOD_IDLE_BASE));

function C:_eat(targetPtr)
	self:_add(targetPtr, 25, CBattleNumberTypeEnum.HP);

	super._eat(self, targetPtr);
end