--change color buff
local C = registerClassAuto(getClass(BUFF_PACKAGE, BUFF_BASE));

function C:ctor()
	self.KEY_HEAD = "clr";
end

function C:awake(buffPtr)
	local b = super.awake(self, buffPtr);

	CBuff.setKind(self.buffPtr, 2);

	local value = CBuff.getSharedData(buffPtr, "r");
	if value == "" then
		self.r = 1.0;
	else
		self.r = tonumber(value);
	end

	local value = CBuff.getSharedData(buffPtr, "g");
	if value == "" then
		self.g = 0.2;
	else
		self.g = tonumber(value);
	end

	local value = CBuff.getSharedData(buffPtr, "b");
	if value == "" then
		self.b = 0.2;
	else
		self.b = tonumber(value);
	end

	local value = CBuff.getSharedData(buffPtr, "a");
	if value == "" then
		self.a = 1.0;
	else
		self.a = tonumber(value);
	end

	self.colorPtr = nil;

	self.insKey = self.KEY_HEAD..CChapterScene.generateInstanceID("Buff_"..self.KEY_HEAD);

	return b;
end

function C:start()
	self.managerPtr = CBuff.getBuffManagerPtr(self.buffPtr);
	self.colorPtr = CGameColor4F.create();
	self.done = false;
end

function C:tick(time)
	local r = CBuff.getCurrentTime(self.buffPtr) / CBuff.getTotalTime(self.buffPtr);
	if r >= 1.0 then
		r = 1.0;
		self.done = true;
	end

	CGameColor4F.set(self.colorPtr, self.r + (1.0 - self.r) * r, self.g + (1.0 - self.g) * r, self.b + (1.0 - self.b) * r, self.a + (1.0 - self.a) * r);
	CBuffManager.changeColor(self.managerPtr, self.insKey, self.colorPtr);
end

function C:isDone(result)
	return true, self.done;
end

function C:dispose()
	if self.colorPtr ~= nil then
		CBuffManager.changeColor(self.managerPtr, self.insKey, nil);
		CGameColor4F.free(self.colorPtr);
		self.colorPtr = nil;
	end

	return true;
end
