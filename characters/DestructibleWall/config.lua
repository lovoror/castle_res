local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setCamp(characterDataPtr, CCampType.UNDEFINED, CCampType.MONSTER);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/Crack");
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/Dust");

	CCharacterData.loadSound(characterDataPtr, "crazing1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "crazing2", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "crazing3", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self:createIdle();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setScriptName(ptr, "Idle", false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionTag(ptr, CEntityType.PLAYER);
	CGameActionData.setCollisionCamp(ptr, false, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
