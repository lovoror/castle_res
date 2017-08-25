local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
end

--[[
function C:damage(attackDataPtr)
	local x, y = CAttackData.getHitPosition(attackDataPtr);

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, x, y, true);
	CBulletBehaviorController.setDoneAnimation(ptr, true);
	CBulletBehaviorController.setAngle(ptr, 360.0 * math.random(), true);
	CBulletBehaviorController.setScale(ptr, 1.4);

	CBullet.createBullet(self.id.."/hit", CAttackData.getAttackerPtr(attackDataPtr), ptr, nil);

	local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "hit"), true);
	CAudioManager.set3DAttributes(chPtr, x, y);
	CAudioManager.setVolume(chPtr, 0.5);
	CAudioManager.setPaused(chPtr, false);

	return true;
end
]]--

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "animation");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	--CGameActionData.setSpeed(ptr, 0.5);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setCollisionForce(ptr, 0, 200.0, 0.0, 0.0, false, 200.0, 0.0, 0.0, false);
	CGameActionData.setWindDamageFactor(ptr, 0, 0.0, 1.0);
	--CGameActionData.setBlockMoveInfluenced(ptr, false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
