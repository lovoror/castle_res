--StaticSpike:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.KEY_LENGTH = "len";
	self.KEY_QUANTITY = "n";
	self.KEY_GAP = "gap";

	self.DEFAULT_QUANTITY = 3;
	self.DEFAULT_GAP = 0.0;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	local disPtr = CGameNode.create();
	CGameNode.setAnchorPoint(disPtr, 0.0, 0.0);
	CGameNode.setPosition(disPtr, 0.0, 0.0);
	CGameRef.retain(disPtr);
	self.disPtr = disPtr;

	self.init = false;

	self.maxNum = self.DEFAULT_QUANTITY;
	self.gap = self.DEFAULT_GAP;
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

	self.maxHeight = nil;
	local value = CEntity.getSharedData(entityPtr, self.KEY_LENGTH);
	if value ~= "" then
		self.maxHeight = tonumber(value);
		if self.maxHeight <= 0.0 then self.maxHeight = nil; end
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

	local resHead = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/";
	for i = 1, self.maxNum do
		local bodyPtr = CGameSprite.createWithSpriteFrameName(resHead.."body");
		CGameNode.setAnchorPoint(bodyPtr, 0.0, 0.0);
		CGameNode.addChild(disPtr, bodyPtr);

		if i == 1 then
			local w, h = CGameNode.getContentSize(bodyPtr);
			self.bodyWidth = w;
			if self.maxHeight == nil then
				self.maxHeight  = h;
			end
			self.startX = -(w * self.maxNum + self.gap * (self.maxNum - 1)) * 0.5;
		end

		local x = self.startX + self.bodyWidth * (i - 1) + self.gap * (i - 1);
		CGameNode.setPosition(bodyPtr, x, 0.0);
	end
end

function C:updateColliders()
	CGameAction.setCollider(self.actionPtr, 0, 0, self.maxHeight * 0.5, 0, 1, 1, 0, self.bodyWidth * self.maxNum + self.gap * (self.maxNum - 1), self.maxHeight, 0);

	return true, true;
end

function C:finish()
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end
