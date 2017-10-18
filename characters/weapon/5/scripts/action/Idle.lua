local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.ROTATION = 360.0;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;

	CGameAction.setUpdateBodyShapeEnabled(actionPtr, false);

	self.init = false;
	self.collW = nil;
end

function C:attacked(attackDataPtr)
	CEntity.setSharedData(self.entityPtr, "atk", "1");
	CEntity.setDie(self.entityPtr);
end

function C:start(itemPtr)
	self.tickOk = false;

	local actionPtr = self.actionPtr;

	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	local number = CEntity.getSharedData(entityPtr, "number");
	self.number = number;
	local res = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/";
	self.symbolPtr = CGameSprite.createWithSpriteFrameName(res..number);
	--CGameSprite.setFilter(self.symbolPtr, CGameFilter.ADDITIVE);
	CGameNode.addChild(self.disPtr, self.symbolPtr);

	local w, h = CGameNode.getContentSize(self.symbolPtr);
	local halfW = w * 0.7 * 0.5;
	local halfH = h * 0.7 * 0.5;
	self.collW = w * 0.95;
	self.collH = h * 0.95;
	CEntity.setBodyShape(entityPtr, CBodyShapeType.BOX, -halfW, -halfH, halfW, halfH, 1.0, 1.0);

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);
end

function C:_init()
	if self.init then return end;
	self.init = true;

	local entityPtr = self.entityPtr;

	CEntity.playSelfSound(entityPtr, tostring(toint(self.number) + 1), 0.5);
end

function C:tick(time)
	local entityPtr = self.entityPtr;

	if not self.tickOk then self.tickOk = self:isBehaviorControllerInit(entityPtr); end
	if not self.tickOk then return; end

	self:_init();

	CGameNode.setRotation(self.symbolPtr, (CGameNode.getRotation(self.symbolPtr) + self.ROTATION * time) % 360.0);
end

function C:updateColliders()
	if self.collW ~= nil then
		CGameAction.setCollider(self.actionPtr, 0, 0.0, 0.0, 0.0, 1.0, 1.0, 0, self.collW - 4, self.collH - 4, 0);
	end

	return true, true;
end

function C:finish()
	CEntity.setSharedData(self.entityPtr, "rotation", tostring(CGameNode.getRotation(self.symbolPtr)));
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end
