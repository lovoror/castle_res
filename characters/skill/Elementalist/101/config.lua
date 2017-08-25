local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/hit");

	CCharacterData.loadSound(characterDataPtr, "1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self.id= CCharacterData.getName(characterDataPtr);

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
	CGameActionData.setResName(ptr, "animation");
	CGameActionData.setSpeed(ptr, 0.7);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setCollisionCycle(ptr, 0.5);
	CGameActionData.setCollisionForce(ptr, 0, 200.0, 0.0, 0.0, false, 200.0, 0.0, 0.0, false);
	CGameActionData.setBlockMoveInfluenced(ptr, false);
	CGameActionData.setWindDamageFactor(ptr, 0, 0.0, 1.0);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(CCharacterData.getName(self.characterDataPtr), "1"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end