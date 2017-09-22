--HornBeast Die
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(actionPtr);

	self.step = 0;
	self.particleDissipatePtr = nil;

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setDoneActionChanged(ptr, true);

	CBullet.createBullet(CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr)).."/3", self.entityPtr, ptr, nil, 0, CChapterScene.getEffectPosteriorLayerPtr());
end

function C:tick(time)
	if self.step == 0 then
		if CGameAnimate.isDone(self.animatePtr) then
			self.step = 1;

			local dcPtr = CEntity.getDisplayContentPtr(self.entityPtr);

			local pdPtr = CParticleDissipate.create();
			self.particleDissipatePtr = pdPtr;
			CParticleDissipate.start(pdPtr, dcPtr, 4.0, 1.5, 0.0, 460.0, 0.0, 400.0, 0.02, 0.0, 0.05);

			CGameNode.addChild(dcPtr, CParticleDissipate.getDisplayPtr(pdPtr));

			local disPtr = CGameAction.getDisplayPtr(self.actionPtr);
			CGameNode.setVisible(disPtr, false);
		end
	else
		CParticleDissipate.tick(self.particleDissipatePtr, time);
	end
end

function C:dispose()
	if self.particleDissipatePtr ~= nil then
		CParticleDissipate.free(self.particleDissipatePtr);
		self.particleDissipatePtr = nil;
	end
	return true;
end

function C:isDone(result)
	if self.step == 0 then
		return true, false;
	else
		return true, CParticleDissipate.isDone(self.particleDissipatePtr);
	end
end
