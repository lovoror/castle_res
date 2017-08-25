local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
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

	self.resName = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/";

	self.scale = 1.6;
	self.totalTime = 0.0;
	self.curSpriteFrameName = self:_getSpriteFrameName(0.0);

	local spritePtr = CGameSprite.createWithSpriteFrameName(self.resName..self.curSpriteFrameName);
	CGameNode.setScale(spritePtr, self.scale, self.scale);
	CGameSprite.setFilter(spritePtr, CGameFilter.DISTORTION);
	CGameNode.setOpacity(spritePtr, 30);
	CGameNode.addChild(self.disPtr, spritePtr);
	self.spritePtr = spritePtr;

	CGameNode.addChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:tick(time)
	self.totalTime = self.totalTime + time;

	local name = self:_getSpriteFrameName(self.totalTime);

	if self.curSpriteFrameName ~= name then
		self.curSpriteFrameName = name;
		CGameSprite.setSpriteFrameByName(self.spritePtr, self.resName..self.curSpriteFrameName);
	end
end

function C:finish()
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end

function C:_getSpriteFrameName(time)
	local start = 0;
	local num = 22;
	local delay = 0.03;
	local maxTime = num * delay;

	time = time % maxTime;
	local step = toint(math.floor(time / delay));

	local name = "hq";
	if step < 10 then
		name = name.."0";
	end
	name = name..tostring(step);
	return name;
end
