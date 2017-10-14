local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.entityPtr = entityPtr;

	local prevActPtr = CGameActionController.getPrevActionPtr(CEntity.getActionControllerPtr(entityPtr));

	if CGameAction.getTag(prevActPtr) == CGameAction.ACTION_KICK then
		local prevAct = CGameAction.getScript(prevActPtr);
		if prevAct ~= nil and prevAct.getMoveX ~= nil then
			local x = prevAct:getMoveX();
			if x == 1 then
				CEntity.appendResistanceVelocity(entityPtr, 200, 0);
			elseif x == -1 then
				CEntity.appendResistanceVelocity(entityPtr, -200, 0);
			end
		end
	end
end

function C:isDone(result)
	local entityPtr = self.entityPtr;

	if CEntity.getPhysicsState(entityPtr) == CPhysicsState.STAND then
		local x, y = CEntity.getResistanceVelocity(entityPtr) ;
		if x == 0 then
			return false, false;
		else
			return true, false;
		end
	else
		return true, true;
	end
end

function C:isCancel(tagPtr, itemPtr)
	if CGameActionTag.hasTagByString(tagPtr, CGameAction.ACTION_SLIDE_TACKLE) then
		return true;
	else
		return false;
	end
end

function C:dispose()
	return true;
end
