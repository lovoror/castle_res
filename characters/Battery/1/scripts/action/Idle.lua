local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:attacking(attackDataPtr)
	CEntity.setDie(self.entityPtr);
	return 0;
end

function C:suffering(attackDataPtr)
	CEntity.setDie(self.entityPtr);
	return 0;
end

function C:start(itemPtr)
	self.entityPtr = CGameAction.getEntityPtr(self.actionPtr);
end

function C:dispose()
	return true;
end
