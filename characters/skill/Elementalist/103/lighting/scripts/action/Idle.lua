local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.MIN_ALPHA = 0.7;
	self.TIME = 0.1;
	self.DIE_TIME = 0.5;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameNode.setCascadeOpacityEnabled(disPtr, true);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;
end

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);
	self.entityPtr = entityPtr;
	self.animatePtr = CGameAction.getAnimatePtr(self.actionPtr);

	self.isDie = CEntity.getSharedData(entityPtr, "die") == "true";

	local scale;
	if self.isDie then
		scale = 6.0;
	else
		scale = 3.0;
	end

	local resName = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/lighting";

	local ltPtr = CGameSprite.createWithSpriteFrameName(resName);
	CGameNode.setAnchorPoint(ltPtr, 1.0, 0.0);
	CGameNode.setScale(ltPtr, scale, scale);
	CGameSprite.setFilter(ltPtr, CGameFilter.COLOR_DODGE);
	CGameNode.addChild(self.disPtr, ltPtr);

	local rtPtr = CGameSprite.createWithSpriteFrameName(resName);
	CGameNode.setAnchorPoint(rtPtr, 1.0, 0.0);
	CGameNode.setScale(rtPtr, -1.0 * scale, scale);
	CGameSprite.setFilter(rtPtr, CGameFilter.COLOR_DODGE);
	CGameNode.addChild(self.disPtr, rtPtr);

	local lbPtr = CGameSprite.createWithSpriteFrameName(resName);
	CGameNode.setAnchorPoint(lbPtr, 1.0, 0.0);
	CGameNode.setScale(lbPtr, scale, -1.0 * scale);
	CGameSprite.setFilter(lbPtr, CGameFilter.COLOR_DODGE);
	CGameNode.addChild(self.disPtr, lbPtr);

	local rbPtr = CGameSprite.createWithSpriteFrameName(resName);
	CGameNode.setAnchorPoint(rbPtr, 1.0, 0.0);
	CGameNode.setScale(rbPtr, -1.0 * scale, -1.0 * scale);
	CGameSprite.setFilter(rbPtr, CGameFilter.COLOR_DODGE);
	CGameNode.addChild(self.disPtr, rbPtr);

	CGameNode.addChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);

	self.time = 0.0;
	self.step = 0;
end

function C:tick(time)
	local a ;

	if self.isDie then
		local ownerPtr = CEntity.getOwnerPtr(self.entityPtr);
		local actPtr = CEntity.getCurrentActionPtr(ownerPtr);
		local ratio = CGameAnimate.getElapsedRatio(self.animatePtr);
		if ratio >= 0.5 then
			self.time = self.time + time;
			a = self.time / self.DIE_TIME;
			if a >= 1.0 then
				a = 1.0;
				CEntity.setDie(self.entityPtr);
			end
			a = 1.0 - a;
			CGameNode.setOpacity(self.disPtr, a * 255);
		end
	else
		self.time = self.time + time;
		a = self.time / self.TIME;
		if self.step == 0 then
			if a >= 1.0 then
				a = 1.0;
				self.step = 1;
				self.time = 0.0;
			end

			a = 1.0 - a;
		else
			if a >= 1.0 then
				a = 1.0;
				self.step = 0;
				self.time = 0.0;
			end
		end

		CGameNode.setOpacity(self.disPtr, (self.MIN_ALPHA + (1.0 - self.MIN_ALPHA) * a) * 255);
	end
end

function C:finish()
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end
