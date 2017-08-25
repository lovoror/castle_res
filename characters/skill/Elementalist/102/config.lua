local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/hit");
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/lighting");

	CCharacterData.loadSound(characterDataPtr, "1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
end

function C:damage(attackDataPtr)
	local x, y = CAttackData.getHitPosition(attackDataPtr);

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, x, y, true);
	CBulletBehaviorController.setDoneAnimation(ptr, true);

	CBullet.createBullet(self.id.."/hit", CAttackData.getAttackerPtr(attackDataPtr), ptr, nil);

	return true;
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setScriptName(ptr, "Idle");
	CGameActionData.setLock(ptr, true);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setCollisionForce(ptr, 0, 200.0, 0.0, 1.0, true, 200.0, 0.0, 1.0, true);
	CGameActionData.setCollisionForceIgnoreRigid(ptr, 0, 1.0, 0.0);
	CGameActionData.setElectricityDamageFactor(ptr, 0, 0.0, 1.0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
