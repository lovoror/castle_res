--HornBeast Skill2 Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr, prevAction)
	self.entityPtr = CGameAction.getEntityPtr(self.actionPtr);
end

function C:attacked(attackDataPtr)
	self:_setDie(CAttackData.getSufferPtr(attackDataPtr));
end

function C:suffered(attackDataPtr)
	if CAttackData.getValue(attackDataPtr) <= 0 and CAttackData.getType(attackDataPtr) == CBattleNumberType.HP then
		self:_setDie(CAttackData.getAttackerPtr(attackDataPtr));
	end
end

function C:_setDie(targetPtr)
	CEntity.setDie(self.entityPtr);

	if CChapterScene.isNetwork() then
		if CEntity.setHost(self.entityPtr) or CEntity.isHost(targetPtr) then
			CProtocol.sendCptEntityDied(self.entityPtr);
		end
	end
end

function C:dispose()
	return true;
end