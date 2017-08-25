local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setFixedDirection(characterDataPtr, true);

	self:createIdle();
	self:createDie();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "Untitled");
	CGameActionData.setLock(ptr, true);
	CGameActionData.setLoop(ptr, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "virtual");
	CGameActionData.setLock(ptr, true);
	CGameActionData.setLoop(ptr, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
