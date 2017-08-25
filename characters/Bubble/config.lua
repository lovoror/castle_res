local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/DieEffect");
	CCharacterData.setMass(characterDataPtr, 0.0);

	self:createCreate();
	self:createIdle();
	self:createDie();
end

function C:createCreate()
	local ptr = createDefaultCreateActionData();
	CGameActionData.setResName(ptr, "chusheng");
	CGameActionData.setScriptName(ptr, "Idle");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.CUSTOM);
	CGameActionData.setCollisionCamp(ptr, true, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setScriptName(ptr, "Idle");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.CUSTOM);
	CGameActionData.setCollisionCamp(ptr, true, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");
	CGameActionData.setScriptName(ptr, "Die");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
