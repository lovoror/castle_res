local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:start(itemPtr)
	self.entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.entityType = CEntity.getType(self.entityPtr);
	--self.num = 0;
end

function C:finish()
	if self.entityType == CEntityType.PLAYER then
		CEntity.setHurtProtect(self.entityPtr);
	end
end

function C:isDone(result)
	local entityPtr = self.entityPtr;

	local x, y = CEntity.getResistanceVelocity(entityPtr) ;
	if x ~= 0.0 or y ~= 0.0 then
		return true, false;
	else
		if CEntity.getPhysicsState(entityPtr) == CPhysicsStateEnum.STAND then
			return false, false;
		else
			local x, y = CEntity.getGravityScale(entityPtr) ;
			if y == 0.0 then
				return false, false;
			else
				return true, false;
			end
		end
	end
end

function C:dispose()
	return true;
end
