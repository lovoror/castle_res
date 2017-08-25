local C = registerClassAuto(getClass(BUFF_PACKAGE, BUFF_BASE));

function C:ctor()
	self.sleep = {};
	self.alive = {};
	self.DELAY = 0.1;
	self.KEEP = 0.5;
	self.START_ALPHA = 0.6;
	self.START_RED = 180 / 255;
	self.START_GREEN = 180 / 255;
	self.START_BLUE = 255 / 255;
	self.END_RED =  0 / 255;
	self.END_GREEN =  0 / 255;
	self.END_BLUE =  255 / 255;

	self.SUB_RED = self.END_RED - self.START_RED;
	self.SUB_GREEN = self.END_GREEN - self.START_GREEN;
	self.SUB_BLUE = self.END_BLUE - self.START_BLUE;
end

function C:awake(buffPtr)
	local b = super.awake(self, buffPtr);

	CBuff.setKind(self.buffPtr, 1);

	self.sleepNum = 0;
	self.aliveNum = 0;

	return b;
end

function C:start()
	--self.curDelay = 0;
	self.curDelay = self.DELAY;
end

function C:tick(time)
	self.curDelay = self.curDelay + time;

	if self.curDelay >= self.DELAY then
		self.curDelay = 0;

		local ownerPtr = CBuff.getOwnerPtr(self.buffPtr);

		local clonePtr = nil;
		if self.sleepNum > 0 then
			clonePtr = self.sleep[self.sleepNum];
			self.sleepNum = self.sleepNum - 1;
		else
			clonePtr = CEntity.clone(ownerPtr);
			if not CisNullptr(clonePtr) then
				CEntity.entityRetain(clonePtr);
				CEntity.setHost(clonePtr, false);
				CEntity.setBehaviorControllerPtr(clonePtr, nil);
				CEntity.setBodyShapeEnabled(clonePtr, false);
				CEntity.setAttackEnabled(clonePtr, false);
				CEntity.setSufferEnabled(clonePtr, false);
				CEntity.setSoundEnabled(clonePtr, false);
				local acPtr = CEntity.getActionControllerPtr(clonePtr);
				CGameActionController.setAutoUpdateEnabled(acPtr, false);
				CGameActionController.setActionUpdateEnabled(acPtr, false);
			end
		end

		if not CisNullptr(clonePtr) then
			CEntity.setAlpha(clonePtr, self.START_ALPHA);
			CEntity.setDirection(clonePtr, CEntity.getDirection(ownerPtr));
			CEntity.setScale(clonePtr, CEntity.getScale(ownerPtr));
			CEntity.setRotation(clonePtr, CEntity.getRotation(ownerPtr));
			self.aliveNum = self.aliveNum + 1;
			self.alive[self.aliveNum] = clonePtr;

			local x, y = CEntity.getPosition(ownerPtr);
			CEntity.setPosition(clonePtr, x, y);
			CEntity.setColor(clonePtr, self.START_RED, self.START_GREEN, self.START_BLUE);

			CEntity.addToLayer(clonePtr, CChapterScene.getEffectPosteriorLayerPtr());

			CGameActionController.changeActionFromOtherAction(CEntity.getActionControllerPtr(clonePtr), CGameActionController.getCurrentActionPtr(CEntity.getActionControllerPtr(ownerPtr)));
		end
	end

	local sub = time / self.KEEP;
	local i = 1;

	while i <= self.aliveNum do
		local ptr = self.alive[i];
		local a = CEntity.getAlpha(ptr);
		a = a - sub;
		if a <= 0 then
			self.alive[i] =self.alive[self.aliveNum];
			self.aliveNum = self.aliveNum - 1;

			CEntity.removeFromLayer(ptr);
			self.sleepNum = self.sleepNum + 1;
			self.sleep[self.sleepNum] = ptr;
		else
			CEntity.setAlpha(ptr, a);
			local r, g, b = CEntity.getColor(ptr);
			CEntity.setColor(ptr, r+ self.SUB_RED * sub, g + self.SUB_GREEN * sub, b + self.SUB_BLUE * sub);
			i = i + 1;
		end
	end
end

function C:dispose()
	for i = 1, self.aliveNum do
		local ptr = self.alive[i];
		CEntity.removeFromLayer(ptr);
		CEntity.entityRelease(ptr);
	end
	for i = 1, self.sleepNum do
		CEntity.entityRelease(self.sleep[i]);
	end

	return true;
end
