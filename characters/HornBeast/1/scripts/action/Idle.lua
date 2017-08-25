--HornBeast/1:Idle
local C = registerClassAuto(getClass("entities.actions", "Base"));

function C:ctor()
	self.CYCLE_MAX_TIME = 0.15;
	self.colliders = {};
	self.path = {};
	self.elementLens = {};
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

function C:start(itemPtr, prevAction)
	local actionPtr = self.actionPtr;
	self.entityPtr = CGameAction.getEntityPtr(actionPtr);

	self.itemPtr = itemPtr;
	self.totalTime = 0.0;
	self.step = 0;
	self.sndChannelPtr = nil;

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);
	self.id = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr));
	self.resHead = self.id.."/";

	self.hitWalPtr = nil;
end

function C:_init()
	if self.init then return; end
	self.init = true;

	local entityPtr = self.entityPtr;

	local startNodePtr = CGameSprite.createWithSpriteFrameName(self.resHead.."start");
	local bodyNodePtr = CGameSprite.createWithSpriteFrameName(self.resHead.."body");
	local endNodePtr = CGameSprite.createWithSpriteFrameName(self.resHead.."hit");

	self.startNodePtr = startNodePtr;
	self.bodyNodePtr = bodyNodePtr;
	self.endNodePtr = endNodePtr;

	CGameSprite.setBlendFunc(startNodePtr, CGameSprite.BLEND_ADD);
	CGameSprite.setBlendFunc(bodyNodePtr, CGameSprite.BLEND_ADD);
	CGameSprite.setBlendFunc(endNodePtr, CGameSprite.BLEND_ADD);

	CGameNode.setScale(startNodePtr, 2.5, 2.5);
	CGameNode.setScale(endNodePtr, 2.0, 2.0);
	CGameNode.setVisible(bodyNodePtr, false);
	CGameNode.setVisible(endNodePtr, false);

	CGameNode.setAnchorPoint(bodyNodePtr, 0.0, 0.5);
	CGameNode.setPosition(bodyNodePtr, 0.0, 0.0);

	CGameNode.addChild(self.disPtr, bodyNodePtr);
	CGameNode.addChild(self.disPtr, startNodePtr);
	CGameNode.addChild(self.disPtr, endNodePtr);

	local px, py = CEntity.getPosition(entityPtr);
	local targetX = tonumber(CEntity.getSharedData(entityPtr, "targetX"));
	local targetY = tonumber(CEntity.getSharedData(entityPtr, "targetY"));
	self.keepTime = tonumber(CEntity.getSharedData(entityPtr, "keepTime"));
	self.cautionTime = tonumber(CEntity.getSharedData(entityPtr, "cautionTime"));
	self.curCautionTime = 0.0;
	self.curKeepTime = 0.0;

	local dx = targetX - px;
	local dy = targetY - py;
	self.angle = math.atan(targetY - py, targetX - px);

	local w, h = CGameNode.getContentSize(bodyNodePtr);
	self.bodyWidth = w;
	self.bodyHeight = h;

	local a = math.rad(10.0);
	if CEntity.getDirection(entityPtr) == CDirectionEnum.LEFT then
		self.angle = self.angle + a;
	else
		self.angle = self.angle - a;
	end
	self.angleAdd = a * 2.0 / self.keepTime;

	self.colliderX = 0.0;
	self.colliderY = 0.0;
	self.colliderRotation = 0.0;
	self.colliderWidth = 0.0;
	self.colliderHeight = 2.0 * h / 3.0;

	self.cycleStep = 0;
	self.cycleTime = 0.0;

	local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "0"), true);
	CAudioManager.set3DAttributes(chPtr, px, py);
	CAudioManager.setPaused(chPtr, false);
end

function C:tick(time)
	if time == 0.0 or (not CEntity.isAddedLayer(self.entityPtr)) then return; end

	self:_init();

	while time > 0.0 do
		time = time - self:_motion(time);
	end
end

function C:_motion(time)
	local entityPtr = self.entityPtr;

	local retTime = time;

	if self.step == 0 then
		self.curCautionTime = self.curCautionTime + time;
		if self.curCautionTime >= self.cautionTime then
			self.step = 1;
			CGameNode.setVisible(self.bodyNodePtr, true);
			CGameNode.setVisible(self.endNodePtr, true);
			retTime = time - (self.curCautionTime - self.cautionTime);

			local px, py = CEntity.getPosition(entityPtr);
			self.sndChannelPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "1"), true);
			CAudioManager.set3DAttributes(self.sndChannelPtr, px, py);
			CAudioManager.setPaused(self.sndChannelPtr, false);
		end
		CGameNode.setRotation(self.startNodePtr, CGameNode.getRotation(self.startNodePtr) + 10.0);
	else
		if self.hitWalPtr == nil then
			local ptr = CBulletBehaviorController.create();
			self.hitWalPtr = CBullet.createBullet(self.resHead.."hitWall", entityPtr, ptr, nil);
		end

		local maxLength = 3000.0;
		local tileMapPtr = CChapterScene.getTileMapPtr();
		local px, py = CEntity.getPosition(entityPtr);
		local b, hitX, hitY = CTileMap.collisionLine(tileMapPtr, px, py, px + math.cos(self.angle) * maxLength, py + math.sin(self.angle) * maxLength, false, true);
		local dx = hitX - px;
		local dy = hitY - py;
		local len = math.sqrt(dx * dx + dy * dy);

		CEntity.setPosition(self.hitWalPtr, hitX, hitY);

		local cycleRatio;
		self.cycleTime = self.cycleTime + retTime;
		if self.cycleStep == 0 then
			if self.cycleTime >= self.CYCLE_MAX_TIME then
				cycleRatio = 1.0;
				self.cycleTime = 0.0;
				self.cycleStep = 1;
			else
				cycleRatio = self.cycleTime / self.CYCLE_MAX_TIME;
			end
		else
			if self.cycleTime >= self.CYCLE_MAX_TIME then
				cycleRatio = 0.0;
				self.cycleTime = 0.0;
				self.cycleStep = 0;
			else
				cycleRatio = 1.0 - self.cycleTime / self.CYCLE_MAX_TIME;
			end
		end

		CGameNode.setScale(self.bodyNodePtr, len / self.bodyWidth, 1.0 + 0.5 * cycleRatio);
		CGameNode.setOpacity(self.bodyNodePtr, 220 + 35 * cycleRatio);

		local curKeepTime = self.curKeepTime + time;
		if curKeepTime > self.keepTime then
			time = self.keepTime - self.curKeepTime;
		end
		self.curKeepTime = curKeepTime;

		local angleAdd;
		local rot;
		if CEntity.getDirection(entityPtr) == CDirectionEnum.LEFT then
			local a;
			if self.angle < 0.0 then
				a = -math.pi - self.angle;
			else
				a = math.pi - self.angle;
			end
			rot = math.deg(-a);
			CGameNode.setPosition(self.endNodePtr, -dx, dy);
			angleAdd = -self.angleAdd * time;
			self.colliderX = -dx * 0.5;
		else
			rot = math.deg(-self.angle);
			CGameNode.setPosition(self.endNodePtr, dx, dy);
			angleAdd = self.angleAdd * time;
			self.colliderX = dx * 0.5;
		end
		CGameNode.setRotation(self.bodyNodePtr, rot);

		self.angle = self.angle + angleAdd;

		self.colliderY = dy * 0.5;
		self.colliderWidth = len;
		self.colliderRotation = -rot;

		if self.curKeepTime >= self.keepTime then
			if self.hitWalPtr ~= nil then
				CEntity.setDie(self.hitWalPtr);
				self.hitWalPtr = nil;
			end

			CEntity.setDie(entityPtr);
		end
	end

	return retTime;
end

function C:updateColliders()
	if self.step == 1 then
		CGameAction.setCollider(self.actionPtr, 0, self.colliderX, self.colliderY, self.colliderRotation, 1, 1, 0, self.colliderWidth , self.colliderHeight, 0);
	end
	return true, true;
end

function C:finish()
	if self.sndChannelPtr ~= nil then
		CAudioManager.stop(self.sndChannelPtr);
		self.sndChannelPtr = nil;
	end

	if self.hitWalPtr ~= nil then
		CEntity.setDie(self.hitWalPtr);
		self.hitWalPtr = nil;
	end

	CGameNode.removeChild(CGameAction.getDisplayPtr(self.actionPtr), self.disPtr);
end

function C:dispose()
	CGameRef.release(self.disPtr);
	return true;
end
