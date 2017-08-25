--SpikeTrap:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.tops = {};

	self.KEY_ELAPSED = "et";
	self.KEY_COOL_DOWN = "cd";
	self.KEY_APPEAR_TIME = "appear";
	self.KEY_DURATION = "dur";
	self.KEY_LENGTH = "len";
	self.KEY_QUANTITY = "n";
	self.KEY_GAP = "gap";

	self.DEFAULT_COOL_DOWN = 1.0;
	self.DEFAULT_APPEAR_TIME = 0.3;
	self.DEFAULT_DURATION = 1.0;
	self.DEFAULT_LENGTH = 60.0;
	self.DEFAULT_QUANTITY = 5;
	self.DEFAULT_GAP = 2.0;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;
	local basesPtr = CGameNode.create();
	CGameNode.setAnchorPoint(basesPtr, 0.0, 0.0);
	CGameNode.setPosition(basesPtr, 0.0, 0.0);
	self.basesPtr = basesPtr;
	local topsPtr = CGameNode.create();
	CGameNode.setAnchorPoint(topsPtr, 0.0, 0.0);
	CGameNode.setPosition(topsPtr, 0.0, 0.0);
	self.topsPtr = topsPtr;
	local leversPtr = CGameNode.create();
	CGameNode.setAnchorPoint(leversPtr, 0.0, 0.0);
	CGameNode.setPosition(leversPtr, 0.0, 0.0);
	CGameNode.setScale(leversPtr, 1.0, 0.0);
	self.leversPtr = leversPtr;
	CGameNode.addChild(disPtr, basesPtr);
	CGameNode.addChild(disPtr, topsPtr);
	CGameNode.addChild(disPtr, leversPtr);

	self.init = false;

	self.maxHeight = self.DEFAULT_LENGTH;
	self.maxTime = self.DEFAULT_APPEAR_TIME;
	self.waitTime = self.DEFAULT_COOL_DOWN;
	self.stayTime = self.DEFAULT_DURATION;
	self.maxNum = self.DEFAULT_QUANTITY;
	self.gap = self.DEFAULT_GAP;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	self.entityPtr = CGameAction.getEntityPtr(actionPtr);

	self.id = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr));

	self:_init();

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);
end

function C:_init()
	if self.init then return; end
	self.init = true;

	local entityPtr = self.entityPtr;

	local value = CEntity.getSharedData(entityPtr, self.KEY_LENGTH);
	if value ~= "" then
		self.maxHeight = tonumber(value);
	end

	local value = CEntity.getSharedData(entityPtr, self.KEY_APPEAR_TIME);
	if value ~= "" then
		self.maxTime = tonumber(value);
	end

	local value = CEntity.getSharedData(entityPtr, self.KEY_COOL_DOWN);
	if value ~= "" then
		self.waitTime = tonumber(value);
	end

	local value = CEntity.getSharedData(entityPtr, self.KEY_DURATION);
	if value ~= "" then
		self.stayTime = tonumber(value);
	end

	local value = CEntity.getSharedData(entityPtr, self.KEY_GAP);
	if value ~= "" then
		self.gap = tonumber(value);
	end

	local value = CEntity.getSharedData(entityPtr, self.KEY_QUANTITY);
	if value ~= "" then
		self.maxNum = tonumber(value);
	end

	if self.maxNum < 1 then
		self.maxNum = 1;
	end

	local disPtr = self.disPtr;
	local basesPtr = self.basesPtr;
	local leversPtr = self.leversPtr;
	local topsPtr = self.topsPtr;

	local resHead = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/";
	for i = 1, self.maxNum do
		local leverPtr = CGameSprite.createWithSpriteFrameName(resHead.."Lever");
		CGameNode.setAnchorPoint(leverPtr, 0.0, 0.0);
		CGameNode.addChild(leversPtr, leverPtr);

		local topPtr = CGameSprite.createWithSpriteFrameName(resHead.."Top");
		CGameNode.setAnchorPoint(topPtr, 0.0, 0.0);
		CGameNode.addChild(topsPtr, topPtr);

		local basePtr = CGameSprite.createWithSpriteFrameName(resHead.."Base");
		CGameNode.setAnchorPoint(basePtr, 0.0, 0.0);
		CGameNode.addChild(basesPtr, basePtr);

		if i == 1 then
			local baseW, baseH = CGameNode.getContentSize(basePtr);
			local leverW, leverH = CGameNode.getContentSize(leverPtr);
			local topW, topH = CGameNode.getContentSize(topPtr);
			self.baseWidth = baseW;
			self.baseHeight = baseH;
			self.leverWidth = leverW;
			self.leverHeight = leverH;
			self.topWidth = topW;
			self.topHeight = topH;
			self.startX = -(self.baseWidth * self.maxNum + self.gap * (self.maxNum - 1)) * 0.5;
		end

		local x = self.startX + self.baseWidth * (i - 1) + self.gap * (i - 1);
		CGameNode.setPosition(basePtr, x, 0.0);
		CGameNode.setPosition(leverPtr, x + (self.baseWidth - self.leverWidth) * 0.5, 0.0);
		CGameNode.setPosition(topPtr, x + (self.baseWidth - self.topWidth) * 0.5, 0.0);

		self.tops[i] = topPtr;
	end

	self.maxHeight = self.maxHeight - self.baseHeight;
	if self.maxHeight < self.baseHeight then
		self.maxHeight = self.baseHeight;
	end

	local value = CEntity.getSharedData(entityPtr, "bodyShape");
	if value == "true" then
		CEntity.setBodyShapeEnabled(entityPtr, false);

		local halfW = self.baseWidth * self.maxNum + self.gap * (self.maxNum - 1) * 0.5;
		CEntity.setBodyShape(entityPtr, CBodyShapeTypeEnum.BOX, -halfW, 0.0, halfW, self.baseHeight, 1.0, 1.0);
	end

	self.step = 0;
	self.curTime = 0.0;
	self.curHeight = 0.0;
	self.curTopHeightScale = 1.0;

	self.isInitTick = true;

	local value = CEntity.getSharedData(entityPtr, self.KEY_ELAPSED);
	if value ~= "" then
		self:tick(tonumber(value));
	end

	self.isInitTick = false;
end

function C:tick(time)
	while time > 0.0 do
		time = time - self:_motion(time);
	end

	self.curHeight = self.curHeight + self.baseHeight;

	if self.curHeight >= self.topHeight then
		--CGameNode.setScale(self.topsPtr, 1.0, 1.0);
		CGameNode.setPosition(self.topsPtr, 0.0, self.curHeight - self.topHeight );
		CGameNode.setScale(self.leversPtr, 1.0, (self.curHeight - self.topHeight) / self.leverHeight);

		if self.curTopHeightScale ~= 1.0 then
			self.curTopHeightScale = 1.0;
			for i = 1, self.maxNum do
				CGameSprite.setSubTextureRect(self.tops[i], 0.0, 0.0, 1.0, 1.0);
			end
		end
	else
		--CGameNode.setScale(self.topsPtr, 1.0, self.curHeight / self.topHeight);
		CGameNode.setPosition(self.topsPtr, 0.0, 0.0);
		CGameNode.setScale(self.leversPtr, 1.0, 0.0);

		local sy = self.curHeight / self.topHeight;
		self.curTopHeightScale = sy;
		for i = 1, self.maxNum do
			CGameSprite.setSubTextureRect(self.tops[i], 0.0, 0.0, 1.0, sy);
		end
	end
end

function C:_motion(time)
	if self.step == 0 then
		self.curHeight = 0.0 ;
		self.curTime = self.curTime + time;
		if self.curTime > self.waitTime then
			local sub = self.curTime - self.waitTime;
			self.step = 1;
			self.curTime = 0.0;

			if not self.isInitTick then
				CEntity.playSound(self.entityPtr, CGameResource.getCharacterSoundFile(self.id, "0"), 1.0, true);
			end

			return time - sub;
		else
			return time;
		end
	elseif self.step == 1 then
		self.curTime = self.curTime + time;
		local t = self.curTime;
		if t > self.maxTime then t = self.maxTime; end

		local h = self.maxHeight * t / self.maxTime;
		--CGameNode.setScale(self.leversPtr, 1, h / self.leverHeight);
		--CGameNode.setPosition(self.topsPtr, 0, h);
		self.curHeight = h;

		if self.curTime >= self.maxTime then
			local sub = self.curTime - self.maxTime;
			self.step = 2;
			self.curTime = 0.0;
			return time - sub;
		else
			return time;
		end
	elseif self.step == 2 then
		self.curHeight = self.maxHeight;
		self.curTime = self.curTime + time;
		if self.curTime > self.stayTime then
			local sub = self.curTime - self.stayTime;
			self.step = 3;
			self.curTime = 0.0;

			if not self.isInitTick then
				CEntity.playSound(self.entityPtr, CGameResource.getCharacterSoundFile(self.id, "1"), 1.0, true);
			end

			return time - sub;
		else
			return time;
		end
	elseif self.step == 3 then
		self.curTime = self.curTime + time;
		local t = self.curTime;
		if t > self.maxTime then t = self.maxTime; end

		local h = self.maxHeight - self.maxHeight * t / self.maxTime;
		--CGameNode.setScale(self.leversPtr, 1, h / self.leverHeight);
		--CGameNode.setPosition(self.topsPtr, 0, h);
		self.curHeight = h;

		if self.curTime >= self.maxTime then
			local sub = self.curTime - self.maxTime;
			self.step = 0;
			self.curTime = 0.0;
			return time - sub;
		else
			return time;
		end
	end
end

function C:updateColliders()
	if self.step >= 1 and self.step <= 3 then
		CGameAction.setCollider(self.actionPtr, 0, 0, self.curHeight * 0.5, 0, 1, 1, 0, self.baseWidth * self.maxNum + self.gap * (self.maxNum - 1), self.curHeight, 0);
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
