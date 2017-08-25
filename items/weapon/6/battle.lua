local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.SHOOTING_TIME = SWORD_SHOOTING_TIME;
	--self.INSTRUCTION0_NEED_MP = 10.0;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.enabled = false;
	self.shot1 = false;
	--self.shot2 = false;
	self.time = 0;
	--self.instruction0ID = 0;
	--self.instruction0Ok = 0;
end

--[[
function C:equipment(count)
	super.equipment(self, count);

	if count == 1 then
		if CEntity.isHost(self.entityPtr) then
			local formulaPtr = createInstructionFormula_DFX(CGameKeyButtonFlag.ATTACK);
			CInstructionFormula.setHandler(formulaPtr, CItem.getBattleScriptRef(self.itemPtr), "_instruction0Handler");
			self.instruction0ID = CEntity.registerInstructionFormula(self.entityPtr, formulaPtr);
		end
	end
end
]]--

--[[
function C:discharge(count)
	super.discharge(self, count);

	if count == 0 then
		CEntity.unregisterInstructionFormula(self.entityPtr, self.instruction0ID);
	end
end

function C:_instruction0Handler()
	if not self.enabled then
		self.instruction0Ok = 1;
	end
end
]]--

function C:getSkillTag()
	return CGameAction.ACTION_SKILL..SWORD_ACTION_INDEX;
end

function C:useCondition()
	--if self.instruction0Ok and CEntity.getMP(self.entityPtr) < self.INSTRUCTION0_NEED_MP then
	--	self.instruction0Ok = 0;
	--end

	return true;
end

function C:use()
	self.enabled = true;
	self.shot1 = false;
	self.shot2 = false;
	self.time = 0.0;

	--if self.instruction0Ok == 1 then
	--	self.instruction0Ok = 2;
	--else
	--	self.instruction0Ok = 0;
	--end
end

--[[
function C:collectSync(bytesPtr)
	CByteArray.writeUInt8(bytesPtr, self.instruction0Ok);
end

function C:executeSync(bytesPtr)
	self.instruction0Ok = CByteArray.readUInt8(bytesPtr);
end
]]--

function C:preBattle(time)
	if self.enabled then
		if not self.shot1 then
			self.shot1 = true;

			local itemPtr = self.itemPtr;

			local ptr = CBulletBehaviorController.create();
			CBulletBehaviorController.setStartTime(ptr, time);
			CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
			CBulletBehaviorController.setFollowOwner(ptr, true);
			CBulletBehaviorController.setDoneAnimation(ptr, true);
			CBulletBehaviorController.setDoneAction(ptr, true);
			CBulletBehaviorController.setFixedMoveableDirection(ptr, true);
			--local scPtr = CSoundPackage.create();
			--CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(res, "1"));
			--CBulletBehaviorController.setStartSound(ptr, scPtr);
			--CBulletBehaviorController.setGravityScale(ptr, 0, 0);
			--CBulletBehaviorController.setAngle(ptr, 30, true);

			CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.5);
			CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.5);

			CBullet.createBullet(CItem.getRes(itemPtr), CItem.getEntityPtr(itemPtr), ptr, itemPtr);
		end

		--[[
		if not self.shot2 then
			self.time = self.time + time;
			local t = self.time - self.SHOOTING_TIME;
			if t >= 0 then
				self.shot2 = true;

				local itemPtr = self.itemPtr;
				local res = CItem.getRes(itemPtr);

				local ptr = CBulletBehaviorController.create();
				CBulletBehaviorController.setInitActionTag(ptr, CGameAction.ACTION_SKILL.."0");
				CBulletBehaviorController.setStartTime(ptr, t);
				CBulletBehaviorController.setAlphaDodgeWhenDone(ptr, 0.2);
				CBulletBehaviorController.setAttackDisabledWithAlpha(ptr, 0.1);
				CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
				if self.instruction0Ok == 2 then
					CEntity.appendMP(self.entityPtr, -self.INSTRUCTION0_NEED_MP);
					CBulletBehaviorController.setAlphaDodge(ptr, 0.8);
					CBulletBehaviorController.setDoneTime(ptr, 1.0);

					local scPtr = CSoundPackage.create();
					CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(res, "2"));
					CBulletBehaviorController.setStartSound(ptr, scPtr);

					CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.5);
				else
					CBulletBehaviorController.setAlphaDodge(ptr, 0.0);
					CBulletBehaviorController.setDoneTime(ptr, 0.2);

					CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.45);
				end
				CBulletBehaviorController.setDoneHitBlock(ptr, true, false);
				--CBulletBehaviorController.setDoneAnimation(ptr, true);
				CBulletBehaviorController.setVelocity(ptr, 600.0);
				CBulletBehaviorController.setFixedMoveableDirection(ptr, true);

				CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.0);

				CBullet.createBullet(res, CItem.getEntityPtr(itemPtr), ptr, itemPtr);
			end
		end
		]]--
	end
end

function C:actionEnd()
	self.enabled = false;
end
