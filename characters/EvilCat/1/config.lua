local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
end

function C:createIdle()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setScriptName(ptr, "Idle", false);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionCamp(ptr, false, true);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.NRM, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setCollisionForce(ptr, 0, 200.0, 0.0, 0.0, false, 200.0, 0.0, 0.0, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
