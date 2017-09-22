local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);

	local x, y = CEntity.getPosition(entityPtr);
	local id = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/DieEffect";

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, x, y, true);
	CBulletBehaviorController.setDoneActionChanged(ptr, true);

	CBullet.createBullet(id, entityPtr, ptr, nil, 0, CChapterScene.getEffectPosteriorLayerPtr());
end

function C:dispose()
	return true;
end
