local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setIgnoreOneWayBlock(characterDataPtr, true);

	self:createIdle();
	self:createDie();
end

function C:createIdle()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setScriptName(ptr, "IdleOrDie", false);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionCamp(ptr, false, true);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.NRM, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setCollisionForce(ptr, 0, 200.0, 0.0, 0.0, false, 200.0, 0.0, 0.0, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_DIE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_DIE);
	CGameActionData.setScriptName(ptr, "IdleOrDie", false);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
