local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/1");
	CCharacterData.setMass(characterDataPtr, 0.0);

	self:createIdle();
	self:createSkill0();
	self:createSkill1();
	self:createHurt();
	self:createDie();
end

function C:injured(attackDataPtr)
	setDefaultInjuredEffect(attackDataPtr);

	return true;
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setResName(ptr, "gongji1");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);
	CGameActionData.setRigid(ptr, 1, CRigidAtk.NRM, CRigidDef.LOW);
	CGameActionData.setCollisionForce(ptr, 1, 200.0, 400.0, 0.0, true, 200.0, 400.0, 0.2, true);
	CGameActionData.setATKFactor(ptr, 1, 0.0, 1.5);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill1()
	local ptr = createDefaultSkillActionData("1");
	CGameActionData.setResName(ptr, "gongji2");
	CGameActionData.setScriptName(ptr, "Skill1", false);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createHurt()
	local ptr = createDefaultHurtActionData();
	CGameActionData.setResName(ptr, "shouji");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW - 1);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
