local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setSlopeEqualFullBlock(characterDataPtr, true);
	CCharacterData.setEdgeFreeTileEqualFullBlock(characterDataPtr, true);
	CCharacterData.setIgnoreOneWayBlock(characterDataPtr, true);

	self:createIdle();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "gongji_dun");
	CGameActionData.setLock(ptr, true);
	setActionDataDefaultBattleData(ptr, 0);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
