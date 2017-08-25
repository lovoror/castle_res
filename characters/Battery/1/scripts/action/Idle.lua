local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:attacked(attackDataPtr)
	CEntity.setDie(self.entityPtr);
end

function C:suffered(attackDataPtr)
	CEntity.setDie(self.entityPtr);
end

function C:start(itemPtr)
	self.entityPtr = CGameAction.getEntityPtr(self.actionPtr);
end

function C:dispose()
	return true;
end
