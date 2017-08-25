local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:updateColliders()
	CGameAction.setCollider(self.actionPtr, 0, 0.0, 0.0, 0.0, 1.0, 1.0, 0, 10.0, 10.0, 0);

	return true, true;
end

function C:dispose()
	return true;
end
