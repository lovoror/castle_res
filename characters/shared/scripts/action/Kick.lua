local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:attacked(attackDataPtr)
	if not self.isAttacked and CAttackData.getValue(attackDataPtr) <= 0 and CAttackData.getType(attackDataPtr) == CBattleNumberTypeEnum.HP then
		self.isAttacked = true;

		self:_createBuff(0.25);
	end
end

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.entityPtr = entityPtr;

	self.isAttacked = false;

	local l, r, u, d = CEntity.getJoyStickButtonPressing(entityPtr);
	if l then
		self.moveX = -1;
	elseif r then
		self.moveX = 1;
	else
		self.moveX = 0;
	end

	self:_createBuff(-1.0);
end

function C:tick(time)
	if time <= 0 then
		return;
	end

	local entityPtr = self.entityPtr;

	if self.moveX == -1 then
		CEntity.appendInstantVelocity(entityPtr, -800, 0);
	elseif self.moveX == 1 then
		CEntity.appendInstantVelocity(entityPtr, 800, 0);
	end
end

function C:finish()
	if not self.isAttacked then
		CEntity.removeBuffsFromKind(self.entityPtr, 4);
	end
end

function C:dispose()
	return true;
end

function C:isDone(result)
	if self.isAttacked then
		return true, true;
	else
		return false, false;
	end
end

function C:getMoveX()
	return self.moveX;
end

function C:_createBuff(time)
	if CEntity.getSufferEnabled(self.entityPtr) then
		local buffPtr = CBuff.create(CEntity.getID(self.entityPtr), 4, time);
		CBuff.setSharedData(buffPtr, SHARE_DATA_KEY_KICK_SUFFER_CLIP, CGameActionData.getSharedData(CGameAction.getActionDataPtr(self.actionPtr), SHARE_DATA_KEY_KICK_SUFFER_CLIP));
		CEntity.addBuff(self.entityPtr, buffPtr);
	end
end