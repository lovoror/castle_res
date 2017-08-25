local C = registerClassAuto();

function C:ctor()
end

function C:awake(buffPtr)
	self.buffPtr = buffPtr;
	return true;
end

function C:start()
end

function C:tick(time)
end

function C:isDone(result)
	return false, false
end

function C:dispose()
	return false;
end
