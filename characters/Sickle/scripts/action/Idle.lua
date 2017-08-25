--Sickle:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.KEY_ELAPSED = "et";
	self.KEY_MAX_ANGLE = "a";
	self.KEY_CYCLE = "cycle";
	self.KEY_CHAINS = "n";

	self.DEFAULT_CHAINS = 12;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	self.START_OFFSET = 7.0;
	self.SICKLE_COLLIDER_OFFSET = 22.0;

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;

	self.maxHeight = 40.0;
	self.maxTime = 0.3;
	self.waitTime = 1.0;
	self.stayTime = 1.0;
	self.maxNum = 10;
	self.gap = 10.0;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	self.entityPtr = CGameAction.getEntityPtr(actionPtr);

	self.id = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr));

	self.sndPath = CGameResource.getCharacterSoundFile(self.id, "0", false);
	self.sndPtr = CAudioManager.getSoundPtr(self.sndPath);
	self.sndHalfLength = CAudioManager.getLength(self.sndPtr) * 0.5;

	self:_init();

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);
end

function C:_init()
	local entityPtr = self.entityPtr;

	self.maxAngle = 0.0;
	self.maxTime = 0.0;

	local value = CEntity.getSharedData(entityPtr, self.KEY_MAX_ANGLE);
	if value ~= "" then
		self.maxAngle = tonumber(value);
	end

	local value = CEntity.getSharedData(entityPtr, self.KEY_CYCLE);
	if value ~= "" then
		self.maxTime = tonumber(value);
	end

	local numChains = self.DEFAULT_CHAINS;
	local value = CEntity.getSharedData(entityPtr, self.KEY_CHAINS);
	if value ~= "" then
		numChains = tonumber(value);
	end

	self.g = self.maxAngle / (0.5 * self.maxTime * self.maxTime);
	self.step = 1;
	self.curAngle = 0.0;
	self.curTime = 0.0;

	local height = 0.0;

	local startPtr = CGameSprite.createWithSpriteFrameName(self.id.."/start");
	CGameNode.addChild(self.disPtr, startPtr);
	local w, h = CGameNode.getContentSize(startPtr);
	h = h * 0.5;

	height = height - h + self.START_OFFSET;

	local chainH;
	for i = 1, numChains do
		local chainPtr = CGameSprite.createWithSpriteFrameName(self.id.."/chain");
		if i == 1 then
			local w, h = CGameNode.getContentSize(chainPtr);
			chainH = h;
		end

		CGameNode.setPosition(chainPtr, 0.0, height - chainH * 0.5);
		CGameNode.addChild(self.disPtr, chainPtr);

		height = height - chainH;
	end

	local sicklePtr = CGameSprite.createWithSpriteFrameName(self.id.."/sickle");
	CGameNode.setAnchorPoint(sicklePtr, 0.0, 1.0);
	CGameNode.setPosition(sicklePtr, 0.0, height);
	CGameNode.addChild(self.disPtr, sicklePtr);

	local sicklePtr = CGameSprite.createWithSpriteFrameName(self.id.."/sickle");
	CGameNode.setAnchorPoint(sicklePtr, 0.0, 1.0);
	CGameNode.setPosition(sicklePtr, 0.0, height);
	CGameNode.setScale(sicklePtr, -1.0, 1.0);
	CGameNode.addChild(self.disPtr, sicklePtr);

	local w, h = CGameNode.getContentSize(sicklePtr);

	self.collisionPy = height - h + self.SICKLE_COLLIDER_OFFSET;

	self.isInitTick = true;
	self.canPlaySnd = true;

	local value = CEntity.getSharedData(entityPtr, self.KEY_ELAPSED);
	if value ~= "" then
		self:tick(tonumber(value));
	end

	self.isInitTick = false;
end

function C:tick(time)
	if self.maxTime > 0.0 then
		while time > 0.0 do
			time = time - self:_motion(time);
		end
	end
end

function C:_motion(time)
	local entityPtr = self.entityPtr;

	local returnTime = time;
	local nextStep = false;

	self.curTime = self.curTime + time;
	local sub = self.maxTime - self.curTime;

	if self.canPlaySnd and (not self.isInitTick) and (self.step == 2 or self.step == -2) then
		if sub <= self.sndHalfLength then
			self.canPlaySnd = false;
			CEntity.playSound(self.entityPtr, self.sndPath, 1.0, true);
		end
	end

	if sub <= 0.0 then
		self.curTime = 0.0;
		returnTime = time + sub;
		nextStep = true;
	end

	if self.step == 1 then
		self.canPlaySnd = true;
		if nextStep then
			self.step = 2;
			CEntity.setRotation(entityPtr, self.maxAngle);
		else
			CEntity.setRotation(entityPtr, self.maxAngle - self:_getRotation(self.maxTime - self.curTime));
		end
	elseif self.step == 2 then
		if nextStep then
			self.step = -1;
			CEntity.setRotation(entityPtr, 0.0);
		else
			CEntity.setRotation(entityPtr, self.maxAngle - self:_getRotation(self.curTime));
		end
	elseif self.step == -1 then
		self.canPlaySnd = true;
		if nextStep then
			self.step = -2;
			CEntity.setRotation(entityPtr, -self.maxAngle);
		else
			CEntity.setRotation(entityPtr, self:_getRotation(self.maxTime - self.curTime) - self.maxAngle);
		end
	elseif self.step == -2 then
		if nextStep then
			self.step = 1;
			CEntity.setRotation(entityPtr, 0.0);
		else
			CEntity.setRotation(entityPtr, self:_getRotation(self.curTime) - self.maxAngle);
		end
	end

	return returnTime;
end

function C:updateColliders()
	local actionPtr = self.actionPtr;

	CGameAction.setCollider(actionPtr, 0, -32.0, self.collisionPy, -22.0, 1.0, 1.0, 0, 78.0, 22.0, 0);
	CGameAction.setCollider(actionPtr, 0, 32.0, self.collisionPy, 22.0, 1.0, 1.0, 0, 78.0, 22.0, 1);

	return true, true;
end

function C:finish()
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end

function C:_getRotation(time)
	return 0.5 * self.g * time * time;
end
