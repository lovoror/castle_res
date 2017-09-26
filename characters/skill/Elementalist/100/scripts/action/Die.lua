--skill\Elementalist\100 Die
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setDoneActionChanged(ptr, true);
	CBullet.createBullet(CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/DieEffect", entityPtr, ptr, nil, 0, CEntity.getLayerPtr(entityPtr));
end

function C:dispose()
	return true;
end
