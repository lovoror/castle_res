local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/hit");

	for i = 1, 7 do
		CCharacterData.loadSound(characterDataPtr, tostring(i), SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	end
	CCharacterData.loadSound(characterDataPtr, "die", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self.id= CCharacterData.getName(characterDataPtr);

	self:createIdle();
	self:createDie();
end

function C:damage(attackDataPtr)
	local x, y = CAttackData.getHitPosition(attackDataPtr);

	local attackerPtr = CAttackData.getAttackerPtr(attackDataPtr);
	local number = CEntity.getSharedData(attackerPtr, "number");

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, x, y, true);
	CBulletBehaviorController.setDoneAnimation(ptr, true);

	local bulletPtr = CBullet.createBullet(self.id.."/hit", attackerPtr, ptr, nil);
	if number == "1" then
		CEntity.setColor(bulletPtr, 0.0, 1.0, 0.0);
	elseif number == "2" then
		CEntity.setColor(bulletPtr, 0.0, 0.86, 1.0);
	elseif number == "3" then
		CEntity.setColor(bulletPtr, 1.0, 1.0, 0.0);
	elseif number == "4" then
		CEntity.setColor(bulletPtr, 1.0, 0.0, 1.0);
	elseif number == "5" then
		CEntity.setColor(bulletPtr, 1.0, 0.45, 0.0);
	elseif number == "6" then
		CEntity.setColor(bulletPtr, 1.0, 0.0, 0.0);
	end

	return true;
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setLock(ptr, true);
	CGameActionData.setScriptName(ptr, "Idle", false);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setBlockMoveInfluenced(ptr, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setScriptName(ptr, "Die", false);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
