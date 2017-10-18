local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);

	CCharacterData.loadSound(characterDataPtr, "atk", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "hurt", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "die", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "rnd", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
	self:createRun();
	self:createFall();
	self:createLanding();
	self:createSkill0();
	self:createHurt();
	self:createDie();
end

function C:injured(attackDataPtr)
	setDefaultInjuredEffect(attackDataPtr);

	if math.random() < 0.2 then
		local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "hurt"), true);
		CAudioManager.set3DAttributes(chPtr, x, y);
		CAudioManager.setPaused(chPtr, false);
	end

	return true;
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createRun()
	local ptr = createDefaultRunActionData();
	CGameActionData.setResName(ptr, "yidong");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createFall()
	local ptr = createDefaultFallActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createLanding()
	local ptr = createDefaultLandingActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setKeepTime(ptr, 0.5);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setResName(ptr, "gongji");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);
	CGameActionData.setRigid(ptr, 1, CRigidAtk.NRM, CRigidDef.LOW);
	CGameActionData.setCollisionForce(ptr, 1, 200.0, 0.0, 0.0, false, 200.0, 0.0, 1.0, false);
	CGameActionData.setATKFactor(ptr, 1, 0.0, 1.5);

	CCharacterData.setActionData(self.characterDataPtr, ptr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.setTime(scPtr, 0.83);
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "atk"));
	CGameActionData.addSound(ptr, scPtr);
end

function C:createHurt()
	local ptr = createDefaultHurtActionData();
	CGameActionData.setResName(ptr, "shouji");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW - 1);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");

	CCharacterData.setActionData(self.characterDataPtr, ptr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.setTime(scPtr, 0.2);
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "die"));
	CGameActionData.addSound(ptr, scPtr);
end