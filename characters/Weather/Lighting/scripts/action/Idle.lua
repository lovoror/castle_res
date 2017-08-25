--Weater/Lighting Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.MIN_TIME = 10.0;
	self.MAX_TIME = 20.0;
	self.NUM_ACTIONS = 3;
end

function C:start(itemPtr)
	self.time = self.MIN_TIME + math.random() * (self.MAX_TIME - self.MIN_TIME);
end

function C:tick(time)
	self.time = self.time - time;
	if self.time <= 0.0 then
		local entityPtr = CGameAction.getEntityPtr(self.actionPtr);
		if math.random() < 0.5 then
			CEntity.setDirection(entityPtr, CDirectionEnum.LEFT);
		else
			CEntity.setDirection(entityPtr, CDirectionEnum.RIGHT);
		end
		
		local px, py = CEntity.getCreatePosition(entityPtr);
		CEntity.setPosition(entityPtr, px - 320.0 + math.random() * 640.0, py);

		CGameActionController.changeAction(CEntity.getActionControllerPtr(entityPtr), CGameAction.ACTION_SKILL..tostring(toint(math.floor(math.random() * self.NUM_ACTIONS))));
	end
end

function C:dispose()
	return true;
end
