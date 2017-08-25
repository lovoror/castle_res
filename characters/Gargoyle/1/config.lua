local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
	self:createSkill0();
	self:createDie();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "chusheng");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_SKILL.."0");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setResName(ptr, "yidong");
	CGameActionData.setGravityScale(ptr, 0.0, 0.0);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
