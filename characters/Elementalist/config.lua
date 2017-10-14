local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setRotation(characterDataPtr, 0, 90);
	CCharacterData.setHurtProtectTime(characterDataPtr, 0.8);
	for i = 1, 5 do
		CCharacterData.loadSound(characterDataPtr, "atk"..tostring(i), SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	end
	for i = 1, 5 do
		CCharacterData.loadSound(characterDataPtr, "hurt"..tostring(i), SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	end
	for i = 1, 4 do
		CCharacterData.loadSound(characterDataPtr, "run"..tostring(i), SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	end
	CCharacterData.loadSound(characterDataPtr, "die", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "dodge", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "landing", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "jump", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "jumpMore", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "slideTrackle", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self.id = CCharacterData.getName(characterDataPtr);

	CCharacterData.setScriptName(characterDataPtr, "ActionController", false);

	self:createIdle();
	self:createRun();
	self:createVeer();
	self:createJump();
	self:createJumpMore();
	self:createFall();
	self:createKick();
	self:createSlideTrackle();
	self:createDodge();
	self:createSquat();
	self:createLanding();
	self:createMagicWeapon();
	self:createSword();
	self:createMagic();
	self:createHurt();
	self:createDie();
end

function C:injured(attackDataPtr)
	setDefaultInjuredEffect(attackDataPtr);

	return true;
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createRun()
	local ptr = createDefaultRunActionData();
	CGameActionData.setResName(ptr, "yidong");
	CGameActionData.setScriptName(ptr, "DynamicAnimationSpeedRun", true);
	CGameActionData.setSharedData(ptr, "standardVelocity", 300.0);
	--CGameActionData.setSpeed(ptr, 0.5);

	local scPtr = CSoundPackage.create();
	for i = 1, 4 do
		CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "run"..tostring(i)));
	end
	CSoundPackage.setTime(scPtr, 0.0);
	CGameActionData.addSound(ptr, scPtr);

	local scPtr = CSoundPackage.create();
	for i = 1, 4 do
		CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "run"..tostring(i)));
	end
	CSoundPackage.setTime(scPtr, 0.43);
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createVeer()
	local ptr = createDefaultIdleActionData(CGameAction.ACTION_VEER);
	CGameActionData.setResName(ptr, "zhuanshen");
	CGameActionData.addTag(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.addTag(ptr, CGameAction.ACTION_RUN);
	CGameActionData.setLoop(ptr, false);
	--CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_IDLE);
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_RUN);
	CGameActionCondition.addBlackTag(condPtr, CGameAction.ACTION_VEER);
	
	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);
end

function C:createJump()
	local ptr = createDefaultJumpActionData();
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setResName(ptr, "tiaoyue");
	local linkName = CGameAction.ACTION_JUMP.."-2";
	CGameActionData.setLinkName(ptr, linkName);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "jump"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);

	local ptr = createDefaultJumpActionData();
	CGameActionData.setName(ptr, linkName);
	CGameActionData.setResName(ptr, "tiaoyue_chixu");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createJumpMore()
	local ptr = createDefaultJumpMoreActionData();
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setResName(ptr, "tiaoyue_2duan");
	local linkName = CGameAction.ACTION_JUMP_MORE.."-2";
	CGameActionData.setLinkName(ptr, linkName);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "jumpMore"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);

	local ptr = createDefaultJumpMoreActionData();
	CGameActionData.setName(ptr, linkName);
	CGameActionData.setResName(ptr, "tiaoyue_chixu");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createFall()
	local ptr = createDefaultFallActionData();
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setResName(ptr, "xialuo_qianyao");
	local linkName = CGameAction.ACTION_FALL.."-2";
	CGameActionData.setLinkName(ptr, linkName);

	CCharacterData.setActionData(self.characterDataPtr, ptr);

	local ptr = createDefaultFallActionData();
	CGameActionData.setName(ptr, linkName);
	CGameActionData.setResName(ptr, "xialuo_chixu");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createKick()
	local ptr = createDefaultKickActionData();
	CGameActionData.setResName(ptr, "xiati");
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setATKFactor(ptr, 0, 0.0, 0.1);

	CGameActionData.setSharedData(ptr, SHARE_DATA_KEY_KICK_SUFFER_CLIP, "70");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSlideTrackle()
	local ptr = createDefaultSlideTrackleActionData();
	CGameActionData.setResName(ptr, "huachan");
	CGameActionData.setScriptName(ptr, "SlideTrackle", true);
	CGameActionData.addTag(ptr, CGameAction.ACTION_SQUAT);
	--CGameActionData.setSpeed(ptr, 1.8);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setATKFactor(ptr, 0, 0.0, 0.1);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "slideTrackle"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDodge()
	local ptr = createDefaultDodgeActionData();
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setResName(ptr, "houche");
	CGameActionData.setSharedData(ptr, "unlockTime", tostring(0.33));

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "dodge"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSquat()
	local ptr = createDefaultSquatActionData();
	CGameActionData.setResName(ptr, "xiadun");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createLanding()
	local ptr = createDefaultLandingActionData();
	CGameActionData.setResName(ptr, "luodi_yingzhi");
	CGameActionData.addTag(ptr, CGameAction.ACTION_SQUAT);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createMagicWeapon()
	local ptr = createDefaultSkillActionData(MAGIC_WEAPON_ACTION_INDEX);
	CGameActionData.setResName(ptr, "zhanli_gongji");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.addTag(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());

	CCharacterData.setActionData(self.characterDataPtr, ptr);

	local ptr = createDefaultSkillActionData(MAGIC_WEAPON_ACTION_INDEX);
	CGameActionData.setResName(ptr, "xiadun_gongji");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.addTag(ptr, CGameAction.ACTION_SQUAT);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());
	--CGameActionData.setKeepTime(ptr, 0.5);

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_SQUAT);

	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);

	local ptr = createDefaultSkillActionData(MAGIC_WEAPON_ACTION_INDEX);
	CGameActionData.setResName(ptr, "tiaoyue_gongji");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.addTag(ptr, CGameAction.ACTION_JUMP);
	CGameActionData.addTag(ptr, CGameAction.ACTION_JUMP_MORE);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_JUMP);
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_JUMP_MORE);

	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);

	local ptr = createDefaultSkillActionData(MAGIC_WEAPON_ACTION_INDEX);
	CGameActionData.setResName(ptr, "xialuo_gongji");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.addTag(ptr, CGameAction.ACTION_FALL);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_FALL);

	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);
end

function C:createSword()
	local ptr = createDefaultSkillActionData(SWORD_ACTION_INDEX);
	CGameActionData.setResName(ptr, "zhanli_wuqi_gongji");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.addTag(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());

	CCharacterData.setActionData(self.characterDataPtr, ptr);

	local ptr = createDefaultSkillActionData(SWORD_ACTION_INDEX);
	CGameActionData.setResName(ptr, "xiadun_wuqi_gongji");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.addTag(ptr, CGameAction.ACTION_SQUAT);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());
	--CGameActionData.setKeepTime(ptr, 0.5);

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_SQUAT);

	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);

	local ptr = createDefaultSkillActionData(SWORD_ACTION_INDEX);
	CGameActionData.setResName(ptr, "tiaoyue_wuqi_gongji");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.addTag(ptr, CGameAction.ACTION_JUMP);
	CGameActionData.addTag(ptr, CGameAction.ACTION_JUMP_MORE);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_JUMP);
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_JUMP_MORE);

	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);

	local ptr = createDefaultSkillActionData(SWORD_ACTION_INDEX);
	CGameActionData.setResName(ptr, "xialuo_wuqi_gongji");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.addTag(ptr, CGameAction.ACTION_FALL);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_FALL);

	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);
end

function C:createMagic()
	local ptr = createDefaultSkillActionData(MAGIC_ACTION_INDEX);
	CGameActionData.setResName(ptr, "zhanli_shifa");
	CGameActionData.addTag(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());
	--CGameActionData.setSpeed(ptr, 1.5);

	CCharacterData.setActionData(self.characterDataPtr, ptr);

	local ptr = createDefaultSkillActionData(MAGIC_ACTION_INDEX);
	CGameActionData.setResName(ptr, "xiadun_shifa");
	CGameActionData.addTag(ptr, CGameAction.ACTION_SQUAT);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());
	--CGameActionData.setKeepTime(ptr, 0.5);

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_SQUAT);

	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);

	local ptr = createDefaultSkillActionData(MAGIC_ACTION_INDEX);
	CGameActionData.setResName(ptr, "tiaoyue_shifa");
	CGameActionData.addTag(ptr, CGameAction.ACTION_JUMP);
	CGameActionData.addTag(ptr, CGameAction.ACTION_JUMP_MORE);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_JUMP);
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_JUMP_MORE);

	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);

	local ptr = createDefaultSkillActionData(MAGIC_ACTION_INDEX);
	CGameActionData.setResName(ptr, "xialuo_shifa");
	CGameActionData.addTag(ptr, CGameAction.ACTION_FALL);
	CGameActionData.addSound(ptr, self:_createAtkSoundConfig());

	local condPtr = CGameActionCondition.create();
	CGameActionCondition.addWhiteOrTag(condPtr, CGameAction.ACTION_FALL);

	CCharacterData.setActionData(self.characterDataPtr, ptr, condPtr);
end

function C:createHurt()
	local ptr = createDefaultHurtActionData();
	CGameActionData.setResName(ptr, "shouji");
	--CGameActionData.setSpeed(ptr, 2.0);

	local scPtr = CSoundPackage.create();
	for i = 1, 5 do
		CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "hurt"..tostring(i)));
	end
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "die"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:_createAtkSoundConfig()
	local ptr = CSoundPackage.create();
	for i = 1, 5 do
		CSoundPackage.add(ptr, CGameResource.getCharacterSoundFile(self.id, "atk"..tostring(i)), 0.8);
	end
	CSoundPackage.add(ptr, "");
	CSoundPackage.add(ptr, "");
	CSoundPackage.add(ptr, "");
	CSoundPackage.add(ptr, "");
	CSoundPackage.add(ptr, "");
	CSoundPackage.add(ptr, "");
	return ptr;
end
