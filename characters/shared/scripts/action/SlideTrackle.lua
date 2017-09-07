local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:attacked(attackDataPtr)
	if not self.isAttacked and CAttackData.getValue(attackDataPtr) <= 0 and CAttackData.getType(attackDataPtr) == CBattleNumberType.HP then
		self.isAttacked = true;
	end
end

function C:start(itemPtr)
	self.isAttacked = false;
end

function C:finish()
	CEntity.setSlideTackleCD(CGameAction.getEntityPtr(self.actionPtr), 0.3);
end

function C:dispose()
	return true;
end

function C:isDone(result)
	if self.isAttacked then
		return true, true;
	else
		return false, false;
	end
end
