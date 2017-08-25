local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.SHOOTING_TIME = SWORD_SHOOTING_TIME;
	--self.INSTRUCTION0_NEED_MP = 10.0;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.enabled = false;
	self.shot = false;
	--self.shot2 = false;
	self.time = 0.0;
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
	self.shot = false;
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
		if not self.shot then
			self.shot = true;

			local itemPtr = self.itemPtr;

			local ptr = CBulletBehaviorController.create();
			CBulletBehaviorController.setStartTime(ptr, time);
			CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0);
			CBulletBehaviorController.setFollowOwner(ptr, true, 0.2);
			CBulletBehaviorController.setDoneAnimation(ptr, true);

			local entityPtr = CItem.getEntityPtr(itemPtr);
			local baPtr = CEntity.getBattleAttributePtr(entityPtr);
			local mat = CBattleAttribute.getFinalMAT(baPtr);
			local count = CItem.getCurrentTotalCount(self.itemPtr);
			mat = mat + count * 0.1;
			
			CBulletBehaviorController.setATKFactor(ptr, 0.0, 0.0);
			CBulletBehaviorController.setMATFactor(ptr, mat * 0.25, 0.0);
			CBulletBehaviorController.setMPPFactor(ptr, 0.3 + count * 0.001, 1.0);
			CBulletBehaviorController.setWindDamageFactor(ptr, mat * 0.25, 1.0);
			
			CBullet.createBullet(CItem.getRes(itemPtr), entityPtr, ptr, itemPtr);
		end
	end
end

function C:actionEnd()
	self.enabled = false;
end
