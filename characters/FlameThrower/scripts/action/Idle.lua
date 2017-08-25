--FlameThrower:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.BASE_WIDTH = 79.0;
	self.BASE_HEIGHT = 20.0;
	self.FIRE_WIDTH = 75.0;
	self.FIRE_HEIGHT = 300.0;

	self.FIRE_COLLIDER_OFFSET_W = -10.0;
	self.FIRE_COLLIDER_OFFSET_H = -10.0;

	self.KEY_ELAPSED = "et";
	self.KEY_COOL_DOWN = "cd";
	self.KEY_DURATION = "dur";
	self.KEY_LENGTH = "len";

	self.DEFAULT_COOL_DOWN = 2.0;
	self.DEFAULT_DURATION = 4.0;
	self.DEFAULT_LENGTH = self.FIRE_HEIGHT + self.BASE_HEIGHT;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	self.baseContainerPtr = disPtr;
	CGameNode.addChild(self.disPtr, self.baseContainerPtr);

	self.init = false;
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

	self.waitTime = self.DEFAULT_COOL_DOWN;
	local value = CEntity.getSharedData(entityPtr, self.KEY_COOL_DOWN);
	if value ~= "" then
		self.waitTime = tonumber(value);
	end

	self.stayTime = self.DEFAULT_DURATION;
	local value = CEntity.getSharedData(entityPtr, self.KEY_DURATION);
	if value ~= "" then
		self.stayTime = tonumber(value);
	end

	local scale = 1.0;
	local value = CEntity.getSharedData(entityPtr, self.KEY_LENGTH);
	if value ~= "" then
		scale = (tonumber(value) - self.BASE_HEIGHT) / self.FIRE_HEIGHT;
	end

	if scale < 0.0 then
		scale = 0.0;
	end

	self.colliderHeight = (self.FIRE_HEIGHT + self.FIRE_COLLIDER_OFFSET_H) * scale;

	local flLibPtr = CCharacterData.getFLLibiaryPtr(CEntity.getCharacterDataPtr(entityPtr));

	local ptr = CFLLibrary.createInstance(flLibPtr, "act_base_idle");
	CGameRef.retain(ptr);
	self.baseIdlePtr = ptr;

	local ptr = CFLLibrary.createInstance(flLibPtr, "act_base_start");
	CGameRef.retain(ptr);
	self.baseStartPtr = ptr;
	self.baseStartTime = CFLDisplayObject.getTotalTime(self.baseStartPtr);

	local ptr = CFLLibrary.createInstance(flLibPtr, "act_base_persist");
	CGameRef.retain(ptr);
	self.basePersistPtr = ptr;

	local ptr = CFLLibrary.createInstance(flLibPtr, "act_base_end");
	CGameRef.retain(ptr);
	self.baseEndPtr = ptr;
	self.baseEndTime = CFLDisplayObject.getTotalTime(self.baseEndPtr);

	local ptr = CFLLibrary.createInstance(flLibPtr, "act_fire_start");
	CGameRef.retain(ptr);
	CGameNode.setPosition(ptr, 0.0, self.BASE_HEIGHT);
	CGameNode.setScale(ptr, 1.0, scale);
	self.fireStartPtr = ptr;
	self.fireStartTime = CFLDisplayObject.getTotalTime(self.fireStartPtr);

	local ptr = CFLLibrary.createInstance(flLibPtr, "act_fire_persist");
	CGameRef.retain(ptr);
	CGameNode.setPosition(ptr, 0.0, self.BASE_HEIGHT);
	CGameNode.setScale(ptr, 1.0, scale);
	self.firePersistPtr = ptr;

	local ptr = CFLLibrary.createInstance(flLibPtr, "act_fire_end");
	CGameRef.retain(ptr);
	CGameNode.setPosition(ptr, 0.0, self.BASE_HEIGHT);
	CGameNode.setScale(ptr, 1.0, scale);
	self.fireEndPtr = ptr;
	self.fireEndTime = CFLDisplayObject.getTotalTime(self.fireEndPtr);

	local t = self.baseStartTime;
	if self.waitTime < t then
		self.waitTime = t;
	end
	self.waitTime = self.waitTime - t;

	local t = self.fireStartTime + self.fireEndTime + self.baseEndTime;
	if self.stayTime < t then
		self.stayTime = t;
	end
	self.stayTime = self.stayTime - t;

	self.step = 0;
	self.curWaitTime = 0.0;
	self.curStayTime = 0.0;

	self.basePtr = self.baseIdlePtr;
	self.firePtr = nil;

	CFLDisplayObject.reset(self.basePtr);
	CFLDisplayObject.setCurrentTime(self.basePtr, 0.0);
	CGameNode.addChild(self.baseContainerPtr, self.basePtr);

	self.sndChannelPtr = nil;
	self.isInitTick = true;

	local value = CEntity.getSharedData(entityPtr, self.KEY_ELAPSED);
	if value ~= "" then
		self:tick(tonumber(value));
	end

	self.isInitTick = false;
end

function C:tick(time)
	local stepTime = time;

	while time > 0.0 do
		stepTime = self:_motion(time);
		time = time - stepTime;
	end

	CFLDisplayObject.step(self.basePtr, stepTime);
	if self.firePtr ~= nil then
		CFLDisplayObject.step(self.firePtr, stepTime);
	end
end

function C:_motion(time)
	local entityPtr = self.entityPtr;

	if self.step == 0 then -- base idle
		self.curWaitTime = self.curWaitTime + time;
		if self.curWaitTime > self.waitTime then
			self.step = 1;
			local t = self.curWaitTime;
			self.curWaitTime = 0.0;

			CGameNode.removeFromParent(self.basePtr);

			self.basePtr = self.baseStartPtr;

			CFLDisplayObject.reset(self.basePtr);
			CGameNode.addChild(self.baseContainerPtr, self.basePtr);
			CFLDisplayObject.setCurrentTime(self.basePtr, 0.0);

			return time - t + self.waitTime;
		else
			return time;
		end
	elseif self.step == 1 then -- base start
		self.curWaitTime = self.curWaitTime + time;
		if self.curWaitTime> self.baseStartTime then
			self.step = 2;
			local t = self.curWaitTime;
			self.curStayTime = 0.0;

			CGameNode.removeFromParent(self.basePtr);

			self.basePtr = self.basePersistPtr;
			self.firePtr = self.fireStartPtr;

			CFLDisplayObject.reset(self.basePtr);
			CFLDisplayObject.reset(self.firePtr);
			CGameNode.addChild(self.baseContainerPtr, self.basePtr);
			CGameNode.addChild(self.disPtr, self.firePtr);
			CFLDisplayObject.setCurrentTime(self.basePtr, 0.0);
			CFLDisplayObject.setCurrentTime(self.firePtr, 0.0);

			if not self.isInitTick then
				local px, py = CEntity.getPosition(self.entityPtr);
				local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "0"), true);
				CAudioManager.set3DAttributes(chPtr, px, py);
				CAudioManager.setPaused(chPtr, false);
			end

			return time - t + self.baseStartTime;
		else
			return time;
		end
	elseif self.step == 2 then --fire start
		self.curStayTime = self.curStayTime + time;
		if self.curStayTime > self.fireStartTime then
			self.step = 3;
			local t = self.curStayTime;
			self.curStayTime = 0.0;

			CGameNode.removeFromParent(self.firePtr);

			self.firePtr = self.firePersistPtr;

			CFLDisplayObject.reset(self.firePtr);
			CGameNode.addChild(self.disPtr, self.firePtr);
			CFLDisplayObject.setCurrentTime(self.firePtr, 0.0);

			if self.sndChannelPtr == nil then
			local px, py = CEntity.getPosition(self.entityPtr);
			self.sndChannelPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "1"), true);
			CAudioManager.set3DAttributes(self.sndChannelPtr, px, py);
			CAudioManager.setPaused(self.sndChannelPtr, false);
			end

			return time - t + self.fireStartTime;
		else
			return time;
		end
	elseif self.step == 3 then --fire run
		self.curStayTime = self.curStayTime + time;
		if self.curStayTime > self.stayTime then
			self.step = 4;
			local t = self.curStayTime;
			self.curStayTime = 0.0;

			CGameNode.removeFromParent(self.firePtr);

			self.firePtr = self.fireEndPtr;

			CFLDisplayObject.reset(self.firePtr);
			CGameNode.addChild(self.disPtr, self.firePtr);
			CFLDisplayObject.setCurrentTime(self.firePtr, 0.0);

			if self.sndChannelPtr ~= nil then
				CAudioManager.stop(self.sndChannelPtr);
				self.sndChannelPtr = nil;
			end

			if not self.isInitTick then
				local px, py = CEntity.getPosition(self.entityPtr);
				local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "2"), true);
				CAudioManager.set3DAttributes(chPtr, px, py);
				CAudioManager.setPaused(chPtr, false);
			end

			return time - t + self.stayTime;
		else
			return time;
		end
	elseif self.step == 4 then --fire end
		self.curStayTime = self.curStayTime + time;
		if self.curStayTime > self.fireEndTime then
			self.step = 5;
			local t = self.curStayTime;
			self.curStayTime = 0.0;

			CGameNode.removeFromParent(self.basePtr);
			CGameNode.removeFromParent(self.firePtr);

			self.basePtr = self.baseEndPtr;
			self.firePtr = nil;

			CFLDisplayObject.reset(self.basePtr);
			CGameNode.addChild(self.baseContainerPtr, self.basePtr);
			CFLDisplayObject.setCurrentTime(self.basePtr, 0.0);

			return time - t + self.fireEndTime;
		else
			return time;
		end
	elseif self.step == 5 then --base end
		self.curStayTime = self.curStayTime + time;
		if self.curStayTime > self.baseEndTime then
			self.step = 0;
			local t = self.curStayTime;
			self.curWaitTime = 0.0;

			CGameNode.removeFromParent(self.basePtr);

			self.basePtr = self.baseIdlePtr;

			CFLDisplayObject.reset(self.basePtr);
			CGameNode.addChild(self.baseContainerPtr, self.basePtr);
			CFLDisplayObject.setCurrentTime(self.basePtr, 0.0);

			return time - t + self.baseEndTime;
		else
			return time;
		end
	else
		return time;
	end
end

function C:updateColliders()
	if self.step == 2 or self.step == 3 then
		local baseH = self.BASE_HEIGHT;
		local fireH = self.colliderHeight;
		if self.step == 2 then
			fireH = fireH * CFLDisplayObject.getAccumulateTime(self.firePtr) / self.fireStartTime;
		--elseif self.step == 4 then
		--	fireH = fireH * (1.0 - CFLDisplayObject.getAccumulateTime(self.firePtr) / self.fireStartTime);
		--	baseH = baseH + self.colliderHeight - fireH;
		end

		CGameAction.setCollider(self.actionPtr, 0, 0.0, baseH + fireH * 0.5, 0.0, 1.0, 1.0, 0, self.FIRE_WIDTH + self.FIRE_COLLIDER_OFFSET_W, fireH, 0);
	end

	return true, true;
end

function C:finish()
	if self.sndChannelPtr ~= nil then
		CAudioManager.stop(self.sndChannelPtr);
		self.sndChannelPtr = nil;
	end

	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);

	CGameRef.release(self.baseIdlePtr);
	CGameRef.release(self.baseStartPtr);
	CGameRef.release(self.basePersistPtr);
	CGameRef.release(self.baseEndPtr);
	CGameRef.release(self.fireStartPtr);
	CGameRef.release(self.firePersistPtr);
	CGameRef.release(self.fireEndPtr);

	return true;
end
