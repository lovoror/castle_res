local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/1");
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/2");
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/3");
	CCharacterData.setMass(characterDataPtr, 0.0);
	--characterData:setClipRect(0.0, 0.0, 300000.0, 300000.0);

	CCharacterData.loadSound(characterDataPtr, "skill0_0", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "skill0_1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "skill0_2", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "skill0_hit", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "skill2_0", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "skill10_0", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "skill10_1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "skill10_2", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "skill11_0", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	CCharacterData.setMATFactor(characterDataPtr, 0, 0.0, 0.0);

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
	self:createRun();
	self:createVeer();
	self:createSkill0();
	self:createSkill2();
	self:createSkill10();
	self:createSkill11();
	self:createHurt();
	self:createDie();
end

function C:damage(attackDataPtr)
	local x, y = CAttackData.getHitPosition(attackDataPtr);
	local attackerPtr = CAttackData.getAttackerPtr(attackDataPtr);
	local actPtr = CEntity.getCurrentActionPtr(attackerPtr);
	local actTag = CGameAction.getTag(actPtr);

	local hitSndName = "";
	if actTag == CGameAction.ACTION_SKILL.."0" then
		hitSndName = "skill0_hit";
	end

	--[[
	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, x, y, true);
	CBulletBehaviorController.setDoneAnimation(ptr, true);
	CBulletBehaviorController.setAngle(ptr, 360.0 * math.random(), true);
	CBulletBehaviorController.setScale(ptr, 1.4);

	CBullet.createBullet(self.id.."/hit", CAttackData.getAttackerPtr(attackDataPtr), ptr, nil);
	]]--

	if hitSndName ~= "" then
		local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, hitSndName), true);
		CAudioManager.set3DAttributes(chPtr, x, y);
		--CAudioManager.setVolume(chPtr, 0.5);
		CAudioManager.setPaused(chPtr, false);
	end

	return true;
end

function C:injured(attackDataPtr)
	setDefaultInjuredEffect(attackDataPtr);

	return true;
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");
	self:_setActionSettings(ptr);
end

function C:createRun()
	local ptr = createDefaultRunActionData();
	CGameActionData.setResName(ptr, "daiji");
	self:_setActionSettings(ptr);
end

function C:createVeer()
	local ptr = createDefaultIdleActionData(CGameAction.ACTION_VEER);
	CGameActionData.setResName(ptr, "zhuanshen");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);
	self:_setActionSettings(ptr, CGameAction.ACTION_IDLE);

	local ptr = createDefaultIdleActionData(CGameAction.ACTION_VEER);
	CGameActionData.setResName(ptr, "zhuanshen");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_RUN);
	self:_setActionSettings(ptr, CGameAction.ACTION_RUN);
end

function C:createSkill0()
	local secondName = "0-1";

	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setResName(ptr, "chong0");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_SKILL..secondName);
	CGameActionData.setSupportRun(ptr, true, true);
	self:_setActionSettings(ptr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "skill0_0"));
	CGameActionData.addSound(ptr, scPtr);

	local ptr = createDefaultSkillActionData("0", secondName);
	CGameActionData.setResName(ptr, "chong1");
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setSupportRun(ptr, true, true);
	CGameActionData.setATKFactor(ptr, 1, 0.0, 1.5);
	self:_setActionSettings(ptr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "skill0_1"));
	CSoundPackage.setPersistActionTag(scPtr, CGameAction.ACTION_SKILL.."0");
	CGameActionData.addSound(ptr, scPtr);
end

function C:createSkill2()
	local ptr = createDefaultSkillActionData("2");
	CGameActionData.setResName(ptr, "skill");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setScriptName(ptr, "Skill2", false);
	self:_setActionSettings(ptr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "skill2_0"));
	CGameActionData.addSound(ptr, scPtr);
end

function C:createSkill10()
	local ptr = createDefaultSkillActionData("10");
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setResName(ptr, "daiji0");
	CGameActionData.setActivated(ptr, false);
	self:_setActionSettings(ptr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "skill10_0"));
	CSoundPackage.setTime(scPtr, 0.0);
	CGameActionData.addSound(ptr, scPtr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "skill10_1"));
	CSoundPackage.setTime(scPtr, 1.66);
	CGameActionData.addSound(ptr, scPtr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "skill10_2"));
	CSoundPackage.addEmpty(scPtr, 3.0);
	CSoundPackage.addEmpty(scPtr, 4.0);
	CSoundPackage.addEmpty(scPtr, 5.0);
	CSoundPackage.addEmpty(scPtr, 6.0);
	CSoundPackage.setPlayMode(scPtr, CSoundPackage.PLAY_MODE_CONTINUE);
	CSoundPackage.setPersistActionTag(scPtr, CGameAction.ACTION_SKILL.."10");
	CGameActionData.addSound(ptr, scPtr);
end

function C:createSkill11()
	local ptr = createDefaultSkillActionData("11");
	CGameActionData.setResName(ptr, "daiji1");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);
	self:_setActionSettings(ptr);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "skill11_0"));
	CGameActionData.addSound(ptr, scPtr);
end

function C:createHurt()
	local ptr = createDefaultHurtActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW - 1);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");
	CGameActionData.setScriptName(ptr, "Die", false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:_setActionSettings(actionDataPtr, state)
	if state == nil then
		state = "";
	end

	CGameActionData.setLandingDone(actionDataPtr, false);
	CGameActionData.setCollisionBehavior(actionDataPtr, CCollisionBehavior.DAMAGE);
	CGameActionData.setRigid(actionDataPtr, 0, CRigidAtk.NRM, CRigidDef.ABS);
	CGameActionData.setCollisionForce(actionDataPtr, 0, 200.0, 0.0, 0.0, false, 200.0, 0.0, 1.0, false);

	CCharacterData.setActionData(self.characterDataPtr, actionDataPtr, state);
end
