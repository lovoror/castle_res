local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "Untitled,Untitled2");
	CGameActionData.setLock(ptr, true);
	CGameActionData.setLoop(ptr, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end