--Battery Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	local bonePtr = CGameAnimate.getBonePtr(CGameAction.getAnimatePtr(actionPtr), "paotong_program");
	local value = CEntity.getSharedData(entityPtr, "rotation");
	if value == "" then
		self.rotation = 90.0;
	else
		self.rotation = tonumber(value);
	end

	CGameSpineBone.setRotation(bonePtr, self.rotation);
end

function C:finish()
	CEntity.setSharedData(self.entityPtr, "rotation", tostring(self.rotation));
end

function C:dispose()
	return true;
end
