local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	self:createIdle();
	self:createIdle2();
end

function C:loadGeneric()
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "animation");
	CGameActionData.setSpeed(ptr, 0.7);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createIdle2()
	local ptr = createDefaultIdleActionData(CGameAction.ACTION_IDLE.."1");
	CGameActionData.setResName(ptr, "animation2");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end