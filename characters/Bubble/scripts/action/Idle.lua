local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:suffered(attackDataPtr)
	if CAttackData.getValue(attackDataPtr) <= 0 and CAttackData.getType(attackDataPtr) == CBattleNumberType.HP then
		CEntity.setDie(CGameAction.getEntityPtr(self.actionPtr));

		if CChapterScene.isNetwork() then
			if CEntity.setHost(self.entityPtr) or CEntity.isHost(CAttackData.getAttackerPtr(attackDataPtr)) then
				CProtocol.sendCptEntityDied(self.entityPtr);
			end
		end
	end
end

function C:dispose()
	return true;
end
