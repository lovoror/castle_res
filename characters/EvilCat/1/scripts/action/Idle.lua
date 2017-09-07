--EvilCat/1 IdleOrDie
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.MAX_DISTANCE = 550.0;
	self.MAX_TIME = 0.333 * 0.5;
	self.LENGTH_PER_SECOND = self.MAX_DISTANCE / self.MAX_TIME;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;
end

function C:attacked(attackDataPtr)
	self.isAttacked = true;
end

function C:start(itemPtr)
	self.init = false;
	self.tickOk = false;
	self.collW = nil;
	self.curScale = 0.0;
	self.isAttacked = false;
	self.backTime = nil;

	CGameNode.addChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:_init()
	if self.init then return; end
	self.init = true;

	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	local ptr = CGameSprite.createWithSpriteFrameName(CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/shetou2");
	CGameNode.setAnchorPoint(ptr, 0.0, 0.5);
	CGameNode.addChild(self.disPtr, ptr);

	local w, h = CGameNode.getContentSize(ptr);
	self.collW = w;
	self.collH = h;

	local px, py = CEntity.getPosition(entityPtr);
	local r = math.rad(-CEntity.getRotation(entityPtr));
	local sx, sy = CEntity.getScale(entityPtr);
	local sinValue = math.sin(r);
	local cosValue = math.cos(r);
	local len = sx * self.MAX_DISTANCE;
	local ex = px + cosValue * len;
	local ey = py + sinValue * len;
	if CEntity.getDirection(entityPtr) == CDirection.LEFT then
		ex = px + px - ex;
	end
	local result, hx, hy = CTileMap.collisionLine(CChapterScene.getTileMapPtr(), px, py, ex, ey, false, false);
	if result then
		self.hitBlockTime = nil;
	else
		local dx = px - hx;
		local dy = py - hy;
		local dis = math.sqrt(dx * dx + dy * dy) / sx;
		self.hitBlockTime = dis / self.LENGTH_PER_SECOND;
	end
end

function C:tick(time)
	if not self.tickOk then self.tickOk = self:isBehaviorControllerInit(CGameAction.getEntityPtr(self.actionPtr)); end
	if not self.tickOk then return; end

	self:_init();

	local at = CGameAction.getAccumulateElapsed(self.actionPtr);

	if self.backTime == nil then
		if self.hitBlockTime ~= nil and at >= self.hitBlockTime then
			self.backTime = self.hitBlockTime;
		else
			if self.isAttacked or at > self.MAX_TIME  then
				self.backTime = at;
				if self.backTime > self.MAX_TIME then
					self.backTime = self.MAX_TIME;
				end
			end
		end
	end

	if self.backTime ~= nil then
		at = at - self.backTime;
		if at >= self.backTime then
			self.curScale = 0.0;
			CGameNode.setScale(self.disPtr, 0.0, 1.0);
			CEntity.setDie(self.entityPtr);
			return;
		else
			 at = self.backTime - at;
		end
	end

	local len = at * self.LENGTH_PER_SECOND;
	self.curScale = len / self.collW;
	CGameNode.setScale(self.disPtr, self.curScale, 1.0);
end

function C:updateColliders()
	if self.collW ~= nil then
		local w = self.collW * self.curScale;
		CGameAction.setCollider(self.actionPtr, 0, w * 0.5, 0.0, 0.0, 1.0, 1.0, 0, w, self.collH, 0);
	end

	return true, true;
end

function C:finish()
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end
