--Elementlist:Skill0
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:isCancel(tag, itemPtr)
	if tag == CGameAction.ACTION_SKILL.."1" then
		return true;
	else
		return false;
	end
end

function C:dispose()
	return true;
end
