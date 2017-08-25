local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/Lighting");
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/Distortion");
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/ShootEffect");
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/BoomEffect");
	CCharacterData.setCamp(characterDataPtr, CCampType.UNDEFINED, CCampType.ANY);

	CCharacterData.loadSound(characterDataPtr, "1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "2", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
	self:createDie();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "Fire");
	CGameActionData.setScriptName(ptr, "Idle");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.CUSTOM);
	CGameActionData.setBlockMoveInfluenced(ptr, false);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "1"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "Fireboom");
	CGameActionData.setScriptName(ptr, "Die");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setBlockMoveInfluenced(ptr, false);
	CGameActionData.setFireDamageFactor(ptr, 0, 0.0, 1.0);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "2"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
