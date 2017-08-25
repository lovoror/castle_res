local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
	self:createDie();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setScriptName(ptr, "IdleOrDie", false);
	CGameActionData.setLock(ptr, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setScriptName(ptr, "IdleOrDie", false);
	CGameActionData.setLoop(ptr, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end