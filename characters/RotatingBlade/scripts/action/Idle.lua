--RotatingBlade:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.AXLE_OFFSET = 20.0;
	self.LEVER_COLLIDER_OFFSET = 20.0;

	self.KEY_ELAPSED = "et";
	self.KEY_ROTATE_SPEED = "spd";
	self.KEY_UP = "up";
	self.KEY_DOWN = "down";
	self.KEY_LEFT = "left";
	self.KEY_RIGHT = "right";
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;

	self.init = false;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	self.entityPtr = CGameAction.getEntityPtr(actionPtr);

	self:_init();

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);
end

function C:_init()
	if self.init then return; end
	self.init = true;

	local entityPtr = self.entityPtr;

	self.v = 0.0;

	local value = CEntity.getSharedData(entityPtr, self.KEY_ROTATE_SPEED);
	if value ~= "" then
		self.v = tonumber(value);
	end

	local up = CEntity.getSharedData(entityPtr, self.KEY_UP) == "1";
	local down = CEntity.getSharedData(entityPtr, self.KEY_DOWN) == "1";
	local left = CEntity.getSharedData(entityPtr, self.KEY_LEFT) == "1";
	local right = CEntity.getSharedData(entityPtr, self.KEY_RIGHT) == "1";

	self.collW = nil;

	if up then
		self:_setLever(0.0, 0.0, self.AXLE_OFFSET);
		self.up = true;
	end

	if down then
		self:_setLever(180.0, 0.0, -self.AXLE_OFFSET);
		self.down = true;
	end

	if left then
		self:_setLever(270.0, -self.AXLE_OFFSET, 0.0);
		self.left = true;
	end

	if right then
		self:_setLever(90.0, self.AXLE_OFFSET, 0.0);
		self.right = true;
	end

	local resHead = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/";
	CGameNode.addChild(self.disPtr, CGameSprite.createWithSpriteFrameName(resHead.."axle"));

	local value = CEntity.getSharedData(entityPtr, self.KEY_ELAPSED);
	if value ~= "" then
		self:tick(tonumber(value));
	end
end

function C:_setLever(rotation, x, y)
	local leverPtr = CGameSprite.createWithSpriteFrameName("RotatingBlade/lever");
	CGameNode.setAnchorPoint(leverPtr, 0.5, 0.0);
	CGameNode.setRotation(leverPtr, rotation);
	CGameNode.setPosition(leverPtr, x, y);
	CGameNode.addChild(self.disPtr, leverPtr);

	if self.collW == nil then
		local w, h = CGameNode.getContentSize(leverPtr);
		h = h - self.LEVER_COLLIDER_OFFSET;
		self.collW = w - 35.0;
		self.collH = h - 10.0;
		self.collHalfLen = h * 0.5;
	end
end

function C:tick(time)
	local r = CEntity.getRotation(self.entityPtr) + self.v * time;
	r = r % 360.0;

	CEntity.setRotation(self.entityPtr, r);
end

function C:updateColliders()
	local actionPtr = self.actionPtr;

	local index = 0;
	local offset = self.AXLE_OFFSET + self.LEVER_COLLIDER_OFFSET;

	if self.up then
		CGameAction.setCollider(actionPtr, 0, 0.0, self.collHalfLen + offset, 0.0, 1.0, 1.0, 0, self.collW, self.collH, index);
		index = index + 1;
	end

	if self.down then
		CGameAction.setCollider(actionPtr, 0, 0.0, -self.collHalfLen - offset, 0.0, 1.0, 1.0, 0, self.collW, self.collH, index);
		index = index + 1;
	end

	if self.left then
		CGameAction.setCollider(actionPtr, 0, -self.collHalfLen - offset, 0.0, 0.0, 1.0, 1.0, 0, self.collH, self.collW, index);
		index = index + 1;
	end

	if self.right then
		CGameAction.setCollider(actionPtr, 0, self.collHalfLen + offset, 0.0, 0.0, 1.0, 1.0, 0, self.collH, self.collW, index);
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
