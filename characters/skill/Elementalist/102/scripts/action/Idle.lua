--Elementalist/102:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.WAIT_TIME = 0.2;

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

	local contentPtr = CGameNode.create();
	CGameNode.setAnchorPoint(contentPtr, 0.0, 0.0);
	CGameNode.setPosition(contentPtr, 0.0, 0.0);
	CGameNode.setVisible(contentPtr, false);
	CGameNode.addChild(disPtr, contentPtr);
	self.contentPtr = contentPtr;

	self.init = false;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	self.itemPtr = itemPtr;
	self.totalTime = 0;
	self.init = false;
	self.thickness = nil;
	self.tickOk = false;
	self.curWaitTime = 0.0;
	self.atkValid = false;
	self.isCteated = false;
	self.breakX = nil;
	self.breakY = nil;

	CGameNode.addChild(CGameAction.getDisplayPtr(actionPtr), self.disPtr);

	self.resHead = CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr));

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setFollowOwner(ptr, true);
	CBulletBehaviorController.setDoneOwnerDie(ptr, true);

	CBullet.createBullet(self.resHead.."/lighting", entityPtr, ptr, nil, 0, CChapterScene.getDynamicLightingLayerPtr());
end

function C:_init()
	if self.init then return; end
	self.init = true;

	local entityPtr = self.entityPtr;
	local itemPtr = self.itemPtr;

	local isNetwork = CChapterScene.isNetwork();
	self.isHost = (not isNetwork) or CEntity.isHost(entityPtr);

	local lv = 1;
	local maxLv = 1;
	if not CisNullptr(itemPtr) then
		lv = CItem.getLevel(itemPtr);
		maxLv = CItem.getMaxLevel(itemPtr);
	end
	self.lv = lv;
	self.maxLv = maxLv;

	local flip = CEntity.getDirection(entityPtr) == CDirection.LEFT;
	self.flip = flip;

	if self.isHost then
		local sqrtFunc = math.sqrt;
		local atanFunc = math.atan;
		local degFunc = math.deg;
		local rnd = math.random;

		local detail = 15.0;
		local maxLength = 600.0 + lv * 30.0;

		local numPathLen = 0;
		local path = self.path;
		local calculateLightingPath;
		calculateLightingPath = function(x1, y1, x2, y2, displace)
			if displace < detail then
				path[numPathLen + 1] = x2;
				path[numPathLen + 2] = y2;
				numPathLen = numPathLen + 2;
			else
				local d = displace;
				if d > 60.0 then d = 60.0; end
				local midX = (x2 + x1) * 0.5 + (rnd() - 0.5) * d;
				local midY = (y2 + y1) * 0.5 + (rnd() - 0.5) * d;
				local half = displace * 0.5;
				calculateLightingPath(x1, y1, midX, midY, half);
				calculateLightingPath(midX, midY, x2, y2, half);
			end
		end

		local startX = 0.0;
		local startY = 0.0;
		local hitX = maxLength;
		local hitY = 0.0;
		local endX = hitX;
		local endY = 0.0;
		local startToHitLength = maxLength;
		local hitToEndLength = 0.0;

		local px, py = CEntity.getPosition(entityPtr);
		local bcPtr = CAISearchTargetsTask.searchBattleColliderPtr(-maxLength , maxLength, -maxLength, maxLength, px, py, CEntity.getAttackCamp(entityPtr), true, false);

		if CisNullptr(bcPtr) then
			if flip then
				hitX = -hitX;
				endX = -endX;
			end
		else
			local bcX, bcY = CBattleCollider.getPosition(bcPtr);
			hitX = bcX - px;
			hitY = bcY - py;
			local len = sqrtFunc(hitX * hitX + hitY * hitY);
			if len == 0.0 then
				len = 1.0;
				hitX = thiX + 1.0;
			end
			local sub = maxLength - len;
			if sub ~= 0.0 then
				local vx = hitX / len;
				local vy = hitY / len;

				if sub > 0.0 then
					endX = hitX + vx * sub;
					endY = hitY + vy * sub;
					startToHitLength = len;
					hitToEndLength = sub;
				elseif sub < 0.0 then
					hitX = vx * maxLength;
					hitY = vy * maxLength;
					endX = hitX;
					endY = hitY;
				end
			end
		end

		numPathLen = 2;
		path[1] = startX;
		path[2] = startY;
		calculateLightingPath(startX, startY, hitX, hitY, startToHitLength * 0.35);

		if hitToEndLength > 0.0 then
			calculateLightingPath(hitX, hitY, endX, endY, hitToEndLength * 0.35);
		end

		local floorFn = math.floor;
		for i = 3, numPathLen do
			path[i] =  floorFn(path[i]);
		end

		local numElements = numPathLen * 0.5 - 1;

		self.numElements = numElements;

		if isNetwork then
			CProtocol.sendCptActorActionSync(self.actionPtr,
			function(baPtr)
				CByteArray.writeUInt8(baPtr, numElements);
				for i = 3, numPathLen do
					CByteArray.writeInt16(baPtr, path[i]);
				end
			end);
		end

		self:_create();
	end

	local startNodePtr = CGameSprite.createWithSpriteFrameName(self.resHead.."/start");
	CGameSprite.setBlendFunc(startNodePtr, CGameSprite.BLEND_ADD);
	local minSize = 0.5;
	local maxSize = 1.2;
	local curSize = minSize + (maxSize - minSize) * (lv / maxLv);
	CGameNode.setScale(startNodePtr, curSize, curSize);
	CGameNode.addChild(self.disPtr, startNodePtr);
end

function C:executeSync(bytesPtr)
	self:_init();

	local path = self.path;

	self.numElements = CByteArray.readUInt8(bytesPtr);
	local size = self.numElements * 2;
	for i = 1, size do
		path[i + 2] = CByteArray.readInt16(bytesPtr);
	end
	path[1] = 0.0;
	path[2] = 0.0;

	self:_create();
end

function C:_create()
	self.isCteated = true;

	local entityPtr = self.entityPtr;

	CEntity.playSound(entityPtr, CGameResource.getCharacterSoundFile(self.resHead, "1"));

	local numElements = self.numElements;
	local lv = self.lv;
	local maxLv = self.maxLv;
	local flip = self.flip;

	local path = self.path;
	local px, py = CEntity.getPosition(entityPtr);

	local sqrtFunc = math.sqrt;
	local atanFunc = math.atan;
	local degFunc = math.deg;
	local rnd = math.random;

	local minThickness = 2.0;
	local thickness = 8.0 + lv * 0.5;

	local colliders = self.colliders ;

	local realLength = 0.0;
	local elementLens = self.elementLens;
	for i = 1, numElements do
		local pathIndex = (i - 1) * 2 + 1;
		local sx = path[pathIndex];
		local sy = path[pathIndex + 1];
		local ex = path[pathIndex + 2];
		local ey = path[pathIndex + 3];

		local dx = ex - sx;
		local dy = ey - sy;
		local len = sqrtFunc(dx * dx + dy * dy);
		elementLens[i] = len;
		realLength = realLength + len;
	end

	local isBreak = false;
	local tileMapPtr = CChapterScene.getTileMapPtr();
	local collisionLineFunc = CTileMap.collisionLine;
	local scaleX, scaleY = CEntity.getScale(entityPtr);

	for i = 1, numElements do
		local pathIndex = (i - 1) * 2 + 1;
		local sx = path[pathIndex];
		local sy = path[pathIndex + 1];
		local ex = path[pathIndex + 2];
		local ey = path[pathIndex + 3];

		local result, collHitX, collHitY = collisionLineFunc(tileMapPtr, px + sx * scaleX, py + sy * scaleY, px + ex * scaleX, py + ey * scaleY, false);
		if not result then
			isBreak = true;

			ex = collHitX - px;
			ey = collHitY - py;

			local dx = ex - sx;
			local dy = ey - sy;
			local len = sqrtFunc(dx * dx + dy * dy) + 4.0;
			local a = math.atan(dy, dx);
			ex = sx + math.cos(a) * len;
			ey = sy + math.sin(a) * len;

			--ex = ex / scaleX;
			--ey = ey / scaleY;
			path[pathIndex + 2] = ex;
			path[pathIndex + 3] = ey;
			numElements = i;

			local dx = ex - sx;
			local dy = ey - sy;
			--local len = sqrtFunc(dx * dx + dy * dy);
			elementLens[i] = len;
			break;
		end
	end

	local spriteFramePtr = CGameSpriteFrame.getSpriteFrame(self.resHead.."/body");
	local lb_u, lb_v, lt_u, lt_v, rt_u, rt_v, rb_u, rb_v = CGameSpriteFrame.getUVRect(spriteFramePtr);
	local sizeW, sizeH, sizeOffX, sizeOffY = CGameSpriteFrame.getSpriteSize(spriteFramePtr);

	local texPath = CCharacterData.getTexPath(CEntity.getCharacterDataPtr(entityPtr));

	local psPtr = CPolySprite.create(texPath, CPolySprite.QUADS);
	CGameSprite.setBlendFunc(psPtr, CGameSprite.BLEND_ADD);
	CGameNode.setAnchorPoint(psPtr, 0.0, 0.0);
	CGameNode.setPosition(psPtr, 0.0, 0.0);
	CPolySprite.createElements(psPtr, numElements, false, false);

	local psPtr2 = CPolySprite.create(texPath, CPolySprite.QUADS);
	CGameSprite.setBlendFunc(psPtr2, CGameSprite.BLEND_ADD);
	CGameNode.setAnchorPoint(psPtr2, 0.0, 0.0);
	CGameNode.setPosition(psPtr2, 0.0, 0.0);
	CPolySprite.createElements(psPtr2, numElements, false, false);
	CGameNode.setColor(psPtr2, 0, 0, 127);

	local psPtr3 = CPolySprite.create(texPath, CPolySprite.QUADS);
	CGameSprite.setBlendFunc(psPtr3, CGameSprite.BLEND_ADD);
	CGameNode.setAnchorPoint(psPtr3, 0.0, 0.0);
	CGameNode.setPosition(psPtr3, 0.0, 0.0);
	CPolySprite.createElements(psPtr3, numElements, false, false);
	CGameNode.setColor(psPtr3, 51, 51, 51);

	local prevThickness = thickness;
	local curTrailLen = 0.0;

	local prevRTX = nil;
	local prevRTY;
	local prevRBX;
	local prevRBY;

	local rndOffX1 = 0.0;
	local rndOffY1 = 0.0;

	local rndOffX2 = 0.0;
	local rndOffY2 = 0.0;

	for i = 1, numElements do
		local pathIndex = (i - 1) * 2 + 1;
		local sx = path[pathIndex];
		local sy = path[pathIndex + 1];
		local ex = path[pathIndex + 2];
		local ey = path[pathIndex + 3];

		local dx = ex - sx;
		local dy = ey - sy;
		local len = elementLens[i];
		local vx = dx / len;
		local vy = dy / len;
		local nx = vy;
		local ny = vx;

		local lbX;
		local lbY;
		local ltX;
		local ltY;

		if prevRTX == nil then
			local startThx = prevThickness * nx;
			local startThy = prevThickness * ny;
			lbx = sx + startThx;
			lby = sy - startThy;
			ltx = sx - startThx;
			lty = sy + startThy;
		else
			lbx = prevRBX;
			lby = prevRBY;
			ltx = prevRTX;
			lty = prevRTY;
		end

		curTrailLen = curTrailLen + len;
		prevThickness = thickness * (1.0 - curTrailLen / realLength);
		if prevThickness < minThickness then prevThickness = minThickness; end;

		local endThx = prevThickness * nx;
		local endThy = prevThickness * ny;

		local rtx = ex - endThx;
		local rty = ey + endThy;
		local rbx = ex +endThx;
		local rby = ey - endThy;

		prevRTX = rtx;
		prevRTY = rty;
		prevRBX = rbx;
		prevRBY = rby;

		local rot = degFunc(atanFunc(dy, dx));

		if flip then
			sx = -sx;
			--ex = -ex;
			dx = -dx;
			--startThx = -startThx;
			--endThx = -endThx;
			ltx = -ltx;
			lbx = -lbx;
			rtx = -rtx;
			rbx = -rbx;
			if rot < 0.0 then
				rot = -180.0 - rot;
			else
				rot = 180.0 - rot;
			end
		end

		local vertexIndex = (i - 1) * 4;
		CPolySprite.setVertex(psPtr, vertexIndex, lbx + sizeOffX, lby + sizeOffY);
		CPolySprite.setVertex(psPtr, vertexIndex + 1, ltx + sizeOffX, lty + sizeOffY);
		CPolySprite.setVertex(psPtr, vertexIndex + 2, rtx + sizeOffX, rty + sizeOffY);
		CPolySprite.setVertex(psPtr, vertexIndex + 3, rbx + sizeOffX, rby + sizeOffY);

		CPolySprite.setVertex(psPtr2, vertexIndex, lbx + sizeOffX + rndOffX1, lby + sizeOffY + rndOffY1);
		CPolySprite.setVertex(psPtr2, vertexIndex + 1, ltx + sizeOffX + rndOffX1, lty + sizeOffY + rndOffY1);

		CPolySprite.setVertex(psPtr3, vertexIndex, lbx + sizeOffX + rndOffX2, lby + sizeOffY + rndOffY2);
		CPolySprite.setVertex(psPtr3, vertexIndex + 1, ltx + sizeOffX + rndOffX2, lty + sizeOffY + rndOffY2);
		if i == numElements then
			rndOffX1 = 0.0;
			rndOffY1 = 0.0;

			rndOffX2 = 0.0;
			rndOffY2 = 0.0;
		else
			rndOffX1 = rnd() * 30.0 - 15.0;
			rndOffY1 = rnd() * 30.0 - 15.0;

			rndOffX2 = rnd() * 30.0 - 15.0;
			rndOffY2 = rnd() * 30.0 - 15.0;
		end
		CPolySprite.setVertex(psPtr2, vertexIndex + 2, rtx + sizeOffX + rndOffX1, rty + sizeOffY + rndOffY1);
		CPolySprite.setVertex(psPtr2, vertexIndex + 3, rbx + sizeOffX + rndOffX1, rby + sizeOffY + rndOffY1);

		CPolySprite.setVertex(psPtr3, vertexIndex + 2, rtx + sizeOffX + rndOffX2, rty + sizeOffY + rndOffY2);
		CPolySprite.setVertex(psPtr3, vertexIndex + 3, rbx + sizeOffX + rndOffX2, rby + sizeOffY + rndOffY2);

		CPolySprite.setUV(psPtr, vertexIndex, lb_u, lb_v);
		CPolySprite.setUV(psPtr, vertexIndex + 1, lt_u, lt_v);
		CPolySprite.setUV(psPtr, vertexIndex + 2, rt_u, rt_v);
		CPolySprite.setUV(psPtr, vertexIndex + 3, rb_u, rb_v);

		CPolySprite.setUV(psPtr2, vertexIndex, lb_u, lb_v);
		CPolySprite.setUV(psPtr2, vertexIndex + 1, lt_u, lt_v);
		CPolySprite.setUV(psPtr2, vertexIndex + 2, rt_u, rt_v);
		CPolySprite.setUV(psPtr2, vertexIndex + 3, rb_u, rb_v);

		CPolySprite.setUV(psPtr3, vertexIndex, lb_u, lb_v);
		CPolySprite.setUV(psPtr3, vertexIndex + 1, lt_u, lt_v);
		CPolySprite.setUV(psPtr3, vertexIndex + 2, rt_u, rt_v);
		CPolySprite.setUV(psPtr3, vertexIndex + 3, rb_u, rb_v);

		local collIndex = (i - 1) * 4 + 1;
		colliders[collIndex] = sx + dx * 0.5;
		colliders[collIndex + 1] = sy + dy * 0.5;
		colliders[collIndex + 2] = rot;
		colliders[collIndex + 3] = len;
	end

	local endNodePtr = nil;
	if isBreak then
		local pathIndex = (numElements - 1) * 2 + 1;
		local ex = path[pathIndex + 2];
		local ey = path[pathIndex + 3];

		endNodePtr = CGameSprite.createWithSpriteFrameName(self.resHead.."/hit");
		if flip then ex = -ex; end
		CGameSprite.setBlendFunc(endNodePtr, CGameSprite.BLEND_ADD);
		CGameNode.setPosition(endNodePtr, ex, ey);
		curSize = prevThickness / thickness;
		if curSize < 0.5 then
			curSize = 0.5;
		end
		curSize = curSize * 0.8;
		CGameNode.setScale(endNodePtr, curSize, curSize);

		self.breakX = ex;
		self.breakY = ey;
	end

	CPolySprite.createBufferObject(psPtr);
	CPolySprite.freeRes(psPtr);
	CPolySprite.createBufferObject(psPtr2);
	CPolySprite.freeRes(psPtr2);
	CPolySprite.createBufferObject(psPtr3);
	CPolySprite.freeRes(psPtr3);

	self.numElements = numElements;
	self.thickness = thickness;
	self.bodyPtr = psPtr;
	self.bodyEffectPtr1 = psPtr2;
	self.bodyEffectPtr2 = psPtr3;

	CGameNode.addChild(self.contentPtr, psPtr);
	CGameNode.addChild(self.contentPtr, psPtr2);
	CGameNode.addChild(self.contentPtr, psPtr3);
	if endNodePtr ~= nil then
		CGameNode.addChild(self.contentPtr, endNodePtr);
	end
end

function C:tick(time)
	local entityPtr = self.entityPtr;

	if not self.tickOk then self.tickOk = self:isBehaviorControllerInit(entityPtr); end
	if not self.tickOk then return; end

	self:_init();

	if not self.atkValid then
		self.curWaitTime = self.curWaitTime + time;

		if self.curWaitTime >= self.WAIT_TIME then
			time = time - self.curWaitTime + self.WAIT_TIME;
			CGameNode.setVisible(self.contentPtr, true);
			self.atkValid = true;

			if not (self.breakX == nil) then
				local ptr = CBulletBehaviorController.create();
				CBulletBehaviorController.setPosition(ptr, 0, self.breakX , self.breakY);
				CBulletBehaviorController.setDoneAnimation(ptr, true);

				CBullet.createBullet(self.resHead.."/hit", self.entityPtr, ptr, nil);
			end
		else
			return;
		end
	end

	if not self.isCteated then return; end

	self.totalTime = self.totalTime + time;

	local waitTime = 0.1;
	local a = 1.0;
	if self.totalTime >= waitTime then
		a = (self.totalTime - waitTime) / 0.2;
		if a > 1.0 then a = 1.0; end;
		a = 1.0 - a;
	end

	a = a * 255;
	CGameNode.setOpacity(self.bodyPtr, a);
	CGameNode.setOpacity(self.bodyEffectPtr1, a);
	CGameNode.setOpacity(self.bodyEffectPtr2, a);

	if a <= 0.0 then
		CEntity.setDie(entityPtr);
	end
end

function C:updateColliders()
	if self.atkValid and self.isCteated then
		local h = self.thickness ;
		if h ~= nil then
			h = h + h;
			local actionPtr = self.actionPtr;
			local colliders = self.colliders;

			local setColliderFunc = CGameAction.setCollider;

			for i = 1, self.numElements do
				local collIndex = (i - 1) * 4 + 1;
				setColliderFunc(actionPtr, 0, colliders[collIndex], colliders[collIndex + 1], colliders[collIndex + 2], 1.0, 1.0, 0, colliders[collIndex + 3], h, i - 1);
			end
		end
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
