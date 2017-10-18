local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:attacked(attackDataPtr)
	if not self.isAttacked and CAttackData.getValue(attackDataPtr) <= 0 and CAttackData.getType(attackDataPtr) == CBattleNumberType.HP then
		self.isAttacked = true;
	end
end

function C:start(itemPtr)
	self.entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.isAttacked = false;
	self.rotation = 0.0;
end

function C:tileMapTicked(time)
	local r = 0.0;

	if CEntity.getPhysicsState(self.entityPtr) == CPhysicsState.STAND then
		local x, y = CEntity.getStandVector(self.entityPtr);
		if y < 0.0 and x ~= 0.0 then
			r = math.deg(math.atan(-x, -y));
			if CEntity.getDirection(self.entityPtr) == CDirection.LEFT then
				 r = -r;
			end
		end
	end

	if self.rotation ~= r then
		self:_restoreRotation();
		self.rotation = r;

		CEntity.setRotation(self.entityPtr, CEntity.getRotation(self.entityPtr) + self.rotation);
	end
end

function C:finish()
	self:_restoreRotation();

	CEntity.setSlideTackleCD(CGameAction.getEntityPtr(self.actionPtr), 0.3);
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

function C:_restoreRotation()
	if self.rotation ~= 0.0 then
		local r = CEntity.getRotation(self.entityPtr) - self.rotation;
		if r ~= 0.0 and r <= 0.01 and r >= 0.01 then
			r = 0.0;
		end
		CEntity.setRotation(self.entityPtr, r);
		self.rotation = 0.0;
	end
end