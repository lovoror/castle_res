--ButtonSwitcher
local C = registerClassAuto(getClass(AI_PACKAGE, AI_BASE));

function C:ctor()
	self.TRIGGER_SWITCH_ON = "Switch_on";
	self.TRIGGER_SWITCH_OFF = "Switch_off";
end

function C:awake(executorPtr)
	super.awake(self, executorPtr);

	self.entityPtr = CAIExecutor.getEntityPtr(self.executorPtr);

	self.isOn = 0;
end

function C:tick(time)
	if self.isOn == 1 then
		self.isOn = 2;
	elseif self.isOn == 2 then
		self.isOn = 0;
		CGameActionController.changeAction(CEntity.getActionControllerPtr(self.entityPtr), CGameAction.ACTION_SKILL.."1", true, true);

		CEntityTrigger.sendTrigger(self.entityPtr, self.TRIGGER_SWITCH_OFF, "0");
	end
end

function C:attacking(attackDataPtr)
	if self.isOn == 0 then
		CGameActionController.changeAction(CEntity.getActionControllerPtr(self.entityPtr), CGameAction.ACTION_SKILL.."0", true, true);

		CEntityTrigger.sendTrigger(self.entityPtr, self.TRIGGER_SWITCH_ON, "1");
	end
	
	self.isOn = 1;

	return CCollisionResult.FAILED;
end
