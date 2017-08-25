local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	CCharacterData.loadSound(characterDataPtr, "1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "hit", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setScriptName(ptr, "Idle", false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setBlockMoveInfluenced(ptr, false);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "1"), 0.5);
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
