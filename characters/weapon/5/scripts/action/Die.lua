local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.ROTATION = 360.0;

	self.SYMBOL_DOINE_TIME = 0.2;
	self.SRIPPLE_DOINE_TIME = 0.5;
	self.SRIPPLE_MAX_SCALE = 1.5;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;

	self.init = false;
	self.done = false;
	self.wavePtr = nil;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;

	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	self.tickOk = false;
	self.curTime = 0.0;

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);
end

function C:_init()
	if self.init then return end;
	self.init = true;

	local entityPtr = self.entityPtr;

	local number = CEntity.getSharedData(entityPtr, "number");
	local id = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr));
	local res = id.."/";
	self.symbolPtr = CGameSprite.createWithSpriteFrameName(res..number);
	--CGameSprite.setBlendFunc(self.symbolPtr, CGameSprite.BLEND_ADD);
	CGameNode.addChild(self.disPtr, self.symbolPtr);
	self.ripplePtr = CGameSprite.createWithSpriteFrameName(res.."xs");
	CGameNode.setScale(self.ripplePtr, 0.0, 0.0);
	CGameNode.addChild(self.disPtr, self.ripplePtr);

	local sx, sy = CEntity.getScale(entityPtr);
	self.waveScale = sx;
	self.waveAlpha = 0.5;
	self.wavePtr = CGameSprite.createWithSpriteFrameName(res.."wave");
	CGameRef.retain(self.wavePtr);
	CGameSprite.setFilter(self.wavePtr, CGameFilter.DISTORTION);
	CGameNode.setScale(self.wavePtr, 0.0, 0.0);
	CGameNode.addChild(CChapterScene.getDistortionLayerPtr(), self.wavePtr);

	CGameNode.setRotation(self.symbolPtr, tonumber(CEntity.getSharedData(entityPtr, "rotation")));

	CEntity.playSound(entityPtr, CGameResource.getCharacterSoundFile(id, "die"), 0.5);
end

function C:tick(time)
	local entityPtr = self.entityPtr;

	if not self.tickOk then self.tickOk = self:isBehaviorControllerInit(entityPtr); end
	if not self.tickOk then return; end

	self:_init();

	self.curTime = self.curTime + time;

	local a = self.curTime / self.SYMBOL_DOINE_TIME;
	if a > 1.0 then a = 1.0 end;
	a = 1.0 - a;
	CGameNode.setOpacity(self.symbolPtr, a * 255.0);

	a = self.curTime / self.SRIPPLE_DOINE_TIME;
	if a > 1.0 then a = 1.0 end;
	local s = self.SRIPPLE_MAX_SCALE  * a;
	a = 1.0 - a;
	CGameNode.setScale(self.ripplePtr, s, s);
	CGameNode.setOpacity(self.ripplePtr, a * 255.0);

	local px, py = CEntity.getPosition(entityPtr);
	local s1 = s * self.waveScale;
	CGameNode.setOpacity(self.wavePtr, self.waveAlpha * a * 255.0);
	CGameNode.setScale(self.wavePtr, s1, s1);
	CGameNode.setPosition(self.wavePtr, px, py);

	if a <= 0.0 then
		self.done = true;
	end

	CGameNode.setRotation(self.symbolPtr, (CGameNode.getRotation(self.symbolPtr) + self.ROTATION * time) % 360.0);
end

function C:isDone(result)
	return true, self.done;
end

function C:finish()
	if self.wavePtr ~= nil then
		CGameNode.removeFromParent(self.wavePtr);
		CGameRef.release(self.wavePtr);
		self.wavePtr = nil;
	end
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end
