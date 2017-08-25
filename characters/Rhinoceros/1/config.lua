local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setSlopeEqualFullBlock(characterDataPtr, true);
	CCharacterData.setIgnoreOneWayBlock(characterDataPtr, true);

	self:createIdle();
	self:createDie();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "huoqiu");
	CGameActionData.setLock(ptr, true);
	setActionDataDefaultBattleData(ptr, 0);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setFireDamageFactor(ptr, 0, 0.0, 1.0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "baozha");
	CGameActionData.setLock(ptr, true);
	setActionDataDefaultBattleData(ptr, 0);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setFireDamageFactor(ptr, 0, 0.0, 1.0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end