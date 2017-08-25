local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);

	local head = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr));

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setFollowOwner(ptr, true);
	CBulletBehaviorController.setDoneAction(ptr, true);

	local sdPtr = CSharedData.create();
	CSharedData.setSharedData(sdPtr, "die", "true");

	CBullet.createBullet(head.."/Lighting", entityPtr, ptr, nil, 0, CChapterScene.getDynamicLightingLayerPtr(), sdPtr);

	CSharedData.free(sdPtr);

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, 0.0, 0.0, false);
	CBulletBehaviorController.setDoneAnimation(ptr, true);
	
	CBullet.createBullet(head.."/BoomEffect", entityPtr, ptr, nil, 0, CChapterScene.getEffectMiddleLayerPtr());
end

function C:dispose()
	return true;
end
