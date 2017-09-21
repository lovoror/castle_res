local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
	self:createSkill0();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "shouji");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setResName(ptr, "siwang");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
