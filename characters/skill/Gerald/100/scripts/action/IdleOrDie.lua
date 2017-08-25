--Gerald skill 100:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.RADIUS = 60.0;
	self.SPEED = math.rad(180.0);
	self.FADE_IN = 0.5;
	self.FADE_OUT = 1.0;

	self.cellPtrs = {};
	self.cellRads = {};
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	self.isDieAction = CGameAction.getTag(actionPtr) == CGameAction.ACTION_DIE;
	
	if self.isDieAction then
		self.disPtr = nil;
	else
		local disPtr = CGameNode.create();
		CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
		CGameNode.setPosition(disPtr, 0.0, 0.0);
		CGameRef.retain(disPtr);
		CGameNode.setOpacity(disPtr, 0);
		self.disPtr = disPtr;
	end

	self.prevActionScript = nil;
	self.actionMode = 0;
	self.numCells = 0;
	self.init = false;
end

function C:start(itemPtr)
	self.entityPtr = CGameAction.getEntityPtr(self.actionPtr);

	self:_init();

	if self.disPtr ~= nil then CGameNode.addChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr); end
end

function C:_init()
	if self.init then return; end
	self.init = true;

	local entityPtr = self.entityPtr;

	if self.isDieAction then
		self.prevActionScript = CGameAction.getScript(CGameActionController.getPrevActionPtr(CEntity.getActionControllerPtr(entityPtr)));
		self.prevActionScript:setActionMode(1);
	else
		self.numCells = toint(CEntity.getSharedData(entityPtr, "num"));
		self.isFront = CEntity.getSharedData(entityPtr, "front") == "true";

		local res = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/icon";

		local preRad = math.pi * 2.0 / self.numCells;
		local rad = 0.0;
		for i = 1, self.numCells do
			local iconPtr = CGameSprite.createWithSpriteFrameName(res);
			self.cellPtrs[i] = iconPtr;
			self.cellRads[i] = rad;
			CGameNode.addChild(self.disPtr, iconPtr);

			rad = rad + preRad;
		end
	end

	self.curFadeTime = 0.0;
end

function C:tick(time)
	if self.isDieAction then
		self.prevActionScript:tick(time);
	else
		if self.actionMode == 0 then
			if self.curFadeTime < self.FADE_IN then
				self.curFadeTime = self.curFadeTime + time;
				if self.curFadeTime >= self.FADE_IN then
					CGameNode.setOpacity(self.disPtr, 255);
				else
					CGameNode.setOpacity(self.disPtr, 255 * self.curFadeTime / self.FADE_IN);
				end
			end
		else
			self.curFadeTime = self.curFadeTime + time;
			if self.curFadeTime >= self.FADE_OUT then
				CGameNode.setOpacity(self.disPtr, 0);
			else
				CGameNode.setOpacity(self.disPtr, 255 * (1.0 - self.curFadeTime / self.FADE_OUT));
			end
		end

		local r = time * self.SPEED;
		local angle90 = math.pi * 0.5;
		local angle180 = math.pi;
		local angle270 = angle90 * 3.0;
		local angle360 = math.pi * 2.0;

		for i = 1, self.numCells do
			local rad = (self.cellRads[i] + r) % angle360;
			self.cellRads[i] = rad;

			local isVisible;
			if self.isFront then
				isVisible = rad <= math.pi;
			else
				isVisible = rad > math.pi;
			end

			local cellPtr = self.cellPtrs[i];
			CGameNode.setVisible(cellPtr, isVisible);
			if isVisible then
				local x, y = rotatePoint(0.0, self.RADIUS, math.sin(rad), math.cos(rad));
				CGameNode.setPosition(cellPtr, y, 0.0);

				local sx;
				if rad <= angle90 then
					sx = rad / angle90;
				elseif rad <= angle180 then
					sx = (angle180 - rad) / angle90;
				elseif rad <= angle270 then
					sx = (rad - angle180) / angle90;
				else
					sx = (angle360 - rad) / angle90;
				end

				local brightness = 105;
				local sy = 0.7;
				if self.isFront then
					brightness = brightness + 75 + sx * 75;
					sy = sy + 0.15 + sx * 0.15;
				else
					brightness = brightness + (1.0 - sx) * 75;
					sy = sy + (1.0 - sx) * 0.15;
				end
				CGameNode.setScale(cellPtr, sx, sy);
				CGameNode.setColor(cellPtr, brightness, brightness, brightness);
			end
		end
	end
end

function C:isDone(result)
	if self.isDieAction then
		return self.prevActionScript:isDone(result);
	else
		if self.actionMode == 0 then
			return false, false;
		else
			return true, self.curFadeTime >= self.FADE_OUT;
		end
	end
end

function C:dispose()
	if self.disPtr ~= nil then
		CGameRef.release(self.disPtr);
		self.disPtr = nil;
	end

	return true;
end

function C:setActionMode(mode)
	self.actionMode = mode;
	if self.actionMode == 1 then
		self.curDieTime = self.FADE_OUT * (1.0 - CGameNode.getOpacity(self.disPtr) / 255);
	end
end