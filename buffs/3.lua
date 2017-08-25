--change spd buff
local C = registerClassAuto(getClass(BUFF_PACKAGE, BUFF_BASE));

function C:ctor()
	self.PER_ADD_SPD = 12.0;
end

function C:awake(buffPtr)
	local b = super.awake(self, buffPtr);

	CBuff.setKind(self.buffPtr, 3);

	local value = CBuff.getSharedData(buffPtr, "lv");
	if value == "" then
		lv = 1.0;
	else
		lv = tonumber(value);
	end

	self.maxAddSpd = lv * self.PER_ADD_SPD;
	self.curAddSpd = 0.0;
	self.managerPtr = nil;

	return b;
end

function C:start()
	self.managerPtr = CBuff.getBuffManagerPtr(self.buffPtr);
	self.done = false;
end

function C:tick(time)
	local r = CBuff.getCurrentTime(self.buffPtr) / CBuff.getTotalTime(self.buffPtr);
	if r >= 1.0 then
		r = 1.0;
		self.done = true;
	end

	local newAddSpd = self.maxAddSpd - self.maxAddSpd * r;

	CBuffManager.changeSPD(self.managerPtr, newAddSpd - self.curAddSpd);
	self.curAddSpd = newAddSpd;
	--CGameDebugger.print(tostring(self.curAddSpd));
end

function C:isDone(result)
	return true, self.done;
end

function C:dispose()
	if self.managerPtr ~= nil then
		CBuffManager.changeSPD(self.managerPtr, -self.curAddSpd);
		self.managerPtr = nil;
	end

	return true;
end
