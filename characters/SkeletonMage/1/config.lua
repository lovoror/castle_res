local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/hit");

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
end

function C:damage(attackDataPtr)
	local x, y = CAttackData.getHitPosition(attackDataPtr);

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, x, y, true);
	CBulletBehaviorController.setDoneActionChanged(ptr, true);

	CBullet.createBullet(self.id.."/hit", CAttackData.getAttackerPtr(attackDataPtr), ptr, nil);

	return true;
end

function C:createIdle()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setScriptName(ptr, "Idle");
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionCamp(ptr, false, true);
	setActionDataDefaultBattleData(ptr, 0);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setElectricityDamageFactor(ptr, 0, 0.0, 1.0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
