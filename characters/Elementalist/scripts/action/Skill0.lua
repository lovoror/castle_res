--Elementlist:Skill0
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:isCancel(tagPtr, itemPtr)
	if CGameActionTag.hasTagByString(tagPtr, CGameAction.ACTION_SKILL..MAGIC_ACTION_INDEX) then
		return true;
	else
		return false;
	end
end

function C:dispose()
	return true;
end
