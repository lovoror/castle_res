local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
	self:createSkill0();
	self:createSkill1();
	self:createSkill2();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setScriptName(ptr, "Idle", false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setResName(ptr, "shandian_1");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill1()
	local ptr = createDefaultSkillActionData("1");
	CGameActionData.setResName(ptr, "shandian_2");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill2()
	local ptr = createDefaultSkillActionData("2");
	CGameActionData.setResName(ptr, "shandian_0");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end