--ActionControllerBase
local C = registerClassAuto();

function C:ctor()
end

function C:awake(controllerPtr)
	self.controllerPtr = controllerPtr;
	self.entityPtr = CGameActionController.getEntityPtr(controllerPtr);
end

function C:update()
	return false;
end

function C:changedPhysicsState()
end

function C:dispose()
	return true;
end
