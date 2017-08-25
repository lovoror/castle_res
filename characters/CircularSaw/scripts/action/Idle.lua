--CircularSaw:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.KEY_FORE_ROTATE_SPEED = "fspd";
	self.KEY_BACK_ROTATE_SPEED = "bspd";
	self.KEY_ELAPSED = "et";
	self.KEY_VELOCITY = "v";
	self.KEY_MOTION_MODE = "mode";
	self.KEY_DELAY = "delay";
	self.KEY_PATH = "path";

	self.DEFAULT_FORE_ROTATE_SPEED = -90.0;
	self.DEFAULT_BACK_ROTATE_SPEED = 90.0;
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

	local value = CEntity.getSharedData(entityPtr, self.KEY_FORE_ROTATE_SPEED);
	if value == "" then
		self.frontRotateSpeed = self.DEFAULT_FORE_ROTATE_SPEED
	else
		self.frontRotateSpeed = tonumber(value);
	end

	local value = CEntity.getSharedData(entityPtr, self.KEY_BACK_ROTATE_SPEED);
	if value == "" then
		self.backRotateSpeed = self.DEFAULT_BACK_ROTATE_SPEED
	else
		self.backRotateSpeed = tonumber(value);
	end

	local resHead = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr)).."/";
	local backPtr = CGameSprite.createWithSpriteFrameName(resHead.."back");
	local frontPtr = CGameSprite.createWithSpriteFrameName(resHead.."front");
	self.backPtr = backPtr;
	self.frontPtr = frontPtr;
	local w, h = CGameNode.getContentSize(frontPtr);
	self.collW = w * 0.8;
	self.collH = h * 0.8;

	CGameNode.addChild(self.disPtr, backPtr);
	CGameNode.addChild(self.disPtr, frontPtr);

	local elapsed = CEntity.getSharedData(entityPtr, self.KEY_ELAPSED);
	if elapsed == "" then
		elapsed = 0.0;
	else
		elapsed = tonumber(value);
	end

	local path = CEntity.getSharedData(entityPtr, self.KEY_PATH);
	if path ~= "" then
		local v = CEntity.getSharedData(entityPtr, self.KEY_VELOCITY);
		if v == "" then
			v = 0.0;
		else
			v = tonumber(v);
		end

		if v > 0.0 then
			local comPtr = CEntityComponentTranslationPath.create();
			CEntityComponentTranslationPath.setGeneral(comPtr, elapsed, v, path);

			local mode = CEntity.getSharedData(entityPtr, self.KEY_MOTION_MODE);
			if mode == "" or mode == "0" then
				local delay = CEntity.getSharedData(entityPtr, self.KEY_DELAY);
				if delay == "" then
					delay = 0.0;
				else
					delay = tonumber(delay);
				end
				CEntityComponentTranslationPath.setPingPong(comPtr, delay);
			else
				CEntityComponentTranslationPath.setCircular(comPtr);
			end

			CEntity.addComponent(entityPtr, comPtr);
		end
	end

	if elapsed > 0.0 then
		self:tick(elapsed);
	end
end

function C:tick(time)
	CGameNode.setRotation(self.frontPtr, (CGameNode.getRotation(self.frontPtr) + self.frontRotateSpeed * time) % 360.0);
	CGameNode.setRotation(self.backPtr, (CGameNode.getRotation(self.backPtr) + self.backRotateSpeed * time) % 360.0);
end

function C:updateColliders()
	local actionPtr = self.actionPtr;

	CGameAction.setCollider(actionPtr, 0, 0, 0, 0, 1, 1, 0, self.collW, self.collH, 0);

	return true, true;
end

function C:finish()
	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end