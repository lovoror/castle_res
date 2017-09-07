--SkeletonArcher/1 IdleOrDie
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.DIE_TIME_WAIT = 0.7;
	self.DIE_TIME = 0.3;

	self.KEY_HIT = "true";
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;

	CGameAction.setUpdateBodyShapeEnabled(actionPtr, false);

	self.isDie = CGameActionData.getTag(CGameAction.getActionDataPtr(actionPtr)) == CGameAction.ACTION_DIE;
	self.delayDie = false;
	self.curDieTime = 0.0;
	self.dieStep = 0;
	self.dieAlpha = 1.0;
end

function C:attacked(attackDataPtr)
	CEntity.setSharedData(self.entityPtr, self.KEY_HIT, "1");
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	self.entityPtr = CGameAction.getEntityPtr(actionPtr);

	local resHead = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr));
	local ptr = CGameSprite.createWithSpriteFrameName(resHead.."/jian");
	CGameNode.setAnchorPoint(ptr, 0.0, 0.5);
	CGameNode.addChild(self.disPtr, ptr);

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);
	local w, h = CGameNode.getContentSize(ptr);
	CGameNode.setPosition(ptr, -w * 0.5, 0.0);
	local halfH = h * 0.5;

	self.delayDie = CEntity.getSharedData(self.entityPtr, self.KEY_HIT) ~= "1";
	if self.isDie then
		local px, py = CEntity.getPosition(self.entityPtr);
		local sx, sy = CEntity.getScale(self.entityPtr);
		local r = CEntity.getRotation(self.entityPtr);
		r = -math.rad(r);
		local len = w * 0.5 * sx + 10.0;
		px = px + math.cos(r) * len;
		py = py + math.sin(r) * len;

		if CTileMap.collisionPoint(CChapterScene.getTileMapPtr(), px, py, true) then
			CGameSprite.setSubTextureRect(ptr, 0.0, 0.0, 0.5 + halfH / w, 1.0);
		end

		--CEntity.setBodyShape(self.entityPtr, CBodyShapeType.BOX, -halfH, -halfH, halfH, halfH, 1.0, 1.0);
		CEntity.setBodyShape(self.entityPtr, CBodyShapeType.NONE);
		CEntity.setPersistVelocity(self.entityPtr, 0.0, 0.0);
	else
		self.collW = w;
		self.collH = h;

		CEntity.setBodyShape(self.entityPtr, CBodyShapeType.BOX, -0.5, -0.5, 0.5, 0.5, 1.0, 1.0);
	end
end

function C:tick(time)
	if self.isDie then
		self.curDieTime = self.curDieTime + time;

		if self.dieStep == 0 then
			if self.curDieTime >= self.DIE_TIME_WAIT then
				self.dieStep = 1;
				self.curDieTime = 0.0;
			end
		else
			local a = self.curDieTime / self.DIE_TIME;
			if a > 1.0 then a = 1.0; end
			a = 1.0 - a;
			self.dieAlpha = a;
			CGameNode.setOpacity(self.disPtr, a * 255);
		end
	end
end

function C:isDone(result)
	if self.isDie then
		return true, (not self.delayDie) or self.dieAlpha <= 0.0;
	else
		return false, false;
	end
end

function C:updateColliders()
	if not self.isDie then
		CGameAction.setCollider(self.actionPtr, 0, 0.0, 0.0, 0.0, 1.0, 1.0, 0, self.collW, self.collH, 0);
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
