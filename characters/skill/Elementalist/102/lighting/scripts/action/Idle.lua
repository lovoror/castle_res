local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	--CGameNode.setCascadeOpacityEnabled(disPtr, true);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;
end

function C:start(itemPtr)
	local entityPtr = CGameAction.getEntityPtr(self.actionPtr);

	local scale = 3.0;

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
end

function C:finish()
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end
