local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);

	self:createIdle();
	self:createDie();
	self:createSkill0();
	self:createSkill1();
end

function C:injured(attackDataPtr)
	setDefaultInjuredEffect(attackDataPtr);

	return true;
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setScriptName(ptr, "Idle", false);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setResName(ptr, "qianyao");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_SKILL.."1");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill1()
	local ptr = createDefaultSkillActionData("1");
	CGameActionData.setResName(ptr, "gongji");
	CGameActionData.setScriptName(ptr, "Skill1", false);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setDarkDamageFactor(ptr, 1, 0.0, 1.0);
	setActionDataDefaultBattleData(ptr, 1);
	CGameActionData.setATKFactor(ptr, 1, 0.0, 1.5);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
