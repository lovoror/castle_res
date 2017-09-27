--DestructibleWall/Crack:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.size = {0.0, 0.0};
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;

	self.hp = -1;
	self.resPtr = nil;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	self.entityPtr = CGameAction.getEntityPtr(actionPtr);

	self.id = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr));

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);
end

function C:trigger(name, value)
	if name == "size" then
		stringSplit(value, ",", self.size);
		self.size[1] = tonumber(self.size[1]);
		self.size[2] = tonumber(self.size[2]);
	elseif name == "type" then
		if value == "0" then
			if self.type ~= 0 then
				self:_setType(value);
			end
		elseif value == "1" then
			if self.type ~= 1 then
				self:_setType(value);
			end
		else
			self:_releaseRes();
		end
	end
end

function C:finish()
	self:_releaseRes();
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end

function C:_releaseRes()
	if self.resPtr ~= nil then
		CGameNode.removeFromParent(self.resPtr);
		self.resPtr = nil;
	end
end

function C:_setType(name)
	self:_releaseRes();

	self.resPtr = CGameSprite.createWithSpriteFrameName(self.id .."/"..name);
	local w, h = CGameNode.getContentSize(self.resPtr);
	CEntity.setScale(self.entityPtr, self.size[1] / w, self.size[2] / h);
	CGameNode.addChild(self.disPtr, self.resPtr);
end