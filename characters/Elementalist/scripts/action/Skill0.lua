--Elementlist:Skill0
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:isCancel(tag, itemPtr)
	if tag == MAGIC_ACTION_INDEX then
		return true;
	else
		return false;
	end
end

function C:dispose()
	return true;
end
