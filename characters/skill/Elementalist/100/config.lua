local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	CCharacterData.loadSound(characterDataPtr, "1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "2", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
	self:createSkill0_1();
	self:createSkill0_2();
	self:createDie();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "bd_normal_shengzhang");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_SKILL.."0-1");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setBlockMoveInfluenced(ptr, false);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "1"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0_1()
	local ptr = createDefaultSkillActionData("0", "0-1");
	CGameActionData.setResName(ptr, "bd_normal_xiaoshi");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_SKILL.."0-2");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.NRM, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setCollisionForce(ptr, 0, 200.0, 0.0, 0.0, false, 200.0, 0.0, 0.0, false);
	CGameActionData.setCollisionForceIgnoreRigid(ptr, 0, 1.0, 0.0);
	CGameActionData.setBlockMoveInfluenced(ptr, false);
	CGameActionData.setIceDamageFactor(ptr, 0, 0.0, 1.0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0_2()
	local ptr = createDefaultSkillActionData("0", "0-2");
	CGameActionData.setResName(ptr, "bd_normal_yidong");
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLandingDone(ptr, false);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.NRM, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setCollisionForce(ptr, 0, 200.0, 0.0, 0.0, false, 200.0, 0.0, 0.0, false);
	CGameActionData.setCollisionForceIgnoreRigid(ptr, 0, 1.0, 0.0);
	CGameActionData.setBlockMoveInfluenced(ptr, false);
	CGameActionData.setIceDamageFactor(ptr, 0, 0.0, 1.0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "bd_normal_daji");
	CGameActionData.setBlockMoveInfluenced(ptr, false);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "2"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
