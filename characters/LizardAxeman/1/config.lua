local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "animation");
	CGameActionData.setScriptName(ptr, "Idle");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);
	CGameActionData.setBlockMoveInfluenced(ptr, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
