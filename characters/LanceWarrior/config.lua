local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/1");
	CCharacterData.setMass(characterDataPtr, 0.0);

	self:createIdle();
	self:createRun();
	self:createFall();
	self:createLanding();
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
	self:_setActionSettings(ptr);
end

function C:createRun()
	local ptr = createDefaultRunActionData();
	CGameActionData.setResName(ptr, "daiji");
	self:_setActionSettings(ptr);
end

function C:createFall()
	local ptr = createDefaultFallActionData();
	CGameActionData.setResName(ptr, "daiji");
	self:_setActionSettings(ptr);
end

function C:createLanding()
	local ptr = createDefaultLandingActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setKeepTime(ptr, 0.5);
	self:_setActionSettings(ptr);
end

function C:createSkill0()
	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setResName(ptr, "gongji_qiang");
	CGameActionData.setCollisionForce(ptr, 1, 300.0, 0.0, 1.0, false, 300.0, 0.0, 1.0, false);
	CGameActionData.setATKFactor(ptr, 1, 0.0, 2.0);

	self:_setActionSettings(ptr);
end

function C:createSkill1()
	local ptr = createDefaultSkillActionData("1");
	CGameActionData.setResName(ptr, "gongji_dun");
	CGameActionData.setScriptName(ptr, "Skill1", false);
	CGameActionData.setCollisionForce(ptr, 1, 200.0, 0.0, 0.0, false, 200.0, 0.0, 1.0, false);
	CGameActionData.setATKFactor(ptr, 1, 0.0, 2.0);

	self:_setActionSettings(ptr);
end

function C:createHurt()
	local ptr = createDefaultHurtActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW - 1);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:_setActionSettings(actionDataPtr)
	CGameActionData.setCollisionBehavior(actionDataPtr, CCollisionBehavior.DAMAGE);
	CGameActionData.setRigid(actionDataPtr, 0, CRigidAtk.NRM, CRigidDef.ABS);
	CGameActionData.setCollisionForce(actionDataPtr, 0, 200.0, 0.0, 0.0, false, 200.0, 0.0, 1.0, false);
	CGameActionData.setRigid(actionDataPtr, 1, CRigidAtk.HIGH, CRigidDef.ABS);
	CGameActionData.setDEFFactor(actionDataPtr, 1, 0.0, 0.5);
	CGameActionData.setMDFFactor(actionDataPtr, 1, 0.0, 0.5);

	CCharacterData.setActionData(self.characterDataPtr, actionDataPtr);
end
