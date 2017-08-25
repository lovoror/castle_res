local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	self:createIdle();
end

function C:loadGeneric()
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "ym1,ym2,ym3,ym4");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end