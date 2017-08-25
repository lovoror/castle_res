local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
	self:createDie();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setScriptName(ptr, "Idle");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.CUSTOM);
	CGameActionData.setBlockMoveInfluenced(ptr, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.NRM, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setBlockMoveInfluenced(ptr, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
